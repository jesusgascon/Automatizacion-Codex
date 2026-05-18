# FAQ

## Se suben mis sesiones a GitHub?

No. El proyecto publica codigo y documentacion, no tu base local ni tus resumenes personales.

## Funciona con otro usuario distinto?

Si. El script usa `$HOME` y detecta rutas automaticamente.

## Funciona con otro Codex?

Si, siempre que ese equipo tenga Codex CLI instalado, autenticado y con sesiones locales disponibles.

## Se borran sesiones?

No. El menu ofrece archivado reversible, no borrado destructivo.

## Por que una sesion muestra `Sesion sin titulo util`?

Porque Codex guardo un titulo poco informativo, por ejemplo `.` o `exit`.

## Por que una sesion marca `NO` en `Resumen`?

Porque aun no existe un resumen asociado por ID de sesion. Selecciona la sesion y usa `1) Generar resumen`.

## Puedo consultar un resumen sin regenerarlo?

Si. Selecciona la sesion y usa `5) Ver ultimo resumen guardado`.

## Donde se guardan los backups?

En `<Escritorio>/Documentacion/Codex/Resumenes/backups/`. Se crean antes de archivar o desarchivar y por defecto se conservan los 10 mas recientes.

## Que debo hacer despues de actualizar desde GitHub?

Ejecuta:

```bash
git pull --ff-only
bash -n resumir-sesion-codex.sh instalar.sh
python3 -m unittest discover -s tests -v
bash instalar.sh
```

Asi validas el codigo y regeneras el lanzador si cambio la plantilla o la ruta.
