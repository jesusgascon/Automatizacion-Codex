# Arquitectura

## Vision general

El sistema esta formado por tres capas:

1. Interfaz de acceso:
   - lanzador `.desktop` visible en el Escritorio.
2. Orquestacion:
   - script Bash `resumir-sesion-codex.sh`.
3. Persistencia:
   - base SQLite local de Codex,
   - resumenes `.txt`,
   - logs `.log`.

```text
Usuario
  |
  v
Lanzador .desktop
  |
  v
Script Bash
  |-- detecta binario codex
  |-- detecta state_*.sqlite
  |-- consulta SQLite mediante Python
  |-- muestra selector
  |
  +--> codex exec resume --ephemeral --> resumen .txt + log .log
  |
  +--> codex resume <session_id> --> sesion interactiva
```

## Modulos logicos del script

### 1. Deteccion del entorno

Funciones:

- `detect_codex_bin`
- `detect_state_db`
- `detect_desktop_dir`

Responsabilidad:

- evitar rutas duras,
- permitir replicacion entre usuarios y equipos,
- soportar instalaciones de Codex tanto globales como via `nvm`.

### 2. Validaciones previas

El script detiene la ejecucion si:

- no existe el binario de Codex,
- no existe ninguna base `state_*.sqlite`.

Eso evita fallos posteriores mas ambiguos.

### 3. Consulta de sesiones

Se usa Python 3 con `sqlite3` sobre la tabla `threads`.

Campos utilizados:

- `id`
- `cwd`
- `title`
- `first_user_message`
- `updated_at`

Filtros:

- `cwd like "$HOME%"`
- `archived = 0`
- `source in ('cli', 'vscode')`

Orden:

- `updated_at desc`

### 4. Normalizacion visual

Algunos hilos guardan como titulo:

- cadena vacia,
- `.`,
- `exit`.

Esos casos se muestran como `Sesion sin titulo util`.

Motivo:

- no eliminarlos,
- conservar trazabilidad,
- mejorar la lectura humana.

### 5. Acciones disponibles

#### Generar resumen

Comando base:

```bash
codex exec resume "$sid" \
  --skip-git-repo-check \
  --ephemeral \
  -C "$cwd" \
  -o "$OUT" \
  "Resume en espanol..."
```

Efecto:

- reabre la sesion solo para extraer contexto,
- genera la ultima respuesta del agente en un archivo,
- no persiste una nueva sesion adicional.

#### Abrir para continuar

Comando base:

```bash
codex resume "$sid"
```

Efecto:

- vuelve a la sesion interactiva real,
- conserva el contexto original.

#### Resumir y abrir

Secuencia:

1. genera resumen,
2. muestra vista previa,
3. espera Enter,
4. abre la sesion.

## Persistencia de salidas

### Resumenes

Ruta:

```text
<Escritorio>/Documentacion/Codex/Resumenes/
```

Formato:

```text
resumen-codex-YYYYMMDD-HHMMSS.txt
```

### Logs

Ruta:

```text
<Escritorio>/Documentacion/Codex/Resumenes/logs/
```

Formato:

```text
resumen-codex-YYYYMMDD-HHMMSS.log
```

## Seguridad y reversibilidad

- No borra sesiones.
- No modifica la base SQLite.
- Solo lee metadatos y lanza comandos oficiales de Codex.
- No altera proyectos origen.
- Los resumenes son salidas nuevas, separadas del historial real.

## Dependencias externas

- Bash.
- `find`, `sort`, `tail`, `sed`.
- Python 3.
- `sqlite3` de la libreria estandar de Python.
- Codex CLI.
- `xdg-user-dir` opcional.
- `xdg-terminal-exec` para abrir el terminal predeterminado desde el lanzador.

## Riesgos tecnicos

- Cambio de esquema SQLite por parte de Codex.
- Cambio de CLI o subcomandos de Codex.
- Instalaciones no compatibles con `gnome-terminal`.
- Sesiones antiguas con metadatos escasos.
