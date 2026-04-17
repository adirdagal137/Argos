[WORK_PACKET]
ID: ARG-1776613001000
ROLE_REQUESTED: Codex
SUBJECT: Archivar deuda histÃ³rica â€” packets done/done que siguen listados como open en argos.state.json
STATUS: open
PRIORITY: P1
ROOM: ARGOS
TYPE: maintenance
TOKENS_SPENT: 0

OBJECTIVE:
argos.state.json tiene una lista open_packets con decenas de entradas cuyo estado real en
packet_states es "open:done" o "done:done". El dispatcher los lee como activos en cada ciclo,
generando ruido y confusiÃ³n sobre quÃ© estÃ¡ realmente pendiente.

TAREAS:
1. Leer state/argos.state.json. Identificar todos los IDs en open_packets cuyo valor en
   packet_states sea "open:done", "done:done", "mitigated:done" o cualquier variante que indique
   cierre real.
2. Moverlos de open_packets a done_packets_summary (o eliminarlos de open_packets si ya estÃ¡n
   reflejados en done_packets_summary.total).
3. Actualizar done_packets_summary.total y done_packets_summary.latest_ids con los mÃ¡s recientes.
4. Verificar que in_progress_packets (ARG-1776035003286, ARG-1776038585290, ARG-1776040957963)
   tienen fichero real en work_packets/in_progress/ â€” si no existe el fichero, mover el ID a
   open_packets o done segÃºn su estado real.
5. Escribir el state.json resultante en UTF-8 sin BOM.
6. Confirmar vÃ­a GET /api/tasks que el tablero muestra solo packets con actividad real.

ENTREGABLE:
- argos.state.json con open_packets reducido a lo realmente activo.
- ConfirmaciÃ³n de que el dispatcher no re-infla la lista en el siguiente ciclo.

CONTEXTO:
- El archivo: c:/Users/Widox/Desktop/ARGOS/ARGOS_RUNTIME/state/argos.state.json
- Archivado histÃ³rico: state/argos.state.archive.json (los completados van ahÃ­)
[/WORK_PACKET]
