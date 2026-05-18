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

1. Clonar el repositorio privado desde GitHub:

```bash
mkdir -p "$HOME/Proyectos"
cd "$HOME/Proyectos"
gh repo clone jesusgascon/Automatizacion-Codex
```

2. Entrar al proyecto:

```bash
cd "$HOME/Proyectos/Automatizacion-Codex"
```

3. Ejecutar el instalador:

```bash
bash instalar.sh
```

4. Verificar que aparezca un lanzador en el Escritorio.

## Que hace `instalar.sh`

- detecta la carpeta de Escritorio,
- copia el lanzador desde plantilla,
- sustituye la ruta absoluta al script,
- marca como ejecutables el script y el lanzador,
- intenta marcar el lanzador como confiable mediante `gio` cuando el entorno lo permite,
- avisa si faltan `python3`, `xdg-terminal-exec` o `codex`,
- crea la carpeta de salida de resumenes.

## Si el repositorio sigue siendo privado

Antes de clonar en el equipo nuevo:

```bash
gh auth login -h github.com
```

Después:

```bash
gh repo clone jesusgascon/Automatizacion-Codex
```

Si prefieres `git clone` por HTTPS, el equipo debe tener credenciales válidas para acceder al repositorio privado.

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
bash resumir-sesion-codex.sh
```

Uso recomendado:

- solo para diagnostico,
- solo si la autodeteccion no encuentra el recurso correcto.

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
6. Confirmar que existen:

```text
<Escritorio>/Documentacion/Codex/Resumenes/
<Escritorio>/Documentacion/Codex/Resumenes/logs/
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

### Se ven sesiones con `Sesion sin titulo util`

No es un fallo. Significa que la sesion existe, pero su titulo original no aporta informacion.
