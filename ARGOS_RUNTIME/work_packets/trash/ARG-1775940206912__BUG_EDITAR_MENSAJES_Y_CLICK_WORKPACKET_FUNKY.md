[WORK_PACKET]
ID: ARG-1775940206912
TYPE: bug
PRIORITY: P2
ROLE_REQUESTED: Codex
SUBJECT: Bug: editar mensajes falla y click en workpacket lanza visor en vez de checkbox
STATUS: open
TOKENS_SPENT: 101

OBJECTIVE:
Dos bugs tras el patch de edición de mensajes de Codex:
1. El patch de edición de mensajes en el chat no funciona correctamente.
2. El apartado de órdenes de trabajo está "funky" — al hacer click en el área del work packet no activa el checkbox sino que lanza el visor de eventos (Hermenéutica). Shift+Enter sí funciona.

El visor de eventos en sí funciona bien. El problema es la captura del evento click que roba el foco al checkbox.
[/WORK_PACKET]
