# Especificacion: gestor local de sesiones de Codex

## Estado

Implementado y en evolucion.

## Objetivo

Permitir que un usuario de Linux encuentre, entienda, resuma, reabra, archive y limpie sesiones locales de Codex sin tener que inspeccionar manualmente bases SQLite ni recordar rutas antiguas.

## Usuarios principales

- Usuario individual que trabaja con Codex en varios proyectos.
- Usuario que quiere documentar sesiones antiguas antes de retomarlas.
- Usuario que instala la herramienta en varios equipos con distintos `$HOME`.
- Usuario que quiere limpiar ruido de sesiones asociadas a carpetas ya borradas.

## Problema

Codex mantiene historial local, pero la recuperacion manual puede ser confusa:

- las sesiones pueden tener titulos poco utiles,
- la ruta original puede haber cambiado,
- algunas carpetas ya no existen,
- distinguir sesiones activas y archivadas no es evidente,
- generar documentacion requiere trabajo manual,
- abrir la sesion incorrecta puede perder tiempo.

## Alcance funcional

### Listar sesiones

El sistema debe mostrar sesiones locales de Codex en formato tabular con:

- numero seleccionable,
- fecha de actualizacion,
- fecha de inicio,
- tokens,
- estado de resumen,
- ruta abreviada,
- descripcion.

Solo deben mostrarse sesiones bajo `$HOME`, con carpeta existente y origen de trabajo humano reconocible (`cli` o `vscode`).

### Navegar entre vistas

El sistema debe ofrecer una vista inicial con:

- sesiones activas,
- sesiones archivadas,
- resumen de sesiones,
- salida.

Desde cualquier listado debe existir retorno al menu inicial sin cerrar la ventana.

### Filtrar

El usuario debe poder filtrar sesiones por:

- ID,
- ruta,
- titulo,
- primer mensaje.

### Generar resumen

El usuario debe poder generar un resumen de una sesion concreta usando Codex. El resumen debe guardarse en una carpeta local configurable y asociarse al `session_id`.

El resumen debe incluir:

- objetivo,
- trabajo realizado,
- archivos tocados,
- decisiones importantes,
- pendientes,
- riesgos.

El sistema debe crear salida en texto plano y una copia Markdown del mismo resumen.

### Consultar resumen existente

El usuario debe poder abrir la ultima version guardada de un resumen sin regenerarla.

El usuario debe poder abrir el ultimo resumen en el editor o visor predeterminado sin buscar manualmente el fichero.

### Detalles tecnicos

El usuario debe poder ver metadatos completos de una sesion seleccionada: ID, ruta completa, fechas, tokens, estado de resumen y ultimo fichero asociado.

### Reabrir sesion

El usuario debe poder continuar una sesion mediante `codex resume <session_id>` desde la ruta original de trabajo, siempre que exista.

### Archivar y desarchivar

El usuario debe poder archivar y desarchivar sesiones sin borrarlas. Antes de cambiar la base SQLite debe crearse un backup.

### Limpiar rutas inexistentes

El sistema debe ocultar por defecto sesiones cuya carpeta ya no existe y permitir eliminarlas de la base local solo tras confirmacion literal y backup previo.

### Exportar diagnostico

El usuario debe poder exportar un diagnostico local de sesiones a Markdown desde el menu inicial.

El usuario debe poder exportar el listado visible de sesiones a Markdown y CSV.

### Abrir carpetas operativas

El usuario debe poder abrir la carpeta de resumenes y la carpeta de backups desde el menu inicial.

### Vista por proyecto

El usuario debe poder ver las sesiones agrupadas por carpeta/proyecto.

Si una sesion vive dentro de un repositorio Git, debe agruparse por la raiz Git.

### Restauracion asistida

El usuario debe poder restaurar un backup SQLite desde el menu con confirmacion explicita, manteniendo una copia previa de la base reemplazada.

Antes de confirmar, el sistema debe mostrar un resumen del backup seleccionado.

### Modo solo lectura

El usuario debe poder ejecutar el sistema con `CODEX_READ_ONLY=1` para ocultar archivado, desarchivado y limpieza de rutas inexistentes.

### Instalar

El instalador debe:

- detectar Codex,
- preguntar carpeta de salidas en modo interactivo,
- crear lanzador en Escritorio,
- crear entrada de aplicacion GNOME,
- respetar terminal predeterminado cuando sea posible,
- usar terminales alternativos si no existe `xdg-terminal-exec`.

## Fuera de alcance

- Sincronizar historiales entre equipos.
- Editar contenido interno de conversaciones.
- Subir resumenes a servicios externos.
- Borrado masivo sin confirmacion.
- Sustituir a Codex CLI.

## Criterios de aceptacion

- El script arranca sin rutas duras del desarrollador original.
- Una instalacion nueva en otro `$HOME` usa sesiones y salidas de ese usuario.
- Las sesiones con carpetas borradas no aparecen en el listado normal.
- La limpieza de rutas inexistentes crea backup y requiere confirmacion.
- Los backups de limpieza rotan segun `MAX_BACKUPS`.
- El usuario puede volver al menu inicial con `0`.
- El menu se limpia entre pantallas en terminal interactiva.
- El modo solo lectura oculta acciones que modifican SQLite.
- La exportacion de diagnostico crea un fichero Markdown local.
- La opcion de abrir resumen usa `xdg-open` o `CODEX_SUMMARY_OPENER`.
- El instalador genera `Exec=` con fallback de terminal si falta `xdg-terminal-exec`.
- La restauracion asistida exige `RESTAURAR` y queda bloqueada en modo solo lectura.
- La vista por proyecto solo incluye carpetas existentes bajo HOME.
- La comprobacion de privacidad debe ejecutarse en CI.
- El diagnostico de esquema debe avisar sobre indices recomendados si no existen.
- El proyecto conserva tests automatizados sin dependencias externas.
- README y documentacion explican rutas configurables y funcionamiento.

## Riesgos

- Codex puede cambiar el esquema de `state_*.sqlite`.
- Codex puede cambiar el formato o disponibilidad de `codex resume`.
- Algunas instalaciones pueden no tener `xdg-terminal-exec`.
- Resumir sesiones muy grandes puede consumir tiempo o fallar por autenticacion.
- Los nombres de carpetas con caracteres especiales exigen escapado cuidadoso.
