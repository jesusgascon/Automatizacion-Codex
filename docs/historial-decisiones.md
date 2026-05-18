# Historial de decisiones

## 1. Usar un unico lanzador

Decision:

- concentrar resumen y reapertura en una sola herramienta.

Motivo:

- reduce iconos en el Escritorio,
- evita duplicidad funcional,
- centraliza mantenimiento.

## 2. Leer SQLite en vez de pedir IDs manuales

Decision:

- consultar la base local de Codex.

Motivo:

- el usuario no necesita conocer UUIDs,
- se aprovecha el estado ya mantenido por Codex,
- permite ordenar por uso reciente.

## 3. No ocultar sesiones con titulos pobres

Decision:

- mostrarlas como `Sesion sin titulo util` y separar fecha de inicio + tokens en columnas dedicadas.

Motivo:

- una sesion con mal titulo puede seguir siendo importante,
- ocultarla reduciria recuperabilidad,
- enriquecerla visualmente permite distinguir una sesion larga de una apertura accidental sin perder datos.

## 4. Separar resumen y log

Decision:

- `.txt` para salida util,
- `.log` para detalle tecnico.

Motivo:

- mejor experiencia de usuario,
- mejor diagnostico,
- menos ruido en pantalla.

## 5. Usar `--ephemeral` al resumir

Decision:

- evitar que el acto de resumir cree nuevas sesiones persistentes.

Motivo:

- no contaminar el historial,
- mantener semantica limpia,
- separar documentacion de trabajo real.

## 6. Hacer portable la deteccion de rutas

Decision:

- eliminar dependencias de rutas de usuario concretas,
- detectar Codex, base y Escritorio automaticamente.

Motivo:

- replicar el sistema en otros equipos,
- reducir mantenimiento,
- evitar roturas al actualizar Node o Codex.

## 7. Mantener instalador pequeno

Decision:

- `instalar.sh` solo crea lo necesario.

Motivo:

- facilitar auditoria,
- evitar magia oculta,
- permitir adaptar el lanzador a otros terminales.

## 8. Archivar antes que borrar

Decision:

- ofrecer archivado y desarchivado desde el menu,
- no ofrecer borrado real.

Motivo:

- limpiar el listado activo sin perder informacion,
- mantener reversibilidad,
- evitar tocar datos de forma destructiva sin soporte explicito de la CLI.

## 9. Navegacion sin cerrar la ventana

Decision:

- usar `0` para volver atras,
- usar `q` para salir desde el menu inicial.

Motivo:

- evitar cerrar y reabrir el lanzador para corregir una eleccion,
- permitir explorar activas y archivadas en una sola ejecucion,
- mejorar ergonomia sin aumentar riesgo.

## 10. Asociar resumenes por ID de sesion

Decision:

- incluir el `session_id` en el nombre de los resumenes nuevos,
- mostrar columna `Resumen` con `SI` o `NO`.

Motivo:

- saber de un vistazo que sesiones ya estan documentadas,
- evitar adivinar por fecha o por carpeta,
- mantener una relacion exacta entre conversacion y resumen.

## 11. Ver resumenes existentes sin regenerarlos

Decision:

- anadir una opcion para mostrar el ultimo resumen asociado.

Motivo:

- `SI` confirma que existe, pero no permite consultarlo,
- regenerar solo para leerlo seria innecesario,
- mejora el uso diario del lanzador como indice de sesiones.
