# Roadmap

## Posibles mejoras futuras

- Añadir `CODEX_READ_ONLY=1` para ocultar acciones que escriben en la base local.
- Exportar el resumen de sesiones a texto o Markdown para diagnostico.
- Exportar resumenes a Markdown ademas de texto plano.
- Ampliar filtros con fecha o estado de resumen.
- Añadir deteccion de terminales sin `xdg-terminal-exec`.
- Permitir abrir directamente el fichero de resumen en el editor predeterminado.
- Añadir pruebas automatizadas para el formateo del menu y consultas SQLite.
- Añadir workflow de tests Python en GitHub Actions, ademas de ShellCheck.
- Añadir comprobacion automatica de privacidad para evitar rutas personales, bases SQLite o logs en commits.

## Mejoras priorizadas por SDD

1. Tests de render de consola.
2. Modo solo lectura.
3. Exportacion Markdown.
4. Diagnostico exportable.
5. Rotacion de backups de limpieza.

La justificacion completa esta en `.specify/specs/001-gestor-sesiones-codex/plan.md`.

## Fuera de alcance por ahora

- Borrado destructivo de sesiones.
- Sincronizacion automatica de historiales entre equipos.
- Edicion directa de conversaciones antiguas.
