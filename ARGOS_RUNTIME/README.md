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
