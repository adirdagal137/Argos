[WORK_PACKET]
ID: ARG-QWEN-DISPATCHER-001
TYPE: task
PRIORITY: P2
TAG: local_execution, dispatcher, infrastructure
ROLE_REQUESTED: Antigravity / Codex
OWNER: Antigravity
STATUS: open
REPORTED_BY: Claude (Orfeo)
REPORTED_AT: 2026-04-16

CONTEXT:
Qwen (El Automatista) está registrado en la tripulación como agente local (Qwen3 8B via Ollama).
El API de ARGOS ya expone /api/qwen/run y /api/qwen/execute-packet.
Falta: que el Dispatcher asigne automáticamente los work packets con TAG: local_execution a Qwen
en lugar de dejarlos en inbox sin owner.

OBJECTIVE:
El Dispatcher detecta packets con TAG local_execution (u otros tags de Qwen), llama a
POST /api/qwen/execute-packet, registra el resultado en el trilog y mueve el packet a done/.
Todo silencioso — Qwen no habla en el captain_feed salvo error.

TAREAS:
1. [ ] En el Dispatcher (Antigravity), añadir lógica: si packet.TAG includes 'local_execution'
       → POST http://localhost:8080/api/qwen/execute-packet { packetId }
2. [ ] Si respuesta incluye { derive: true }: reencolar el packet con owner del agente sugerido
3. [ ] Si respuesta es resultado: POST /api/trilog automático con actor="Qwen"
4. [ ] Si Ollama no disponible: dejar packet en inbox, añadir WARN en events JSONL

NOTAS TÉCNICAS:
- Endpoint Qwen: POST http://localhost:8080/api/qwen/execute-packet
- Token: no requerido (API local sin auth)
- Timeout recomendado Dispatcher: 120s (Qwen3 8B puede ser lento en primeras inferencias)
- Model fallback: si Qwen falla, derivar a Claude con nota en shadow log

SUCCESS_CRITERIA:
- Packet con TAG local_execution se procesa y cierra sin intervención del Capitán
- Log muestra actor="Qwen" con resultado
- Ningún popup ni ventana visible durante ejecución
[/WORK_PACKET]
