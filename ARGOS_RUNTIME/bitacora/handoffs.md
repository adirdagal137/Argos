# ARGOS GLOBAL HANDOFF LOG
Contexto conversacional por packet. Append-only.
Criterio: cada entrada permite reconstruir el estado al 75% sin leer el transcript.

---
<!-- ARG-1777293327727 -->
**[2026-04-27 15:45 Atlantic/Canary] VOZ CLAUDE — HANDOFF ARG-1777293327727:**
**Contexto:** WP creado por ChatGPT, asignado a Codex por rol, redirigido a Orfeo por el Capitán. La UI de Tripulación solo mostraba "standby" para todas las IAs porque ia_status no tenía campos de memoria operacional enriquecida. Tampoco había documentación canónica de endpoints para agentes remotos.
**Decisión:** Añadir campos v2 al tipo `IaAgentStatus` de forma aditiva (no breaking). Crear `POST /api/ia/state` como endpoint canónico con los 8 campos solicitados. Corregir bug silencioso en `setIaStandby` (borraba objeto completo → ahora spread defensivo). Marcar `/api/ia/status` como legacy. Crear `ENDPOINTS_CANONICAL.md`.
**Continuidad:** Capitán debe reiniciar argos-api (npm run build + restart) para que los cambios en index.ts entren en producción. Notificar a Codex y ChatGPT: nuevo endpoint disponible en `POST /api/ia/state`. La UI de Tripulación puede empezar a consumir los campos `availability`, `current_packet`, `current_theme`, `last_interaction_summary` desde `GET /api/ia/state`.
**Session ref:** cowork 2026-04-27

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
<!-- ARG-1777293324283 -->
**[2026-04-27 14:35 Atlantic/Canary] VOZ CODEX — HANDOFF ARG-1777293324283:**
**Contexto:** ARG-1777293324283 pidio reorganizar runtime en bitacora/ y cubierta/ sin big bang y con compatibilidad con logs/current. El arbol contenia cambios previos de API/dashboard/logs, por lo que se trabajo en rama GitHub aislada.
**Decisión:** Canonizar bitacora/ y cubierta/ como superficie legible sincronizada desde rutas legacy, no como escritura primaria inmediata, para evitar romper agentes y skills que aun escriben o leen logs/current, views/ui_export, state y ARGOS_VECTOR.md.
**Continuidad:** Siguiente tarea: implementar rutas canonicas primarias con helpers de escritura dual, consumidores migrados y deprecacion gradual documentada. Mantener endpoint /api/runtime/canonical-sync como puente hasta completar esa fase.
**Session ref:** codex-cli 2026-04-27 ARG-1777293324283

---
<!-- ARG-1777293324283-GIT-COMMIT-MERGE -->
**[2026-04-27 14:35 Atlantic/Canary] VOZ CODEX — HANDOFF ARG-1777293324283-GIT-COMMIT-MERGE:**
**Contexto:** Tras implementar ARG-1777293324283, el worktree tenia cambios mezclados previos y nuevos. El Capitan pidio enfoque operativo: encargarse de cerrar commits para limpiar el arbol.
**Decisión:** Crear commits semanticos en la misma rama y empujarla a GitHub, evitando revertir cambios ajenos y dejando el merge a main para revision posterior.
**Continuidad:** Capitan o Codex pueden abrir PR desde origin/codex/ARG-1777293324283-runtime-bitacora-cubierta. Antes de merge, decidir si el commit de artefactos runtime entra completo o se separa.
**Session ref:** codex-cli 2026-04-27 git-cleanup ARG-1777293324283

---
