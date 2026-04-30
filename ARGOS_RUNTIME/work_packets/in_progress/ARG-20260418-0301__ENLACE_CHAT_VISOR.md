[WORK_PACKET]
ID: ARG-20260418-0301
ROLE_REQUESTED: Codex / Antigravity
SUBJECT: Enlace de IDs en Chat Feed con Visor de Eventos
PRIORITY: mid
STATUS: in_progress
CREATED_AT: 2026-04-18 02:01 Atlantic/Canary

OBJECTIVE:
Mejorar la navegación y trazabilidad en el dashboard permitiendo que los IDs de Work Packets que aparecen en los mensajes del Feed del Capitán (Chat) sean interactivos.

Al hacer clic en un ID dentro de un mensaje del chat, el sistema debe llamar a la función de apertura del panel lateral (probablemente `window.openEventInPanel`) para mostrar los detalles técnicos del evento o la misión relacionada.

REQUISITOS:
1. Identificar el renderizado de mensajes de chat en `app.js`.
2. Implementar un "regex" o lógica de detección de IDs (`ARG-XXXX`).
3. Envolver dichos IDs en un elemento clickeable (link o span con clase interactiva).
4. Vincular el evento `click` a la apertura del panel de detalles.

NOTAS TÉCNICAS:
- El dashboard ya dispone de `window.openEventInPanel(id)` que se usa en la lista de órdenes.
- El chat se alimenta de `/api/chat`.
[/WORK_PACKET]
