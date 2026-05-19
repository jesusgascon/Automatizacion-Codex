# Recuperacion desde backups SQLite

## Objetivo

El lanzador crea backups locales antes de operaciones que modifican la base de sesiones de Codex:

- archivar,
- desarchivar,
- limpiar sesiones con rutas inexistentes.

Este documento explica como restaurar una copia si una operacion no produce el resultado esperado.

## Donde estan los backups

Los backups se guardan en:

```text
<Carpeta-de-salidas-elegida>/backups/
```

Formatos habituales:

```text
state-before-archive-YYYYMMDD-HHMMSS.sqlite
state-before-cleanup-YYYYMMDD-HHMMSS.sqlite
```

## Regla principal

No restaures la base mientras Codex este abierto.

Antes de restaurar:

1. cierra Codex,
2. cierra el lanzador,
3. localiza la base activa,
4. crea una copia adicional de seguridad,
5. sustituye la base activa por el backup elegido.

## Localizar la base activa

Normalmente esta en:

```bash
find "$HOME/.codex" -maxdepth 1 -type f -name 'state_*.sqlite' | sort -V
```

Si hay varias, el lanzador usa por defecto la ultima segun orden versionado. Tambien puedes forzar una concreta con `STATE_DB`.

## Restauracion manual

Ejemplo con una base activa `state_5.sqlite`:

```bash
cd "$HOME/.codex"
cp state_5.sqlite "state_5.sqlite.before-restore-$(date +%Y%m%d-%H%M%S)"
cp "/ruta/a/backups/state-before-cleanup-YYYYMMDD-HHMMSS.sqlite" state_5.sqlite
```

Despues abre de nuevo el lanzador y revisa las sesiones.

## Restauracion asistida desde el menu

Desde el menu inicial pulsa `r`.

El lanzador:

1. muestra los ultimos backups disponibles,
2. pide seleccionar uno,
3. muestra un resumen del backup seleccionado,
4. exige escribir `RESTAURAR`,
5. crea un backup previo de la base que va a reemplazar,
6. copia el backup elegido sobre la base activa.

La restauracion asistida queda deshabilitada si ejecutas con:

```bash
CODEX_READ_ONLY=1 bash resumir-sesion-codex.sh
```

## Probar un backup sin restaurar

Si no quieres sobrescribir la base activa inmediatamente, puedes probar el backup primero:

```bash
STATE_DB="/ruta/a/backups/state-before-cleanup-YYYYMMDD-HHMMSS.sqlite" \
bash resumir-sesion-codex.sh
```

Esto permite verificar que el backup contiene lo esperado antes de restaurarlo.

## Recomendaciones

- Trata los backups como datos sensibles.
- No subas backups a GitHub.
- Conserva solo los backups necesarios.
- Usa `CODEX_READ_ONLY=1` si solo quieres auditar sin modificar SQLite.
