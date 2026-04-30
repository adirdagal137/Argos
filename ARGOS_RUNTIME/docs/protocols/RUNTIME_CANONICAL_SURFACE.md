---
doc_id: runtime-canonical-surface
title: ARGOS Runtime Canonical Surface
version: 1.0.0
status: active
last_updated: 2026-04-27
owner: Codex
change_type: minor
summary_of_changes: Canoniza bitacora/ y cubierta/ como superficie legible con compatibilidad logs/current, state y views.
---

# ARGOS RUNTIME CANONICAL SURFACE

Contrato de rutas para la reorganizacion gradual de `ARGOS_RUNTIME`.

---

## Rutas canonicas

### `ARGOS_RUNTIME/bitacora/`

| Archivo | Fuente legacy compatible | Uso |
|---------|--------------------------|-----|
| `log.md` | `logs/current/ARGOS_GLOBAL_LOG.md` | Log global vivo |
| `shadowlog.md` | `logs/current/ARGOS_GLOBAL_SHADOW_LOG.md` | Sombra/reflexion operativa |
| `handoffs.md` | `logs/current/ARGOS_GLOBAL_HANDOFF_LOG.md` | Handoffs obligatorios por packet |
| `glitches.md` | `logs/current/ARGOS_GLOBAL_GLITCH_LOG.md` | Glitches humanos de proceso/pipeline |

### `ARGOS_RUNTIME/cubierta/`

| Archivo | Fuente legacy compatible | Uso |
|---------|--------------------------|-----|
| `feed.md` | `views/ui_export/captain_feed.jsonl` | Feed humano visible para cubierta |
| `state.json` | `state/argos.state.json` | Estado activo del proyecto |
| `vector.md` | `ARGOS_VECTOR.md` | Vector activo |
| `inbox.md` | `work_packets/inbox/` | Resumen liviano del inbox |
| `artefactos.md` | `views/`, `events/`, `state/` | Indice de artefactos visibles |

---

## Compatibilidad

Esta fase no mueve ni borra rutas antiguas. La API sigue escribiendo en:

- `logs/current/ARGOS_GLOBAL_*.md`
- `views/ui_export/captain_feed.jsonl`
- `state/argos.state.json`
- `ARGOS_VECTOR.md`

`argos-api` materializa los alias canonicos al arrancar, cada minuto, y bajo demanda con:

```http
POST /api/runtime/canonical-sync
```

La misma sincronizacion existe sin servidor:

```powershell
node ARGOS_RUNTIME/tools/sync_runtime_canon.mjs
```

---

## Deprecacion gradual

1. Fase actual: `bitacora/` y `cubierta/` son superficie canonica legible; rutas legacy siguen siendo escritura primaria.
2. Fase siguiente: cambiar appends internos para escribir mediante helper comun y espejar en ambas superficies en la misma operacion.
3. Fase final: promover `bitacora/` y `cubierta/` a escritura primaria; dejar `logs/current/`, `views/ui_export/captain_feed.jsonl`, `state/` y `ARGOS_VECTOR.md` como aliases o snapshots de compatibilidad.

No ejecutar big bang mientras existan agentes remotos o skills que referencien rutas legacy.

---

## Checklist de referencias antiguas

Revisar y migrar en tandas:

- `AGENTS.md`, `CLAUDE.md`, `README.md`
- `ARGOS_RUNTIME/ARGOS_QUICKSTART.md`
- `ARGOS_RUNTIME/INTER_AI_PROTOCOL.md`
- `ARGOS_RUNTIME/REGISTRY.md`
- `ARGOS_RUNTIME/agents/*__SYSTEM_INSTRUCTIONS.md`
- `ARGOS_RUNTIME/tools/skills/*/SKILL.md`
- `argos-api/src/index.ts`
- `ARGOS_RUNTIME/tools/merge_argos_history.ps1`
- `ARGOS_RUNTIME/tools/gemini_append_bridge.js`

