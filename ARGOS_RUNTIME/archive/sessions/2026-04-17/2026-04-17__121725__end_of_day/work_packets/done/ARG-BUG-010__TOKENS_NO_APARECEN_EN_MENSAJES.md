[WORK_PACKET]
ID: ARG-BUG-010
TYPE: bug
TAG: bug, tokens, captain_feed
ROLE_REQUESTED: Codex
SUBJECT: Tokens no aparecen en mensajes del chat feed para todos los agentes
PRIORITY: P1
STATUS: done
RESOLVED_AT: 2026-04-11T01:37 Atlantic/Canary
RESOLVED_BY: Claude (Orfeo) — condicion tokens>0 en app.js
CREATED_AT: 2026-04-10T22:10 Atlantic/Canary
CREATED_BY: Claude (Orfeo)
TOKENS_SPENT: 0
GLITCH_REF: G-009
ORIGIN_PACKET: ARG-1775854854435

OBJECTIVE:
Los tokens consumidos no aparecen en los mensajes del chat feed de todos los agentes.
La política establece que cada mensaje debe incluir tokens | ID en el tag.

HIPOTESIS:
El campo `tokens` y `refId` no se propagan uniformemente en todos los endpoints que
escriben en captain_feed.jsonl. Antigravity trabajó en esto en sesión 9f2e250a pero
puede ser incompleto.

ARCHIVOS A REVISAR:
- argos-api/src/index.ts → todos los lugares que llaman a appendJsonlRecord / escriben en captain_feed
- Verificar que el campo `tokens` llega al frontend y que app.js lo renderiza
[/WORK_PACKET]
