# Privacidad

## Principio general

`Automatizacion-Codex` es una utilidad local. No transmite sesiones, resúmenes ni metadatos fuera del equipo por cuenta propia.

## Datos que lee

- Base SQLite local de Codex en `~/.codex/state_*.sqlite`.
- Metadatos de sesión:
  - identificador,
  - ruta de trabajo,
  - título,
  - primer mensaje,
  - fechas,
  - tokens,
  - estado de archivado.

## Datos que escribe

- Resúmenes de sesión en el Escritorio del usuario.
- Logs técnicos de generación de resumen.
- Backups locales de la base antes de archivar o desarchivar.
- Campos `archived` y `archived_at` en la base local cuando el usuario archiva o desarchiva.

## Datos que no debe incluir el repositorio

- Bases SQLite reales.
- Rollouts o historiales de conversación.
- Resúmenes personales generados.
- Logs de ejecución reales.
- Rutas privadas innecesarias.
- Tokens o credenciales.

## Decisiones de diseño

- Se archiva en lugar de borrar.
- Antes de modificar el estado de archivado se crea un backup local de la base SQLite.
- Los resúmenes se guardan fuera del repositorio, bajo el Escritorio del usuario.
- La asociación resumen-sesión se hace por ID solo en el nombre del archivo local.
- El repositorio publica código y documentación, no datos de uso.

## Recomendaciones

- No compartas resúmenes generados sin revisarlos antes.
- Conserva una copia de seguridad de `~/.codex` si dependes de tu historial.
- Revisa los logs antes de publicarlos en incidencias.
