[WORK_PACKET]
ID: ARGOS-UI-002
ROLE_REQUESTED: Voz Antigravity / Ingeniero FullStack
SUBJECT: Conexión Backend-Frontend Argos Command Center
LEVEL_TARGET: Arquitectura Profunda
TASK_TYPE: Integración de Sistemas

OBJECTIVE: 
Acoplar la UI estática actual (Vanilla JS) con el servidor local Node.js (`argos-api`) para dotar de capacidad interactiva con el disco duro, permitiendo que la interfaz envíe órdenes orquestadas a Antigravity y redacte expedientes para Claude/ChatGPT.

DEPENDENCIES:
- `file:///C:/Users/Widox/.gemini/antigravity/scratch/argos-dashboard/app.js`
- `file:///C:/Users/Widox/.gemini/antigravity/scratch/argos-api/src/index.ts`

INPUT_SUMMARY:
Actualmente la UI vive bajo el sandbox del navegador (imposibilidad de interactuar con disco / terminal). Se debe usar el servidor Express (`argos-api`) construido como puente (Backend-For-Frontend) para salvar el formato Markdown directo al Drive cuando el Capitán ordene algo, facilitando la operativa asíncrona ("Alt+Tab") para los modelos de caja cerrada (Claude/GPT Desktop).

REQUIRED_OUTPUT:
- Servidor `argos-api` configurado y levantado aceptando llamadas `POST /command`.
- Código `app.js` con método `fetch()` enganchado a los botones de la UI enviando los comandos.
- Archivo de prueba de ping cruzado simulando la creación de un paquete.

CONSTRAINTS:
- **Restricción 1:** No intentar saltarse los protocolos de sandboxing del browser. Todo acceso al SO debe pasar por Express.
- **Restricción 2:** No diseñar integraciones o túneles hacia la app nativa de Claude, asumiendo su hermetismo. Para el diálogo multi-agente, la UI escupirá el paquete en Markdown al disco y el humano operará.
- **Inhumo/Siva:** Código liviano sin dependencias innecesarias en el cliente.

OUTPUT_FORMAT:
1. Código actualizado en el workspace local.
2. Confirmación de operatividad servidor <> cliente.
[/WORK_PACKET]
