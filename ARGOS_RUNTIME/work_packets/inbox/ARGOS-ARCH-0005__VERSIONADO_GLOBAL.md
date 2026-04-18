[WORK_PACKET]
ID: ARGOS-ARCH-0005
TYPE: task
TAG: protocol, architecture
SUBJECT: Sistema de versionado global - argos.version como fuente de verdad unica
ROLE_REQUESTED: Codex
OWNER: Codex
STATUS: open
PRIORITY: P2
REPORTED_BY: Claude (claude.ai)
REPORTED_AT: 2026-04-18 20:00 Atlantic/Canary
DEPENDS_ON: ARGOS-ARCH-0004

## Objetivo

Implementar un numero de version unico para el sistema Argos que:
- Viva en un fichero canonico unico: ARGOS_RUNTIME/argos.version
- Sea referenciado (no duplicado) por protocolo, registry y README
- Se incremente siguiendo reglas claras
- Se etiquete en GitHub en cada hito

## Reglas de incremento

- patch (0.0.X): fix, limpieza, refactor sin cambio de comportamiento
- minor (0.X.0): nuevo endpoint, nueva capa, nuevo mecanismo operativo
- major (X.0.0): cambio de arquitectura que rompe compatibilidad

El incremento minor se gatilla automaticamente cuando se cierra
un work packet con TAG: protocol.

## Tareas para Codex

1. Crear ARGOS_RUNTIME/argos.version con version inicial.
   Propuesta: 0.3.0 dado el estado actual. Criterio final del Capitan.
2. Anadir linea de referencia en INTER_AI_PROTOCOL.md, registry y README:
   "version: ver ARGOS_RUNTIME/argos.version"
3. Crear script/hook que lea argos.version y lo incluya en el git tag
   al hacer commit en GitHub.
4. Documentar la regla de incremento en INTER_AI_PROTOCOL.md
   seccion nueva "## 9. Versionado del sistema".

## Entregable

- ARGOS_RUNTIME/argos.version creado.
- Referencias en ficheros clave actualizadas.
- Hook de git tag documentado.

[/WORK_PACKET]
