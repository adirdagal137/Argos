[WORK_PACKET]
ID: ARG-1776816000003
TYPE: task
PRIORITY: P2
TAG: openclaw, desktop_control, automation, local_execution
ROLE_REQUESTED: Codex / Capitán
OWNER: Codex
STATUS: open
REPORTED_BY: Claude (Orfeo)
REPORTED_AT: 2026-04-22

CONTEXT:
OpenClaw ya está parcialmente integrado en ARGOS:
- Gateway en localhost:18789 (argos-api lo usa para webhook /hooks/argos)
- desktop_sources.json tiene una entrada "openclaw" apuntando a
  C:/Users/Widox/Desktop/ARGOS_DESKTOP_SHARED/OpenClaw (ruta no existe aún)
- desktop_ingest.state.json confirma que el proceso corre con actor OpenClaw/Antigravity
  pero la ruta da warnings de "no existe"
- openclaw.live.json está en legacy/ marcado como deprecado desde 2026-04-18

OpenClaw tiene una "Desktop Control Skill" (disponible en su marketplace) que ofrece:
- Control de ratón y teclado pixel-perfect
- Captura de pantalla de alta velocidad
- Reconocimiento de imagen (OpenCV)
- Gestión de ventanas y portapapeles

El valor para ARGOS: ejecutar automatizaciones de escritorio con coste cero de tokens
si se usa con Qwen/Ollama como modelo subyacente, o bajo coste si se usa Claude como
fallback solo para razonamiento complejo. El modelo híbrido local/cloud recorta costes
un 80-90% respecto a hacer todo vía Computer Use de Anthropic.

OBJECTIVE:
Instalar y configurar OpenClaw con la Desktop Control Skill, integrarlo con Qwen como
modelo primario y establecer el canal de comunicación con ARGOS API para que los work
packets con TAG desktop_control puedan ser ejecutados por OpenClaw/Qwen de forma autónoma.

TAREAS:
1. [ ] CAPITÁN: Verificar si OpenClaw está instalado en el equipo
       (buscar en %APPDATA% o %LOCALAPPDATA%\OpenClaw o "Claw Desktop")
       Si no: descargar desde https://openclawdesktop.com (instalación < 5 min, no requiere terminal)

2. [ ] CAPITÁN: Instalar la Desktop Control Skill desde el marketplace de OpenClaw
       Referencia: https://lobehub.com/skills/openclaw-skills-control

3. [ ] CAPITÁN: Configurar modelo en OpenClaw:
       - Modelo primario: Ollama local (localhost:11434, modelo qwen3:8b)
       - Modelo fallback: Claude (claude-sonnet-4-6) para razonamiento complejo
       Esto garantiza coste cero en tareas rutinarias de escritorio

4. [ ] CODEX: Crear carpeta ARGOS_DESKTOP_SHARED/OpenClaw en escritorio
       (eliminar warnings en desktop_ingest.state.json)

5. [ ] CODEX: Revisar y actualizar openclaw.live.json desde legacy/ a un nuevo
       state/openclaw.state.json con estructura compatible con ia_status actual:
       { agent, status, task, last_output, since, webhook_active, skill_version }

6. [ ] CODEX: Añadir en el Dispatcher (argos-api) soporte para TAG desktop_control:
       Si packet.TAG includes 'desktop_control' → POST http://localhost:18789/api/execute
       con { packetId, skill: "desktop_control", instructions: packet.OBJECTIVE }
       Igual que ARG-QWEN-DISPATCHER-001 pero para skills de escritorio

7. [ ] CODEX: Exponer endpoint GET /api/openclaw/status en argos-api que devuelva
       el estado del gateway (:18789) y si la Desktop Control Skill está activa

8. [ ] CLAUDE/ORFEO (próxima sesión): Documentar en INTER_AI_PROTOCOL.md el nuevo
       rol de OpenClaw como ejecutor de desktop tasks y su jerarquía de modelo
       (Qwen primario → Claude fallback)

DEPENDENCIAS:
- ARG-QWEN-DISPATCHER-001 (infraestructura de routing local — puede implementarse en paralelo)
- ARG-QWEN-001 (autonomía Qwen — comparte infraestructura Ollama)
- Ollama corriendo en localhost:11434 con qwen3:8b disponible

NOTAS TÉCNICAS:
- OpenClaw gateway: localhost:18789 (ya referenciado en INTER_AI_PROTOCOL.md)
- El webhook /hooks/argos ya existe en argos-api — OpenClaw puede usarlo para reportar resultados
- Desktop Control Skill requiere permisos de accesibilidad de Windows (UAC)
- Para tareas de automatización sin razonamiento → Qwen (costo: 0 tokens cloud)
- Para tareas que requieren decisión o contexto de sesión → Claude fallback
- Coste comparativo: Computer Use Anthropic ~1k-3k tokens/screenshot vs OpenClaw+Qwen ~0 tokens cloud

SUCCESS_CRITERIA:
- OpenClaw con Desktop Control Skill instalado y conectado a Qwen local
- Packet con TAG desktop_control se procesa vía OpenClaw/Qwen sin intervención del Capitán
- carpeta ARGOS_DESKTOP_SHARED/OpenClaw existe y desktop_ingest no da warnings
- GET /api/openclaw/status devuelve estado real del gateway
- Log muestra actor="OpenClaw" con resultado en events/argos.events.jsonl

TOKENS_SPENT: 0
[/WORK_PACKET]
