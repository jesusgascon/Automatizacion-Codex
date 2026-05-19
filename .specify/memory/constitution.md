# Constitucion del proyecto

## Proyecto

Automatizacion-Codex es una utilidad local para Linux que organiza, resume, reabre y archiva sesiones locales de Codex desde una interfaz de consola lanzada mediante escritorio o menu de aplicaciones.

## Principios no negociables

### 1. Privacidad local por defecto

El proyecto no debe subir sesiones, bases SQLite, logs ni resumenes a servicios externos. Cualquier salida sensible generada durante el uso debe permanecer fuera del repositorio y dentro de rutas locales elegidas por el usuario.

Implicaciones:

- no incluir bases `state_*.sqlite` en Git,
- no registrar IDs reales de sesiones en documentacion publica,
- no crear telemetria,
- no enviar contenido de sesiones a APIs distintas del propio Codex invocado por el usuario.

### 2. Portabilidad entre usuarios y equipos

La aplicacion debe funcionar en distintos equipos Linux sin rutas duras. Las rutas deben derivarse de `$HOME`, `xdg-user-dir`, variables de entorno o seleccion explicita del usuario.

Implicaciones:

- no depender de rutas personales reales ni de un nombre concreto de usuario,
- detectar `codex` por varias rutas habituales,
- permitir `CODEX_BIN`, `STATE_DB` y `CODEX_SUMMARY_DIR`,
- documentar claramente que cada equipo usa sus propias sesiones locales.

### 3. Reversibilidad antes de modificar estado

Cualquier operacion que cambie la base local de Codex debe tener confirmacion explicita y backup previo.

Implicaciones:

- archivar/desarchivar exige confirmacion,
- limpiar sesiones con rutas inexistentes exige confirmacion literal,
- crear backup antes de cambiar SQLite,
- no borrar sesiones utiles por defecto.

### 4. Consola clara, util y no invasiva

La interfaz debe ser legible en terminal, limpiar la pantalla entre vistas y mostrar acciones comprensibles sin esconder informacion operativa importante.

Implicaciones:

- mantener navegacion con `0` y `q`,
- usar cajas y separadores sin romper terminales basicos,
- degradar a ASCII si no hay UTF-8,
- evitar salida tecnica extensa en la ventana principal.

### 5. Documentacion como parte del producto

Cada cambio relevante debe quedar reflejado en la documentacion adecuada: README, guia tecnica, roadmap, troubleshooting o especificaciones.

Implicaciones:

- los cambios de instalacion se explican en README y guias,
- las decisiones tecnicas se registran,
- las futuras mejoras se convierten en tareas trazables,
- los criterios de aceptacion deben poder revisarse antes de programar.

### 6. Validacion automatica minima

El proyecto debe mantener una bateria de validacion ligera que pueda ejecutarse en cualquier equipo sin instalar dependencias externas.

Implicaciones:

- `bash -n resumir-sesion-codex.sh instalar.sh`,
- `python3 -m unittest discover -s tests -v`,
- tests sobre rutas, deteccion, filtros, backups y limpieza,
- evitar dependencias que compliquen la instalacion domestica.

## Criterios de calidad

- Sin rutas privadas en Git.
- Sin datos personales en fixtures o documentacion.
- Sin cambios destructivos sin confirmacion.
- Instalacion reproducible desde GitHub.
- Interfaz usable en Ubuntu moderno y terminales basicos.
- Compatibilidad razonable con instalaciones Codex via npm, nvm, `.local/bin` y PATH.

## Politica de evolucion

Antes de implementar una mejora relevante se debe:

1. describir el problema,
2. escribir o actualizar la especificacion,
3. definir criterios de aceptacion,
4. actualizar el plan tecnico,
5. crear tareas verificables,
6. implementar,
7. validar con tests,
8. documentar.
