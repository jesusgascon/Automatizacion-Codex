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
- [x] Documentar procedimiento de recuperacion desde backup SQLite.
- [x] Abrir ultimo resumen con editor o visor predeterminado.
- [x] Anadir fallback de terminales cuando falta `xdg-terminal-exec`.
- [x] Anadir tests SQLite para titulos con caracteres raros y deteccion de base mas reciente.
- [x] Abrir carpetas de resumenes y backups desde el menu inicial.
- [x] Mostrar detalles tecnicos completos de una sesion.
- [x] Restaurar backups SQLite de forma asistida con confirmacion.
- [x] Agrupar sesiones visibles por proyecto/carpeta.
- [x] Crear workflow Python formal con matriz de versiones.
- [x] Anadir comprobacion automatica de privacidad.
- [x] Exportar listado de sesiones a Markdown y CSV.
- [x] Probar backup antes de restaurar comparandolo con la base actual.
- [x] Agrupar proyectos por raiz Git cuando existe.
- [x] Ampliar diagnostico de esquema SQLite con indices recomendados.
- [x] Anadir ayuda contextual en listado y menu de acciones de sesion.
- [x] Exportar e importar configuracion local.
- [x] Crear comprobacion local de release.
- [x] Auditar compatibilidad con Codex CLI desde el menu.

## Pendiente recomendado

- [ ] Ampliar filtros por fecha o estado de resumen.
- [ ] Ampliar pruebas de consultas SQLite con bases grandes.

## Criterios antes de cerrar una tarea

- [ ] No introduce rutas duras.
- [ ] No guarda datos privados en el repositorio.
- [ ] Tiene prueba automatizada si afecta a logica.
- [ ] Actualiza README o documento tecnico si cambia uso o instalacion.
- [ ] Pasa `bash -n`.
- [ ] Pasa `python3 -m unittest discover -s tests -v`.
