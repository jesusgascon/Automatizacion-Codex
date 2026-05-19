# Tareas SDD: gestor local de sesiones de Codex

## Completado

- [x] Crear selector de sesiones activas.
- [x] Crear selector de sesiones archivadas.
- [x] Generar resumen asociado a `session_id`.
- [x] Consultar ultimo resumen guardado.
- [x] Reabrir sesion con `codex resume`.
- [x] Archivar y desarchivar con backup.
- [x] Filtrar sesiones por texto.
- [x] Ocultar sesiones con ruta inexistente.
- [x] Limpiar sesiones con ruta inexistente tras confirmacion.
- [x] Crear instalador interactivo.
- [x] Crear lanzador de Escritorio.
- [x] Crear entrada de aplicacion GNOME.
- [x] Detectar Codex por PATH, npm, nvm y rutas habituales.
- [x] Documentar instalacion en otros equipos.
- [x] Crear tests de regresion.
- [x] Mejorar interfaz de consola con limpieza de pantalla y cajas.
- [x] Validar esquema SQLite antes de consultar sesiones.
- [x] Crear tests de render de consola para Unicode, ASCII y ausencia de ANSI fuera de TTY.
- [x] Anadir `CODEX_READ_ONLY=1` para ocultar acciones de escritura.
- [x] Exportar resumenes tambien como Markdown.
- [x] Exportar diagnostico de sesiones a archivo local.
- [x] Rotar tambien backups de limpieza de rutas inexistentes.

## Pendiente recomendado

- [ ] Documentar procedimiento de recuperacion desde backup SQLite.
- [ ] Crear workflow adicional de tests Python en GitHub Actions.
- [ ] Anadir comprobacion de privacidad automatizada para patrones sensibles.

## Criterios antes de cerrar una tarea

- [ ] No introduce rutas duras.
- [ ] No guarda datos privados en el repositorio.
- [ ] Tiene prueba automatizada si afecta a logica.
- [ ] Actualiza README o documento tecnico si cambia uso o instalacion.
- [ ] Pasa `bash -n`.
- [ ] Pasa `python3 -m unittest discover -s tests -v`.
