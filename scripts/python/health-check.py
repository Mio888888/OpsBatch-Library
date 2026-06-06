#!/usr/bin/env python3
"""Print a safe, read-only health summary for the local machine."""

from __future__ import annotations

import json
import os
import platform
import shutil
import socket
import time
from pathlib import Path


def load_average() -> dict[str, float] | None:
    if not hasattr(os, "getloadavg"):
        return None
    one, five, fifteen = os.getloadavg()
    return {"1m": round(one, 2), "5m": round(five, 2), "15m": round(fifteen, 2)}


def disk_usage(path: str = "/") -> dict[str, str]:
    usage = shutil.disk_usage(path)
    return {
        "path": str(Path(path).resolve()),
        "total_gb": f"{usage.total / (1024 ** 3):.1f}",
        "used_gb": f"{usage.used / (1024 ** 3):.1f}",
        "free_gb": f"{usage.free / (1024 ** 3):.1f}",
        "used_percent": f"{usage.used / usage.total * 100:.1f}",
    }


def main() -> None:
    summary = {
        "hostname": socket.gethostname(),
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
        "platform": platform.platform(),
        "python": platform.python_version(),
        "load_average": load_average(),
        "disk": disk_usage(os.environ.get("CHECK_PATH", "/")),
    }
    print(json.dumps(summary, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
