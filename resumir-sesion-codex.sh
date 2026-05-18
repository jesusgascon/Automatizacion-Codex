#!/usr/bin/env bash
set -u

detect_codex_bin() {
  if [[ -n "${CODEX_BIN:-}" && -x "${CODEX_BIN:-}" ]]; then
    printf '%s\n' "$CODEX_BIN"
    return 0
  fi

  if command -v codex >/dev/null 2>&1; then
    command -v codex
    return 0
  fi

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
OUT_DIR="$DESKTOP_DIR/Documentacion/Codex/Resumenes"
LOG_DIR="$OUT_DIR/logs"
BACKUP_DIR="$OUT_DIR/backups"
MAX_BACKUPS="${MAX_BACKUPS:-10}"

if [[ ! -x "$CODEX_BIN" ]]; then
  printf 'No se encuentra Codex en:\n%s\n' "$CODEX_BIN"
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

for sid, cwd, title, first_user_message, created_at, updated_at, tokens_used in rows:
    raw_title = (title or "").strip()
    raw_first = (first_user_message or "").strip()
    haystack = "\n".join((sid, cwd, raw_title, raw_first)).casefold()
    if session_filter and session_filter not in haystack:
        continue
    when = datetime.fromtimestamp(updated_at).strftime("%Y-%m-%d %H:%M")
    started = datetime.fromtimestamp(created_at).strftime("%Y-%m-%d %H:%M")
    low_signal = {"", ".", "exit"}
    if raw_title in low_signal:
        clean_title = "Sesion sin titulo util"
    elif raw_first in low_signal and raw_title == raw_first:
        clean_title = "Sesion sin titulo util"
    else:
        clean_title = raw_title
    clean_title = clean_title.replace("\t", " ").replace("\n", " ")
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

show_session_table() {
  if [[ "$VIEW_MODE" == "archived" ]]; then
    printf '\nSesiones archivadas de Codex\n\n'
  else
    printf '\nSesiones activas de Codex\n\n'
  fi
  if [[ -n "$SESSION_FILTER" ]]; then
    printf 'Filtro activo: %s\n\n' "$SESSION_FILTER"
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
    printf '\nResumen guardado en:\n%s\n' "$OUT"
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
  if [[ "$MAX_BACKUPS" =~ ^[0-9]+$ ]] && (( MAX_BACKUPS > 0 )); then
    mapfile -t backups_to_remove < <(
      find "$BACKUP_DIR" -maxdepth 1 -type f -name 'state-before-archive-*.sqlite' |
        sort |
        head -n "-$MAX_BACKUPS"
    )
    if [[ ${#backups_to_remove[@]} -gt 0 ]]; then
      rm -f -- "${backups_to_remove[@]}"
    fi
  fi
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

while true; do
  printf '\nVista inicial:\n'
  printf ' [Enter] Sesiones activas\n'
  printf ' a       Sesiones archivadas\n'
  printf ' q       Salir\n'
  printf '\nOpcion: '
  if ! read -r view_choice; then
    exit 0
  fi

  case "$view_choice" in
    q|Q)
      exit 0
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

  if [[ ${#sessions[@]} -eq 0 ]]; then
    if [[ "$VIEW_MODE" == "archived" ]]; then
      printf '\nNo hay sesiones archivadas bajo %s.\n' "$HOME"
    else
      printf '\nNo hay sesiones activas bajo %s.\n' "$HOME"
    fi
    continue
  fi

  while true; do
    show_session_table
    printf '\n 0) Volver al menu inicial\n'
    printf ' f) Filtrar por texto\n'
    if [[ -n "$SESSION_FILTER" ]]; then
      printf ' l) Limpiar filtro\n'
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

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#sessions[@]} )); then
      printf '\nSeleccion no valida.\n'
      continue
    fi

    IFS=$'\t' read -r sid when started tokens has_summary cwd short_cwd title <<< "${sessions[$((choice - 1))]}"

    while true; do
      printf '\nQue quieres hacer con esta sesion?\n'
      printf ' 1) Generar resumen\n'
      printf ' 2) Abrir sesion para continuar\n'
      printf ' 3) Generar resumen y despues abrir sesion\n'
      if [[ "$VIEW_MODE" == "archived" ]]; then
        printf ' 4) Desarchivar sesion\n'
      else
        printf ' 4) Archivar sesion\n'
      fi
      printf ' 5) Ver ultimo resumen guardado\n'
      printf ' 0) Volver al listado de sesiones\n'
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
        *)
          printf '\nOpcion no valida.\n'
          ;;
      esac
    done
  done
done
