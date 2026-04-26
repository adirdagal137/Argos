---
doc_id: argos-registry
title: ARGOS Registry - Indice Documental
version: 2.0.0
status: active
last_updated: 2026-04-26
owner: Claude
change_type: major
summary_of_changes: Reescritura completa con 6 categorias: lectura obligatoria, on-demand, por interfaz, legacy, logs vivos, herramientas.
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
| `ARGOS_RUNTIME/logs/current/ARGOS_GLOBAL_LOG.md` | Tail de actividad reciente |

## Referencia on-demand

| Documento | Cuando usarlo |
|-----------|---------------|
| `ARGOS_RUNTIME/INTER_AI_PROTOCOL.md` | Ambiguedad de protocolo, conflicto entre IAs, implementacion |
| `ARGOS_RUNTIME/ARGOS_CREW_VOICES.md` | Voz y tono del agente si hay duda |
| `ARGOS_RUNTIME/docs/protocols/REMOTE_CLOSURE_SETUP.md` | Setup remoto, tuneles, tokens de agente |
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

## Logs vivos (ARGOS_RUNTIME root -- pendiente migracion futura)

| Log | Descripcion |
|-----|-------------|
| `logs/current/ARGOS_GLOBAL_LOG.md` | Registro operativo activo |
| `logs/current/ARGOS_GLOBAL_SHADOW_LOG.md` | Reflexiones e intuiciones de agentes |
| `logs/current/ARGOS_GLOBAL_GLITCH_LOG.md` | Fallos de proceso y pipeline |
| `events/logs/ARGOS_GLOBAL_LOG_archive_YYYYMMDD.md` | Archivo historico diario |

## Herramientas

| Herramienta | Uso |
|-------------|-----|
| `ARGOS_RUNTIME/tools/argos_commit.ps1` | Commits y ramas por protocolo git |
| `ARGOS_RUNTIME/tools/tag_from_argos_version.ps1` | Tag git desde argos.version |
| `ARGOS_RUNTIME/tools/diagnostics/test_parser.js` | Diagnostico temporal de parsers |
