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

## Plan de implementacion futura

1. Documentar procedimiento de recuperacion desde backup SQLite.
2. Crear workflow adicional de tests Python en GitHub Actions.
3. Anadir comprobacion automatica de privacidad.
4. Ampliar filtros por fecha o estado de resumen.
5. Revisar release notes y GitHub Actions tras cada cambio.

## Validacion obligatoria

```bash
bash -n resumir-sesion-codex.sh instalar.sh
python3 -m unittest discover -s tests -v
```

Si se modifican lanzadores:

```bash
bash instalar.sh
grep '^Exec=' "$HOME/Escritorio/Resumir sesion de Codex.desktop" 2>/dev/null || \
grep '^Exec=' "$HOME/Desktop/Resumir sesion de Codex.desktop"
```
