# Changelog

## Unreleased

## 1.2.2 - 2026-05-20

### Changed

- El diagnostico de sesiones ya no muestra atajos que no se pueden usar dentro de esa pantalla informativa.
- Las sesiones con titulos poco utiles usan una descripcion de una linea basada en el primer mensaje o la carpeta de trabajo.

## 1.2.1 - 2026-05-20

### Changed

- Menu principal reorganizado por frecuencia de uso, con herramientas en submenu propio.
- Accesos de diagnostico, exportacion, carpetas y restauracion movidos al submenu de herramientas.

### Fixed

- Los tests del instalador ya no heredan stdin interactivo, evitando esperas de `Enter` durante `python3 -m unittest discover`.

## 1.2.0 - 2026-05-19

### Added

- Capa documental de Spec-Driven Development inspirada en GitHub Spec Kit.
- Constitucion del proyecto con principios de privacidad, portabilidad, reversibilidad y validacion.
- Especificacion funcional, plan tecnico y tareas trazables en `.specify/`.
- Guia `docs/spec-driven-development.md` para aplicar el flujo `Spec -> Plan -> Tasks -> Implement`.
- Validacion previa del esquema SQLite de Codex antes de listar sesiones.
- Tests de render de consola para cajas Unicode, fallback ASCII y ausencia de ANSI fuera de TTY.
- Modo solo lectura `CODEX_READ_ONLY=1`.
- Copia Markdown automatica de cada resumen generado.
- Exportacion Markdown del diagnostico de sesiones desde el menu inicial.
- Rotacion de backups de limpieza de rutas inexistentes.
- Opcion para abrir el resumen en el editor o visor predeterminado.
- Fallback de terminales en el instalador si no existe `xdg-terminal-exec`.
- Procedimiento documentado de recuperacion desde backups SQLite.
- Tests SQLite adicionales para titulos con caracteres raros y deteccion de la base mas reciente.
- Apertura de carpetas de resumenes y backups desde el menu inicial.
- Restauracion asistida de backups SQLite con confirmacion y backup previo de la base reemplazada.
- Vista agrupada por proyecto/carpeta.
- Detalles tecnicos completos por sesion.
- Workflow Python formal con matriz 3.11, 3.12 y 3.13.
- Comprobacion automatica de privacidad mediante `scripts/privacy_check.py` y workflow dedicado.
- Exportacion del listado de sesiones visibles a Markdown y CSV.
- Vista por proyecto mejorada con agrupacion por raiz Git cuando existe.
- Restauracion asistida con resumen previo del backup seleccionado.
- Diagnostico de esquema SQLite con aviso de indices recomendados.

## 1.1.0 - 2026-05-18

### Added

- Filtro textual de sesiones por ID, ruta, titulo o primer mensaje.
- Logo vectorial propio e integracion visual en README, manual y lanzador.
- Seccion de creditos del proyecto.
- Carpeta de salida configurable mediante `CODEX_SUMMARY_DIR`.
- Instalador interactivo para elegir la carpeta de resumenes, logs y backups.
- Entrada de aplicacion de usuario para GNOME en `~/.local/share/applications/`.
- Limpieza confirmada con `x` de sesiones con rutas inexistentes.

### Changed

- Deteccion ampliada de Codex usando `PATH`, shell de login, `npm prefix -g`, rutas habituales, instalaciones de sistema y `nvm`.
- Documentacion actualizada para distinguir entre carpeta de salida elegida y ruta predeterminada.
- Resumen explicativo de sesiones desde la vista inicial.

### Fixed

- Prompt interactivo del instalador para que se muestre y no contamine la ruta elegida.

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
