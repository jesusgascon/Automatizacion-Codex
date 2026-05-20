#!/usr/bin/env bash
set -u

detect_codex_bin() {
  local candidate login_shell_path npm_prefix
  if [[ -n "${CODEX_BIN:-}" && -x "${CODEX_BIN:-}" ]]; then
    printf '%s\n' "$CODEX_BIN"
    return 0
  fi

  if command -v codex >/dev/null 2>&1; then
    command -v codex
    return 0
  fi

  if [[ -n "${SHELL:-}" && -x "${SHELL:-}" ]]; then
    login_shell_path="$("$SHELL" -lc 'type -P codex 2>/dev/null' 2>/dev/null || true)"
    if [[ -n "$login_shell_path" && -x "$login_shell_path" ]]; then
      printf '%s\n' "$login_shell_path"
      return 0
    fi
  fi

  if command -v npm >/dev/null 2>&1; then
    npm_prefix="$(npm prefix -g 2>/dev/null || true)"
    if [[ -n "$npm_prefix" && -x "$npm_prefix/bin/codex" ]]; then
      printf '%s\n' "$npm_prefix/bin/codex"
      return 0
    fi
  fi

  for candidate in \
    "$HOME/.local/bin/codex" \
    "$HOME/.npm-global/bin/codex" \
    "$HOME/node_modules/.bin/codex" \
    "/usr/local/bin/codex" \
    "/usr/bin/codex"; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  find "$HOME/.nvm/versions/node" -path '*/bin/codex' -executable 2>/dev/null |
    sort -V |
    tail -n 1
}

detect_state_db() {
  if [[ -n "${STATE_DB:-}" && -f "${STATE_DB:-}" ]]; then
    printf '%s\n' "$STATE_DB"
    return 0
  fi

  find "$HOME/.codex" -maxdepth 1 -type f -name 'state_*.sqlite' 2>/dev/null |
    sort -V |
    tail -n 1
}

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

CODEX_BIN="$(detect_codex_bin)"
STATE_DB="$(detect_state_db)"
DESKTOP_DIR="$(detect_desktop_dir)"
OUT_DIR="${CODEX_SUMMARY_DIR:-$DESKTOP_DIR/Documentacion/Codex/Resumenes}"
LOG_DIR="$OUT_DIR/logs"
BACKUP_DIR="$OUT_DIR/backups"
MAX_BACKUPS="${MAX_BACKUPS:-10}"
READ_ONLY_MODE=0
if [[ "${CODEX_READ_ONLY:-}" == "1" || "${CODEX_READ_ONLY:-}" == "true" || "${CODEX_READ_ONLY:-}" == "TRUE" ]]; then
  READ_ONLY_MODE=1
fi

if [[ "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" == *UTF-8* || "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" == *utf8* ]]; then
  RULE_CHAR='─'
  BOX_TOP_LEFT='┌'
  BOX_TOP_RIGHT='┐'
  BOX_BOTTOM_LEFT='└'
  BOX_BOTTOM_RIGHT='┘'
  BOX_VERTICAL='│'
else
  RULE_CHAR='-'
  BOX_TOP_LEFT='+'
  BOX_TOP_RIGHT='+'
  BOX_BOTTOM_LEFT='+'
  BOX_BOTTOM_RIGHT='+'
  BOX_VERTICAL='|'
fi

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  STYLE_TITLE=$'\033[1;36m'
  STYLE_LABEL=$'\033[1m'
  STYLE_RESET=$'\033[0m'
else
  STYLE_TITLE=''
  STYLE_LABEL=''
  STYLE_RESET=''
fi

clear_screen() {
  if [[ -t 1 ]]; then
    printf '\033[2J\033[H'
  fi
}

print_rule() {
  if [[ "$RULE_CHAR" == '─' ]]; then
    printf '%s\n' '───────────────────────────────────────────────────────────────────────────────'
  else
    printf '%s\n' '-------------------------------------------------------------------------------'
  fi
}

print_title() {
  printf '\n'
  print_box_top
  print_box_line "$1" "$STYLE_TITLE"
  print_box_bottom
}

print_option() {
  printf '  %s%-8s%s %s\n' "$STYLE_LABEL" "$1" "$STYLE_RESET" "$2"
}

print_subtitle() {
  printf '\n%s%s%s\n' "$STYLE_LABEL" "$1" "$STYLE_RESET"
  print_rule
}

print_box_top() {
  printf '%s' "$BOX_TOP_LEFT"
  print_rule | tr -d '\n'
  printf '%s\n' "$BOX_TOP_RIGHT"
}

print_box_bottom() {
  printf '%s' "$BOX_BOTTOM_LEFT"
  print_rule | tr -d '\n'
  printf '%s\n' "$BOX_BOTTOM_RIGHT"
}

print_box_line() {
  local text="$1"
  local style="${2:-}"
  if (( ${#text} > 77 )); then
    text="${text:0:74}..."
  fi
  printf '%s %s%-77s%s %s\n' "$BOX_VERTICAL" "$style" "$text" "$STYLE_RESET" "$BOX_VERTICAL"
}

print_option_panel() {
  print_box_top
  while (( "$#" )); do
    print_box_line "$1"
    shift
  done
  print_box_bottom
}

rotate_backups() {
  local pattern="$1"
  if [[ "$MAX_BACKUPS" =~ ^[0-9]+$ ]] && (( MAX_BACKUPS > 0 )); then
    mapfile -t backups_to_remove < <(
      find "$BACKUP_DIR" -maxdepth 1 -type f -name "$pattern" |
        sort |
        head -n "-$MAX_BACKUPS"
    )
    if [[ ${#backups_to_remove[@]} -gt 0 ]]; then
      rm -f -- "${backups_to_remove[@]}"
    fi
  fi
}

if [[ ! -x "$CODEX_BIN" ]]; then
  printf 'No se encuentra Codex automaticamente.\n'
  printf 'Prueba en una terminal normal:\n'
  printf '  command -v codex\n'
  printf 'Si devuelve una ruta, reinstala con:\n'
  printf '  CODEX_BIN=\"/ruta/que/devuelva/command-v\" bash instalar.sh\n'
  printf 'Pulsa Enter para cerrar...'
  read -r
  exit 1
fi

if [[ ! -f "$STATE_DB" ]]; then
  printf 'No se encuentra la base local de sesiones de Codex:\n%s\n' "$STATE_DB"
  printf 'Pulsa Enter para cerrar...'
  read -r
  exit 1
fi

validate_state_schema() {
  STATE_DB="$STATE_DB" python3 - <<'PY'
import os
import sqlite3
import sys

required = {
    "id",
    "cwd",
    "title",
    "first_user_message",
    "created_at",
    "updated_at",
    "tokens_used",
    "archived",
    "archived_at",
    "source",
}

try:
    con = sqlite3.connect(os.environ["STATE_DB"])
    rows = con.execute("pragma table_info(threads)").fetchall()
    indexes = con.execute("pragma index_list(threads)").fetchall()
    con.close()
except sqlite3.Error as exc:
    print(f"No se pudo leer la base local de Codex: {exc}")
    sys.exit(1)

if not rows:
    print("La base local de Codex no contiene la tabla esperada: threads")
    sys.exit(1)

columns = {row[1] for row in rows}
missing = sorted(required - columns)
if missing:
    print("La base local de Codex no tiene el esquema esperado.")
    print("Columnas que faltan: " + ", ".join(missing))
    print("Puede que Codex haya cambiado su formato interno.")
    sys.exit(1)

recommended = {"id", "cwd", "updated_at", "archived", "source"}
indexed_columns = set()
try:
    con = sqlite3.connect(os.environ["STATE_DB"])
    for index in indexes:
        index_name = index[1]
        indexed_columns.update(row[2] for row in con.execute(f"pragma index_info({index_name!r})").fetchall())
    con.close()
except sqlite3.Error:
    indexed_columns = set()

missing_indexes = sorted(recommended - indexed_columns)
if missing_indexes:
    print("Aviso: no se detectaron indices para columnas recomendadas: " + ", ".join(missing_indexes))
PY
}

if ! validate_state_schema; then
  printf 'Pulsa Enter para cerrar...'
  read -r
  exit 1
fi

load_sessions() {
  mapfile -t sessions < <(
  HOME_DIR="$HOME" STATE_DB="$STATE_DB" OUT_DIR="$OUT_DIR" ARCHIVED_VALUE="$ARCHIVED_VALUE" SESSION_FILTER="$SESSION_FILTER" python3 - <<'PY'
import os
import sqlite3
from datetime import datetime
from pathlib import Path

db = os.environ["STATE_DB"]
home = os.environ["HOME_DIR"]
out_dir = Path(os.environ["OUT_DIR"])
archived_value = int(os.environ["ARCHIVED_VALUE"])
session_filter = os.environ["SESSION_FILTER"].strip().casefold()
con = sqlite3.connect(db)
rows = con.execute(
    """
    select id, cwd, title, first_user_message, created_at, updated_at, tokens_used
    from threads
    where (cwd = ? or cwd like ?)
      and archived = ?
      and source in ('cli', 'vscode')
    order by updated_at desc
    """,
    (home, f"{home}/%", archived_value),
).fetchall()
con.close()

def project_label(cwd):
    path = Path(cwd)
    home_path = Path(home)
    if path == home_path:
        return "Carpeta personal"
    root = path
    for parent in [path, *path.parents]:
        if parent == home_path.parent:
            break
        if (parent / ".git").is_dir():
            root = parent
            break
    return root.name or path.name or cwd

def describe_session(cwd, raw_title, raw_first):
    low_signal = {"", ".", "exit"}
    title_line = " ".join(raw_title.split())
    first_line = " ".join(raw_first.split())
    label = project_label(cwd)
    if title_line.casefold() not in low_signal:
        return title_line
    if first_line.casefold() not in low_signal:
        return f"{label}: {first_line}"
    return label

for sid, cwd, title, first_user_message, created_at, updated_at, tokens_used in rows:
    if not Path(cwd).is_dir():
        continue
    raw_title = (title or "").strip()
    raw_first = (first_user_message or "").strip()
    haystack = "\n".join((sid, cwd, raw_title, raw_first)).casefold()
    if session_filter and session_filter not in haystack:
        continue
    when = datetime.fromtimestamp(updated_at).strftime("%Y-%m-%d %H:%M")
    started = datetime.fromtimestamp(created_at).strftime("%Y-%m-%d %H:%M")
    clean_title = describe_session(cwd, raw_title, raw_first)
    if len(clean_title) > 58:
        clean_title = clean_title[:55] + "..."
    short_cwd = cwd.replace(home, "~", 1)
    if len(short_cwd) > 34:
        short_cwd = "..." + short_cwd[-31:]
    token_label = f"{tokens_used:,}".replace(",", ".")
    has_summary = "SI" if any(out_dir.glob(f"resumen-codex-{sid}-*.txt")) else "NO"
    print(f"{sid}\t{when}\t{started}\t{token_label}\t{has_summary}\t{cwd}\t{short_cwd}\t{clean_title}")
PY
  )
}

export_session_list() {
  mkdir -p "$OUT_DIR"
  export_stamp="$(date '+%Y%m%d-%H%M%S')"
  md_path="$OUT_DIR/listado-sesiones-codex-${export_stamp}.md"
  csv_path="$OUT_DIR/listado-sesiones-codex-${export_stamp}.csv"
  HOME_DIR="$HOME" STATE_DB="$STATE_DB" OUT_DIR="$OUT_DIR" ARCHIVED_VALUE="$ARCHIVED_VALUE" SESSION_FILTER="$SESSION_FILTER" MD_PATH="$md_path" CSV_PATH="$csv_path" python3 - <<'PY'
import csv
import os
import sqlite3
from datetime import datetime
from pathlib import Path

db = os.environ["STATE_DB"]
home = os.environ["HOME_DIR"]
out_dir = Path(os.environ["OUT_DIR"])
archived_value = int(os.environ["ARCHIVED_VALUE"])
session_filter = os.environ["SESSION_FILTER"].strip().casefold()
md_path = Path(os.environ["MD_PATH"])
csv_path = Path(os.environ["CSV_PATH"])

con = sqlite3.connect(db)
rows = con.execute(
    """
    select id, cwd, title, first_user_message, created_at, updated_at, tokens_used
    from threads
    where (cwd = ? or cwd like ?)
      and archived = ?
      and source in ('cli', 'vscode')
    order by updated_at desc
    """,
    (home, f"{home}/%", archived_value),
).fetchall()
con.close()

def project_label(cwd):
    path = Path(cwd)
    home_path = Path(home)
    if path == home_path:
        return "Carpeta personal"
    root = path
    for parent in [path, *path.parents]:
        if parent == home_path.parent:
            break
        if (parent / ".git").is_dir():
            root = parent
            break
    return root.name or path.name or cwd

def describe_session(cwd, raw_title, raw_first):
    low_signal = {"", ".", "exit"}
    title_line = " ".join(raw_title.split())
    first_line = " ".join(raw_first.split())
    label = project_label(cwd)
    if title_line.casefold() not in low_signal:
        return title_line
    if first_line.casefold() not in low_signal:
        return f"{label}: {first_line}"
    return label

items = []
for sid, cwd, title, first_user_message, created_at, updated_at, tokens_used in rows:
    if not Path(cwd).is_dir():
        continue
    raw_title = (title or "").strip()
    raw_first = (first_user_message or "").strip()
    haystack = "\n".join((sid, cwd, raw_title, raw_first)).casefold()
    if session_filter and session_filter not in haystack:
        continue
    clean_title = describe_session(cwd, raw_title, raw_first)
    short_cwd = cwd.replace(home, "~", 1)
    has_summary = "SI" if any(out_dir.glob(f"resumen-codex-{sid}-*.txt")) else "NO"
    items.append(
        {
            "id": sid,
            "updated": datetime.fromtimestamp(updated_at).strftime("%Y-%m-%d %H:%M"),
            "started": datetime.fromtimestamp(created_at).strftime("%Y-%m-%d %H:%M"),
            "tokens": tokens_used,
            "summary": has_summary,
            "path": short_cwd,
            "title": clean_title,
        }
    )

with csv_path.open("w", newline="", encoding="utf-8") as fh:
    writer = csv.DictWriter(fh, fieldnames=["id", "updated", "started", "tokens", "summary", "path", "title"])
    writer.writeheader()
    writer.writerows(items)

lines = ["# Listado de sesiones de Codex", ""]
lines.append("| Actualizada | Iniciada | Tokens | Resumen | Ruta | Descripcion |")
lines.append("| --- | --- | ---: | --- | --- | --- |")
for item in items:
    lines.append(
        f"| {item['updated']} | {item['started']} | {item['tokens']} | {item['summary']} | `{item['path']}` | {item['title']} |"
    )
md_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(md_path)
print(csv_path)
PY
}

show_session_table() {
  if [[ "$VIEW_MODE" == "archived" ]]; then
    print_title 'Sesiones archivadas de Codex'
  else
    print_title 'Sesiones activas de Codex'
  fi
  if [[ -n "$SESSION_FILTER" ]]; then
    printf '%sFiltro activo:%s %s\n\n' "$STYLE_LABEL" "$STYLE_RESET" "$SESSION_FILTER"
  fi
  printf '%-3s %-16s %-16s %-12s %-8s %-34s %s\n' 'N' 'Actualizada' 'Iniciada' 'Tokens' 'Resumen' 'Ruta' 'Descripcion'
  printf '%-3s %-16s %-16s %-12s %-8s %-34s %s\n' '---' '----------------' '----------------' '------------' '--------' '----------------------------------' '----------------------------------------------------------'
  for i in "${!sessions[@]}"; do
    IFS=$'\t' read -r sid when started tokens has_summary cwd short_cwd title <<< "${sessions[$i]}"
    printf '%-3d %-16s %-16s %-12s %-8s %-34s %s\n' "$((i + 1))" "$when" "$started" "$tokens" "$has_summary" "$short_cwd" "$title"
  done
}

generate_summary() {
  if [[ ! -d "$cwd" ]]; then
    printf '\nNo se puede generar el resumen porque ya no existe el directorio original:\n%s\n' "$cwd"
    return 1
  fi

  mkdir -p "$OUT_DIR" "$LOG_DIR"
  safe_stamp="$(date '+%Y%m%d-%H%M%S')"
  OUT="$OUT_DIR/resumen-codex-${sid}-${safe_stamp}.txt"
  MD_OUT="$OUT_DIR/resumen-codex-${sid}-${safe_stamp}.md"
  LOG="$LOG_DIR/resumen-codex-${sid}-${safe_stamp}.log"

  printf '\nGenerando resumen de:\n%s\n%s\n\n' "$cwd" "$title"
  printf 'Procesando. La salida tecnica se guarda aparte para no ensuciar esta ventana.\n'
  "$CODEX_BIN" exec \
    -C "$cwd" \
    resume "$sid" \
    --skip-git-repo-check \
    --ephemeral \
    -o "$OUT" \
    "Resume en espanol esta sesion de Codex. Incluye: objetivo, trabajo realizado, archivos tocados, decisiones importantes, pendientes y riesgos. Se concreto." \
    >"$LOG" 2>&1

  summary_status=$?
  if [[ $summary_status -eq 0 && -s "$OUT" ]]; then
    {
      printf '# Resumen de sesion Codex\n\n'
      printf -- "- Session ID: \`%s\`\n" "$sid"
      printf -- "- Ruta: \`%s\`\n" "$cwd"
      printf -- "- Generado: \`%s\`\n\n" "$safe_stamp"
      cat "$OUT"
    } >"$MD_OUT"
    printf '\nResumen guardado en:\n%s\n' "$OUT"
    printf '\nResumen Markdown guardado en:\n%s\n' "$MD_OUT"
    printf '\nLog tecnico guardado en:\n%s\n' "$LOG"
    printf '\n--- Vista previa ---\n'
    sed -n '1,24p' "$OUT"
  else
    printf '\nNo se pudo generar el resumen.\n'
    printf 'Codex termino con codigo %s.\n' "$summary_status"
    if grep -q 'failed to load CLI auth from keyring' "$LOG"; then
      printf 'Motivo probable: Codex no pudo acceder al llavero de autenticacion.\n'
      printf 'Prueba desde una sesion grafica normal o vuelve a iniciar sesion con Codex si persiste.\n'
    fi
    printf 'Revisa el log tecnico en: %s\n' "$LOG"
  fi
  return "$summary_status"
}

show_latest_summary() {
  latest_summary="$(find "$OUT_DIR" -maxdepth 1 -type f -name "resumen-codex-${sid}-*.txt" 2>/dev/null | sort | tail -n 1)"
  if [[ -z "$latest_summary" ]]; then
    printf '\nNo hay resumen asociado a esta sesion.\n'
    return 1
  fi

  printf '\nUltimo resumen guardado:\n%s\n' "$latest_summary"
  printf '\n--- Contenido ---\n'
  sed -n '1,120p' "$latest_summary"
  return 0
}

open_latest_summary_file() {
  latest_summary="$(find "$OUT_DIR" -maxdepth 1 -type f \( -name "resumen-codex-${sid}-*.md" -o -name "resumen-codex-${sid}-*.txt" \) 2>/dev/null | sort | tail -n 1)"
  if [[ -z "$latest_summary" ]]; then
    printf '\nNo hay resumen asociado a esta sesion.\n'
    return 1
  fi

  if [[ -n "${CODEX_SUMMARY_OPENER:-}" ]]; then
    "$CODEX_SUMMARY_OPENER" "$latest_summary"
    return $?
  fi

  if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$latest_summary" >/dev/null 2>&1 &
    printf '\nResumen abierto con xdg-open:\n%s\n' "$latest_summary"
    return 0
  fi

  printf '\nNo se encontro xdg-open para abrir el resumen automaticamente.\n'
  printf 'Resumen disponible en:\n%s\n' "$latest_summary"
  return 1
}

open_path_with_default_app() {
  local target_path="$1"
  if [[ ! -e "$target_path" ]]; then
    printf '\nNo existe la ruta:\n%s\n' "$target_path"
    return 1
  fi

  if [[ -n "${CODEX_PATH_OPENER:-}" ]]; then
    "$CODEX_PATH_OPENER" "$target_path"
    return $?
  fi

  if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$target_path" >/dev/null 2>&1 &
    printf '\nRuta abierta con xdg-open:\n%s\n' "$target_path"
    return 0
  fi

  printf '\nNo se encontro xdg-open para abrir la ruta automaticamente.\n'
  printf 'Ruta disponible en:\n%s\n' "$target_path"
  return 1
}

show_session_details() {
  printf '\nID completo: %s\n' "$sid"
  printf 'Titulo: %s\n' "$title"
  printf 'Ruta completa: %s\n' "$cwd"
  printf 'Ruta abreviada: %s\n' "$short_cwd"
  printf 'Actualizada: %s\n' "$when"
  printf 'Iniciada: %s\n' "$started"
  printf 'Tokens: %s\n' "$tokens"
  printf 'Resumen asociado: %s\n' "$has_summary"
  latest_summary="$(find "$OUT_DIR" -maxdepth 1 -type f \( -name "resumen-codex-${sid}-*.md" -o -name "resumen-codex-${sid}-*.txt" \) 2>/dev/null | sort | tail -n 1)"
  if [[ -n "$latest_summary" ]]; then
    printf 'Ultimo resumen: %s\n' "$latest_summary"
  else
    printf 'Ultimo resumen: no disponible\n'
  fi
}

open_session() {
  printf '\nAbriendo sesion en Codex:\n%s\n%s\n\n' "$cwd" "$title"
  cd "$cwd" || {
    printf 'No se pudo acceder al directorio de la sesion.\n'
    return 1
  }
  exec "$CODEX_BIN" resume "$sid"
}

set_archive_state() {
  local new_value="$1"
  local verb="$2"
  if [[ "$READ_ONLY_MODE" -eq 1 ]]; then
    printf '\nModo solo lectura activo. No se modifica la base local de Codex.\n'
    return 1
  fi
  mkdir -p "$BACKUP_DIR"
  backup_stamp="$(date '+%Y%m%d-%H%M%S')"
  backup_path="$BACKUP_DIR/state-before-archive-${backup_stamp}.sqlite"
  STATE_DB="$STATE_DB" BACKUP_PATH="$backup_path" python3 - <<'PY'
import os
import sqlite3

source = sqlite3.connect(os.environ["STATE_DB"])
target = sqlite3.connect(os.environ["BACKUP_PATH"])
source.backup(target)
target.close()
source.close()
PY
  backup_status=$?
  if [[ $backup_status -ne 0 ]]; then
    printf '\nNo se pudo crear el backup previo. Archivado cancelado.\n'
    return "$backup_status"
  fi
  rotate_backups 'state-before-archive-*.sqlite'
  STATE_DB="$STATE_DB" SID="$sid" NEW_VALUE="$new_value" python3 - <<'PY'
import os
import sqlite3
import time

db = os.environ["STATE_DB"]
sid = os.environ["SID"]
new_value = int(os.environ["NEW_VALUE"])
archived_at = int(time.time()) if new_value else None

con = sqlite3.connect(db)
cur = con.execute(
    "update threads set archived = ?, archived_at = ? where id = ?",
    (new_value, archived_at, sid),
)
con.commit()
con.close()

if cur.rowcount != 1:
    raise SystemExit(1)
PY
  archive_status=$?
  if [[ $archive_status -eq 0 ]]; then
    printf '\nSesion %s correctamente.\n' "$verb"
    printf 'Backup previo guardado en: %s\n' "$backup_path"
  else
    printf '\nNo se pudo cambiar el estado de archivado.\n'
  fi
  return "$archive_status"
}

create_state_backup() {
  mkdir -p "$BACKUP_DIR"
  backup_stamp="$(date '+%Y%m%d-%H%M%S')"
  backup_path="$BACKUP_DIR/state-before-cleanup-${backup_stamp}.sqlite"
  STATE_DB="$STATE_DB" BACKUP_PATH="$backup_path" python3 - <<'PY'
import os
import sqlite3

source = sqlite3.connect(os.environ["STATE_DB"])
target = sqlite3.connect(os.environ["BACKUP_PATH"])
source.backup(target)
target.close()
source.close()
PY
}

clean_missing_path_sessions() {
  if [[ "$READ_ONLY_MODE" -eq 1 ]]; then
    printf '\nModo solo lectura activo. La limpieza de sesiones esta deshabilitada.\n'
    return 1
  fi
  printf '\nSe eliminaran de la base local las sesiones cuyo directorio ya no existe.\n'
  printf 'La operacion crea un backup previo y no borra carpetas del disco.\n'
  printf 'Escribe LIMPIAR para confirmar: '
  if ! read -r confirm; then
    exit 0
  fi
  if [[ "$confirm" != "LIMPIAR" ]]; then
    printf 'Limpieza cancelada.\n'
    return 1
  fi

  create_state_backup
  backup_status=$?
  if [[ $backup_status -ne 0 ]]; then
    printf '\nNo se pudo crear el backup previo. Limpieza cancelada.\n'
    return "$backup_status"
  fi

  removed_count="$(STATE_DB="$STATE_DB" HOME_DIR="$HOME" python3 - <<'PY'
import os
import sqlite3
from pathlib import Path

db = os.environ["STATE_DB"]
home = os.environ["HOME_DIR"]

con = sqlite3.connect(db)
rows = con.execute(
    """
    select id, cwd
    from threads
    where (cwd = ? or cwd like ?)
      and source in ('cli', 'vscode')
    """,
    (home, f"{home}/%"),
).fetchall()
missing_ids = [sid for sid, cwd in rows if not Path(cwd).is_dir()]
if missing_ids:
    con.executemany("delete from threads where id = ?", [(sid,) for sid in missing_ids])
    con.commit()
con.close()
print(len(missing_ids))
PY
)"
  printf '\nLimpieza completada.\n'
  printf 'Backup previo guardado en: %s\n' "$backup_path"
  printf 'Sesiones eliminadas: %s\n' "$removed_count"
  rotate_backups 'state-before-cleanup-*.sqlite'
}

restore_backup_interactive() {
  if [[ "$READ_ONLY_MODE" -eq 1 ]]; then
    printf '\nModo solo lectura activo. Restauracion deshabilitada.\n'
    return 1
  fi

  mapfile -t restore_backups < <(
    find "$BACKUP_DIR" -maxdepth 1 -type f \( -name 'state-before-archive-*.sqlite' -o -name 'state-before-cleanup-*.sqlite' \) 2>/dev/null |
      sort |
      tail -n 10
  )
  if [[ ${#restore_backups[@]} -eq 0 ]]; then
    printf '\nNo hay backups disponibles en:\n%s\n' "$BACKUP_DIR"
    return 1
  fi

  print_title 'Restaurar backup SQLite'
  printf 'Base actual:\n%s\n\n' "$STATE_DB"
  for i in "${!restore_backups[@]}"; do
    printf '%-3d %s\n' "$((i + 1))" "${restore_backups[$i]}"
  done
  printf '\n0   Cancelar\n'
  printf '\nNumero de backup: '
  if ! read -r backup_choice; then
    exit 0
  fi
  if [[ "$backup_choice" == "0" ]]; then
    printf 'Restauracion cancelada.\n'
    return 1
  fi
  if ! [[ "$backup_choice" =~ ^[0-9]+$ ]] || (( backup_choice < 1 || backup_choice > ${#restore_backups[@]} )); then
    printf 'Seleccion no valida.\n'
    return 1
  fi

  selected_backup="${restore_backups[$((backup_choice - 1))]}"
  printf '\nResumen del backup seleccionado:\n'
  STATE_DB="$selected_backup" HOME_DIR="$HOME" python3 - <<'PY'
import os
import sqlite3
from pathlib import Path

db = os.environ["STATE_DB"]
home = os.environ["HOME_DIR"]
con = sqlite3.connect(db)
rows = con.execute("select cwd, archived, source from threads").fetchall()
con.close()
under_home = [row for row in rows if row[0] == home or row[0].startswith(f"{home}/")]
existing = [row for row in under_home if Path(row[0]).is_dir()]
active = [row for row in existing if row[1] == 0 and row[2] in ("cli", "vscode")]
archived = [row for row in existing if row[1] == 1 and row[2] in ("cli", "vscode")]
print(f"  Sesiones bajo HOME: {len(under_home)}")
print(f"  Activas visibles: {len(active)}")
print(f"  Archivadas visibles: {len(archived)}")
print(f"  Rutas inexistentes: {len(under_home) - len(existing)}")
PY
  printf '\nSe va a reemplazar la base actual por:\n%s\n' "$selected_backup"
  printf 'Cierra Codex antes de continuar si lo tienes abierto.\n'
  printf 'Escribe RESTAURAR para confirmar: '
  if ! read -r confirm; then
    exit 0
  fi
  if [[ "$confirm" != "RESTAURAR" ]]; then
    printf 'Restauracion cancelada.\n'
    return 1
  fi

  pre_restore_backup="$BACKUP_DIR/state-before-restore-$(date '+%Y%m%d-%H%M%S').sqlite"
  cp -- "$STATE_DB" "$pre_restore_backup"
  cp -- "$selected_backup" "$STATE_DB"
  printf '\nRestauracion completada.\n'
  printf 'Backup de la base reemplazada: %s\n' "$pre_restore_backup"
}

show_projects_view() {
  clear_screen
  print_title 'Sesiones por proyecto'
  HOME_DIR="$HOME" STATE_DB="$STATE_DB" ARCHIVED_VALUE="$ARCHIVED_VALUE" python3 - <<'PY'
import os
import sqlite3
from pathlib import Path

db = os.environ["STATE_DB"]
home = os.environ["HOME_DIR"]
archived_value = int(os.environ["ARCHIVED_VALUE"])

con = sqlite3.connect(db)
rows = con.execute(
    """
    select cwd, count(*), max(updated_at), sum(tokens_used)
    from threads
    where (cwd = ? or cwd like ?)
      and archived = ?
      and source in ('cli', 'vscode')
    group by cwd
    order by max(updated_at) desc
    """,
    (home, f"{home}/%", archived_value),
).fetchall()
con.close()

projects = {}
for cwd, count, updated_at, tokens in rows:
    path = Path(cwd)
    if not path.is_dir():
        continue
    root = path
    for parent in [path, *path.parents]:
        if parent == Path(home).parent:
            break
        if (parent / ".git").is_dir():
            root = parent
            break
    key = str(root)
    current = projects.setdefault(key, {"count": 0, "updated": 0, "tokens": 0})
    current["count"] += count
    current["updated"] = max(current["updated"], updated_at)
    current["tokens"] += tokens or 0

if not projects:
    print("No hay proyectos visibles en esta vista.")
else:
    print(f"{'Sesiones':<9} {'Tokens':<14} Ruta")
    print(f"{'--------':<9} {'--------------':<14} {'-' * 54}")
    for cwd, data in sorted(projects.items(), key=lambda item: item[1]["updated"], reverse=True):
        short_cwd = cwd.replace(home, "~", 1)
        if len(short_cwd) > 58:
            short_cwd = "..." + short_cwd[-55:]
        token_label = f"{data['tokens']:,}".replace(",", ".")
        print(f"{data['count']:<9} {token_label:<14} {short_cwd}")
PY
}

show_session_diagnostics() {
  RULE_CHAR="$RULE_CHAR" BOX_TOP_LEFT="$BOX_TOP_LEFT" BOX_TOP_RIGHT="$BOX_TOP_RIGHT" BOX_BOTTOM_LEFT="$BOX_BOTTOM_LEFT" BOX_BOTTOM_RIGHT="$BOX_BOTTOM_RIGHT" BOX_VERTICAL="$BOX_VERTICAL" HOME_DIR="$HOME" STATE_DB="$STATE_DB" python3 - <<'PY'
import os
import sqlite3
from pathlib import Path

db = os.environ["STATE_DB"]
home = os.environ["HOME_DIR"]
con = sqlite3.connect(db)
rows = con.execute("select cwd, archived, source from threads").fetchall()
con.close()

under_home = [row for row in rows if row[0] == home or row[0].startswith(f"{home}/")]
existing = [row for row in under_home if Path(row[0]).is_dir()]
visible_active = [row for row in existing if row[1] == 0 and row[2] in ("cli", "vscode")]
visible_archived = [row for row in existing if row[1] == 1 and row[2] in ("cli", "vscode")]
missing = len(under_home) - len(existing)
technical = len([row for row in existing if row[2] not in ("cli", "vscode")])
outside_home = len(rows) - len(under_home)
rule = os.environ["RULE_CHAR"] * 79
top = f"{os.environ['BOX_TOP_LEFT']}{rule}{os.environ['BOX_TOP_RIGHT']}"
bottom = f"{os.environ['BOX_BOTTOM_LEFT']}{rule}{os.environ['BOX_BOTTOM_RIGHT']}"
vertical = os.environ["BOX_VERTICAL"]

print(f"\n{top}")
print(f"{vertical} {'Resumen de sesiones':<75} {vertical}")
print(bottom)
print(f"  Activas que puedes abrir ahora      {len(visible_active)}")
print(f"  Archivadas que puedes recuperar     {len(visible_archived)}")
print(f"  Antiguas con carpeta ya borrada     {missing}")
print(f"  Tecnicas internas que se ocultan    {technical}")
if outside_home:
    print(f"  Fuera de tu carpeta personal        {outside_home}")

print("\nQue significa")
print(rule)
print("  Activas              vista principal de sesiones disponibles")
print("  Archivadas           sesiones ocultas que se pueden recuperar")
print("  Carpeta borrada      no se muestran para evitar errores al abrirlas")
print("  Tecnicas internas    tareas auxiliares de Codex, no sesiones normales")

print("\nSiguiente paso")
print(rule)
print("  Pulsa Enter para volver a herramientas y elegir una accion.")

print("\nDetalle tecnico")
print(rule)
print(f" Base local usada: {db}")
PY
}

export_session_diagnostics() {
  mkdir -p "$OUT_DIR"
  diagnostic_stamp="$(date '+%Y%m%d-%H%M%S')"
  diagnostic_path="$OUT_DIR/diagnostico-sesiones-codex-${diagnostic_stamp}.md"
  HOME_DIR="$HOME" STATE_DB="$STATE_DB" DIAGNOSTIC_PATH="$diagnostic_path" python3 - <<'PY'
import os
import sqlite3
from pathlib import Path

db = os.environ["STATE_DB"]
home = os.environ["HOME_DIR"]
diagnostic_path = Path(os.environ["DIAGNOSTIC_PATH"])

con = sqlite3.connect(db)
rows = con.execute("select cwd, archived, source from threads").fetchall()
con.close()

under_home = [row for row in rows if row[0] == home or row[0].startswith(f"{home}/")]
existing = [row for row in under_home if Path(row[0]).is_dir()]
visible_active = [row for row in existing if row[1] == 0 and row[2] in ("cli", "vscode")]
visible_archived = [row for row in existing if row[1] == 1 and row[2] in ("cli", "vscode")]
missing = len(under_home) - len(existing)
technical = len([row for row in existing if row[2] not in ("cli", "vscode")])
outside_home = len(rows) - len(under_home)

lines = [
    "# Diagnostico de sesiones de Codex",
    "",
    f"- Activas que puedes abrir ahora: {len(visible_active)}",
    f"- Archivadas que puedes recuperar: {len(visible_archived)}",
    f"- Antiguas con carpeta ya borrada: {missing}",
    f"- Tecnicas internas que se ocultan: {technical}",
]
if outside_home:
    lines.append(f"- Fuera de tu carpeta personal: {outside_home}")
lines.extend(
    [
        "",
        "## Detalle tecnico",
        "",
        f"- Base local usada: `{db}`",
        f"- HOME analizado: `{home}`",
        "",
        "## Criterios de visibilidad",
        "",
        "- `cwd` dentro de HOME.",
        "- Carpeta `cwd` existente.",
        "- `source` igual a `cli` o `vscode`.",
        "- Estado `archived` segun vista activa o archivada.",
    ]
)
diagnostic_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(diagnostic_path)
PY
}

show_tools_help() {
  print_title 'Ayuda de herramientas'
  print_option_panel \
    'd        Resumen visual: activas, archivadas, carpetas borradas y base usada.' \
    'e        Guarda ese diagnostico como Markdown en la carpeta de resumenes.' \
    'l        Exporta el listado activo visible a Markdown y CSV.' \
    'o        Abre la carpeta donde se guardan resumenes y diagnosticos.' \
    'b        Abre la carpeta de backups SQLite creados antes de cambios.' \
    'r        Restaura un backup SQLite con resumen previo y confirmacion.' \
    '0        Vuelve al menu inicial sin hacer cambios.'
}

show_tools_menu() {
  while true; do
    clear_screen
    print_title 'Herramientas'
    print_option_panel \
      'd        Resumen de sesiones' \
      'e        Exportar diagnostico' \
      'l        Exportar listado' \
      'o        Abrir carpeta de resumenes' \
      'b        Abrir carpeta de backups' \
      'r        Restaurar backup SQLite' \
      '?        Ayuda de herramientas' \
      '0        Volver al menu inicial'
    printf '\nOpcion: '
    if ! read -r tool_choice; then
      exit 0
    fi

    case "$tool_choice" in
      0)
        return 0
        ;;
      d|D)
        clear_screen
        show_session_diagnostics
        printf '\nPulsa Enter para volver a herramientas...'
        read -r
        ;;
      e|E)
        clear_screen
        print_title 'Exportar diagnostico'
        exported_path="$(export_session_diagnostics)"
        printf '\nDiagnostico guardado en:\n%s\n' "$exported_path"
        printf '\nPulsa Enter para volver a herramientas...'
        read -r
        ;;
      l|L)
        clear_screen
        print_title 'Exportar listado'
        VIEW_MODE="active"
        ARCHIVED_VALUE=0
        SESSION_FILTER=""
        exported_listing="$(export_session_list)"
        printf '\nListado guardado en:\n%s\n' "$exported_listing"
        printf '\nPulsa Enter para volver a herramientas...'
        read -r
        ;;
      o|O)
        clear_screen
        print_title 'Abrir carpeta de resumenes'
        mkdir -p "$OUT_DIR"
        open_path_with_default_app "$OUT_DIR"
        printf '\nPulsa Enter para volver a herramientas...'
        read -r
        ;;
      b|B)
        clear_screen
        print_title 'Abrir carpeta de backups'
        mkdir -p "$BACKUP_DIR"
        open_path_with_default_app "$BACKUP_DIR"
        printf '\nPulsa Enter para volver a herramientas...'
        read -r
        ;;
      r|R)
        clear_screen
        restore_backup_interactive
        printf '\nPulsa Enter para volver a herramientas...'
        read -r
        ;;
      '?'|ayuda|Ayuda|AYUDA)
        clear_screen
        show_tools_help
        printf '\nPulsa Enter para volver a herramientas...'
        read -r
        ;;
      *)
        printf '\nOpcion no valida.\n'
        printf '\nPulsa Enter para continuar...'
        read -r
        ;;
    esac
  done
}

while true; do
  clear_screen
  print_title 'Automatizacion-Codex'
  printf '%sSelecciona una opcion%s\n\n' "$STYLE_LABEL" "$STYLE_RESET"
  print_option_panel \
    '[Enter]  Sesiones activas' \
    'a        Sesiones archivadas' \
    'p        Vista por proyecto' \
    'h        Herramientas' \
    'q        Salir'
  printf '\nOpcion: '
  if ! read -r view_choice; then
    exit 0
  fi

  case "$view_choice" in
    q|Q)
      exit 0
      ;;
    p|P)
      VIEW_MODE="active"
      ARCHIVED_VALUE=0
      show_projects_view
      printf '\nPulsa Enter para volver al menu inicial...'
      read -r
      continue
      ;;
    h|H)
      show_tools_menu
      continue
      ;;
    a|A)
      VIEW_MODE="archived"
      ARCHIVED_VALUE=1
      ;;
    *)
      VIEW_MODE="active"
      ARCHIVED_VALUE=0
      ;;
  esac

  SESSION_FILTER=""
  load_sessions

  while true; do
    clear_screen
    if [[ ${#sessions[@]} -eq 0 ]]; then
      if [[ "$VIEW_MODE" == "archived" ]]; then
        printf '\nNo hay sesiones archivadas que mostrar bajo %s.\n' "$HOME"
      else
        printf '\nNo hay sesiones activas que mostrar bajo %s.\n' "$HOME"
      fi
    else
      show_session_table
    fi
    print_subtitle 'Acciones del listado'
    list_actions=(
      '0        Volver al menu inicial'
      'f        Filtrar por texto'
    )
    if [[ "$READ_ONLY_MODE" -eq 0 ]]; then
      list_actions+=('x        Limpiar sesiones con ruta inexistente')
    else
      printf '\nModo solo lectura activo: limpieza y archivado deshabilitados.\n'
    fi
    print_option_panel "${list_actions[@]}"
    if [[ -n "$SESSION_FILTER" ]]; then
      print_option 'l' 'Limpiar filtro'
    fi
    printf '\nNumero de sesion: '
    if ! read -r choice; then
      exit 0
    fi

    if [[ "$choice" == "0" ]]; then
      break
    fi

    if [[ "$choice" == "f" || "$choice" == "F" ]]; then
      printf '\nTexto a buscar en ID, ruta, titulo o primer mensaje: '
      if ! read -r SESSION_FILTER; then
        exit 0
      fi
      load_sessions
      if [[ ${#sessions[@]} -eq 0 ]]; then
        printf '\nNo hay sesiones que coincidan con el filtro actual.\n'
      fi
      continue
    fi

    if [[ "$choice" == "l" || "$choice" == "L" ]]; then
      SESSION_FILTER=""
      load_sessions
      continue
    fi

    if [[ "$choice" == "x" || "$choice" == "X" ]]; then
      if [[ "$READ_ONLY_MODE" -eq 1 ]]; then
        printf '\nModo solo lectura activo. Opcion no disponible.\n'
        continue
      fi
      clean_missing_path_sessions
      load_sessions
      continue
    fi

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#sessions[@]} )); then
      printf '\nSeleccion no valida.\n'
      continue
    fi

    IFS=$'\t' read -r sid when started tokens has_summary cwd short_cwd title <<< "${sessions[$((choice - 1))]}"

    while true; do
      clear_screen
      print_title 'Acciones de la sesion'
      print_option_panel \
        "Sesion: $title" \
        "Ruta:   $cwd"
      print_subtitle 'Acciones disponibles'
      if [[ "$VIEW_MODE" == "archived" ]]; then
        archive_action='4        Desarchivar sesion'
      else
        archive_action='4        Archivar sesion'
      fi
      if [[ "$READ_ONLY_MODE" -eq 0 ]]; then
        print_option_panel \
          '1        Generar resumen' \
          '2        Abrir sesion para continuar' \
          '3        Generar resumen y despues abrir sesion' \
          "$archive_action" \
          '5        Ver ultimo resumen guardado' \
          '6        Abrir resumen en editor predeterminado' \
          '7        Ver detalles tecnicos' \
          '0        Volver al listado de sesiones'
      else
        print_option_panel \
          '1        Generar resumen' \
          '2        Abrir sesion para continuar' \
          '3        Generar resumen y despues abrir sesion' \
          '5        Ver ultimo resumen guardado' \
          '6        Abrir resumen en editor predeterminado' \
          '7        Ver detalles tecnicos' \
          '0        Volver al listado de sesiones'
        printf '\nModo solo lectura activo: archivado y limpieza deshabilitados.\n'
      fi
      printf '\nOpcion: '
      if ! read -r action; then
        exit 0
      fi

      case "$action" in
        0)
          break
          ;;
        1)
          generate_summary
          printf '\nPulsa Enter para volver al listado...'
          read -r
          break
          ;;
        2)
          open_session
          ;;
        3)
          generate_summary
          status=$?
          if [[ $status -ne 0 ]]; then
            printf '\nPulsa Enter para volver al listado...'
            read -r
            break
          fi
          printf '\nPulsa Enter para abrir la sesion y continuar...'
          read -r
          open_session
          ;;
        4)
          if [[ "$READ_ONLY_MODE" -eq 1 ]]; then
            printf '\nModo solo lectura activo. Opcion no disponible.\n'
            printf '\nPulsa Enter para volver al menu de acciones...'
            read -r
            continue
          fi
          if [[ "$VIEW_MODE" == "archived" ]]; then
            set_archive_state 0 'desarchivada'
          else
            printf '\nVas a ocultar esta sesion del listado activo, sin borrarla.\n'
            printf 'Escribe ARCHIVAR para confirmar: '
            if ! read -r confirm; then
              exit 0
            fi
            if [[ "$confirm" != "ARCHIVAR" ]]; then
              printf 'Archivado cancelado.\n'
              printf '\nPulsa Enter para volver al listado...'
              read -r
              break
            fi
            set_archive_state 1 'archivada'
          fi
          printf '\nPulsa Enter para volver al listado...'
          read -r
          load_sessions
          break
          ;;
        5)
          show_latest_summary
          printf '\nPulsa Enter para volver al menu de acciones...'
          read -r
          ;;
        6)
          open_latest_summary_file
          printf '\nPulsa Enter para volver al menu de acciones...'
          read -r
          ;;
        7)
          show_session_details
          printf '\nPulsa Enter para volver al menu de acciones...'
          read -r
          ;;
        *)
          printf '\nOpcion no valida.\n'
          ;;
      esac
    done
  done
done
