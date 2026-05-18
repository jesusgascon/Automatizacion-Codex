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

## Como encuentro una sesion cuando hay muchas?

Desde el listado pulsa `f` y escribe texto de la ruta, del titulo, del primer mensaje o del ID. Para volver al listado completo, pulsa `l`.

## Por que ya no aparece una sesion antigua?

Si borraste o moviste la carpeta original, la sesion se oculta por defecto para mantener limpio el listado. Si quieres eliminar esas entradas antiguas de la base local, pulsa `x` desde el listado y confirma con `LIMPIAR`; antes se crea un backup.

## Donde se guardan los backups?

En `<Escritorio>/Documentacion/Codex/Resumenes/backups/`. Se crean antes de archivar o desarchivar y por defecto se conservan los 10 mas recientes.

## Puedo guardar los resumenes en otra carpeta?

Si. Durante `bash instalar.sh`, el instalador te pregunta la carpeta si lo ejecutas de forma interactiva. Tambien puedes definir `CODEX_SUMMARY_DIR` antes de ejecutar el instalador o el script, por ejemplo:

```bash
CODEX_SUMMARY_DIR="$HOME/Documentos/Codex/Resumenes" bash instalar.sh
```

## Puedo elegir desde el instalador donde guardar el ejecutable y la documentacion?

No durante la instalacion. El ejecutable, el logo y la documentacion forman parte del repositorio y permanecen en la carpeta donde lo clonaste. Si quieres otra ubicacion para la aplicacion, elige esa carpeta antes de ejecutar `git clone`.

## Aparece en el lanzador de aplicaciones de GNOME?

Si. `instalar.sh` crea `~/.local/share/applications/automatizacion-codex.desktop`, de modo que se puede buscar como `Resumir sesion de Codex` desde GNOME.

## Que debo hacer despues de actualizar desde GitHub?

Ejecuta:

```bash
git pull --ff-only
bash -n resumir-sesion-codex.sh instalar.sh
python3 -m unittest discover -s tests -v
bash instalar.sh
```

Asi validas el codigo y regeneras el lanzador si cambio la plantilla o la ruta.
