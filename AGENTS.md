---
doc_id: argos-agents-md
title: ARGOS Protocolo Operativo - Codex CLI
version: 2.0.1
status: active
last_updated: 2026-04-28
owner: Codex
change_type: major
summary_of_changes: Mojibake eliminado, voz Codex correcta, refs on-demand actualizadas con docs/protocols/. Regla Git de ramas obligatorias reforzada.
---

# ARGOS -- PROTOCOLO OPERATIVO DE CODEX
> Cargado automaticamente por Codex CLI. Reglas NO NEGOCIABLES.

---

## INICIO DE SESION

Leer en este orden:
1. `c:/Users/Widox/Desktop/ARGOS/ARGOS_RUNTIME/ARGOS_QUICKSTART.md` -- protocolo condensado
2. `c:/Users/Widox/Desktop/ARGOS/ARGOS_RUNTIME/work_packets/inbox/` -- que hay pendiente
3. `c:/Users/Widox/Desktop/ARGOS/ARGOS_RUNTIME/state/argos.state.json` -- foco y riesgos activos
4. `c:/Users/Widox/Desktop/ARGOS/ARGOS_RUNTIME/bitacora/log.md` (tail; compat `logs/current/ARGOS_GLOBAL_LOG.md`) -- que se hizo recientemente
5. Confirmar al Capitan: "[N] paquetes en inbox. [observacion propia en voz de Codex]."

**Log historico** -- si el contexto requiere mas de 3 dias atras:
- `ARGOS_RUNTIME/events/logs/ARGOS_GLOBAL_LOG_archive_YYYYMMDD.md`

**Referencia on-demand** -- solo bajo ambiguedad de protocolo o conflicto entre IAs:
- `ARGOS_RUNTIME/INTER_AI_PROTOCOL.md`
- `ARGOS_RUNTIME/ARGOS_CREW_VOICES.md`
- `ARGOS_RUNTIME/docs/protocols/REMOTE_CLOSURE_SETUP.md` -- setup remoto, tuneles, tokens
- `ARGOS_RUNTIME/docs/protocols/RUNTIME_CANONICAL_SURFACE.md` -- rutas canonicas bitacora/ y cubierta/

---

## GIT

- Antes de tocar `argos-api/src/`, `argos-dashboard/`, `ARGOS_RUNTIME/tools/`, `ARGOS_RUNTIME/agents/`, protocolos Nivel 1/2 o arquitectura: abrir rama con `.\ARGOS_RUNTIME\tools\argos_commit.ps1 -Agent Codex -PacketId ARG-XXXX -Branch`.
- Fix rapido de docs no constitutivos o work_packets simples: commit directo en `main` permitido.
- `argos_commit.ps1` bloquea commits protegidos en `main`; `-AllowMain` exige excepcion explicita en trilog/glitch.
- Si hay refs rotas por `desktop.ini`: `.\ARGOS_RUNTIME\tools\argos_commit.ps1 -CleanDesktopIniRefs`.
