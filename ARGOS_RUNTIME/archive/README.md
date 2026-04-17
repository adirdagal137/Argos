# ARCHIVE

Carpeta historica de Argos. No forma parte del contexto vivo por defecto.

## Zonas
- `sessions/`: snapshots de rollover de sesion (inicio/fin de jornada).
- `legacy/`: artefactos antiguos, backups y estructuras pre-estandar.

## Convencion de sesiones
Ruta:
- `archive/sessions/YYYY-MM-DD/YYYY-MM-DD__HHMMSS__MODE/`

Contenido tipico:
- `logs/`, `shadow/`, `glitch/`, `events/`, `transcripts/`, `chat/`, `work_packets/`
- `session.archive.manifest.json`

## Regla operativa
- Todo lo vivo se escribe fuera de `archive/`.
- Todo lo cerrado se mueve a `archive/` mediante `/api/session/archive`.
