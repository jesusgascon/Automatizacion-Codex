# Compatibilidad

## Entornos previstos

| Entorno | Compatibilidad | Notas |
| --- | --- | --- |
| Ubuntu reciente | Alta | `xdg-terminal-exec` disponible en versiones modernas. |
| GNOME con Ptyxis o GNOME Terminal | Alta | El lanzador respeta el terminal predeterminado. |
| Codex instalado en `PATH` | Alta | Detección directa con `command -v codex`. |
| Codex instalado mediante `nvm` | Alta | Se buscan ejecutables bajo `~/.nvm/versions/node/*/bin/codex`. |
| KDE, XFCE u otros escritorios | Media | Puede requerir adaptar el lanzador si falta `xdg-terminal-exec`. |

## Requisitos funcionales

- Bash con soporte para `mapfile`.
- Python 3.
- Módulo estándar `sqlite3`.
- Base local de Codex con tabla `threads`.

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
