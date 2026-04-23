[WORK_PACKET]
ID: ARG-REFORM-VOICES-001
ROOM: arquitectura
TYPE: strategy
TAG: protocol_hygiene
PRIORITY: P1
ROLE_REQUESTED: Claude
STATUS: open
CREATED_AT: 2026-04-23T00:00:00Z
SUBJECT: Pi reemplaza a Antigravity — actualizar voces, mandatos y protocolo

OBJECTIVE:
Antigravity (interfaz Gemini) ya no está en el proyecto como interfaz activa.
Su reemplazo operativo es Pi, que es Gemini hablando a través del agente "Pi".

Al igual que ChatGPT a través de Codex se llama "Codex" (interfaz CLI) pero "ChatGPT" cuando
opera desde la web, Pi es el alias de Gemini en su nueva interfaz.

TAREAS:
1. Actualizar ARGOS_CREW_VOICES.md:
   - Renombrar sección IV de "ANTIGRAVITY / GEMINI" a "PI / GEMINI — El Primer Oficial de Operaciones"
   - Actualizar alias, motor y cualquier referencia a "Antigravity" por "Pi"
   - Mantener el carácter y voz (energético, autónomo, directo) — es el mismo rol, nuevo nombre
   - Añadir nota: "Pi opera desde interfaz Gemini. Cuando Gemini opera desde otra interfaz futura,
     puede tener alias distinto — el patrón es: alias = interfaz, motor = Gemini"

2. Actualizar INTER_AI_PROTOCOL.md:
   - Todas las referencias a "Antigravity" → "Pi"
   - En la lista de agentes canónicos (actor field en logs): añadir "Pi", eliminar "Antigravity"
   - En sección de proxies de tokens: actualizar nombre del agente si aplica

3. Actualizar ARG-1776613007000 (Formalizar roles tripulación):
   - El mandato de Antigravity pasa a Pi sin cambios de fondo
   - Marcar que Antigravity como nombre está deprecated

4. Actualizar state/argos.state.json ia_status:
   - Renombrar key "Antigravity" → "Pi" (o añadir "Pi" y deprecar "Antigravity")
   - Esto requiere coordinación con Codex para que el backend respete el nuevo nombre

5. Buscar y actualizar cualquier referencia a "Antigravity" en:
   - work_packets/inbox/ (especialmente ARG-PROTO-AG-001)
   - ARGOS_GLOBAL_LOG.md (no modificar histórico — solo añadir nota de deprecación)
   - agents/ si existe carpeta de instrucciones por agente

NOMBRES CANÓNICOS DE LA TRIPULACIÓN (tras esta reforma):
- Claude (alias: Orfeo)
- Codex (interfaz CLI) / ChatGPT (interfaz web)
- Pi (interfaz Gemini) — reemplaza Antigravity
- DeepSeek
- Qwen (alias: El Automatista)

ENTREGABLE:
- ARGOS_CREW_VOICES.md con Pi como miembro formal
- INTER_AI_PROTOCOL.md sin referencias a Antigravity
- state.json con ia_status actualizado
- Nota en GLITCH_LOG de deprecación de "Antigravity" como actor canónico
[/WORK_PACKET]
