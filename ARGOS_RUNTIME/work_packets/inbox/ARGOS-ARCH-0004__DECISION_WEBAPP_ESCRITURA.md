[WORK_PACKET]
ID: ARGOS-ARCH-0004
TYPE: decision
TAG: protocol, architecture
SUBJECT: Cerrar decision arquitectonica - scope de escritura de la webapp en ARGOS_RUNTIME
ROLE_REQUESTED: Claude
OWNER: Capitan
STATUS: open
PRIORITY: P1
REPORTED_BY: Claude (claude.ai)
REPORTED_AT: 2026-04-18 20:00 Atlantic/Canary

## Contexto

Riesgo activo pendiente de sesiones anteriores: la decision de si la webapp
escribia o no en ARGOS_RUNTIME estaba sin formalizar documentalmente.

## Decision tomada por el Capitan (sesion 2026-04-18)

La webapp SI escribe en ARGOS_RUNTIME, con scope definido:
- captain_feed: escritura directa desde UI.
- work_packets: el Capitan puede editar, marcar completados y borrar desde la UI.
- Otras interacciones directas confirmadas en sesion.

La webapp NO es read-only. Tampoco tiene acceso irrestricto.

## Impacto

- ARGOS-ARCH-0004 queda cerrado como riesgo activo.
- El sistema de versionado (ARGOS-ARCH-0005) puede proceder sin bloqueo.
- INTER_AI_PROTOCOL.md debe reflejar este scope en proxima actualizacion.

## Entregable

Registrar decision en log. Actualizar state.json marcando done.
Referenciar en protocolo cuando se actualice.

[/WORK_PACKET]
