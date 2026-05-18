# Automatizacion-Codex

Proyecto local para seleccionar sesiones de Codex, resumirlas y reabrirlas desde un unico lanzador de escritorio.

## Objetivo

Resolver tres necesidades operativas:

1. Ver las sesiones de Codex disponibles en el equipo sin tener que recordar rutas ni UUID.
2. Generar un resumen tecnico reutilizable de una sesion cerrada.
3. Reabrir una sesion concreta para continuar trabajando desde el mismo punto.
4. Archivar sesiones para limpiar el listado sin borrarlas.

## Componentes

- `resumir-sesion-codex.sh`
  Script principal. Lee la base local de Codex, presenta el selector y ejecuta la accion elegida.
- `Resumir sesion de Codex.desktop`
  Lanzador grafico ubicado en el Escritorio. Abre el script con `xdg-terminal-exec`, respetando el terminal predeterminado del sistema.
- `Documentacion/Codex/Resumenes/`
  Carpeta de salida de los resumenes.
- `Documentacion/Codex/Resumenes/logs/`
  Carpeta de trazas tecnicas de cada ejecucion.
- `docs/`
  Documentacion tecnica y de despliegue del proyecto.
- `plantillas/`
  Archivos base reutilizables para instalar el sistema en otros equipos.

## Flujo de uso

1. El usuario abre `Resumir sesion de Codex.desktop`.
2. El script detecta:
   - binario de Codex,
   - base SQLite de sesiones,
   - carpeta de Escritorio del usuario.
3. Se listan las sesiones principales encontradas bajo `$HOME`.
4. El usuario elige una sesion.
5. El usuario elige una accion:
   - generar resumen,
   - abrir sesion,
   - generar resumen y despues abrir sesion,
   - archivar o desarchivar,
   - consultar el ultimo resumen guardado.
6. La navegacion permite volver atras con `0` y salir desde el menu inicial con `q`.
7. Si se genera resumen:
   - el resultado limpio se guarda como `.txt`,
   - la salida tecnica completa se guarda como `.log`,
   - se muestra una vista previa en pantalla.
8. La tabla indica si una sesion ya tiene resumen asociado mediante la columna `Resumen`.

## Estado actual

- Funcional en Linux con terminal compatible con `xdg-terminal-exec` y Codex CLI.
- Preparado para instalaciones con Codex en `PATH` o bajo `~/.nvm/versions/node/*/bin/codex`.
- Detecta automaticamente el fichero `state_*.sqlite` mas reciente dentro de `~/.codex`.
- Usa `xdg-user-dir DESKTOP` cuando esta disponible, con fallback a `~/Escritorio` o `~/Desktop`.

## Requisitos

- Bash.
- Python 3 con modulo estandar `sqlite3`.
- Codex CLI instalado y autenticado.
- Un emulador de terminal configurado como predeterminado para `xdg-terminal-exec`.
- Base local de Codex en `~/.codex/state_*.sqlite`.

## Estructura recomendada

```text
Automatizacion-Codex/
├── README.md
├── manual-completo.html
├── resumir-sesion-codex.sh
├── instalar.sh
├── docs/
│   ├── arquitectura.md
│   ├── funcionamiento-detallado.md
│   ├── historial-decisiones.md
│   ├── replicacion-en-otros-equipos.md
│   ├── troubleshooting.md
│   └── gpt-personalizado-documentador.md
├── gpt-personalizado/
│   ├── README.md
│   ├── instructions.txt
│   ├── welcome-message.txt
│   ├── conversation-starters.txt
│   └── knowledge-files.txt
└── plantillas/
    └── resumir-sesion-codex.desktop.template
```

## Decisiones de diseno

- Se usa SQLite directamente porque Codex ya mantiene ahi el catalogo de sesiones.
- Se filtran solo sesiones de origen `cli` y `vscode` para evitar mostrar ejecuciones internas o subagentes.
- No se ocultan las sesiones con titulo pobre; se renombran visualmente como `Sesion sin titulo util` y se acompanan de columnas de inicio y tokens para no perder acceso a datos validos.
- El resumen usa `codex exec resume --ephemeral` para no generar nuevas sesiones persistentes solo por documentar una antigua.
- Los resumenes nuevos incluyen el ID de sesion en el nombre para poder asociarlos de forma exacta desde el menu.
- La salida detallada de Codex se redirige a logs para mantener limpia la experiencia del usuario.
- La apertura para continuar usa `codex resume <id>` y no un resumen, para recuperar la sesion real.
- El archivado usa los campos locales `archived` y `archived_at`; oculta la sesion del listado activo, pero no la borra.

## Limites conocidos

- La estructura interna de la base SQLite de Codex podria cambiar en versiones futuras.
- Si Codex deja de usar `state_*.sqlite`, habra que adaptar la deteccion.
- El lanzador usa `xdg-terminal-exec`; si el sistema no lo ofrece, habra que sustituirlo por el terminal disponible.
- El orden depende de `updated_at`, por lo que las sesiones mas recientes aparecen primero aunque tengan titulos poco descriptivos.

## Documentacion ampliada

- [Arquitectura](docs/arquitectura.md)
- [Funcionamiento detallado](docs/funcionamiento-detallado.md)
- [Replicacion en otros equipos](docs/replicacion-en-otros-equipos.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Historial de decisiones](docs/historial-decisiones.md)
- [FAQ](docs/faq.md)
- [Roadmap](docs/roadmap.md)
- [GPT personalizado documentador](docs/gpt-personalizado-documentador.md)
