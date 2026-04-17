[WORK_PACKET]
ID: ARG-QWEN-WEBHOOK-001
TYPE: task
PRIORITY: P2
TAG: webhook_processing, zoom, drive, openclaw
ROLE_REQUESTED: Codex
OWNER: Codex
STATUS: open
REPORTED_BY: Claude (Orfeo)
REPORTED_AT: 2026-04-16

CONTEXT:
OpenClaw ya tiene configurado el webhook de Zoom en /hooks/zoom (ver openclaw.json).
El ARGOS API ya tiene zoom.routes.ts con el endpoint /api/zoom/webhook (firma verificada,
estructura del evento parseada, pero processZoomRecording() está comentado).
La función DriveService existe en drive.service.ts pero está en modo MOCK (sin credenciales).

OBJECTIVE:
Activar el pipeline completo: Zoom dispara webhook → OpenClaw recibe → forwarda a ARGOS API
→ ARGOS descarga transcript/grabación → Drive guarda en carpeta del alumno.

TAREAS:
1. [ ] Decidir arquitectura de bridge: ¿OpenClaw webhook → llama directamente a ARGOS?
       O más simple: exponer el webhook directamente en ARGOS API y que Zoom llame ahí.
       Recomendación: usar ARGOS API directamente (ya tiene el endpoint), eliminar middleman OpenClaw
       para este caso salvo que se quiera procesamiento IA previo con Qwen.
2. [ ] Implementar processZoomRecording() en zoom.routes.ts:
       - Descargar transcript (.vtt) con token de Zoom API
       - Extraer nombre del alumno del título de la reunión
       - Llamar a driveService.findFolderForStudent(nombre)
       - Llamar a driveService.uploadFile(...)
3. [ ] Configurar credenciales Drive:
       - Service Account JSON → argos-api/credentials/service_account.json
       - Scope: drive.file (ya configurado en drive.service.ts)
4. [ ] Configurar credenciales Zoom:
       - ZOOM_SECRET_TOKEN en .env de argos-api
       - Server-to-Server OAuth app en Zoom Marketplace para descargar recordings
5. [ ] Añadir mapeo Meeting Title → Alumno (JSON config o lookup en Drive)
6. [ ] Silencio operativo: proceso no escribe en captain_feed, solo en events JSONL

DEPENDENCIAS:
- Google Drive Service Account (requiere acción del Capitán en Google Cloud Console)
- Zoom Server-to-Server OAuth app (requiere acción del Capitán en Zoom Developer)
- ARG-QWEN-DISPATCHER-001 (opcional — Qwen puede pre-procesar el payload antes de Drive)

NOTAS:
- OpenClaw webhook /hooks/zoom puede usarse si se quiere que Qwen clasifique
  o transforme el payload antes de que llegue al pipeline de Drive.
  No es estrictamente necesario para MVP.

SUCCESS_CRITERIA:
- Sesión de Zoom completada → 5 min después → transcript en carpeta Drive del alumno
- Sin intervención manual del Capitán
- Log de evento en events/argos.events.jsonl
[/WORK_PACKET]
