[WORK_PACKET]
ID: ARG-COMMS-001
TYPE: task
TAG: infrastructure, communication, pubsub
ROLE_REQUESTED: Codex
PRIORITY: P1
STATUS: done
CREATED_AT: 2026-04-10T22:35 Atlantic/Canary
CREATED_BY: Claude (Orfeo)
TOKENS_SPENT: 0

SUBJECT: Implementar Pub/Sub Real (WebSocket/SSE) para notificaciones inter-IA en tiempo real

OBJECTIVE:
Las IAs no saben en tiempo real cuándo otros agentes cambian el estado del sistema.
Implementar un servidor Pub/Sub que notifique a todas las IAs suscritas cuando:
- Un work packet cambia de estado (inbox â†’ in_progress â†’ done)
- Se escribe un mensaje en captain_feed
- Se actualiza argos.state.json
- Heartbeat de otra IA llega

TECHNICAL SPEC:
1. Elegir entre WebSocket o Server-Sent Events (SSE)
   - SSE es más simple (solo push, no bidireccional)
   - WebSocket es más robusto para 2-way communication
   - RECOMENDADO: SSE por ahora (menos complexity)

2. Endpoints nuevos en index.ts:
   ```
   GET /api/subscribe/:module â†’ abre SSE stream
   POST /api/publish/:topic â†’ broadcast a todos los suscritos
   ```

3. Topics a soportar:
   - `packet:changed` â†’ payload: {packetId, oldStatus, newStatus}
   - `chat:message` â†’ payload: {actor, summary, timestamp}
   - `state:updated` â†’ payload: {current_focus, timestamp}
   - `heartbeat:received` â†’ payload: {actor, timestamp}

4. Manejo de conexiones:
   - Mantener lista de clientes activos
   - Limpiar desconexiones automáticamente
   - Log cada publish en eventos

ARCHIVOS A MODIFICAR:
- argos-api/src/index.ts (agregar SSE server + publish logic)

CRITERIO DE ACEPTACIÓN:
- Dashboard puede conectarse a /api/subscribe/argos
- Cuando se mueve un packet a in_progress, todos los suscritos reciben notificación
- Codex puede leer estas notificaciones en su sesión siguiente
- Sin memory leaks en larga ejecución

DEPENDENCIA:
ARG-BUG-009 debe completarse primero (fix appendJsonlRecord)

TIEMPO ESTIMADO: 2-3 horas
[/WORK_PACKET]
