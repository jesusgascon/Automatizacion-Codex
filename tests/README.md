# Tests

Ejecutar:

```bash
python3 -m unittest discover -s tests -v
```

Cobertura actual:

- exclusión de rutas que solo comparten prefijo con `$HOME`,
- rechazo de resumen cuando el `cwd` original ya no existe,
- ocultacion por defecto y limpieza confirmada de rutas inexistentes,
- rotación de backups de archivado y limpieza,
- validacion del esquema SQLite esperado,
- render de consola Unicode y fallback ASCII,
- modo solo lectura,
- exportacion Markdown de resumenes,
- exportacion Markdown del diagnostico de sesiones,
- generación segura del lanzador con rutas que contienen caracteres especiales.
