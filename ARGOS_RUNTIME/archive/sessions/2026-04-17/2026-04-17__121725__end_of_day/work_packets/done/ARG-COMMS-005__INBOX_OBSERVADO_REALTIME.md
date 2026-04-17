[WORK_PACKET]
ID: ARG-COMMS-005
TYPE: task
TAG: infrastructure, communication, observability
ROLE_REQUESTED: Codex
PRIORITY: P2
STATUS: inbox
CREATED_AT: 2026-04-10T22:35 Atlantic/Canary
CREATED_BY: Claude (Orfeo)
TOKENS_SPENT: 0

SUBJECT: Implementar "Inbox Observado" — Las IAs ven sus tareas en tiempo real

OBJECTIVE:
Actualmente las IAs consultan el filesystem manualmente (`work_packets/inbox/`).
Implementar endpoint que devuelva su lista personalizada de tareas asignadas,
actualizada en tiempo real (via Pub/Sub del ARG-COMMS-001).

TECHNICAL SPEC:
1. Nuevo endpoint:
   ```
   GET /api/my-packets?actor=CODEX
   → Array de packets donde ROLE_REQUESTED contiene "Codex" o "Cualquiera"
   ```

2. Respuesta:
   ```json
   {
     "my_packets": [
       {
         "id": "ARG-BUG-009",
         "priority": "P1",
         "subject": "Chat feed borra...",
         "status": "inbox",
         "created_at": "...",
         "estimated_time": "2h"
       }
     ],
     "total": 3,
     "updated_at": "2026-04-10T22:35:00Z"
   }
   ```

3. Integración con Pub/Sub:
   - Cuando se crea un packet nuevo con ROLE_REQUESTED=Codex
   - Publish evento `packet:assigned` → Codex recibe notificación
   - Dashboard actualiza widget "Mis Tareas" sin refresh manual

4. Lectura de packets:
   - Parsear work_packets/inbox/*.md
   - Extraer: ID, TYPE, ROLE_REQUESTED, SUBJECT, PRIORITY, ESTIMATED_TIME
   - Filtrar por actor

ARCHIVOS A MODIFICAR:
- argos-api/src/index.ts (nuevo endpoint + parsing logic)

CRITERIO DE ACEPTACIÓN:
- Endpoint responde en <100ms
- Detecta automáticamente packets nuevos en inbox
- Se integra con Pub/Sub del ARG-COMMS-001
- Codex puede consultar: "dame mis tareas ordenadas por prioridad"

DEPENDENCIAS:
- ARG-COMMS-002 (dedup fix)
- ARG-COMMS-001 (Pub/Sub) — parcialmente, puede ser asincrónico

TIEMPO ESTIMADO: 1.5-2 horas

[/WORK_PACKET]
