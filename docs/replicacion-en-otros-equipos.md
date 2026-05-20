# Replicacion en otros equipos

## Objetivo

Instalar el mismo sistema en cualquier equipo Linux con Codex CLI para disponer de:

- selector de sesiones,
- resumenes tecnicos,
- reapertura directa de sesiones.

## Requisitos previos

- Linux.
- Bash.
- Python 3.
- Codex CLI instalado y autenticado.
- Entorno grafico con soporte para lanzadores `.desktop`.
- Un terminal grafico disponible.
- `xdg-terminal-exec` si se quiere respetar el terminal predeterminado del sistema.

## Instalacion recomendada

1. Clonar el repositorio publico desde GitHub:

```bash
mkdir -p "$HOME/Proyectos"
cd "$HOME/Proyectos"
git clone https://github.com/jesusgascon/Automatizacion-Codex.git
```

2. Entrar al proyecto:

```bash
cd "$HOME/Proyectos/Automatizacion-Codex"
```

3. Ejecutar el instalador:

```bash
bash instalar.sh
```

4. Cuando pregunte por la carpeta de resumenes:
   - pulsar `Enter` para usar la ruta predeterminada,
   - o escribir una ruta personalizada, por ejemplo `~/Documentos/Codex/Resumenes`.
5. Verificar que aparezca un lanzador en el Escritorio y que `Resumir sesion de Codex` se pueda buscar desde GNOME.

## Resumen rapido para instalar en casa

En el equipo nuevo:

```bash
mkdir -p "$HOME/Proyectos"
cd "$HOME/Proyectos"
git clone https://github.com/jesusgascon/Automatizacion-Codex.git
cd Automatizacion-Codex
bash instalar.sh
```

Despues comprobar:

```bash
bash -n resumir-sesion-codex.sh instalar.sh
python3 -m unittest discover -s tests -v
```

Y despues:

1. mirar en el Escritorio el lanzador `Resumir sesion de Codex.desktop`,
2. abrirlo,
3. si Codex ya esta instalado y autenticado en ese equipo, apareceran las sesiones locales de ese ordenador,
4. si aun no hay sesiones locales, usar primero Codex alli para que exista `~/.codex/state_*.sqlite`.

El instalador adapta automaticamente:

- el `$HOME` del usuario actual,
- la carpeta de Escritorio real,
- el binario de Codex disponible,
- la base local de sesiones de ese equipo,
- la ruta donde se guardan los resumenes.
- una entrada de aplicacion del usuario en `~/.local/share/applications/`.

Durante una instalacion interactiva pregunta donde guardar resumenes, logs y backups. La aplicacion, el ejecutable y la documentacion permanecen en la carpeta donde se clono el repositorio; esa carpeta se elige antes, al hacer `git clone`.

No hace falta tocar rutas manualmente salvo que:

- Codex no este en `PATH`,
- no exista `xdg-terminal-exec`,
- o se quiera forzar una base concreta con `STATE_DB`.

## Que hace `instalar.sh`

- detecta la carpeta de Escritorio,
- copia el lanzador desde plantilla,
- sustituye la ruta absoluta al script,
- marca como ejecutables el script y el lanzador,
- intenta marcar el lanzador como confiable mediante `gio` cuando el entorno lo permite,
- avisa si faltan `python3`, `xdg-terminal-exec` o `codex`,
- crea la carpeta de salida de resumenes.
- pregunta de forma interactiva donde guardar resumenes, logs y backups cuando no se fuerza `CODEX_SUMMARY_DIR`.
- crea una entrada para el menu de aplicaciones del usuario en `~/.local/share/applications/automatizacion-codex.desktop`.

## Alternativa con GitHub CLI

Si ya usas `gh`, tambien puedes clonar con:

```bash
gh repo clone jesusgascon/Automatizacion-Codex
```

Al ser publico, no hace falta iniciar sesion para clonar por HTTPS.

## Si el equipo no tiene `xdg-terminal-exec`

Editar el lanzador y sustituir:

```text
Exec=xdg-terminal-exec -- /ruta/al/script
```

por el terminal disponible, por ejemplo:

```text
Exec=konsole -e /ruta/al/script
Exec=xfce4-terminal -e /ruta/al/script
Exec=xterm -e /ruta/al/script
```

## Variables opcionales

El script permite forzar rutas si hiciera falta:

```bash
CODEX_BIN="/ruta/al/codex" \
STATE_DB="$HOME/.codex/state_X.sqlite" \
CODEX_SUMMARY_DIR="$HOME/Documentos/Codex/Resumenes" \
bash resumir-sesion-codex.sh
```

Uso recomendado:

- solo para diagnostico,
- solo si la autodeteccion no encuentra el recurso correcto,
- o si se quiere guardar la documentacion fuera de la ruta predeterminada del Escritorio.

## Pruebas tras instalar

1. Validar el proyecto:

```bash
bash -n resumir-sesion-codex.sh instalar.sh
python3 -m unittest discover -s tests -v
```

2. Abrir el lanzador.
3. Confirmar que aparece una lista de sesiones.
4. Elegir una sesion conocida.
5. Probar:
   - opcion `1` para generar resumen,
   - opcion `2` para continuar una sesion,
   - opcion `3` para el flujo completo,
   - opcion `5` para leer un resumen existente,
   - opcion `0` para volver sin cerrar la ventana.
6. Confirmar que existen dentro de la carpeta elegida durante la instalacion:

```text
<Carpeta-de-salidas-elegida>/
<Carpeta-de-salidas-elegida>/logs/
```

## Migracion de un equipo a otro

El proyecto se puede copiar tal cual, pero las sesiones no viajan con el script.

Las sesiones dependen de:

- `~/.codex/state_*.sqlite`,
- el contenido real de Codex en cada equipo.

Si se desea continuidad completa entre equipos:

- instalar Codex en ambos,
- transferir o sincronizar el estado de Codex solo si se conoce bien el impacto,
- revisar permisos y compatibilidad de versiones antes de mezclar bases.

## Checklist de mantenimiento

- Revisar cada cierto tiempo si la CLI de Codex cambia de sintaxis.
- Validar que siguen existiendo tablas y columnas esperadas en `threads`.
- Mantener README y documentacion alineados con el script real.
- Conservar logs si se usan para diagnostico; archivarlos si crecen demasiado.
- Consultar [Configuracion y mantenimiento](configuracion-y-mantenimiento.md) para la operacion recurrente.

## Problemas frecuentes

### No se encuentra Codex

Posibles causas:

- no esta instalado,
- esta instalado pero no accesible para aplicaciones graficas,
- no esta bajo `PATH` ni bajo `~/.nvm`.

### No se encuentra la base de sesiones

Posibles causas:

- Codex aun no se ha usado en ese equipo,
- la version futura usa otra ubicacion,
- `$HOME/.codex` no existe.

### El lanzador no abre

Posibles causas:

- falta permiso de ejecucion,
- el entorno grafico no confia aun en el `.desktop`,
- el terminal indicado no existe.

### Se ven descripciones genericas

No es un fallo. Significa que la sesion existe, pero su titulo original no aporta informacion. El selector intenta mostrar proyecto/carpeta y primer mensaje util, o una pista basada solo en la carpeta.
