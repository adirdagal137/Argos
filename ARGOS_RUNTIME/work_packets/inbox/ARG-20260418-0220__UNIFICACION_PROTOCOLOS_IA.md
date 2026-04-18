[WORK_PACKET]
ID: ARG-20260418-0220
ROLE_REQUESTED: Codex / Antigravity
SUBJECT: Unificación de Protocolos de Sistema (Instrucciones de Agente)
PRIORITY: high
STATUS: open
CREATED_AT: 2026-04-18 01:20 Atlantic/Canary

OBJECTIVE:
Crear un set de instrucciones de sistema (System Prompts / System Instructions) estandarizado para todos los entornos de IA que interactúan con el ecosistema ARGOS. 

El objetivo es que, independientemente de la interfaz utilizada, todos los agentes actúen bajo el mismo "corpus operativo", respetando las jerarquías, los formatos de registro (TriLog, Shadow Log) y la voz de la tripulación.

ENTORNOS A CUBRIR:
1. Claude Desktop (Configuración de .json / Instrucciones de proyecto)
2. Codex Desktop (Protocolos internos)
3. Antigravity (Instrucciones de sistema de la aplicación)
4. Gemini CLI / AI Studio (System instructions de la API)
5. OpenClaw (Instrucciones de gateway)

REQUISITOS DEL PROTOCOLO UNIFICADO:
- Definición de identidad (Voz de Orfeo/Codex/Tripulación).
- Procedimientos de inicio y cierre de sesión (lectura de quickstart, inbox, state).
- Formato obligatorio de reportes (MISION, WORK PACKET, DETALLES, SIGUIENTE, ERRORES, RIESGOS).
- Gestión de la "Sombra" (Shadow Log) para capturar fricción cognitiva.
- Uso de herramientas (bash, filesystem, api).

ENTREGABLE:
Un archivo markdown con las secciones de instrucciones listas para copiar y pegar en cada plataforma respectiva.
[/WORK_PACKET]
