# MEMORY RECALL

Esta vista devuelve al runtime la memoria legacy de Argos como lectura activa.

Principio:
- la fuente viva sigue en `ARGOS_RUNTIME`;
- `legacy/` sigue siendo el archivo congelado;
- `views/memory_recall/` es un espejo de lectura y meta-analisis;
- no reanima backends viejos ni convierte snapshots en fuente de verdad.

Fuentes recuperadas:
- `legacy/v1_0_x_google_native_snapshot_2026-04-09/argos_root_logs.snapshot.json`
- `legacy/v1_0_x_google_native_snapshot_2026-04-09/argos_shadow_log.snapshot.json`
- `legacy/logs_cache_2026-04-09/AG_log_2026-04-09.md`
- `legacy/logs_cache_2026-04-09/AG_shadow_log_2026-04-09.md`

Objetivo:
- devolver peso de memoria al navio;
- contar la historia de lo que paso;
- dejar anotadas las inconsciencias detectadas;
- mantener esa memoria lista para lectura por humano, UI o agente.
