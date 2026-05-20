#!/usr/bin/env python3
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


COMMANDS = [
    ["bash", "-n", "resumir-sesion-codex.sh", "instalar.sh"],
    [sys.executable, "-m", "unittest", "discover", "-s", "tests", "-v"],
    [sys.executable, "scripts/privacy_check.py"],
]


def main() -> int:
    for command in COMMANDS:
        print("$ " + " ".join(command), flush=True)
        proc = subprocess.run(command, cwd=ROOT)
        if proc.returncode != 0:
            print(f"Release check failed: {' '.join(command)}", file=sys.stderr)
            return proc.returncode

    print("Release check OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
