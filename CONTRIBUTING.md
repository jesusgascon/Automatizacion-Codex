# Contributing

## Alcance

Este proyecto busca mantenerse pequeno, legible y auditable. Las contribuciones deben conservar:

- compatibilidad con Bash,
- dependencia minima de herramientas externas,
- operaciones reversibles por defecto,
- documentacion sincronizada con el comportamiento real.

## Antes de proponer cambios

1. Ejecuta:

```bash
bash -n resumir-sesion-codex.sh instalar.sh
```

2. Comprueba manualmente:

- vista de sesiones activas,
- vista de archivadas,
- retorno con `0`,
- salida con `q`,
- generacion de resumen,
- lectura de ultimo resumen,
- archivado y desarchivado.

3. Actualiza la documentacion si cambias:

- opciones del menu,
- formato de salida,
- rutas,
- requisitos,
- convenciones de nombres.

## Estilo

- Usa ASCII salvo que el archivo ya requiera UTF-8 por contenido.
- Mantén funciones pequenas y nombres descriptivos.
- Prefiere seguridad y reversibilidad frente a automatismos agresivos.
- No añadas borrado destructivo de sesiones sin una estrategia de recuperacion clara.

## Pull requests

Incluye:

- que cambia,
- por que cambia,
- riesgos,
- comprobaciones realizadas.
