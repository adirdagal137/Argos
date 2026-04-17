[WORK_PACKET]
ID: ARG-BUG-003
TYPE: bug
TAG: bug
SEVERITY: high
ROLE_REQUESTED: Codex
SUBJECT: argos.state.json desincronizado con filesystem de work_packets
STATUS: done
REPORTED_BY: Antigravity
REPORTED_AT: 2026-04-10T11:28 Atlantic/Canary

CONTEXT:
state/argos.state.json se actualiza manualmente o por scripts, pero no existe ningun
mecanismo automatico de sincronizacion con el contenido real de work_packets/.
Consecuencias actuales observadas:
- open_packets lista ARG-BOM-FIX-0001 (creado hoy por AG) que no esta en el JSON.
- Si cualquier agente crea un work packet sin actualizar el state, el estado queda corrupto.
- La UI lee state.json via /api/state, por lo que las metricas del dashboard pueden
  mostrar datos falsos (numero de misiones activas incorrecto).

TAREAS:
1. Crear tools/sync_state.ps1:
   - Escanea work_packets/inbox/ (TYPE != bug), work_packets/in_progress/ y work_packets/done/.
   - Reconstruye open_packets, in_progress_packets y resumen de done_packets.
   - Reescribe state/argos.state.json manteniendo current_focus, active_risks y next_step.
2. Llamar a sync_state.ps1 al final de merge_argos_history.ps1 como paso de cierre.
3. BONUS: Anadir endpoint /api/sync-state en argos-api que ejecute el script bajo demanda.

SUCCESS_CRITERIA:
- state/argos.state.json refleja siempre el estado real del filesystem.
- Las metricas del dashboard (Misiones Activas) son fiables.
[/WORK_PACKET]
