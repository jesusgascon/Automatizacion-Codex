#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/resumir-sesion-codex.sh"
TEMPLATE="$SCRIPT_DIR/plantillas/resumir-sesion-codex.desktop.template"
ICON_PATH="$SCRIPT_DIR/assets/logo.svg"

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

expand_user_path() {
  case "$1" in
    "~")
      printf '%s\n' "$HOME"
      ;;
    "~/"*)
      printf '%s/%s\n' "$HOME" "${1#~/}"
      ;;
    *)
      printf '%s\n' "$1"
      ;;
  esac
}

choose_summary_dir() {
  local default_dir="$1"
  local chosen_dir

  if [[ -n "${CODEX_SUMMARY_DIR:-}" ]]; then
    printf '%s\n' "$CODEX_SUMMARY_DIR"
    return 0
  fi

  if [[ -t 0 ]]; then
    printf 'Carpeta para resumenes, logs y backups:\n' >&2
    printf ' [Enter] %s\n' "$default_dir" >&2
    printf ' Ruta personalizada: ' >&2
    read -r chosen_dir
    if [[ -n "$chosen_dir" ]]; then
      expand_user_path "$chosen_dir"
      return 0
    fi
  fi

  printf '%s\n' "$default_dir"
}

DESKTOP_DIR="$(detect_desktop_dir)"
LAUNCHER="$DESKTOP_DIR/Resumir sesion de Codex.desktop"
DEFAULT_OUT_DIR="$DESKTOP_DIR/Documentacion/Codex/Resumenes"
OUT_DIR="$(choose_summary_dir "$DEFAULT_OUT_DIR")"

if ! command -v python3 >/dev/null 2>&1; then
  printf 'Aviso: no se encuentra python3. El lanzador no funcionara sin Python 3.\n'
fi

if ! command -v xdg-terminal-exec >/dev/null 2>&1; then
  printf 'Aviso: no se encuentra xdg-terminal-exec. Puede que debas adaptar el lanzador manualmente.\n'
fi

if ! command -v codex >/dev/null 2>&1 && [[ ! -d "$HOME/.nvm/versions/node" ]]; then
  printf 'Aviso: no se ha detectado Codex en PATH ni bajo ~/.nvm. Instala Codex antes de usar el lanzador.\n'
fi

mkdir -p "$OUT_DIR"
chmod +x "$SCRIPT_PATH"
TEMPLATE="$TEMPLATE" SCRIPT_PATH="$SCRIPT_PATH" ICON_PATH="$ICON_PATH" LAUNCHER="$LAUNCHER" python3 - <<'PY'
import os
from pathlib import Path

template = Path(os.environ["TEMPLATE"]).read_text()
launcher = (
    template
    .replace("__SCRIPT_PATH__", os.environ["SCRIPT_PATH"])
    .replace("__ICON_PATH__", os.environ["ICON_PATH"])
)
Path(os.environ["LAUNCHER"]).write_text(launcher)
PY
chmod +x "$LAUNCHER"
if command -v gio >/dev/null 2>&1; then
  gio set "$LAUNCHER" metadata::trusted true 2>/dev/null || true
fi

printf 'Instalacion completada.\n'
printf 'Aplicacion y documentacion: %s\n' "$SCRIPT_DIR"
printf 'Lanzador: %s\n' "$LAUNCHER"
printf 'Resumenes: %s\n' "$OUT_DIR"
