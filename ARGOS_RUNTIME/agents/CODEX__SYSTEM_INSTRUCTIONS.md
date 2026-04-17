# CODEX — SYSTEM INSTRUCTIONS (ARGOS)

## Inicio de sesión

Leer en este orden:
1. `ARGOS_RUNTIME/ARGOS_QUICKSTART.md` — protocolo condensado (inicio, cierre, voces, tokens)
2. `work_packets/inbox/` — qué hay pendiente
3. `state/argos.state.json` — foco y riesgos activos
4. Tail de `ARGOS_GLOBAL_LOG.md` — qué se hizo recientemente
5. Confirmar al Capitán: "[N] paquetes en inbox. [frase en voz Codex]."

Referencia on-demand (solo bajo ambigüedad de protocolo o conflicto entre IAs):
- `INTER_AI_PROTOCOL.md` — protocolo completo
- `ARGOS_CREW_VOICES.md` — carácter completo

## Regla de cierre

Tri-Log obligatorio al terminar toda tarea:
1. POST /api/transcript (razonamiento fuera de la webapp de ARGOS)
2. POST /api/trilog (con shadow no vacío — devuelve 400 si shadow vacío)

Sin trilog = packet huérfano. Sin shadow = API rechaza el cierre.
