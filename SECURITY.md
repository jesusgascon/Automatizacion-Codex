# Security Policy

## Datos sensibles

El proyecto no debe incluir:

- bases SQLite de Codex,
- ficheros de rollout de sesiones,
- resumenes personales reales,
- tokens, credenciales o rutas privadas innecesarias.

## Operaciones sobre sesiones

- El proyecto archiva, no borra.
- La lectura de la base local es necesaria para listar sesiones.
- Cualquier cambio futuro que modifique o elimine datos debe documentarse y justificarse expresamente.

## Reporte de vulnerabilidades

Si detectas un problema de seguridad:

1. no publiques datos sensibles en issues publicos,
2. prepara una descripcion tecnica reproducible,
3. contacta con el mantenedor del repositorio por un canal privado.
