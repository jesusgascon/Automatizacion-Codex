#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/resumir-sesion-codex.sh"
TEMPLATE="$SCRIPT_DIR/plantillas/resumir-sesion-codex.desktop.template"

detect_desktop_dir() {
  local desktop_dir
  if command -v xdg-user-dir >/dev/null 2>&1; then
    desktop_dir="$(xdg-user-dir DESKTOP 2>/dev/null || true)"
    if [[ -n "$desktop_dir" ]]; then
      printf '%s\n' "$desktop_dir"
      return 0
    fi
  fi

  if [[ -d "$HOME/Escritorio" ]]; then
    printf '%s\n' "$HOME/Escritorio"
  else
    printf '%s\n' "$HOME/Desktop"
  fi
}

DESKTOP_DIR="$(detect_desktop_dir)"
LAUNCHER="$DESKTOP_DIR/Resumir sesion de Codex.desktop"
OUT_DIR="$DESKTOP_DIR/Documentacion/Codex/Resumenes"

mkdir -p "$OUT_DIR"
chmod +x "$SCRIPT_PATH"
sed "s|__SCRIPT_PATH__|$SCRIPT_PATH|g" "$TEMPLATE" > "$LAUNCHER"
chmod +x "$LAUNCHER"

printf 'Instalacion completada.\n'
printf 'Lanzador: %s\n' "$LAUNCHER"
printf 'Resumenes: %s\n' "$OUT_DIR"
