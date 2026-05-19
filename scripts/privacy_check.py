#!/usr/bin/env python3
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

SKIP_DIRS = {
    ".git",
    "__pycache__",
    ".pytest_cache",
}

SKIP_SUFFIXES = {
    ".pyc",
    ".sqlite",
    ".db",
    ".log",
    ".tmp",
}

ALLOWLIST = {
    re.compile(r"state_\*\.sqlite"),
    re.compile(r"state_X\.sqlite"),
    re.compile(r"state_1\.sqlite"),
    re.compile(r"state_2\.sqlite"),
    re.compile(r"state_5\.sqlite"),
    re.compile(r"state-before-(archive|cleanup|restore)-YYYYMMDD-HHMMSS\.sqlite"),
    re.compile(r"20260518-104807"),
}

PATTERNS = {
    "ruta_home_real": re.compile(r"/home/(?!\$HOME|usuario|tu-usuario)[A-Za-z0-9._-]+"),
    "sqlite_real": re.compile(r"\bstate_\d+\.sqlite\b"),
    "session_uuid": re.compile(r"\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b", re.IGNORECASE),
    "salida_generada": re.compile(r"\bresumen-codex-[0-9a-f-]{8,}-\d{8}-\d{6}\.(txt|md|log)\b", re.IGNORECASE),
}


def is_allowed(line: str) -> bool:
    return any(pattern.search(line) for pattern in ALLOWLIST)


def iter_files():
    for path in ROOT.rglob("*"):
        rel = path.relative_to(ROOT)
        if any(part in SKIP_DIRS for part in rel.parts):
            continue
        if not path.is_file():
            continue
        if path.suffix in SKIP_SUFFIXES:
            continue
        yield path


def main() -> int:
    findings = []
    for path in iter_files():
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        for lineno, line in enumerate(text.splitlines(), 1):
            if is_allowed(line):
                continue
            for name, pattern in PATTERNS.items():
                if pattern.search(line):
                    findings.append((path.relative_to(ROOT), lineno, name, line.strip()))

    if findings:
        print("Posibles datos privados detectados:")
        for rel, lineno, name, line in findings:
            print(f"- {rel}:{lineno} [{name}] {line}")
        return 1

    print("Privacy check OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())

