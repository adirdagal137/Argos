[WORK_PACKET]
ID: ARG-BUG-003
TYPE: bug
TAG: bug
SEVERITY: high
ROLE_REQUESTED: Codex
SUBJECT: argos.state.json desincronizado con filesystem de work_packets - RESUELTO
STATUS: done
REPORTED_BY: Antigravity
REPORTED_AT: 2026-04-10T11:28 Atlantic/Canary
RESOLVED_AT: 2026-04-10T13:06 Atlantic/Canary
RESOLVED_BY: Codex

CAUSA RAIZ:
No habia una rutina automatica que regenerase state/argos.state.json a partir del estado real
de work_packets/inbox, work_packets/in_progress y work_packets/done.
Esto permitia desalineacion entre filesystem y metricas de la UI.

SOLUCION APLICADA:
1. Se crea tools/sync_state.ps1 para reconstruir open_packets, in_progress_packets y
   done_packets_summary desde filesystem, preservando current_focus, active_risks y next_step.
2. merge_argos_history.ps1 ejecuta sync_state.ps1 al final como cierre de consistencia.
3. argos-api expone POST /api/sync-state y ejecuta sync_state en GET /api/state y POST /api/tasks.
4. Se normaliza este paquete a STATUS: done dentro de work_packets/done para evitar falsos activos.
5. Se anaden guardarrailes de resiliencia:
   - Reintento de escritura del state en sync_state.ps1 ante I/O contention.
   - Fallback seguro si state supera 5MB o no parsea (evita bloqueos por snapshots corruptos).
   - Normalizacion de active_risks como array para mantener schema estable.
   - Timeout en argos-api/src/index.ts al ejecutar spawnSync de sync_state.

VERIFICACION:
- GET http://localhost:8080/health -> status ok.
- GET http://localhost:8080/api/state -> state sincronizado.
- POST http://localhost:8080/api/sync-state -> code 0 y conteos consistentes.
- sync_state.ps1 reporta: open_packets=4, in_progress_packets=0, done_packets=17.
- state/argos.state.json vuelve a tamano normal (~1.6KB) tras regeneracion segura.

SUCCESS_CRITERIA CUMPLIDOS:
- state/argos.state.json refleja el estado real de work_packets.
- Las metricas de misiones activas pasan por sincronizacion automatica y son fiables.

[/WORK_PACKET]
