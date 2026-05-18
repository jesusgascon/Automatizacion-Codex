# Configuracion y mantenimiento

## Objetivo

Este documento concentra la operacion diaria que no pertenece estrictamente a la instalacion inicial:

- configuracion opcional,
- validaciones periodicas,
- mantenimiento de salidas,
- criterios para actualizar el proyecto sin romper el flujo.

## Configuracion por defecto

En uso normal no se necesita configurar nada manualmente.

El script detecta:

1. `codex` mediante `CODEX_BIN`, `PATH` o `~/.nvm/versions/node/*/bin/codex`,
2. la base de sesiones mediante `STATE_DB` o el ultimo `~/.codex/state_*.sqlite`,
3. el Escritorio mediante `xdg-user-dir DESKTOP`, `~/Escritorio` o `~/Desktop`.

Durante una ejecucion interactiva de `instalar.sh`, el instalador pregunta donde guardar resumenes, logs y backups. Si se pulsa `Enter`, usa la ruta predeterminada. El codigo, el ejecutable y la documentacion permanecen en la carpeta donde se clono el repositorio.

## Variables opcionales

| Variable | Valor esperado | Uso recomendado |
| --- | --- | --- |
| `CODEX_BIN` | Ruta absoluta a un ejecutable | Diagnosticar instalaciones de Codex no detectadas automaticamente. |
| `STATE_DB` | Ruta absoluta a una base `state_*.sqlite` | Probar una base concreta si existen varias. |
| `CODEX_SUMMARY_DIR` | Ruta absoluta a una carpeta | Cambiar la ubicacion de resumenes, logs y backups. |
| `MAX_BACKUPS` | Entero positivo | Cambiar la retencion de copias previas al archivado. |

Ejemplo:

```bash
CODEX_BIN="$HOME/.nvm/versions/node/v24.0.0/bin/codex" \
STATE_DB="$HOME/.codex/state_1.sqlite" \
CODEX_SUMMARY_DIR="$HOME/Documentos/Codex/Resumenes" \
MAX_BACKUPS=20 \
bash resumir-sesion-codex.sh
```

Por defecto, si `CODEX_SUMMARY_DIR` no se define, se usa:

```text
<Escritorio>/Documentacion/Codex/Resumenes/
```

## Mantenimiento recomendado

### Tras actualizar el repositorio

Ejecutar:

```bash
git pull --ff-only
bash -n resumir-sesion-codex.sh instalar.sh
python3 -m unittest discover -s tests -v
bash instalar.sh
```

Motivo:

- `git pull --ff-only` evita merges accidentales en una copia de uso personal,
- `bash -n` valida sintaxis,
- los tests cubren regresiones conocidas,
- volver a ejecutar el instalador actualiza el lanzador si cambia la ruta o la plantilla.

### Periodicamente

Revisar:

- que Codex sigue abriendo sesiones con `codex resume <id>`,
- que existe una base `~/.codex/state_*.sqlite`,
- que los logs no crecen sin control,
- que los backups conservados siguen siendo suficientes para tu forma de trabajo,
- que README y manual siguen describiendo el comportamiento real si se cambia el script.

## Gestion de salidas

El proyecto escribe fuera del repositorio:

```text
<Escritorio>/Documentacion/Codex/Resumenes/
├── resumen-codex-<session_id>-YYYYMMDD-HHMMSS.txt
├── logs/
│   └── resumen-codex-<session_id>-YYYYMMDD-HHMMSS.log
└── backups/
    └── state-before-archive-YYYYMMDD-HHMMSS.sqlite
```

Recomendaciones:

- conservar los resumenes que tengan valor documental,
- borrar logs solo despues de comprobar que ya no hacen falta para diagnostico,
- tratar los backups SQLite como datos sensibles,
- no mover manualmente ficheros si se quiere conservar la deteccion automatica de la columna `Resumen`.

## Actualizacion del lanzador

El lanzador se genera desde:

```text
plantillas/resumir-sesion-codex.desktop.template
```

Cada vez que cambie:

- la ruta del proyecto,
- el comando de terminal,
- la plantilla `.desktop`,

conviene volver a ejecutar:

```bash
bash instalar.sh
```

## Criterios para futuras modificaciones

Antes de introducir cambios nuevos, comprobar:

1. si el cambio toca solo lectura o tambien escritura sobre SQLite,
2. si mantiene la reversibilidad por defecto,
3. si exige nueva documentacion o tests,
4. si añade dependencias externas justificadas,
5. si sigue funcionando con rutas de usuario distintas.

## Checklist de salud

- `git status` sin cambios inesperados.
- `bash -n resumir-sesion-codex.sh instalar.sh` correcto.
- `python3 -m unittest discover -s tests -v` correcto.
- El lanzador abre el terminal predeterminado.
- La vista inicial distingue activas y archivadas.
- La columna `Resumen` cambia de `NO` a `SI` tras generar un resumen.
- Archivar crea backup y desarchivar devuelve la sesion al listado activo.
