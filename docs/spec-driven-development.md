# Spec-Driven Development aplicado a Automatizacion-Codex

## Que se ha tomado de Spec Kit

GitHub Spec Kit propone que el desarrollo con agentes de IA no empiece directamente por codigo, sino por especificaciones. Su flujo central es:

```text
Spec -> Plan -> Tasks -> Implement
```

Aplicado a este proyecto, eso significa que las mejoras importantes deben pasar por:

1. especificar el comportamiento esperado,
2. convertirlo en plan tecnico,
3. dividirlo en tareas verificables,
4. implementar,
5. validar,
6. documentar.

No es obligatorio instalar Spec Kit para mantener esta disciplina. En este repositorio se ha creado una estructura compatible conceptualmente:

```text
.specify/
├── memory/
│   └── constitution.md
└── specs/
    └── 001-gestor-sesiones-codex/
        ├── spec.md
        ├── plan.md
        └── tasks.md
```

## Por que encaja con esta aplicacion

Automatizacion-Codex toca datos locales de Codex y modifica estado SQLite al archivar, desarchivar o limpiar rutas inexistentes. Eso exige mas rigor que un script rapido.

El enfoque SDD ayuda porque:

- obliga a definir criterios de aceptacion antes de tocar codigo,
- separa requisitos de decisiones tecnicas,
- deja documentadas las razones de cada mejora,
- facilita auditar cambios antes de subirlos a GitHub,
- reduce el riesgo de introducir rutas privadas o comportamiento destructivo.

## Constitucion del proyecto

La constitucion vive en:

```text
.specify/memory/constitution.md
```

Resume las reglas no negociables:

- privacidad local,
- portabilidad entre usuarios,
- backups antes de modificar estado,
- interfaz de consola clara,
- documentacion como parte del producto,
- validacion automatica minima.

## Especificacion funcional

La especificacion principal vive en:

```text
.specify/specs/001-gestor-sesiones-codex/spec.md
```

Define:

- problema,
- usuarios,
- alcance,
- funcionalidades,
- fuera de alcance,
- criterios de aceptacion,
- riesgos.

## Plan tecnico

El plan tecnico vive en:

```text
.specify/specs/001-gestor-sesiones-codex/plan.md
```

Define:

- arquitectura actual,
- decisiones tecnicas,
- mejoras recomendadas,
- plan de implementacion futura,
- validacion obligatoria.

## Tareas

La lista de tareas vive en:

```text
.specify/specs/001-gestor-sesiones-codex/tasks.md
```

Separa:

- trabajo ya completado,
- mejoras recomendadas,
- criterios para cerrar una tarea.

## Como usar este metodo en futuras mejoras

Antes de implementar una mejora, usar este orden:

1. Editar o crear una especificacion en `.specify/specs/`.
2. Definir criterios de aceptacion concretos.
3. Actualizar el plan tecnico.
4. Crear tareas verificables.
5. Implementar el cambio.
6. Ejecutar tests.
7. Actualizar README, roadmap o troubleshooting si cambia el uso.
8. Subir a GitHub.

## Ejemplo practico

Si se quiere anadir exportacion Markdown:

1. En `spec.md`, definir que formatos se admiten y donde se guardan.
2. En `plan.md`, decidir si se genera desde Codex, desde plantilla local o desde el resumen existente.
3. En `tasks.md`, crear tareas concretas.
4. En tests, validar nombres de archivo y compatibilidad hacia atras.
5. En README, documentar la opcion.

## Diferencia con instalar Spec Kit real

Esta integracion es documental y metodologica. No instala la CLI `specify`, no cambia el flujo de ejecucion de la aplicacion y no anade dependencias.

Si en el futuro se quiere usar Spec Kit completo, el proyecto ya tiene una estructura y disciplina cercanas a su enfoque, por lo que la migracion seria menor.

