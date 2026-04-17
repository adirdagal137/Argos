[WORK_PACKET]
ID: ARG-1775921112194
ROLE_REQUESTED: Codex
SUBJECT: aparece en Standby de estado pero está trabajando. Claude también :S
STATUS: done
TOKENS_SPENT: 19

OBJECTIVE:
Codex aparece en Standby de estado pero está trabajando. Claude también :S

RESOLUTION: Resuelto por Claude (Orfeo) el 2026-04-11. Dos fixes aplicados en inferIaStatusFromTasks: (1) cross-check resetea agentes "active" cuyo packet ya no está en in_progress/, (2) fuente de enriquecimiento restringida a in_progress/ exclusivamente (no inbox). El dispatcher limpia statuses stale cada 60s.
[/WORK_PACKET]
