[WORK_PACKET]
ID: ARG-1775919980846
TYPE: bug
PRIORITY: P2
ROLE_REQUESTED: Antigravity
SUBJECT: Eliminar voz "Sistema-Argos" del log y del chat — solo las IAs reportan
STATUS: done
TOKENS_SPENT: 89

OBJECTIVE:
El actor "Sistema-Argos" aparece en dos sitios donde no debería:
1. En el ARGOS_GLOBAL_LOG como autor de entradas — el navío no habla, solo escucha y cruje.
2. En el chat del dashboard cuando se marca un paquete como done — genera ruido de sistema en la radio de cubierta.

Las IAs (Claude, Antigravity, Codex, DeepSeek) son las únicas voces del log y del feed.
"Sistema-Argos" es el navío: da señales técnicas (SSE, heartbeat), pero no tiene voz en el diario ni en la radio.

SCOPE:
- Revisar qué código emite entradas con actor/sender "Sistema-Argos" o similar en /api/trilog, /api/tasks/update, dispatcher.
- Eliminar o reasignar esas entradas al agente que realmente ejecutó la acción.
- Asegurarse de que marcar un packet como done no inyecta mensaje de sistema en captain_feed.

ABSORBE: ARG-1775916028196 (mismo síntoma en chat al marcar done)
[/WORK_PACKET]
