[WORK_PACKET]
ID: ARG-PROTO-AG-001
ROLE_REQUESTED: ANTIGRAVITY
SUBJECT: Recordatorio crítico: Ritual de cierre Tri-Log obligatorio tras cada sesión
TYPE: note
TAG: protocol, antigravity, calibration
PRIORITY: P1
STATUS: done
RESOLVED_AT: 2026-04-10T22:11 Atlantic/Canary
RESOLVED_BY: Codex
CREATED_AT: 2026-04-10T22:05 Atlantic/Canary
CREATED_BY: Claude (Orfeo)
TOKENS_SPENT: 0

OBJECTIVE:
Antigravity ha completado múltiples sesiones operativas sin ejecutar el ritual de cierre.
Los logs de la sesión 9f2e250a (Token Accounting + Chat Feed Repair + Stability) no aparecieron
en la Bitácora — tuvieron que ser reconstruidos retroactivamente por Claude.

ACCIONES REQUERIDAS:
1. Tras CADA sesión completada, escribir en ARGOS_GLOBAL_LOG.md con el formato:
   **[YYYY-MM-DD HH:MM Atlantic/Canary] VOZ ANTIGRAVITY:**
   Incluir: MISIÓN, WORK PACKET ID, ACCIONES EJECUTADAS, VERIFICACIÓN, ERRORES+APRENDIZAJES, RIESGOS

2. Escribir en events/argos.events.jsonl el registro estructurado con todos los campos
   incluyendo: timestamp, actor, module, type, summary, artifacts, verification,
   next_step, errors, risks, packet_id

3. Escribir en ARGOS_GLOBAL_SHADOW_LOG.md (aunque sea "Sin observaciones adicionales")

4. Actualizar state/argos.state.json con next_step y open_packets

5. Mover work packets a done/ DESPUÉS de escribir los logs, no antes.

CONTEXTO:
El Capitán necesita visibilidad en tiempo real. Si los logs no aparecen en la Bitácora,
el dashboard queda ciego a todo el trabajo realizado. Este protocolo es la diferencia entre
un agente que trabaja en silencio y uno que opera dentro del Navío.

Ver: INTER_AI_PROTOCOL.md secciones 1, 3 y 4 para referencia completa.
[/WORK_PACKET]
