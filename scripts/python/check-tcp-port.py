#!/usr/bin/env python3
"""Check TCP connectivity to a host and port without sending application data."""

from __future__ import annotations

import argparse
import socket
import sys


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Check TCP connectivity to a host and port.")
    parser.add_argument("host", nargs="?", default="127.0.0.1", help="Target host")
    parser.add_argument("port", nargs="?", type=int, default=80, help="Target TCP port")
    parser.add_argument("--timeout", type=float, default=3.0, help="Connection timeout in seconds")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        with socket.create_connection((args.host, args.port), timeout=args.timeout):
            print(f"OK: {args.host}:{args.port} is reachable")
            return 0
    except OSError as exc:
        print(f"FAIL: {args.host}:{args.port} is not reachable: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
