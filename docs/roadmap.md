# Roadmap

## Posibles mejoras futuras

- Ampliar filtros con fecha o estado de resumen.
- Añadir deteccion de terminales sin `xdg-terminal-exec`.
- Permitir abrir directamente el fichero de resumen en el editor predeterminado.
- Añadir mas pruebas automatizadas para consultas SQLite complejas.
- Añadir workflow de tests Python en GitHub Actions, ademas de ShellCheck.
- Añadir comprobacion automatica de privacidad para evitar rutas personales, bases SQLite o logs en commits.
- Documentar procedimiento de recuperacion desde backup SQLite.

## Mejoras priorizadas por SDD

1. Workflow adicional de tests Python en GitHub Actions.
2. Comprobacion automatica de privacidad.
3. Procedimiento de recuperacion desde backup SQLite.
4. Filtros por fecha o estado de resumen.
5. Apertura directa del resumen en editor predeterminado.

La justificacion completa esta en `.specify/specs/001-gestor-sesiones-codex/plan.md`.

## Fuera de alcance por ahora

- Borrado destructivo de sesiones.
- Sincronizacion automatica de historiales entre equipos.
- Edicion directa de conversaciones antiguas.
