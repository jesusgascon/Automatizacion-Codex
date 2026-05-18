# Compatibilidad

## Entornos previstos

| Entorno | Compatibilidad | Notas |
| --- | --- | --- |
| Ubuntu reciente | Alta | `xdg-terminal-exec` disponible en versiones modernas. |
| GNOME con Ptyxis o GNOME Terminal | Alta | El lanzador respeta el terminal predeterminado. |
| Codex instalado en `PATH` | Alta | Detección directa con `command -v codex`. |
| Codex instalado mediante `nvm` | Alta | Se buscan ejecutables bajo `~/.nvm/versions/node/*/bin/codex`. |
| Codex en rutas npm/locales habituales | Alta | Se prueban `~/.local/bin`, `~/.npm-global/bin` y `~/node_modules/.bin`. |
| Codex con prefijo npm personalizado | Alta | Se consulta `npm prefix -g` y se prueba `<prefijo>/bin/codex`. |
| Codex visible solo en shell de login | Alta | Se consulta `type -P codex` en el shell de login del usuario. |
| Codex instalado a nivel de sistema | Alta | Se prueban `/usr/local/bin/codex` y `/usr/bin/codex`. |
| KDE, XFCE u otros escritorios | Media | Puede requerir adaptar el lanzador si falta `xdg-terminal-exec`. |

## Requisitos funcionales

- Bash con soporte para `mapfile`.
- Python 3.
- Módulo estándar `sqlite3`.
- Base local de Codex con tabla `threads`.
- El filtro de sesiones acepta el `$HOME` exacto o subdirectorios reales bajo `$HOME`.

## Supuestos actuales sobre Codex

El script espera que existan columnas compatibles con:

- `id`
- `cwd`
- `title`
- `first_user_message`
- `created_at`
- `updated_at`
- `tokens_used`
- `archived`
- `archived_at`
- `source`

Si una versión futura cambia el esquema, habrá que adaptar la consulta SQL.

## Comandos externos usados

- `find`
- `sort`
- `tail`
- `sed`
- `grep`
- `xdg-user-dir` opcional
- `xdg-terminal-exec` recomendado

## Fuera de alcance

- Windows.
- macOS.
- Sincronización automática entre equipos.
- Borrado destructivo de sesiones.
