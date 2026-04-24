[WORK_PACKET]
ID: ARG-REFORM-BITACORA-001
ROOM: arquitectura
TYPE: strategy
TAG: protocol_hygiene, reliability
PRIORITY: P1
ROLE_REQUESTED: Claude
STATUS: open
CREATED_AT: 2026-04-24T14:00:00Z
SUBJECT: Protocolo antiglitch de bitácora — discernir el método más robusto para que nunca falle

OBJECTIVE:
El protocolo de bitácora (log+shadow+glitch) lleva demasiado tiempo fallando por las mismas
causas estructurales: dependencias frágiles, ausencia de cambio de estado al iniciar una orden,
y cierre que no dispara el mensaje al feed de forma fiable.

El objetivo de este packet NO es parchear síntomas. Es discernir, con criterio de ingeniería,
cuál es el método más robusto para que el protocolo se ejecute siempre correctamente,
independientemente del tripulante, la plataforma o si la API está caída.

Hay tres momentos en el ciclo de vida de una orden de trabajo. Cada uno debe ser irrompible:

MOMENTO 1 — INICIO DE SESIÓN (contexto general, no ligado a una orden)
  Todos los tripulantes, al arrancar sesión, leen:
    - ARGOS_QUICKSTART.md
    - inbox/ (los más recientes o asignados)
    - events/feeds/ o state/argos.state.json — estado reciente del resto de tripulantes
  Este momento NO genera entrada de log ni mensaje al feed.

MOMENTO 2 — START DE ORDEN (cuando se toma un packet activo)
  El tripulante que ejecuta la orden (nunca quien la prepara) debe:
    a) Llamar POST /api/ia/start-task → actualiza ia_status a "working" en argos.state.json
    b) El servidor emite automáticamente un evento al feed del Capitán:
       "[Actor] ha tomado: [subject] (ARG-XXXX)"
  Si la API no está disponible: depositar en inbox_deposits/ con sección [STATE] indicando
  working + packet_id, para que el heartbeat lo integre.

MOMENTO 3 — CIERRE DE ORDEN (cuando se completa el trabajo)
  El tripulante ejecutor debe:
    a) Llamar POST /api/remote/closure con:
       - sections.log    — entrada canónica de bitácora (OBLIGATORIO, sin excepción)
       - sections.shadow — reflexión interna (OBLIGATORIO)
       - sections.glitch — vacío si no hay, pero el campo debe existir
       - sections.state  — status: "idle", next_step, handoff_to
       - sections.captain — texto que saldrá por el feed (OBLIGATORIO, es el mensaje al Capitán)
       - mark_packet_done: true/false según corresponda
    b) El servidor, al integrar el closure:
       1. Escribe en log/shadow/glitch canónicos
       2. Actualiza ia_status a "idle"
       3. Emite sections.captain al feed del Capitán
    Si la API no está disponible: depositar en inbox_deposits/ con las 5 secciones.
    El heartbeat integrará y hará los pasos 1-3 en el siguiente ciclo.

REGLA ADICIONAL — BUGS detectados durante ejecución:
  Si se detecta un bug antes del cierre:
    - Añadir al closure en sections.glitch con formato [BUG] + descripción + impacto
    - No requiere llamada separada; el closure lo captura todo

TAREAS DE ANÁLISIS (núcleo del packet):

1. AUDITORÍA DE CAUSAS DE FALLO
   Revisar el historial reciente de bitácora y clasificar los fallos por tipo:
   - Tripulante no hizo START (ia_status quedó stale)
   - Tripulante no hizo cierre (trilog/shadow ausente)
   - API caída y no usó fallback inbox_deposits/
   - Campo captain vacío → feed no recibió mensaje
   - Actor no canónico → entrada huérfana
   - packet_id ausente → entrada no vinculada
   Cuantificar cuántos de los últimos N cierres tienen cada defecto.

2. ANÁLISIS DE FRAGILIDADES ESTRUCTURALES
   Para cada momento del ciclo (START, CLOSE), evaluar:
   - ¿Depende de que la API esté online? ¿Hay fallback real?
   - ¿Depende de que el tripulante recuerde hacerlo? ¿O hay mecanismo que lo fuerce?
   - ¿Qué pasa si se salta el momento? ¿Se detecta? ¿Se puede recuperar?
   - ¿El heartbeat valida o solo integra ciegamente?

3. PROPUESTA DE MÉTODO IRROMPIBLE
   A partir del análisis, proponer el diseño que minimice fallos estructurales:
   - ¿Debe el heartbeat rechazar y marcar ORPHAN las entradas sin packet_id o actor canónico?
   - ¿Debe el endpoint /api/remote/closure devolver error si falta sections.captain o sections.log?
   - ¿Debe el /api/ia/start-task ser la única forma de pasar de idle a working,
     o hay casos legítimos de excepción?
   - ¿Qué validaciones mínimas debe hacer argos-api en cada endpoint para que
     no se integren datos corruptos en los canónicos?
   - Para tripulantes chat (Claude.ai, ChatGPT, Pi web): ¿es el fallback inbox_deposits/
     suficientemente fiable, o necesita estructura más rígida?

4. ENTREGABLE PROTOCOLO
   Con base en la propuesta del punto 3, redactar:
   a) Sección "Ciclo de vida de una orden" en INTER_AI_PROTOCOL.md:
      - Los 3 momentos con pasos exactos, campos obligatorios, y qué hace el servidor
      - Fallback explícito para cada momento cuando API no está disponible
      - Tabla de validaciones que hace argos-api (qué acepta, qué rechaza, qué marca ORPHAN)
   b) Actualización de ARGOS_QUICKSTART.md:
      - Eliminar heartbeat/hitos intermedios (el Capitán los leerá en el log, no quiere saturación)
      - Mostrar ejemplo real de closure completo con los 5 campos rellenos
      - Ejemplo de mensaje al feed que genera el servidor automáticamente

5. ENTREGABLE TÉCNICO (para Codex, no implementar aquí — solo especificar)
   Redactar work packet hijo ARG-REFORM-BITACORA-001-IMPL con:
   - /api/ia/start-task: emite evento SSE al feed al actualizar ia_status
   - /api/remote/closure: valida campos obligatorios antes de integrar; actualiza ia_status a idle;
     emite sections.captain al feed
   - Heartbeat: al integrar inbox_deposits/, rechaza entradas sin packet_id o actor canónico
     y las mueve a ORPHAN (no al canónico)
   - Ningún cambio hasta que el Capitán apruebe la propuesta del punto 3

CONTEXTO Y PACKETS ABSORBIDOS:
  - ARG-REFORM-LOG-001: endurecer protocolo de logs (absorbido en tareas 3 y 4a)
  - ARG-1776826244874: bitácora sigue destrozada (motivación directa)
  - ARG-1776870815525: saneamiento trilog incompleto (auditoría en tarea 1)
  - ARG-1776956082827: heartbeat stale inconsistente (cubierto en tarea 2)
  - ARG-1776613004000: transcript opcional (política ya tomada, confirmar en 4a)
  Estos packets pueden cerrarse como absorbidos una vez este entregue.

CONSTRAINT EXPLÍCITO DEL CAPITÁN:
  - Sin heartbeats ni hitos intermedios al feed. El feed recibe exactamente dos mensajes
    por orden: START y CLOSE. Todo lo demás va al log.

ENTREGABLE FINAL:
  - Informe de auditoría de fallos (tarea 1 + 2): diagnóstico cuantificado
  - Propuesta de método irrompible (tarea 3): para aprobación del Capitán antes de implementar
  - INTER_AI_PROTOCOL.md sección "Ciclo de vida de una orden" (tarea 4a)
  - ARGOS_QUICKSTART.md actualizado (tarea 4b)
  - Work packet hijo para Codex (tarea 5): especificación técnica lista para implementar
[/WORK_PACKET]
