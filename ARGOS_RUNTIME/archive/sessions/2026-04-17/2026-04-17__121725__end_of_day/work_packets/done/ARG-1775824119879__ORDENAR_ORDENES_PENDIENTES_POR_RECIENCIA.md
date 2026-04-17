[WORK_PACKET]
ID: ARG-1775824119879
ROLE_REQUESTED: Cualquiera
SUBJECT: Ordenar ordenes pendientes por recencia
STATUS: done
RESOLVED_AT: 2026-04-10T15:31 Atlantic/Canary
RESOLVED_BY: Codex

OBJECTIVE:
Además, las ordenes pendientes no están ordenadas por recientes.
IMPLEMENTATION_NOTES:
- API `/api/tasks` ahora ordena pendientes (`open`, `in_progress`) por recencia descendente.
- La vista `Ordenes Pendientes` filtra solo pendientes y respeta ese orden.
[/WORK_PACKET]
