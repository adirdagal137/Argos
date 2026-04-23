[WORK_PACKET]
ID: ARG-PROTO-AG-001
TYPE: note
TAG: protocol, antigravity, calibration
PRIORITY: P1
ROLE_REQUESTED: ANTIGRAVITY
SUBJECT: Ritual de cierre Tri-Log obligatorio tras cada sesion
STATUS: open
CREATED_AT: 2026-04-21T21:00:13.883Z
CREATED_BY: Argos Dispatcher
TOKENS_SPENT: 0

OBJECTIVE:
Reforzar disciplina de cierre para Antigravity. Ningun paquete puede cerrarse sin Tri-Log completo y Registro de Transcripcion Literal.

ACCIONES REQUERIDAS:
1. Registrar transcripcion literal en transcripts/YYYY-MM-DD_AGENTE.md (via /api/transcript).
2. Registrar cierre en ARGOS_GLOBAL_LOG.md (LOG lane).
3. Registrar evento estructurado en events/argos.events.jsonl (EVENTS lane).
4. Registrar sombra en ARGOS_GLOBAL_SHADOW_LOG.md (SHADOW lane).
5. Sincronizar state despues del cierre.
[/WORK_PACKET]
