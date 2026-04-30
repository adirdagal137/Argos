---
doc_id: argos-registry
title: ARGOS Registry - Indice Documental
version: 2.2.0
status: active
last_updated: 2026-04-27
owner: Codex
change_type: minor
summary_of_changes: Añadido modelo de lectura webapp para Bitacora Trilog y nota de deuda sobre logs/current.
---

# ARGOS REGISTRY
Indice documental del runtime. Version global: ver `ARGOS_RUNTIME/argos.version`.

---

## Lectura obligatoria (arranque diario)

| Documento | Descripcion |
|-----------|-------------|
| `ARGOS_RUNTIME/ARGOS_QUICKSTART.md` | Tarjeta operativa: inicio, cierre, actores, git, version |
| `ARGOS_RUNTIME/work_packets/inbox/` | Packets pendientes |
| `ARGOS_RUNTIME/state/argos.state.json` | Foco y riesgos activos |
| `ARGOS_RUNTIME/bitacora/log.md` | Tail de actividad reciente |

## Referencia on-demand

| Documento | Cuando usarlo |
|-----------|---------------|
| `ARGOS_RUNTIME/INTER_AI_PROTOCOL.md` | Ambiguedad de protocolo, conflicto entre IAs, implementacion |
| `ARGOS_RUNTIME/ARGOS_CREW_VOICES.md` | Voz y tono del agente si hay duda |
| `ARGOS_RUNTIME/docs/protocols/REMOTE_CLOSURE_SETUP.md` | Setup remoto, tuneles, tokens de agente |
| `ARGOS_RUNTIME/docs/protocols/WEBAPP_LOGBOOK_READ_MODEL.md` | Modelo de lectura visual de Bitacora Trilog en dashboard |
| `ARGOS_RUNTIME/docs/protocols/RUNTIME_CANONICAL_SURFACE.md` | Rutas canonicas bitacora/ y cubierta/ |
| `ARGOS_RUNTIME/ARGOS_VECTOR.md` | Estado estrategico y deuda tecnica activa |
| `ARGOS_RUNTIME/README.md` | Introduccion al runtime |

## Documentos por interfaz

| Interfaz | Archivo de arranque |
|----------|---------------------|
| Claude Code (Orfeo) | `CLAUDE.md` en root del repo |
| Codex CLI | `AGENTS.md` en root del repo |
| Otros agentes locales | `ARGOS_QUICKSTART.md` |
| Agentes cloud/remote | `GET /api/bootstrap` + `ARGOS_QUICKSTART.md` |

## Documentos legacy (no lectura operativa)

| Documento | Razon |
|-----------|-------|
| `ARGOS_RUNTIME/docs/legacy/TRILOG_ARGOS-VERSIONING-0001_Claude_2026-04-21.md` | Historial de propuesta de versionado |
| `ARGOS_RUNTIME/docs/legacy/refresh_msg_2026-04-21.json` | Snapshot legacy de Antigravity |

## Superficies vivas canonicas

| Log | Descripcion |
|-----|-------------|
| `bitacora/log.md` | Registro operativo activo |
| `bitacora/shadowlog.md` | Reflexiones e intuiciones de agentes |
| `bitacora/handoffs.md` | Handoffs obligatorios por packet |
| `bitacora/glitches.md` | Fallos de proceso y pipeline |
| `cubierta/feed.md` | Feed humano visible |
| `cubierta/state.json` | State activo del proyecto |
| `cubierta/vector.md` | Vector activo |
| `cubierta/inbox.md` | Resumen liviano del inbox |
| `cubierta/artefactos.md` | Indice de artefactos visibles |
| `events/logs/ARGOS_GLOBAL_LOG_archive_YYYYMMDD.md` | Archivo historico diario |

Compat 2026-04-27: `logs/current/`, `views/ui_export/captain_feed.jsonl`, `state/argos.state.json` y `ARGOS_VECTOR.md` siguen vigentes como escritura primaria mientras se migran agentes y skills.

## Herramientas

| Herramienta | Uso |
|-------------|-----|
| `ARGOS_RUNTIME/tools/argos_commit.ps1` | Commits y ramas por protocolo git |
| `ARGOS_RUNTIME/tools/tag_from_argos_version.ps1` | Tag git desde argos.version |
| `ARGOS_RUNTIME/tools/diagnostics/test_parser.js` | Diagnostico temporal de parsers |
