[WORK_PACKET]
ID: ARG-1776613003000
ROLE_REQUESTED: Codex
SUBJECT: Añadir campos ROOM y TYPE al schema de work packets y al dispatcher
STATUS: open
PRIORITY: P2
ROOM: ARGOS
TYPE: build
TOKENS_SPENT: 0

OBJECTIVE:
Los work packets no tienen clasificación por proyecto (ROOM) ni por tipo de tarea (TYPE).
Esto impide filtrar el tablero por dominio y hace que tareas de proyectos distintos compitan
visualmente en la misma vista.

VALORES VÁLIDOS:
  ROOM:  ARGOS | SCICLASSMATE | COMENIO | XUANXU | GENERAL
  TYPE:  strategy | build | integration | maintenance | bug | risk | errand

TAREAS:
1. Actualizar el parser de work packets en argos-api para leer los campos ROOM y TYPE del
   encabezado del .md (ya están presentes en los packets de este sprint como demostración).
2. Añadir ROOM y TYPE al objeto TaskRecord (src/index.ts) y propagarlos en:
   - GET /api/tasks (en la respuesta JSON)
   - GET /api/tasks/get
   - POST /api/tasks (creación desde API)
3. Añadir filtros por ROOM y TYPE en GET /api/tasks:
   query params: ?room=ARGOS&type=build
4. En el dashboard (argos-dashboard): añadir selector de ROOM visible en la barra superior.
   Filtrar la lista de packets al seleccionar un ROOM.
5. Si un packet no tiene ROOM declarado, defaultear a "GENERAL". Si no tiene TYPE, defaultear a "task".
6. Actualizar INTER_AI_PROTOCOL.md sección 5 (Handoff canónico) con los valores válidos de ROOM y TYPE.

ENTREGABLE:
- Campos ROOM y TYPE en API y dashboard.
- Filtro por ROOM operativo en UI.
- Documentación actualizada.

NOTA:
Este packet tiene ya los campos ROOM y TYPE como ejemplo de la nueva convención.
[/WORK_PACKET]
