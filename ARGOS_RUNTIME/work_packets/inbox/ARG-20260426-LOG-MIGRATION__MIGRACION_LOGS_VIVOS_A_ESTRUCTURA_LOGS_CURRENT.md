[WORK_PACKET]
ID: ARG-20260426-LOG-MIGRATION
ROOM: ARGOS
TYPE: maintenance
TAG: architecture, logs, migration, filesystem
SUBJECT: Migracion logs vivos a ARGOS_RUNTIME/logs/current/ (Fase 7 de DOC-CONTEXT-HYGIENE)
ROLE_REQUESTED: Codex
OWNER: Codex
STATUS: open
PRIORITY: low
REPORTED_BY: Claude
REPORTED_AT: 2026-04-26

[OBJETIVO]
Mover los tres logs vivos de ARGOS_RUNTIME root a una subestructura ordenada,
coordinando el cambio con argos-api, dashboard, rollover y cualquier herramienta que
los referencie por ruta.

Este packet NO debe ejecutarse sin actualizacion simultanea de todas las dependencias.
Es la Fase 7 aplazada de ARG-20260426-DOC-CONTEXT-HYGIENE.

[CONTEXTO]
Actualmente los logs vivos estan en ARGOS_RUNTIME root junto con los docs operativos:
- ARGOS_RUNTIME/ARGOS_GLOBAL_LOG.md
- ARGOS_RUNTIME/ARGOS_GLOBAL_SHADOW_LOG.md
- ARGOS_RUNTIME/ARGOS_GLOBAL_GLITCH_LOG.md

Propuesta de nueva estructura:
- ARGOS_RUNTIME/logs/current/ARGOS_GLOBAL_LOG.md
- ARGOS_RUNTIME/logs/current/ARGOS_GLOBAL_SHADOW_LOG.md
- ARGOS_RUNTIME/logs/current/ARGOS_GLOBAL_GLITCH_LOG.md
- ARGOS_RUNTIME/logs/archive/ (equivalente al actual events/logs/)

Los logs NO se mueven en ARG-20260426-DOC-CONTEXT-HYGIENE porque estan referenciados
por rutas concretas en argos-api, dashboard y herramientas. Moverlos sin actualizacion
tecnica simultanea rompe la escritura de trilog.

[TAREAS]
- [ ] T1: Identificar todas las rutas hardcodeadas en argos-api/src/index.ts que apuntan a los tres logs.
- [ ] T2: Identificar referencias en argos-dashboard/ (parser, logbook, SSE consumer).
- [ ] T3: Identificar referencias en ARGOS_RUNTIME/tools/session_rollover.ps1 y merge/history tools.
- [ ] T4: Identificar referencias en AGENTS.md, CLAUDE.md, ARGOS_QUICKSTART.md, INTER_AI_PROTOCOL.md, REGISTRY.md.
- [ ] T5: Crear nueva estructura logs/current/ y logs/archive/.
- [ ] T6: Actualizar todas las rutas en argos-api/src/index.ts (rama obligatoria).
- [ ] T7: Actualizar rutas en dashboard.
- [ ] T8: Actualizar rutas en herramientas y docs.
- [ ] T9: Copiar los logs vivos a la nueva ubicacion (NO eliminar los originales hasta verificar).
- [ ] T10: Verificar que el trilog escribe correctamente a la nueva ruta.
- [ ] T11: Verificar que el heartbeat y SSE leen correctamente.
- [ ] T12: Eliminar archivos de la ubicacion antigua.
- [ ] T13: Actualizar REGISTRY.md para reflejar nueva estructura.

[CRITERIOS DE CIERRE]
- [ ] Los tres logs vivos en ARGOS_RUNTIME/logs/current/
- [ ] argos-api escribe correctamente a nueva ruta (trilog verificado)
- [ ] Dashboard muestra datos correctamente
- [ ] session_rollover.ps1 y herramientas funcionan
- [ ] ARGOS_QUICKSTART.md y REGISTRY.md actualizados con nuevas rutas
- [ ] AGENTS.md y CLAUDE.md actualizados
- [ ] Logs antiguos eliminados de ARGOS_RUNTIME root

[RIESGOS]
- Riesgo alto: si se mueven los logs sin actualizar argos-api, el trilog falla silenciosamente
  y los cierres de sesion se pierden. Mitigacion: hacer el cambio en rama, no en main.
- Riesgo medio: el dashboard puede cachear rutas. Verificar SSE y logbook despues del cambio.
- Riesgo bajo: archive de sesiones puede tener rutas relativas que apunten a la ubicacion antigua.

[NOTAS]
- Este packet requiere que Codex (o Claude) toque argos-api/src/index.ts -> RAMA OBLIGATORIA.
- Coordinar con el Capitan antes de ejecutar: el sistema queda momentaneamente sin escritura
  de logs durante la migracion si no se hace con copia previa.
- No bloquea ninguna tarea activa. Prioridad baja -- ejecutar cuando el sistema este en reposo.

[/WORK_PACKET]
