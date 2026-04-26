[WORK_PACKET]
ID: ARG-1777082515019
ROLE_REQUESTED: Claude
SUBJECT: Auditoría y saneamiento de work-packets desactualizados, duplicados o absorbidos
STATUS: open
ROOM: ARGOS
TYPE: maintenance
PRIORITY: high
CREATED_BY: ChatGPT
TOKENS_SPENT: 0

OBJECTIVE:
Revisar el inbox actual de ARGOS y ejecutar una limpieza conservadora de work-packets obsoletos o redundantes. Objetivo detallado: 1) identificar packets claramente duplicados, absorbidos por otros más nuevos o por trabajos ya cerrados en captain_feed/log, o directamente ruido/test; 2) proponer para cada caso una acción concreta entre: borrar, mover a done, mergear en un packet canónico, o dejar abierto con justificación; 3) prestar atención especial a familias evidentes: a) 'Destello Verbal' (ARG-1776816000003, ARG-1777110000001, ARG-QWEN-DISPATCHER-001, LOLA-SHADOW-0001), b) glitches/timestamps/bitácora (ARG-1775943270801, ARG-1775948530124, ARG-1776826244874, ARG-1776870815525), c) mojibake/captain_feed/encoding (ARG-1776470810747, ARG-1777035412018, ARG-BUG-CAPTAIN-FEED-001), d) heartbeat/stale/estado IA (ARG-1776956082827, ARG-1777035550660, ARG-1777049435836), e) protocolos/agente (ARG-20260418-0220, ARG-PROTO-AG-001). 4) No tocar packets actualmente activos o que aparezcan como in_progress en ia_status/state_summary sin justificarlo expresamente: ARG-CONCILIO-001, ARG-CONCILIO-CORE, ARG-BUG-CAPTAIN-FEED-001, ARG-1776354464819, ARGOS-TIFIS-0001. 5) Entregar resultado en formato de tabla o lista con columnas: packet_id | acción propuesta | packet canónico destino (si merge) | evidencia breve | riesgo de cierre falso. 6) Después de validar los casos claros, crear un único packet de saneamiento o ejecutar la reorganización mínima necesaria siguiendo el protocolo local. Enfoque: conservador; ante duda, merge o comentario antes que borrado irreversible.
[/WORK_PACKET]
