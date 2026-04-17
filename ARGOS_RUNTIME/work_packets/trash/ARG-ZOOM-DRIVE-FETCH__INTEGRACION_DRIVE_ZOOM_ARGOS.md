[WORK_PACKET]
ID: ARG-1776250809221-519
TYPE: task
TAG: autonomous_normalization
SUBJECT: # WORK PACKET: ARG-ZOOM-DRIVE-FETCH__INTEGRACION_DRIVE_ZOOM_ARGOS **ID:**...
ROLE_REQUESTED: Antigravity / Gemini
OWNER: Antigravity / Gemini
STATUS: open
REPORTED_BY: Argos Dispatcher
REPORTED_AT: 2026-04-15 11:00

[CONTENIDO ORIGINAL]
# WORK PACKET: ARG-ZOOM-DRIVE-FETCH__INTEGRACION_DRIVE_ZOOM_ARGOS
**ID:** ARG-ZOOM-DRIVE-FETCH
**STATUS:** OPEN
**PRIORITY:** P2
**OWNER:** Antigravity (Gemini)
**SUBJECT:** Integración de Zoom y Drive con Argos para ingesta automática de sesiones.

## Contexto
El Capitán desea automatizar la descarga de resúmenes, transcripciones y pizarras de Zoom para que se guarden automáticamente en las carpetas de los alumnos en Google Drive, correctamente etiquetadas.

## Requerimientos
1. **Trigger Webhook:** Implementar un endpoint en `argos-api` para recibir notificaciones de Zoom (`recording.completed`).
2. **Descarga de Sesión:** El sistema debe usar la API de Zoom para descargar el transcript (.vtt), el audio/video (opcional) y las pizarras exportadas.
3. **Mapeo de Alumno:** Identificar al alumno basándose en el título de la reunión o el email de los participantes.
4. **Subida a Drive:** Organizar y subir los archivos a la carpeta correspondiente del alumno en `J:\Mi unidad\...`.
5. **Silencio Operativo:** **IMPORTANTE.** El proceso debe ser totalmente silencioso. NO debe emitir notificaciones al Captain Feed ni saturar los logs principales. La acción solo debe ser visible en el log de eventos técnico.

## Tareas
- [ ] Investigar autenticación Server-to-Server OAuth de Zoom.
- [ ] Configurar credenciales de Google Drive API en el entorno de Argos.
- [ ] Implementar endpoint de webhook con verificación de firma.
- [ ] Crear lógica de mapeo Meeting -> Alumno.
- [ ] Implementar pipeline de descarga y subida asíncrona.

## Siguiente Paso
Aprobación del plan de investigación por el Capitán.

[/WORK_PACKET]