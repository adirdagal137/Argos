[WORK_PACKET]
ID: ARG-1776613008000
ROLE_REQUESTED: Codex
SUBJECT: Endurecer SSE/dedup/parser y añadir dashboard por ROOM una vez operativos los campos
STATUS: open
PRIORITY: P3
ROOM: ARGOS
TYPE: build
TOKENS_SPENT: 0

OBJECTIVE:
Consolidar la infraestructura técnica de argos-api: SSE más robusto, deduplicación mejorada,
parser de destinatario endurecido, y vista de dashboard por ROOM una vez que el campo esté
operativo (ARG-1776613003000).

BLOQUEANTE:
Requiere que ARG-1776613003000 (campos ROOM/TYPE) esté completado.

TAREAS:

1. SSE (pub/sub):
   - Añadir reconexión automática en el cliente dashboard si se pierde el stream.
   - Añadir ping/keepalive cada 30s para evitar timeouts de proxy.
   - Limpiar sseClients al detectar conexiones muertas (actualmente puede acumular handlers).

2. Deduplicación de eventos:
   - Revisar el TTL del dedupCache para eventos de alta frecuencia (heartbeat, tokens:updated).
   - Añadir métrica: cuántos eventos se descartaron por dedup en las últimas 24h.
     Endpoint: GET /api/stats/dedup → { discarded: N, window: '24h' }

3. Parser de destinatario (normalizeAgentName):
   - Actualmente no reconoce "Qwen" como agente válido — devuelve null.
   - Añadir: 'qwen' | 'automatista' → 'DeepSeek' (o crear entrada propia si el Capitán decide separar).
   - Añadir: 'orfeo' → 'Claude' (actualmente mapea a DeepSeek — bug potencial).
   - Revisar todos los alias en ARGOS_CREW_VOICES.md y asegurar cobertura completa.

4. Dashboard por ROOM:
   - Una vez que ARG-1776613003000 esté completado, añadir vista "Rooms" en el dashboard:
     selector lateral que filtra todos los paneles (tasks, events, feed) por ROOM.
   - El ROOM seleccionado debe persistir en localStorage.

5. Encoding / mojibake:
   - Auditar el global log y eventos por entradas con caracteres corruptos (Ã, â, etc.).
   - Identificar el punto de entrada del mojibake y corregirlo en la escritura.
   - Si el origen es legacy (datos ya escritos), crear script de limpieza one-shot.

ENTREGABLE:
- SSE con keepalive y reconexión.
- dedupCache con métricas.
- normalizeAgentName corregido y completo.
- Dashboard con vista por ROOM.
- Mojibake auditado y corregido.
[/WORK_PACKET]
