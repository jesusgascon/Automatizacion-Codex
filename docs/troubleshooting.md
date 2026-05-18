# Troubleshooting

## El lanzador no abre nada

Comprobar:

1. que el fichero `.desktop` tenga permiso de ejecucion,
2. que el entorno grafico confie en el lanzador,
3. que exista `xdg-terminal-exec`,
4. que la ruta del script dentro de `Exec=` sea correcta.

Diagnostico:

```bash
grep '^Exec=' "$HOME/Escritorio/Resumir sesion de Codex.desktop"
xdg-terminal-exec --print-id
```

Si GNOME lo muestra como archivo normal o pide confianza:

```bash
gio set "$HOME/Escritorio/Resumir sesion de Codex.desktop" metadata::trusted true
```

## Aparece `No se encuentra Codex`

Comprobar:

```bash
command -v codex
ls -l "$HOME/.local/bin/codex" "$HOME/.npm-global/bin/codex" "$HOME/node_modules/.bin/codex" 2>/dev/null
find "$HOME/.nvm/versions/node" -path '*/bin/codex' -executable 2>/dev/null
```

Soluciones posibles:

- instalar Codex CLI,
- asegurar que el binario sea ejecutable,
- exportar `CODEX_BIN=/ruta/al/codex` para una prueba puntual,
- si `command -v codex` funciona en una terminal normal pero el lanzador no, reinstalar con:

```bash
CODEX_BIN="$(command -v codex)" bash instalar.sh
```

## Aparece `No se encuentra la base local de sesiones`

Comprobar:

```bash
find "$HOME/.codex" -maxdepth 1 -type f -name 'state_*.sqlite'
```

Posibles causas:

- Codex aun no se uso en ese usuario,
- la estructura interna cambio en una version futura,
- se esta ejecutando con otro usuario distinto.

## No aparecen sesiones esperadas

El selector muestra solo:

- sesiones no archivadas,
- sesiones bajo `$HOME`,
- origen `cli` o `vscode`.

Si una sesion no aparece, revisar esos criterios antes de asumir perdida de datos.

## Se ven muchas sesiones `Sesion sin titulo util`

No es un error. Significa que Codex guardo titulos poco informativos como:

- `.`
- `exit`
- cadena vacia.

El script no las oculta para no impedir su recuperacion.

## He archivado una sesion y ya no aparece

Es el comportamiento esperado.

Al abrir el lanzador:

1. elegir `a` en la vista inicial,
2. seleccionar la sesion archivada,
3. usar `4) Desarchivar sesion`.

Archivar no borra la sesion; solo la quita del listado activo.

## El resumen no se genera

Revisar:

1. ruta indicada tras `Log tecnico guardado en`,
2. contenido del `.log`,
3. conectividad y autenticacion de Codex,
4. existencia del directorio original de la sesion.

## La columna `Resumen` marca `NO`

Significa que no existe un resumen nuevo asociado de forma exacta a esa sesion.

Para crearlo:

1. seleccionar la sesion,
2. elegir `1) Generar resumen`,
3. volver al listado,
4. comprobar que la columna cambie a `SI`.

Los resumenes antiguos sin ID de sesion en el nombre no se cuentan automaticamente para evitar asociaciones dudosas.

## Se genera resumen pero no abre la sesion

Posibles causas:

- el `cwd` original ya no existe,
- se movio o borro el proyecto,
- Codex no puede reanudar esa sesion por incompatibilidad o estado corrupto.

## El lanzador funciona en terminal pero no desde el Escritorio

Suele indicar diferencia de entorno:

- `PATH` distinto,
- `nvm` no inicializado en aplicaciones graficas,
- terminal grafico distinto.

Este proyecto reduce ese problema buscando Codex tambien bajo `~/.nvm`.

## El script funciona en un equipo y en otro no

Revisar:

- ruta del escritorio,
- terminal disponible,
- version de Codex,
- presencia de Python 3,
- existencia de `~/.codex/state_*.sqlite`.

## Como probar sin generar resumen real

Lanzar el script y escribir una opcion invalida:

```bash
printf '0\n\n' | ./resumir-sesion-codex.sh
```

Eso valida:

- deteccion de dependencias,
- lectura SQLite,
- renderizado del selector.
