# Plan tecnico: gestor local de sesiones de Codex

## Arquitectura actual

```text
Lanzador .desktop / GNOME
  |
  v
instalacion local del repositorio
  |
  v
resumir-sesion-codex.sh
  |
  |-- deteccion de codex
  |-- deteccion de state_*.sqlite
  |-- menu de consola
  |-- consultas SQLite mediante Python stdlib
  |-- backups locales
  |
  +-- codex exec resume --ephemeral -> resumen + log
  +-- codex resume <session_id>      -> sesion interactiva
```

## Decisiones tecnicas

### Bash como orquestador

Bash permite mantener la herramienta ligera, instalable sin compilacion y cercana al entorno Linux de escritorio.

### Python solo para SQLite

Se usa Python 3 con `sqlite3` de la libreria estandar para evitar depender del binario `sqlite3`, que no siempre esta instalado.

### Variables de entorno

Se mantienen puntos de extension:

- `CODEX_BIN`,
- `STATE_DB`,
- `CODEX_SUMMARY_DIR`,
- `MAX_BACKUPS`,
- `CODEX_READ_ONLY`,
- `CODEX_SUMMARY_OPENER`,
- `CODEX_PATH_OPENER`,
- `NO_COLOR`.

### Interfaz de consola

Se prioriza claridad sobre complejidad:

- cajas en cabeceras y paneles,
- limpieza de pantalla solo si stdout es terminal,
- color solo si stdout es terminal y `NO_COLOR` no esta definido,
- degradacion ASCII si el entorno no parece UTF-8.

### Datos locales

El repositorio no guarda datos generados. Los resumenes, logs y backups viven en la carpeta elegida por el usuario.

## Mejoras recomendadas por analisis SDD

### 1. Modo diagnostico exportable

Convertir el resumen de sesiones en una salida opcional exportable a texto o Markdown.

Valor:

- ayuda a soporte,
- permite documentar estado del equipo,
- no expone contenido completo de sesiones.

Estado:

- implementado como exportacion Markdown desde el menu inicial con `e`.

### 2. Tests de presentacion de consola

Anadir tests especificos para:

- cajas Unicode,
- fallback ASCII,
- no imprimir codigos ANSI cuando stdout no es TTY,
- limpieza de pantalla solo en TTY.

Valor:

- evita regresiones visuales,
- mantiene compatibilidad con logs y CI.

Estado:

- implementado con tests para Unicode, ASCII y ausencia de ANSI fuera de TTY.

### 3. Guia SDD para nuevas funciones

Mantener `.specify/` como fuente de verdad para futuras mejoras.

Valor:

- cada cambio nuevo parte de requisitos y criterios de aceptacion,
- reduce cambios improvisados,
- mejora la trazabilidad en GitHub.

### 4. Soporte de exportacion de resumenes

Anadir salida Markdown opcional, manteniendo texto plano por defecto.

Valor:

- mejor lectura en GitHub,
- mejor integracion con documentacion,
- no rompe usuarios actuales.

Estado:

- implementado como copia `.md` automatica junto al `.txt`.

### 5. Validacion de esquema SQLite

Antes de consultar, validar que la tabla `threads` tiene columnas esperadas.

Valor:

- errores mas claros si Codex cambia internamente,
- mejor troubleshooting.

Estado:

- implementado.

### 6. Modo solo lectura

Anadir `CODEX_READ_ONLY=1` para ocultar acciones que cambian SQLite.

Valor:

- util en auditorias,
- reduce riesgo en equipos compartidos.

Estado:

- implementado con `CODEX_READ_ONLY=1`.

### 7. Rotacion de backups de limpieza

Aplicar `MAX_BACKUPS` tambien a backups creados antes de limpiar rutas inexistentes.

Valor:

- reduce acumulacion de copias sensibles,
- mantiene coherencia con backups de archivado.

Estado:

- implementado.

### 8. Apertura directa de resumenes

Permitir abrir el ultimo resumen asociado a una sesion con `xdg-open` o con un opener definido por `CODEX_SUMMARY_OPENER`.

Valor:

- reduce navegacion manual por carpetas,
- mejora el uso diario del lanzador como indice documental.

Estado:

- implementado.

### 9. Fallback de terminales

Si falta `xdg-terminal-exec`, el instalador genera el lanzador con el primer terminal disponible entre `kgx`, `gnome-terminal`, `konsole`, `xfce4-terminal` y `xterm`.

Valor:

- mejora compatibilidad en escritorios sin portal de terminal predeterminado,
- reduce ajustes manuales tras instalar.

Estado:

- implementado.

### 10. Pruebas SQLite ampliadas

Cubrir titulos con tabs/saltos de linea y seleccion automatica de la base `state_*.sqlite` mas reciente.

Valor:

- evita regresiones con metadatos reales de Codex,
- refuerza portabilidad entre equipos con varias bases.

Estado:

- implementado.

### 11. Carpetas operativas desde menu

Abrir la carpeta de resumenes o backups desde el menu inicial usando `xdg-open` o `CODEX_PATH_OPENER`.

Estado:

- implementado.

### 12. Detalles tecnicos de sesion

Mostrar ID completo, ruta completa, fechas, tokens y ultimo resumen asociado.

Estado:

- implementado.

### 13. Restauracion asistida

Permitir restaurar backups SQLite desde menu con seleccion, confirmacion literal y backup previo de la base reemplazada.

Estado:

- implementado.

### 14. Vista por proyecto

Agrupar sesiones visibles por carpeta/proyecto con conteo y tokens acumulados.

Estado:

- implementado.

### 15. Workflow Python formal

Separar tests Python de ShellCheck y ejecutarlos en matriz 3.11, 3.12 y 3.13.

Estado:

- implementado.

### 16. Privacidad automatica

Escanear el repositorio en local y CI para detectar rutas personales reales, bases SQLite, logs, resumenes generados e IDs de sesion.

Estado:

- implementado con `scripts/privacy_check.py` y workflow `privacy`.

### 17. Exportacion de listado

Exportar sesiones visibles a Markdown y CSV desde el menu inicial.

Estado:

- implementado.

### 18. Prueba de backup antes de restaurar

Comparar la base actual con el backup seleccionado antes de exigir confirmacion `RESTAURAR`.

Estado:

- implementado.

### 19. Agrupacion por raiz Git

La vista por proyecto usa la raiz Git cuando existe para agrupar subcarpetas de un mismo repositorio.

Estado:

- implementado.

### 20. Diagnostico SQLite ampliado

Ademas de columnas obligatorias, se avisa si no hay indices sobre columnas recomendadas para consultas frecuentes.

Estado:

- implementado.

### 21. Ayuda contextual ampliada

Anadir ayuda con `?` en listado y acciones de sesion, ademas del submenu de herramientas.

Estado:

- implementado.

### 22. Exportacion e importacion de configuracion

Guardar los ajustes locales detectados en JSON e importarlos para la ejecucion actual.

Estado:

- implementado.

### 23. Comprobacion local de release

Agrupar sintaxis Bash, tests Python y privacidad en `scripts/release_check.py`.

Estado:

- implementado.

### 24. Auditoria de compatibilidad Codex CLI

Verificar version disponible, comandos `resume` y `exec`, rutas detectadas y esquema SQLite desde el submenu de herramientas.

Estado:

- implementado.

## Plan de implementacion futura

1. Ampliar filtros por fecha o estado de resumen.
2. Ampliar pruebas con bases SQLite grandes.
3. Revisar compatibilidad manualmente tras cambios mayores de Codex CLI.

## Validacion obligatoria

```bash
python3 scripts/release_check.py
```

Si se modifican lanzadores:

```bash
bash instalar.sh
grep '^Exec=' "$HOME/Escritorio/Resumir sesion de Codex.desktop" 2>/dev/null || \
grep '^Exec=' "$HOME/Desktop/Resumir sesion de Codex.desktop"
```
