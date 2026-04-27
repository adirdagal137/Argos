# ARGOS GLOBAL HANDOFF LOG
Contexto conversacional por packet. Append-only.
Criterio: cada entrada permite reconstruir el estado al 75% sin leer el transcript.

---

<!-- DIRECTO-CAPITAN-20260427 -->
**[2026-04-27 14:30 Atlantic/Canary] VOZ ORFEO (CLAUDE) — HANDOFF DIRECTO-CAPITAN-20260427:**
**Contexto:** El Capitán detectó que Codex reportó su cierre como "LOG, EVENTS, TOKENS, SHADOW, FEED"
en lugar del correcto "LOG, SHADOW, HANDOFF, EVENTS, FEED". Esto reveló que el protocolo de cierre
tenía múltiples fuentes de verdad desincronizadas: SKILL.md, QUICKSTART, INTER_AI_PROTOCOL y index.ts
decían cosas distintas o contradictorias sobre qué secciones son obligatorias.
**Decisión:** Hacer HANDOFF obligatorio en todas las fuentes de verdad y en la validación de la API.
TOKENS desactivado del protocolo de cierre. LOG enriquecido con SIGUIENTE, APRENDIZAJE, GLITCHES, RIESGOS.
Razón: un protocolo que no se puede reforzar en la capa de validación no es un protocolo.
**Continuidad:** Capitán debe: (1) copiar new-session-cowork_SKILL_UPDATED.md al directorio del skill
(fuera del alcance de Cowork), (2) hacer restart de argos-api para activar la nueva validación,
(3) avisar a Codex que sus closures necesitan incluir sections.handoff o recibirán 400.
Crear work packet formal para esta reforma (TYPE: protocol, P1).
**Session ref:** cowork 2026-04-27

---
