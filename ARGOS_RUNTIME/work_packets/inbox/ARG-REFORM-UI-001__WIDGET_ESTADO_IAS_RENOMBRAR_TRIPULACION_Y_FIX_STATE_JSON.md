[WORK_PACKET]
ID: ARG-REFORM-UI-001
ROOM: arquitectura
TYPE: task
TAG: ui, state
PRIORITY: P1
ROLE_REQUESTED: Codex
STATUS: open
CREATED_AT: 2026-04-23T00:00:00Z
SUBJECT: Widget "Estado de IAs" → renombrar "Tripulación" + fix state.json desincronizado

OBJECTIVE:
El widget "Estado de IAs" en el dashboard tiene dos problemas:
1. El nombre es técnico y frío — debe llamarse "Tripulación"
2. El state.json frecuentemente no refleja el estado real de los agentes, lo que hace que el
   widget muestre datos incorrectos o stale sin criterio claro

TAREAS:
1. Renombrar el widget en el dashboard:
   - Texto visible: "Estado de IAs" → "Tripulación"
   - Mantener funcionalidad idéntica

2. Diagnosticar por qué state.json no se actualiza correctamente:
   - Identificar los paths de escritura al ia_status (POST /api/ia/status, POST /api/ia/start-task,
     POST /api/remote/closure, heartbeat de inactividad)
   - Verificar que cada path escribe correctamente y que no hay race conditions
   - Añadir logging de escritura a ia_status para auditoría

3. Implementar validación de ia_status al arrancar el heartbeat:
   - Si un agente lleva más de 4h sin actualización → marcar stale automáticamente
   - Si un agente tiene status "in_progress" pero su packet está en done/ → corregir a standby
   - El heartbeat actual solo marca stale para Codex — generalizar para todos los agentes

4. Actualizar ia_status para incluir "Pi" y deprecar "Antigravity" (ver ARG-REFORM-VOICES-001):
   - Añadir key "Pi" al ia_status
   - Marcar "Antigravity" como deprecated (o eliminar si no hay datos históricos relevantes)

5. Documentar en INTER_AI_PROTOCOL.md la lógica de stale:
   - Cuándo se marca stale
   - Quién lo marca (heartbeat, no el agente)
   - Cómo se limpia (POST /api/ia/status con status activo)

SUCCESS_CRITERIA:
- El widget muestra "Tripulación" en el dashboard
- El ia_status refleja el estado real de los agentes con latencia < 5 min
- El stale se aplica de forma consistente a todos los agentes, no solo Codex
- Pi aparece en el widget; Antigravity desaparece
[/WORK_PACKET]
