[WORK_PACKET]
ID: ARG-1775828525682
TYPE: task
ROLE_REQUESTED: Antigravity / Codex
SUBJECT: Reeditar UI de tokens y trazabilidad total por IA
STATUS: done

CONTEXT:
Gemini ya inicio una implementacion de tokens (ledger y endpoints), pero el panel no esta
contabilizando de forma fiable ni consistente en toda la experiencia.

OBJECTIVE:
Corregir y completar el sistema para que los tokens queden asociados a mensajes y logs,
y exista recuento total de gasto por IA con desglose temporal.

TAREAS:
1. Validar/ajustar el ledger canonico de tokens (events/argos.tokens.jsonl) y su schema.
2. Corregir la UI de tokens del panel para mostrar:
   - Totales por IA (Codex, Claude, Antigravity)
   - Totales por dia, semana y acumulado global
   - Coste API total estimado/real segun fuente disponible
3. Anadir en cada mensaje de chat una etiqueta "Tokens: XXX" cuando exista asociacion.
4. Anadir en logs (global/interactions/shadow/events) el campo o bloque de tokens asociado
   por entrada cuando exista dato.
5. Garantizar que el recuento agregado no duplique entradas al refrescar.
6. Exponer endpoint(s) de lectura para auditoria de tokens desde webapp.

PROGRESO (2026-04-11 Orfeo):
✓ Ledger argos.tokens.jsonl validado — scope work/report/input separados
✓ Panel muestra solo WORK_TOKENS (scope:work) — sin duplicados
✓ Tokens eliminados del feed radial — solo van al ledger
✓ Backfill automático work desde report si agente olvida processTokens
⏳ PENDIENTE: desglose por día/semana/acumulado en UI
⏳ PENDIENTE: coste API real (actualmente estimación chars/4)
⏳ PENDIENTE: etiqueta tokens por mensaje en chat (requiere cambio en UI app.js)

SUCCESS_CRITERIA:
- El contador del panel refleja datos reales y estables (no mock).
- Cada mensaje/log con consumo conocido muestra su valor de tokens.
- Existe suma confiable por IA + dia + semana + total + coste API.
- La informacion de tokens es trazable desde UI y archivos canonicos.
[/WORK_PACKET]
