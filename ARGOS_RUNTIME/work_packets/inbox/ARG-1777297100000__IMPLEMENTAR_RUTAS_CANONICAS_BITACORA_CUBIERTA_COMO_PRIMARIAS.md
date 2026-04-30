[WORK_PACKET]
ID: ARG-1777297100000
ROLE_REQUESTED: Codex
SUBJECT: Implementar rutas canonicas bitacora/cubierta como primarias
STATUS: open
ROOM: ARGOS
TYPE: task
PRIORITY: high
CREATED_BY: Codex
TOKENS_SPENT: 0

OBJECTIVE:
Convertir `ARGOS_RUNTIME/bitacora/` y `ARGOS_RUNTIME/cubierta/` desde superficie canonica sincronizada a rutas primarias reales de lectura/escritura, manteniendo compatibilidad inversa con las rutas legacy hasta que todos los agentes, skills y endpoints esten migrados.

CONTEXT:
ARG-1777293324283 dejo implementada una fase segura, no destructiva:

- `ARGOS_RUNTIME/bitacora/log.md` deriva de `logs/current/ARGOS_GLOBAL_LOG.md`.
- `ARGOS_RUNTIME/bitacora/shadowlog.md` deriva de `logs/current/ARGOS_GLOBAL_SHADOW_LOG.md`.
- `ARGOS_RUNTIME/bitacora/handoffs.md` deriva de `logs/current/ARGOS_GLOBAL_HANDOFF_LOG.md`.
- `ARGOS_RUNTIME/bitacora/glitches.md` deriva de `logs/current/ARGOS_GLOBAL_GLITCH_LOG.md`.
- `ARGOS_RUNTIME/cubierta/feed.md` deriva de `views/ui_export/captain_feed.jsonl`.
- `ARGOS_RUNTIME/cubierta/state.json` deriva de `state/argos.state.json`.
- `ARGOS_RUNTIME/cubierta/vector.md` deriva de `ARGOS_VECTOR.md`.
- `ARGOS_RUNTIME/cubierta/inbox.md` deriva de `work_packets/inbox/`.
- `ARGOS_RUNTIME/cubierta/artefactos.md` deriva de snapshots/exportes visibles.

La API actual materializa esos alias al arrancar, cada minuto y con `POST /api/runtime/canonical-sync`. Esto es un puente, no la meta final. La siguiente fase debe reducir la duplicacion y cambiar los puntos de escritura para que las rutas canonicas sean la fuente principal.

REFERENCE FILES:
- `ARGOS_RUNTIME/docs/protocols/RUNTIME_CANONICAL_SURFACE.md`
- `ARGOS_RUNTIME/tools/sync_runtime_canon.mjs`
- `argos-api/src/index.ts`
- `argos-api/dist/index.js`
- `ARGOS_RUNTIME/REGISTRY.md`
- `ARGOS_RUNTIME/ARGOS_QUICKSTART.md`
- `AGENTS.md`
- `CLAUDE.md`
- `ARGOS_RUNTIME/tools/gemini_append_bridge.js`
- `ARGOS_RUNTIME/tools/merge_argos_history.ps1`
- `ARGOS_RUNTIME/tools/skills/new-session/SKILL.md`
- `ARGOS_RUNTIME/tools/skills/new-session-cowork/SKILL.md`

IMPLEMENTATION PLAN:
1. Introducir helpers de rutas canonicas en `argos-api/src/index.ts`.
   - Definir constantes primarias para `BITACORA_*` y `CUBIERTA_*`.
   - Definir constantes legacy explicitas para `LEGACY_LOGS_CURRENT_*`, `LEGACY_CAPTAIN_FEED_PATH`, `LEGACY_STATE_PATH`, `LEGACY_VECTOR_PATH`.
   - Evitar nombres ambiguos como `ARGOS_GLOBAL_LOG_PATH` si ya no apuntan a la fuente primaria.

2. Crear helpers de escritura dual.
   - Para markdown append-only: escribir primero en `bitacora/*.md`, luego espejar a `logs/current/ARGOS_GLOBAL_*.md`.
   - Para `state`: escribir primero en `cubierta/state.json`, luego espejar a `state/argos.state.json`.
   - Para `vector`: escribir primero en `cubierta/vector.md`, luego espejar a `ARGOS_VECTOR.md`.
   - Para feed: decidir contrato antes de tocarlo:
     - opcion A: mantener `captain_feed.jsonl` como dato estructurado primario y `cubierta/feed.md` como vista humana;
     - opcion B: crear `cubierta/feed.jsonl` como primario estructurado y dejar `feed.md` como render humano.
   - Recomendacion: no convertir `feed.md` en fuente estructurada; crear `cubierta/feed.jsonl` si se quiere mover feed real.

3. Migrar escrituras API.
   - `/api/remote/closure`: LOG, SHADOW, HANDOFF, GLITCH, STATE y FEED deben pasar por helpers comunes.
   - `/api/trilog`: LOG, SHADOW, EVENTS, FEED y ia_status deben usar helpers comunes.
   - `appendToHandoffLog`: escribir en `bitacora/handoffs.md` y espejar a legacy.
   - glitches humanos: escribir en `bitacora/glitches.md` y espejar a legacy.
   - `readArgosState`/`writeArgosState`: leer preferentemente `cubierta/state.json`, fallback legacy si falta.
   - `ARGOS_VECTOR_PATH`: leer preferentemente `cubierta/vector.md`, fallback legacy si falta.

4. Migrar lecturas API/dashboard.
   - `/api/logbook` debe leer preferentemente `bitacora/log.md`, `shadowlog.md`, `handoffs.md`, `glitches.md`.
   - Mantener fallback a `logs/current/*` para instalaciones no migradas.
   - `/api/bootstrap` y `/api/ia/bootstrap` deben devolver referencias canonicas nuevas.
   - Busquedas transversales deben indexar canonicas y evitar duplicar resultados legacy cuando los contenidos coincidan.

5. Actualizar herramientas locales.
   - `sync_runtime_canon.mjs` debe cambiar de "legacy -> canonico" a verificador/reparador bidireccional o compatibilidad inversa "canonico -> legacy".
   - `gemini_append_bridge.js` debe apuntar a `bitacora/log.md` y/o usar helper comun si invoca API.
   - `merge_argos_history.ps1` debe leer canonicas primero.
   - `session_rollover.ps1` y archivado API deben archivar tanto canonicas como legacy, o generar legacy desde canonicas antes de archivar.

6. Actualizar skills/docs/instrucciones.
   - `AGENTS.md`, `CLAUDE.md`, `ARGOS_QUICKSTART.md` deben quedar sin ambiguedad: lectura diaria desde `bitacora/log.md`.
   - `INTER_AI_PROTOCOL.md` y `REMOTE_CLOSURE_SETUP.md` deben explicar que la API escribe canonico y conserva legacy por compatibilidad.
   - Skills `new-session` y `new-session-cowork` deben usar rutas canonicas.
   - `REGISTRY.md` y `versions.json` deben reflejar la fase de escritura primaria.

7. Deprecacion controlada.
   - Crear checklist `ARGOS_RUNTIME/reports/runtime_route_deprecation_YYYYMMDD.md`.
   - Listar todas las referencias `logs/current`, `ARGOS_GLOBAL_*`, `captain_feed.jsonl`, `state/argos.state.json`, `ARGOS_VECTOR.md`.
   - Clasificar cada referencia como:
     - migrada;
     - compat necesaria;
     - historica/no operativa;
     - pendiente.
   - No borrar legacy hasta que el checklist tenga cero consumidores operativos.

ACCEPTANCE CRITERIA:
- `npm run build` pasa en `argos-api`.
- Crear un cierre remoto escribe primero en:
  - `bitacora/log.md`
  - `bitacora/shadowlog.md`
  - `bitacora/handoffs.md`
  - `bitacora/glitches.md` si hay glitch
  - `cubierta/state.json`
  - feed estructurado canonico decidido
- Las rutas legacy quedan actualizadas por compatibilidad tras cada escritura.
- `/api/logbook` muestra los datos leyendo desde `bitacora/` con fallback legacy.
- `/api/runtime/canonical-sync` sigue existiendo, pero su rol documentado cambia a reparacion/compatibilidad, no a mecanismo principal.
- `rg -n "logs/current|ARGOS_GLOBAL_LOG|ARGOS_GLOBAL_SHADOW|ARGOS_GLOBAL_HANDOFF|ARGOS_GLOBAL_GLITCH|views/ui_export/captain_feed|state/argos.state|ARGOS_VECTOR" ARGOS_RUNTIME argos-api argos-dashboard` produce una lista explicada en el reporte de deprecacion.
- No se pierden entradas existentes de log, shadow, handoff, glitch, feed ni state.

RISKS:
- `feed.md` es humano, no JSONL. Si se usa como fuente primaria estructurada, se rompera UI/SSE/historial. Resolver con `cubierta/feed.jsonl` si se migra feed real.
- El runtime es activo y puede cambiar mientras se migra. Antes de tocar rutas primarias, hacer snapshot o rama.
- Algunos agentes remotos pueden tener rutas hardcodeadas en instrucciones antiguas. Mantener fallback hasta auditar skills e instrucciones.
- Duplicacion en busqueda/logbook si se indexan canonicas y legacy a la vez sin dedupe por contenido/refId.

NON_GOALS:
- No borrar `logs/current/`, `views/ui_export/`, `state/` ni `ARGOS_VECTOR.md` en esta fase.
- No rediseñar visualmente la dashboard salvo lo imprescindible para leer rutas nuevas.
- No mezclar esta migracion con saneamiento historico profundo de bitacora.

SUGGESTED BRANCH:
`codex/ARG-1777297100000-primary-runtime-routes`

[/WORK_PACKET]
