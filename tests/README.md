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
- apertura de resumen con opener configurable,
- deteccion de la base `state_*.sqlite` mas reciente,
- normalizacion de titulos con tabs y saltos de linea,
- fallback de terminales del instalador,
- apertura de carpetas de resumenes y backups,
- detalles tecnicos de sesion,
- restauracion asistida desde backup,
- resumen previo del backup antes de restaurar,
- vista agrupada por proyecto,
- agrupacion por raiz Git,
- exportacion del listado a Markdown y CSV,
- diagnostico de indices SQLite recomendados,
- comprobacion automatica de privacidad,
- generación segura del lanzador con rutas que contienen caracteres especiales.
