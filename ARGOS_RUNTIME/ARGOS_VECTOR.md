---
doc_id: argos-vector
title: ARGOS Vector - Timon Vivo
version: 1.0.0
status: active
last_updated: 2026-04-26
owner: Claude
change_type: minor
summary_of_changes: Reescritura 2026-04-26. Bloqueos resueltos retirados, actores canonicos documentados, deuda activa y tabla de resueltos.
---

# ARGOS VECTOR — TIMÓN VIVO
**Actualizado:** 2026-04-26 20:00 Atlantic/Canary
**Responsable de actualización:** Claude / Orfeo (auditoría ARG-1777224272203)

---

## FOCO ACTUAL

Reconciliación de estado canónico antes de escalar funcionalidad.
La deuda crítica no es técnica: es que Argos toma decisiones sobre memoria que no puede
distinguir entre abierto, hecho, absorbido, duplicado u huérfano.

---

## PRIORIDADES VIVAS

1. **Reforma de actores canónicos en index.ts** (ARG-REFORM-ACTORS-001) — Codex
   Normalizar `normalizeAgentName` y `IaStatusMap`: Pi reemplaza Antigravity, OpenClaw reemplaza DeepSeek.
   Rama: `codex/arg-reform-actors-001`. **Bloqueante para heartbeat limpio.**

2. **Validaciones ORPHAN en heartbeat** (ARG-REFORM-BITACORA-001-IMPL) — Codex
   Rechazar depósitos sin packet_id o con actor no canónico. Implementación en index.ts.
   Rama: `codex/arg-reform-bitacora-001-impl`.

3. **Concilio v1** (ARG-CONCILIO-001) — Claude / ChatGPT / Pi
   Packet canónico restaurado. Ratificar scope con el Capitán y definir formato de convocatoria.

4. **Heartbeat/stale** (ARG-1776956082827, ARG-1777035550660, ARG-1777049435836)
   El stale falso de Pi y Claude se origina en: (a) índices de state.json desincronizados
   y (b) `normalizeAgentName` con actores obsoletos. Se resuelve con ARG-REFORM-ACTORS-001.

5. **Tokens widget** (ARG-1776354464819, ARG-1777035606073)
   El conteo de tokens no es métrica real hasta que el proxy esté activo para todos los agentes.
   Marcar como experimental en dashboard. Subtarea UI: ARG-1777035606073.

6. **Mojibake en source TypeScript** (ARG-REFORM-ACTORS-001 tarea 7, ARG-1777035412018)
   Strings literales en index.ts con encoding roto. El fix ya está documentado en
   ARG-REFORM-ACTORS-001 tarea 7 (línea ~6521). Codex debe incluirlo en su rama.

---

## DECISIONES VIGENTES

1. La carpeta local `C:\Users\Widox\Desktop\ARGOS` es la fuente de verdad.
   Drive for Desktop sincroniza automáticamente. **argos-api está en ruta canónica confirmada.**
2. El tunnel ngrok es la vía de acceso remoto actual (no Cloudflare — tunnel ya migrado).
   URL activa: devuelta por `/api/ia/bootstrap` en campo `tunnel_url`.
3. Autenticación al API: header `X-Argos-Agent-Token` con token por agente.
4. `POST /api/remote/closure` es el endpoint principal de cierre para agentes chat.
5. Agentes locales (Claude Code, Codex CLI) pueden usar `/api/trilog` como alternativa equivalente.
6. La webapp (argos-dashboard) SÍ escribe en ARGOS_RUNTIME con scope definido (ARGOS-ARCH-0004 — done).
7. Actores canónicos de la tripulación: **Claude, Codex, ChatGPT, Gemini, [slot_extra]**.
   Gemini habla con su propia voz desde cualquier plataforma (Pi, CLI, etc.) — siempre "Gemini".
   Aliases legacy de entrada (backward compat): Antigravity → Gemini, DeepSeek → OpenClaw.
   `slot_extra` reservado para futuras IAs sin necesidad de cambiar el schema.
8. state.json: la API lo sobreescribe periódicamente. Las correcciones de packet_states
   deben hacerse vía PATCH /api/workpackets/{id}, no por edición directa del fichero.

---

## DEUDA ACTIVA (requiere acción)

| Ítem | Responsable | Canónico | Notas |
|------|-------------|---------|-------|
| normalizeAgentName en index.ts | Codex | ARG-REFORM-ACTORS-001 | Rama obligatoria |
| Validaciones ORPHAN heartbeat | Codex | ARG-REFORM-BITACORA-001-IMPL | Rama obligatoria |
| Mojibake en strings TS | Codex | ARG-REFORM-ACTORS-001 tarea 7 | Incluir en rama |
| Concilio v1 scope ratificado | Capitán | ARG-CONCILIO-001 | Packet restaurado |
| Tokens widget marcado experimental | Codex/Pi | ARG-1777035606073 | UI menor |
| ARGOS_CREW_VOICES.md → Pi | ✅ Done | ARG-REFORM-VOICES-001 | Hecho en auditoría |
| schema_version en /api/remote/closure | Codex | ARG-REFORM-SCHEMA-001 | Fase 2 |

---

## BLOQUEANTES REALES

- **normalizeAgentName obsoleto** — hasta que Codex lo corrija, el sistema sigue reconociendo
  Antigravity/DeepSeek como actores primarios aunque el state.json tenga Pi/OpenClaw.
  Esto causa stale falsos, ORPHAN silenciosos y feed inconsistente.
- **packet_states en state.json** — la API sobreescribe el fichero. Las correcciones manuales
  de estado son volátiles. Único método fiable: PATCH /api/workpackets/{id}.

---

## RESUELTO DESDE v2026-04-18 (no reabrir)

- ARGOS-ARCH-0004: webapp escribe en ARGOS_RUNTIME — decidido y documentado.
- ARGOS-ARCH-0005: versionado global — done.
- Bearer token en /api/bootstrap — done (ARG-1776816000001).
- argos-api en ruta canónica — confirmado en auditoría 2026-04-26.
- Cloudflare Tunnel — migrado a ngrok como túnel activo.
- INBOX_REVIEW / INBOX_EXECUTE — archivados en legacy/ (deprecated 2026-04-09).
- Pi reemplaza Antigravity en CREW_VOICES — done en auditoría 2026-04-26.
- ARG-CONCILIO-001 restaurado como packet canónico real — done en auditoría 2026-04-26.
