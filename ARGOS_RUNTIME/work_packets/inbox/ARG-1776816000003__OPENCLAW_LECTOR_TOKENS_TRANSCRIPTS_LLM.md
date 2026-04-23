[WORK_PACKET]
ID: ARG-1776816000003
TYPE: task
PRIORITY: P2
TAG: openclaw, desktop_control, tokens, transcripts, local_execution
ROLE_REQUESTED: Codex / Capitán
OWNER: Codex
STATUS: open
REPORTED_BY: Claude (Orfeo)
REPORTED_AT: 2026-04-22
RELATED: ARG-1776813558224, ARG-1776814778570, ARG-QWEN-001

CONTEXT:
El widget de tokens y transcripts del dashboard quedó a medias porque la extracción
de datos desde los entornos reales de cada LLM no está implementada. El planteamiento
original (desktop_sources.json + ARGOS_DESKTOP_SHARED/) era una carpeta intermedia
donde las IAs depositarían sus propios archivos — pero eso implica carga extra para
los agentes y no es sostenible sin un modelo local barato que lo automatice.

La idea correcta: OpenClaw, corriendo de forma autónoma en el escritorio del Capitán,
lee directamente las rutas de instalación de cada entorno LLM y extrae tokens y
transcripts sin que ninguna IA tenga que hacer nada. OpenClaw ya está integrado en
ARGOS vía webhook (/hooks/argos) y tiene Desktop Control Skill con acceso al sistema
de archivos local.

Rutas de instalación conocidas (a verificar con el Capitán):
- Claude Code / Cowork:  %APPDATA%\Claude\  (logs, sessions)
- ChatGPT (desktop):     %APPDATA%\ChatGPT\ o similar
- Gemini / Antigravity:  ruta de Gemini CLI o app desktop si existe
- Ollama/Qwen local:     %USERPROFILE%\.ollama\  o logs de OpenClaw gateway

OBJECTIVE:
Configurar OpenClaw como lector autónomo de tokens y transcripts desde las rutas
reales de instalación de cada LLM, sin intervención de las IAs ni carpetas intermedias.
Los datos llegan a ARGOS API vía webhook o endpoint existente, rellenando el widget
de tokens y el visor de transcripts.

TAREAS:
1. [ ] CAPITÁN: Identificar rutas reales en el equipo donde cada LLM guarda logs/sesiones:
       - Claude/Cowork (%APPDATA%\Claude)
       - ChatGPT desktop si está instalado
       - Gemini CLI / Antigravity
       - Ollama (%USERPROFILE%\.ollama)
       Compartir rutas para actualizar desktop_sources.json

2. [ ] CODEX: Actualizar desktop_sources.json con las rutas reales (no ARGOS_DESKTOP_SHARED)
       y ajustar los globs de búsqueda a los formatos reales de cada entorno

3. [ ] CODEX: Investigar formato de logs de Claude/Cowork en %APPDATA%\Claude\ para
       extraer tokens y transcripts — los archivos de sesión de esta conversación
       están en esa ruta y ya tienen estructura conocida

4. [ ] CAPITÁN / CODEX: Evaluar si OpenClaw puede ejecutar el script de ingesta
       (POST /api/desktop-import/run) de forma programada (cada hora) en lugar de
       depender del heartbeat de argos-api — esto lo haría completamente autónomo
       sin necesidad de modelo cloud

5. [ ] CODEX: Revisar por qué el widget de tokens quedó a medias y qué falta para
       que muestre datos reales una vez que desktop-import tenga rutas válidas

SUCCESS_CRITERIA:
- desktop_sources.json apunta a rutas reales de instalación de LLMs
- POST /api/desktop-import/run importa tokens y transcripts reales sin warnings
- Widget de tokens del dashboard muestra datos de al menos Claude y Ollama/Qwen
- OpenClaw ejecuta la ingesta de forma autónoma sin intervención de ninguna IA

TOKENS_SPENT: 0
[/WORK_PACKET]
