[WORK_PACKET]
ID: ARG-REFORM-LOG-001
ROOM: arquitectura
TYPE: strategy
TAG: protocol_hygiene
PRIORITY: P1
ROLE_REQUESTED: Claude
STATUS: open
CREATED_AT: 2026-04-23T00:00:00Z
SUBJECT: Endurecer protocolo de logs — obligatorio para todas las IAs sin excepción

OBJECTIVE:
El Capitán ha dictado que el protocolo de logs debe ser tan claro y explícito que cualquier IA,
sea cual sea (nueva o veterana, primera sesión o décima), lo ejecute correctamente sin ambigüedad
y sin faltar un solo campo requerido.

Los transcripts quedan fuera del flujo obligatorio. La comunicación entre IAs se basa exclusivamente
en los logs. El protocolo de logs pasa a ser el único canal fiable de memoria inter-sesión.

TAREAS:
1. Revisar INTER_AI_PROTOCOL.md sección 1.1 (LOG) y reescribirla con:
   - Lista exacta de campos OBLIGATORIOS en cada entrada (timestamp, actor, packet_id, summary,
     artifacts, verification, next_step, errors, risks)
   - Ejemplos válidos e inválidos de entradas (positivo y negativo)
   - Regla explícita: una entrada sin packet_id es inválida y debe ser rechazada por el heartbeat
   - Regla de voz: el campo actor debe usar el nombre canónico del agente (Claude, Codex, Pi,
     DeepSeek, Qwen) — nunca "Antigravity", "IA", "sistema", "agente"

2. Añadir sección "## 1.6 Validación de logs por heartbeat":
   - El heartbeat (argos-api) valida campos obligatorios al integrar depósitos
   - Si falta packet_id o actor: entrada marcada como ORPHAN y no integrada en canónico
   - Si actor no es nombre canónico: entrada rechazada con warning en GLITCH_LOG

3. Actualizar ARGOS_QUICKSTART.md para que el ritual de cierre muestre ejemplo de log correcto
   con todos los campos, no solo el bloque de código vacío.

4. Actualizar ARGOS_CREW_VOICES.md sección "En el captain_feed" con ejemplos de log correcto
   por agente (Claude/Orfeo, Codex, Pi, DeepSeek, Qwen).

5. Eliminar toda referencia a Google Sheets como canal activo del sistema.

CONTEXTO:
- Los transcripts pasan a ser opcionales (ver ARG-1776613004000)
- Los logs son ahora el único canal de memoria inter-IA
- Antigravity ha sido reemplazado por Pi (ver ARG-REFORM-VOICES-001)

ENTREGABLE:
- INTER_AI_PROTOCOL.md sección 1.1 y 1.6 reescritas
- ARGOS_QUICKSTART.md ritual de cierre con ejemplo real
- ARGOS_CREW_VOICES.md ejemplos de log por agente actualizados
[/WORK_PACKET]
