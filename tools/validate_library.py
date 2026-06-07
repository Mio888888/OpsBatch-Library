#!/usr/bin/env python3
"""Validate the OpsBatch content repository structure and examples."""

from __future__ import annotations

import json
import py_compile
import re
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
COMMAND_REQUIRED_FIELDS = {
    "name",
    "url",
    "category",
    "tags",
    "risk",
    "description",
    "platform",
    "parameters",
}
SCRIPT_META_REQUIRED_FIELDS = {
    "name",
    "url",
    "language",
    "category",
    "tags",
    "risk",
    "description",
    "parameters",
    "platform",
}
QUICK_ACTION_REQUIRED_FIELDS = {
    "name",
    "description",
    "url",
    "category",
    "risk",
    "tags",
    "platform",
    "steps",
}
VALID_RISKS = {"low", "medium", "high"}
SCRIPT_EXTENSIONS = {".sh", ".py", ".ps1"}
LANGUAGES = {"cn", "en"}
LOCALIZED_STEM_RE = re.compile(r"^(?P<base>.+)_(?P<lang>cn|en)$")


def localized_stem(path: Path) -> tuple[str, str] | None:
    match = LOCALIZED_STEM_RE.match(path.stem)
    if not match:
        return None
    return match.group("base"), match.group("lang")


def meta_stem(path: Path) -> str:
    if path.name.endswith(".meta.json"):
        return path.name[: -len(".meta.json")]
    return path.stem


def localized_meta_stem(path: Path) -> tuple[str, str] | None:
    match = LOCALIZED_STEM_RE.match(meta_stem(path))
    if not match:
        return None
    return match.group("base"), match.group("lang")


def expected_localized_siblings(path: Path, suffix: str) -> set[Path]:
    localized = localized_stem(path)
    if localized is None:
        return set()
    base, _lang = localized
    return {path.with_name(f"{base}_{lang}{suffix}") for lang in LANGUAGES}


def url_path(url: str) -> str:
    marker = "/main/"
    if marker in url:
        return url.split(marker, 1)[1]
    return url.rsplit("/", 1)[-1]


def ref_language(ref: str) -> str | None:
    path = Path(ref)
    if path.name.endswith(".meta.json"):
        localized = localized_meta_stem(path)
    else:
        localized = localized_stem(path)
    if localized is None:
        return None
    return localized[1]

try:
    import yaml  # type: ignore[import-not-found]
except ImportError:  # pragma: no cover - optional dependency
    yaml = None


def fail(message: str, errors: list[str]) -> None:
    errors.append(message)


def relative(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def load_json(path: Path, errors: list[str]) -> Any | None:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        fail(f"{relative(path)}: invalid JSON: {exc}", errors)
    except OSError as exc:
        fail(f"{relative(path)}: cannot read file: {exc}", errors)
    return None


def load_yaml(path: Path, errors: list[str]) -> dict[str, Any] | None:
    text = path.read_text(encoding="utf-8")
    if yaml is not None:
        try:
            data = yaml.safe_load(text)
        except Exception as exc:  # noqa: BLE001 - PyYAML exposes several exception types
            fail(f"{relative(path)}: invalid YAML: {exc}", errors)
            return None
        if not isinstance(data, dict):
            fail(f"{relative(path)}: YAML root must be an object", errors)
            return None
        return data

    # Fallback for environments without PyYAML: validate required top-level keys.
    data: dict[str, Any] = {}
    for field in COMMAND_REQUIRED_FIELDS:
        if re.search(rf"(?m)^{re.escape(field)}\s*:", text):
            data[field] = True
    return data


def require_fields(path: Path, data: dict[str, Any], fields: set[str], errors: list[str]) -> None:
    missing = sorted(field for field in fields if field not in data)
    if missing:
        fail(f"{relative(path)}: missing required fields: {', '.join(missing)}", errors)


def validate_risk(path: Path, data: dict[str, Any], errors: list[str]) -> None:
    risk = data.get("risk")
    if risk not in VALID_RISKS:
        fail(f"{relative(path)}: risk must be one of {sorted(VALID_RISKS)}, got {risk!r}", errors)


def validate_array_fields(path: Path, data: dict[str, Any], fields: set[str], errors: list[str]) -> None:
    for field in sorted(fields):
        if field in data and not isinstance(data.get(field), list):
            fail(f"{relative(path)}: {field} must be an array", errors)


def validate_http_url(path: Path, value: Any, field: str, errors: list[str]) -> bool:
    if not isinstance(value, str) or not value:
        fail(f"{relative(path)}: {field} must be a non-empty HTTP(S) URL, got {value!r}", errors)
        return False
    if not value.startswith(("http://", "https://")):
        fail(f"{relative(path)}: {field} must be an HTTP(S) URL, got {value!r}", errors)
        return False
    return True


def command_metadata_path(script_path: Path) -> Path | None:
    yml_path = script_path.with_suffix(".yml")
    yaml_path = script_path.with_suffix(".yaml")
    if yml_path.exists():
        return yml_path
    if yaml_path.exists():
        return yaml_path
    return None


def validate_json_files(errors: list[str]) -> None:
    for path in sorted(ROOT.rglob("*.json")):
        if ".git" in path.parts or ".trellis" in path.parts or ".claude" in path.parts:
            continue
        load_json(path, errors)


def validate_library_json(errors: list[str]) -> None:
    legacy = ROOT / "library.json"
    if legacy.exists():
        fail("library.json: unsuffixed legacy library metadata is not allowed; use library_cn.json and library_en.json", errors)

    for lang in sorted(LANGUAGES):
        path = ROOT / f"library_{lang}.json"
        if not path.exists():
            fail(f"library_{lang}.json: file is required", errors)
            continue
        data = load_json(path, errors)
        if not isinstance(data, dict):
            fail(f"library_{lang}.json: root must be an object", errors)
            continue
        require_fields(
            path,
            data,
            {"name", "version", "author", "description", "homepage", "categories", "baseUrl"},
            errors,
        )
        categories = data.get("categories")
        if not isinstance(categories, dict):
            fail(f"{relative(path)}: categories must be an object", errors)
        else:
            for field in ("commands", "scripts"):
                if not isinstance(categories.get(field), list):
                    fail(f"{relative(path)}: categories.{field} must be an array", errors)
        validate_http_url(path, data.get("homepage"), "homepage", errors)
        validate_http_url(path, data.get("baseUrl"), "baseUrl", errors)

def validate_localized_pair(path: Path, suffix: str, label: str, errors: list[str]) -> tuple[str, str] | None:
    localized = localized_stem(path)
    if localized is None:
        fail(f"{relative(path)}: unsuffixed legacy {label} file is not allowed; use _cn/_en suffixes", errors)
        return None
    base, lang = localized
    for sibling in expected_localized_siblings(path, suffix):
        if not sibling.exists():
            fail(f"{relative(path)}: missing localized sibling {relative(sibling)}", errors)
    return base, lang


def validate_commands(errors: list[str]) -> None:
    command_root = ROOT / "commands"
    if not command_root.is_dir():
        fail("commands/: directory is required", errors)
        return

    command_files = sorted([*command_root.rglob("*.yml"), *command_root.rglob("*.yaml")])
    if not command_files:
        fail("commands/: at least one command YAML file is required", errors)
        return

    for path in command_files:
        localized = validate_localized_pair(path, path.suffix, "command YAML", errors)
        data = load_yaml(path, errors)
        if data is None:
            continue
        require_fields(path, data, COMMAND_REQUIRED_FIELDS, errors)
        validate_risk(path, data, errors)

        sh_path = path.with_suffix(".sh")
        if not sh_path.exists():
            fail(f"{relative(path)}: missing corresponding script {relative(sh_path)}", errors)

        url = data.get("url", "")
        if validate_http_url(path, url, "url", errors) and localized is not None:
            _base, lang = localized
            expected = relative(sh_path)
            actual = url_path(str(url))
            if actual != expected:
                fail(f"{relative(path)}: url must point to same-language script {expected}, got {actual!r}", errors)
            if ref_language(actual) != lang:
                fail(f"{relative(path)}: url language must be _{lang}, got {url!r}", errors)

        validate_array_fields(path, data, {"parameters", "platform", "tags"}, errors)

    for script_path in sorted(command_root.rglob("*.sh")):
        localized = validate_localized_pair(script_path, ".sh", "command script", errors)
        if localized is not None and command_metadata_path(script_path) is None:
            fail(f"{relative(script_path)}: missing corresponding command YAML {relative(script_path.with_suffix('.yml'))}", errors)

def meta_path_for_script(path: Path) -> Path:
    return path.with_name(f"{path.stem}.meta.json")


def validate_script_meta(path: Path, errors: list[str]) -> None:
    localized = localized_meta_stem(path)
    if localized is None:
        fail(f"{relative(path)}: unsuffixed legacy script metadata is not allowed; use _cn/_en suffixes", errors)
    else:
        base, _lang = localized
        for lang in sorted(LANGUAGES):
            sibling = path.with_name(f"{base}_{lang}.meta.json")
            if not sibling.exists():
                fail(f"{relative(path)}: missing localized sibling {relative(sibling)}", errors)

    data = load_json(path, errors)
    if not isinstance(data, dict):
        fail(f"{relative(path)}: metadata root must be an object", errors)
        return
    require_fields(path, data, SCRIPT_META_REQUIRED_FIELDS, errors)
    validate_risk(path, data, errors)
    if not isinstance(data.get("parameters"), list):
        fail(f"{relative(path)}: parameters must be an array", errors)
    if not isinstance(data.get("platform"), list):
        fail(f"{relative(path)}: platform must be an array", errors)
    if not isinstance(data.get("tags"), list):
        fail(f"{relative(path)}: tags must be an array", errors)
    url = data.get("url", "")
    if validate_http_url(path, url, "url", errors) and localized is not None:
        _base, lang = localized
        expected = relative(path.with_name(f"{meta_stem(path)}.sh"))
        actual = url_path(str(url))
        if actual != expected:
            fail(f"{relative(path)}: url must point to same-language script {expected}, got {actual!r}", errors)
        if ref_language(actual) != lang:
            fail(f"{relative(path)}: url language must be _{lang}, got {url!r}", errors)


def validate_scripts(errors: list[str]) -> None:
    script_root = ROOT / "scripts"
    if not script_root.is_dir():
        fail("scripts/: directory is required", errors)
        return

    scripts = sorted(
        path for path in script_root.rglob("*") if path.is_file() and path.suffix in SCRIPT_EXTENSIONS
    )
    if not scripts:
        fail("scripts/: at least one script file is required", errors)
        return

    for script in scripts:
        if script.suffix == ".sh" and script.parent == ROOT / "scripts" / "shell":
            localized = validate_localized_pair(script, ".sh", "shell script", errors)
            if localized is not None:
                base, _lang = localized
                for lang in sorted(LANGUAGES):
                    meta = script.with_name(f"{base}_{lang}.meta.json")
                    if not meta.exists():
                        fail(f"{relative(script)}: missing localized metadata file {relative(meta)}", errors)
        meta = meta_path_for_script(script)
        if not meta.exists():
            fail(f"{relative(script)}: missing metadata file {relative(meta)}", errors)
        else:
            validate_script_meta(meta, errors)

def validate_quick_actions(errors: list[str]) -> None:
    quick_action_root = ROOT / "quick-actions"
    if not quick_action_root.is_dir():
        fail("quick-actions/: directory is required", errors)
        return

    quick_actions = sorted(quick_action_root.glob("*.json"))
    if not quick_actions:
        fail("quick-actions/: at least one quick action JSON file is required", errors)
        return

    for path in quick_actions:
        localized = validate_localized_pair(path, ".json", "quick action", errors)
        lang = localized[1] if localized else None
        data = load_json(path, errors)
        if not isinstance(data, dict):
            fail(f"{relative(path)}: quick action root must be an object", errors)
            continue
        require_fields(path, data, QUICK_ACTION_REQUIRED_FIELDS, errors)
        validate_risk(path, data, errors)
        qa_url = data.get("url")
        if validate_http_url(path, qa_url, "url", errors):
            actual = url_path(str(qa_url))
            expected = relative(path)
            if actual != expected:
                fail(f"{relative(path)}: url must point to this quick action file {expected}, got {actual!r}", errors)
        steps = data.get("steps")
        if not isinstance(steps, list) or not steps:
            fail(f"{relative(path)}: steps must be a non-empty array", errors)
            continue
        for index, step in enumerate(steps, start=1):
            if not isinstance(step, dict):
                fail(f"{relative(path)}: step {index} must be an object", errors)
                continue
            ref = step.get("ref")
            step_type = step.get("type")
            if step_type not in {"command", "script"}:
                fail(f"{relative(path)}: step {index} has invalid type {step_type!r}", errors)
            if not isinstance(ref, str) or not ref:
                fail(f"{relative(path)}: step {index} must include a non-empty ref", errors)
                continue
            if lang is not None and ref_language(ref) != lang:
                fail(f"{relative(path)}: step {index} ref must use _{lang} resource, got {ref!r}", errors)
            target = ROOT / ref
            if not target.exists():
                fail(f"{relative(path)}: step {index} ref does not exist: {ref}", errors)
            step_url = step.get("url")
            if step_url is not None and validate_http_url(path, step_url, f"step {index} url", errors):
                actual = url_path(str(step_url))
                if actual != ref:
                    fail(f"{relative(path)}: step {index} url must point to ref {ref}, got {actual!r}", errors)
                if lang is not None and ref_language(actual) != lang:
                    fail(f"{relative(path)}: step {index} url must use _{lang} resource, got {step_url!r}", errors)

def run_command(command: list[str], errors: list[str], label: str) -> None:
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True, check=False)
    if result.returncode != 0:
        output = (result.stderr or result.stdout).strip()
        fail(f"{label}: {output}", errors)


def validate_script_syntax(errors: list[str]) -> None:
    bash = shutil.which("bash")
    if bash:
        for path in sorted((ROOT / "scripts" / "shell").glob("*.sh")):
            run_command([bash, "-n", str(path)], errors, f"{relative(path)} shell syntax")
        # Also validate command .sh scripts
        command_root = ROOT / "commands"
        if command_root.is_dir():
            for path in sorted(command_root.rglob("*.sh")):
                run_command([bash, "-n", str(path)], errors, f"{relative(path)} shell syntax")

    for path in sorted((ROOT / "scripts" / "python").glob("*.py")):
        try:
            py_compile.compile(str(path), doraise=True)
        except py_compile.PyCompileError as exc:
            fail(f"{relative(path)} python syntax: {exc.msg}", errors)

    pwsh = shutil.which("pwsh")
    if pwsh:
        for path in sorted((ROOT / "scripts" / "powershell").glob("*.ps1")):
            command = (
                "$tokens=$null; $errors=$null; "
                f"[System.Management.Automation.Language.Parser]::ParseFile('{path}', [ref]$tokens, [ref]$errors) | Out-Null; "
                "if ($errors.Count -gt 0) { $errors | ForEach-Object { Write-Error $_.Message }; exit 1 }"
            )
            run_command([pwsh, "-NoProfile", "-Command", command], errors, f"{relative(path)} powershell syntax")


def main() -> int:
    errors: list[str] = []
    validate_json_files(errors)
    validate_library_json(errors)
    validate_commands(errors)
    validate_scripts(errors)
    validate_quick_actions(errors)
    validate_script_syntax(errors)

    if errors:
        print("Validation failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print("OpsBatch library validation passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
