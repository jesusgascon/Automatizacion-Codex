# Tests

Ejecutar:

```bash
python3 -m unittest discover -s tests -v
```

Cobertura actual:

- exclusión de rutas que solo comparten prefijo con `$HOME`,
- rechazo de resumen cuando el `cwd` original ya no existe,
- ocultacion por defecto y visualizacion bajo demanda de rutas inexistentes,
- rotación de backups,
- generación segura del lanzador con rutas que contienen caracteres especiales.
