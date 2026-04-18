# ARGOS RUNTIME

`ARGOS_RUNTIME` es la fuente de verdad operativa de Argos.

## Regla de oro
- `events/`, `state/`, `work_packets/`, `transcripts/` y los `ARGOS_GLOBAL_*.md` son capas vivas.
- `archive/` es historico. No se carga por defecto en el flujo diario.

## Estructura canonica (vivo)
- `ARGOS_GLOBAL_LOG.md`: trilog visible activo (sesion actual).
- `ARGOS_GLOBAL_SHADOW_LOG.md`: observaciones activas de sombra.
- `ARGOS_GLOBAL_GLITCH_LOG.md`: glitches activos de pipeline.
- `events/`: JSONL activo (`argos.events.jsonl`, `argos.glitches.jsonl`, `argos.tokens.jsonl`).
- `transcripts/`: transcripts activos (sesion actual).
- `inbox_deposits/`: deposito canonico para agentes chat (`<agente>_YYYY-MM-DD_HH-MM.md`) y cola `processed/`.
- `legacy/live_deprecated_2026-04-18/`: capa `live/` archivada por ARGOS-PROTO-0001.
- `state/argos.state.json`: solo packets activos.
- `work_packets/inbox|in_progress|done|archived|trash`: handoff canonico.
- `views/`: vistas de UI/exportes de apoyo (no backend principal).

## Estructura canonica (historico)
- `archive/sessions/YYYY-MM-DD/YYYY-MM-DD__HHMMSS__{start_of_day|end_of_day}/`
- `archive/legacy/`: backups y artefactos heredados.

## Protocolo de archivado de sesion
Se ejecuta por API:
- `POST /api/session/archive` con `mode: "start_of_day"` o `mode: "end_of_day"`.

Efectos:
1. Mueve logs activos, events, transcripts y feed al snapshot de sesion.
2. Opcional: mueve `work_packets/done` al snapshot.
3. Compacta `state/argos.state.json` moviendo `*:done` a `state/argos.state.archive.json`.
4. Resetea lanes activas para evitar inflado de contexto.

Script rapido:
- `tools/session_rollover.ps1 -Mode end_of_day`
- `tools/session_rollover.ps1 -Mode start_of_day`

## Nota de compatibilidad
- `events/` queda reservado a datos activos.
- Historial previo ubicado fuera de `archive/sessions` se considera legado y se migra gradualmente a `archive/legacy`.

## Depositos chat (ARGOS-PROTO-0001)
- Agentes locales escriben directo en canonicos (`ARGOS_GLOBAL_*`, `events/*.jsonl`, `state/argos.state.json`, `views/ui_export/captain_feed.jsonl`).
- Agentes chat depositan un unico markdown en `inbox_deposits/`.
- El heartbeat de `argos-api` procesa el deposito al detectarlo, integra secciones `[LOG] [SHADOW] [GLITCH] [STATE] [CAPTAIN]` y mueve el archivo a `inbox_deposits/processed/`.
- Red de seguridad: cada hora se reprocesan pendientes y se marca `stale` en `ia_status` cuando un agente supera 60 minutos sin actividad.
