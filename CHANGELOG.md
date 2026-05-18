# Changelog

## 1.0.0 - 2026-05-18

### Added

- Selector de sesiones activas y archivadas de Codex.
- Generacion de resumenes asociados por `session_id`.
- Consulta del ultimo resumen guardado.
- Reapertura de sesiones interactivas.
- Archivado y desarchivado reversible.
- Navegacion interna con `0` para volver y `q` para salir.
- Deteccion portable de Codex, base SQLite y carpeta de Escritorio.
- Instalador y plantilla de lanzador `.desktop`.
- Documentacion tecnica completa y paquete de instrucciones para GPT personalizado.
- Avisos de dependencias y marcado de confianza del lanzador durante la instalacion.
- Validacion de `cwd` antes de generar resumenes.
- Rotacion configurable de backups con `MAX_BACKUPS`.
- Filtro de rutas bajo `$HOME` mas estricto.
- Tests automatizados de regresion.
- Documento de configuracion y mantenimiento.
- Ampliacion del README, FAQ, manual y guias operativas para reflejar la version endurecida.
- Guia de instalacion actualizada para distribucion publica.
- Filtro textual de sesiones por ID, ruta, titulo o primer mensaje.
- Logo vectorial propio e integracion visual en README, manual y lanzador.
- Seccion de creditos del proyecto.
- Carpeta de salida configurable mediante `CODEX_SUMMARY_DIR`.
- Instalador interactivo para elegir la carpeta de resumenes, logs y backups.
- Correccion del prompt interactivo para que se muestre y no contamine la ruta elegida.
- Entrada de aplicacion de usuario para GNOME en `~/.local/share/applications/`.
