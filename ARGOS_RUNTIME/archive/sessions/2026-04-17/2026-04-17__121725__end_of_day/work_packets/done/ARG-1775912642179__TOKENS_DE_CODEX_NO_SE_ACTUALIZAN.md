[WORK_PACKET]
ID: ARG-1775912642179
ROLE_REQUESTED: Codex
SUBJECT: Tokens de codex no se actualizan
STATUS: done
TOKENS_SPENT: 700

OBJECTIVE:
Hacer que el panel WORK_TOKENS refleje el gasto estimado real de Codex y Antigravity/Gemini (sin mezclar report tokens).

CONTEXT:
- La UI carga `GET /api/tokens?scope=work` (solo WORK_TOKENS).
- Antes del fix, muchos registros legacy en `events/argos.tokens.jsonl` no traían `scope`/`channel` y el sistema los infería como `report` por el prefijo del `ref` ("Chat Rep:"), dejando a Codex/Antigravity casi a cero en el panel.

EVIDENCIA (antes, 2026-04-11):
- `GET /api/tokens?scope=work` => Claude ~39700, Antigravity ~1623, Codex ~3187 (solo Claude parecía realista).

ROOT CAUSE:
- `inferTokenScope()` estaba usando heurística basada en `ref` (p.ej. `ref.startsWith('chat rep:')`) incluso cuando faltaba `channel`, clasificando histórico legacy como `report`.
- Como el panel pide `scope=work`, esos tokens desaparecían del recuento.

CAMBIOS APLICADOS (API):
- `inferTokenScope()` ahora infiere solo por `channel` cuando `scope` falta. Si no hay `channel`, se considera `work` por defecto (excepto `captain_input`).
- Se mantiene separación `work` vs `report` cuando `scope` y/o `channel` vienen informados.
- Se añadió fallback en `POST /api/chat` para generar WORK_TOKENS estimados por paquete si llega `refId` y no existe ya work record (multiplicador conservador).
- Se añadió backfill de WORK_TOKENS desde report ledger en arranque cuando hay `refId` de work packet.

VERIFICACION (después, servidor reiniciado 2026-04-11):
- `GET /api/tokens?scope=work` => Claude 49000, Antigravity 17602, Codex 3410.

RESOLUTION: Resuelto por Claude (Orfeo) el 2026-04-11. El problema más amplio de trazabilidad automática de tokens queda en P1_ARG-TOKEN-AUTO-001 y P1_ARG-1775828525682.
[/WORK_PACKET]
