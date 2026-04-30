[WORK_PACKET]
ID: ARG-1776613007000
UPDATED_BY: Claude
UPDATED_AT: 2026-04-26T15:40:14.452Z
ASSIGNED_TO: Claude
ROLE_REQUESTED: Claude
SUBJECT: Formalizar roles de la tripulación en INTER_AI_PROTOCOL y ARGOS_CREW_VOICES
STATUS: open
PRIORITY: low
ROOM: ARGOS
TYPE: strategy
TOKENS_SPENT: 0

OBJECTIVE:
Los roles de la tripulación son implícitos, no declarados con suficiente dureza en el protocolo.
Claude actúa como navegadora en la práctica pero no está formalizado. Pi (antes Antigravity) tiene voz
pero mandato difuso. Esta ambigüedad hace que los roles se renegocien en cada sesión.

Formalizar los roles no es burocracia — es evitar que el Capitán haga de árbitro constante
sobre quién hace qué.

TAREAS:
1. Actualizar INTER_AI_PROTOCOL.md con una sección nueva "## 1b. División de Mandatos":
   
   CLAUDE (Navegadora)
   - Define enfoque y prioridades de sesión
   - Parte tareas y decide destinatario
   - Detecta contradicciones en protocolo o estado
   - Valida cierres de impacto arquitectónico
   - NO implementa código rutinario — lo delega a Codex
   
   CODEX (Mecánico)
   - Implementa, repara, refactoriza, testea
   - Dueño de argos-api, parsers, SSE, deduplicación, encoding
   - Endurece lo que Claude diseña
   - NO decide arquitectura — ejecuta con criterio técnico
   
   PI (Primer Oficial / Integrador)
   - Sostiene continuidad operativa entre sesiones
   - Resuelve fricciones entre capas (UI ↔ API ↔ protocolo)
   - Mantiene higiene de comunicación y reporting
   - Cubre huecos operativos sin invadir estrategia
   - Dueño del dashboard y la capa de presentación
   
   QWEN / DEEPSEEK (Recadero Local)
   - Tareas rutinarias: clasificación, file ops, transformaciones
   - Búsqueda en logs históricos sin coste cloud
   - No escribe en captain_feed salvo error crítico

2. Actualizar ARGOS_CREW_VOICES.md para reflejar el mandato operativo de cada agente
   (además del tono/voz que ya documenta).

3. Actualizar instrucciones individuales de cada agente (agents/) para incluir:
   - "Tu mandato es X. Fuera de X, delega."
   - Los límites explícitos de cada rol.

NOTA:
El mandato de Pi como "cohesionador" (rol antes asociado a Antigravity) es una evolución respecto a su rol actual
(infraestructura/UI). Introducirlo gradualmente: primero documentar la aspiración, luego
validar en sesiones reales antes de darle más autoridad cross-domain.

ENTREGABLE:
- Sección "División de Mandatos" en INTER_AI_PROTOCOL.md.
- ARGOS_CREW_VOICES.md actualizado.
- Instrucciones de agentes actualizadas con mandato y límites explícitos.
[/WORK_PACKET]


NOTE: Antigravity (deprecated) -> Pi (canonico actual).
