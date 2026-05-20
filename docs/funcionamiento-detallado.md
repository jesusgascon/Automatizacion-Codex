# Funcionamiento detallado

## 1. Inicio

El usuario ejecuta el lanzador:

```text
Resumir sesion de Codex.desktop
```

El lanzador abre:

```bash
xdg-terminal-exec -- /ruta/al/proyecto/resumir-sesion-codex.sh
```

## 2. Deteccion automatica

### Binario de Codex

Orden de prioridad:

1. Variable de entorno `CODEX_BIN`, si existe y apunta a un ejecutable.
2. `command -v codex`.
3. Shell de login del usuario con `type -P codex`.
4. Prefijo global real de npm mediante `npm prefix -g`.
5. Rutas frecuentes:
   - `~/.local/bin/codex`,
   - `~/.npm-global/bin/codex`,
   - `~/node_modules/.bin/codex`,
   - `/usr/local/bin/codex`,
   - `/usr/bin/codex`.
6. Ultimo ejecutable hallado bajo `~/.nvm/versions/node/*/bin/codex`, incluyendo enlaces simbolicos.

### Base de sesiones

Orden de prioridad:

1. Variable de entorno `STATE_DB`, si existe y apunta a un fichero.
2. Ultimo fichero `state_*.sqlite` encontrado en `~/.codex`.

### Carpeta de Escritorio

Orden de prioridad:

1. `xdg-user-dir DESKTOP`.
2. `~/Escritorio`.
3. `~/Desktop`.

### Carpeta de salidas

Orden de prioridad:

1. Variable `CODEX_SUMMARY_DIR`, si se define.
2. Ruta elegida durante `instalar.sh`; si se pulsa `Enter`, `<Escritorio>/Documentacion/Codex/Resumenes/`.

## 3. Lectura del historial de sesiones

La base SQLite se consulta desde Python porque:

- `sqlite3` forma parte de la libreria estandar,
- se evita depender del binario externo `sqlite3`,
- el formateo de fechas y titulos queda centralizado.

Consulta logica:

```sql
select id, cwd, title, first_user_message, created_at, updated_at, tokens_used
from threads
where cwd = "$HOME" or cwd like "$HOME/%"
  and archived = 0
  and source in ('cli', 'vscode')
order by updated_at desc;
```

## 4. Presentacion del selector

Cada sesion muestra:

- numero de opcion,
- fecha y hora de ultima actualizacion,
- fecha y hora de inicio,
- tokens acumulados,
- directorio de trabajo,
- si existe resumen asociado,
- titulo normalizado.

Si el titulo original no aporta informacion, el selector combina proyecto/carpeta y primer mensaje util. Si tampoco hay primer mensaje util, usa la carpeta de trabajo como pista, por ejemplo `Automatizacion-Codex`.

Las sesiones cuyo directorio original ya no existe se ocultan por defecto. Desde el listado se puede pulsar `x` para eliminarlas de la base local tras confirmacion explicita y backup previo.

Si `CODEX_READ_ONLY=1`, la opcion `x` se oculta y la limpieza queda deshabilitada.

Ejemplo:

```text
1   2026-05-18 11:03  2026-05-18 08:48  23.072.099  NO  ~/Escritorio  Automatizacion-Codex: revisar menu
```

## 5. Seleccion de accion

Opciones:

```text
1) Generar resumen
2) Abrir sesion para continuar
3) Generar resumen y despues abrir sesion
4) Archivar sesion
5) Ver ultimo resumen guardado
6) Abrir resumen en editor predeterminado
7) Ver detalles tecnicos
0) Volver al listado de sesiones
```

La pantalla inicial se reserva para acciones frecuentes: sesiones activas, sesiones archivadas, vista por proyecto, herramientas y salida. En la vista de archivadas, la opcion `4` pasa a ser `Desarchivar sesion`.
Desde el listado de sesiones, `0` vuelve al menu inicial. Desde el menu inicial, `q` sale del lanzador.

Desde el submenu `h) Herramientas`:

- `d`: muestra resumen de sesiones,
- `e`: exporta diagnostico,
- `l`: exporta el listado visible de sesiones a Markdown y CSV,
- `o`: abre la carpeta de resumenes,
- `b`: abre la carpeta de backups,
- `r`: inicia restauracion asistida desde backup SQLite,
- `0`: vuelve al menu inicial.

Desde el menu inicial, `p` muestra sesiones agrupadas por carpeta/proyecto.

La vista por proyecto agrupa por raiz Git cuando la carpeta de la sesion pertenece a un repositorio; si no hay `.git`, agrupa por carpeta exacta.

Desde el listado tambien se puede:

- pulsar `f` para filtrar por texto,
- buscar sobre ID, ruta, titulo o primer mensaje,
- pulsar `l` para limpiar el filtro activo,
- pulsar `x` para limpiar sesiones con ruta inexistente.

La opcion `6` usa `CODEX_SUMMARY_OPENER` si esta definido; si no, intenta `xdg-open`.
La opcion `7` muestra ID completo, ruta completa, fechas, tokens y ultimo resumen asociado.

El resumen explicativo informa:

- cuantas sesiones hay en la base,
- cuantas estan bajo `$HOME`,
- cuantas conservan carpeta existente,
- cuantas quedan visibles en activas y archivadas,
- cuantas sesiones tecnicas internas se ocultan.

Archivar:

- crea antes un backup local de la base SQLite,
- modifica `archived = 1`,
- rellena `archived_at`,
- oculta la sesion del listado activo,
- no elimina la conversacion ni sus ficheros de rollout.

## 6. Generacion del resumen

### Por que `exec resume`

Se usa `exec resume` porque:

- trabaja de forma no interactiva,
- permite mandar un prompt concreto,
- permite capturar la ultima respuesta en un archivo con `-o`.

### Por que `--ephemeral`

Se usa `--ephemeral` porque:

- el objetivo es documentar una sesion ya existente,
- no interesa crear otra sesion nueva solo por resumir,
- se reduce ruido en el historial.

### Por que `-C "$cwd"`

Se usa el directorio original de la sesion para:

- mantener contexto coherente,
- respetar el entorno del proyecto,
- evitar que Codex interprete la sesion desde otra carpeta.

Antes de resumir se valida que `cwd` siga existiendo. Si el proyecto fue movido o borrado, la operación se cancela con un mensaje explícito.

### Separacion entre resumen y log

El resumen limpio va a `.txt`.

La salida tecnica completa de Codex va a `.log`.

Ventajas:

- la terminal queda legible,
- el usuario recibe una vista previa inmediata,
- si algo falla, queda traza suficiente para diagnosticar.

### Asociacion entre sesion y resumen

Los resumenes nuevos se nombran asi:

```text
resumen-codex-<session_id>-YYYYMMDD-HHMMSS.txt
```

Eso permite que el listado marque `SI` o `NO` en la columna `Resumen`.

Cuando una sesion ya tiene resumen, la opcion `5` muestra el ultimo resumen asociado sin regenerarlo.

Los resumenes antiguos creados antes de esta convencion pueden existir en disco, pero no se consideran asociados automaticamente porque no contienen el ID de sesion.

### Backups antes de archivar

Antes de archivar o desarchivar, el script crea:

```text
<Carpeta-de-salidas-elegida>/backups/state-before-archive-YYYYMMDD-HHMMSS.sqlite
```

Esto refuerza la reversibilidad de la unica operación que modifica la base local de Codex.

Por defecto se conservan los 10 backups más recientes. El número puede ajustarse con `MAX_BACKUPS`.

La misma rotacion se aplica a los backups creados antes de limpiar sesiones con rutas inexistentes.

## 7. Reapertura interactiva

Cuando se elige abrir:

1. el script hace `cd "$cwd"`,
2. ejecuta `codex resume "$sid"`,
3. usa `exec` para sustituir el proceso Bash por Codex.

Resultado:

- la terminal pasa directamente a la sesion real,
- no queda un proceso intermedio innecesario.

## 8. Codigos de error

Casos tratados:

- binario ausente,
- base ausente,
- lista vacia,
- seleccion invalida,
- opcion invalida,
- error al generar resumen,
- directorio original inaccesible.

## 9. Salidas creadas

Ejemplo:

```text
<Carpeta-de-salidas-elegida>/
├── resumen-codex-<session_id>-20260518-104807.txt
├── logs/
│   └── resumen-codex-<session_id>-20260518-104807.log
└── backups/
    └── state-before-archive-20260518-104807.sqlite
```

## 10. Que no hace

- No borra sesiones.
- No exporta conversaciones completas.
- No modifica configuracion de Codex.
- No sincroniza entre equipos.
- No reemplaza un sistema de backup.
- No deduce proyectos si el `cwd` ya no existe.
