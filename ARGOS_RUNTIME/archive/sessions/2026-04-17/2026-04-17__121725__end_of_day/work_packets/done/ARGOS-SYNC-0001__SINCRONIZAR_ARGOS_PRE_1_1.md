[WORK_PACKET]
ID: ARG-1775844378397-116
TYPE: task
TAG: autonomous_normalization
SUBJECT: # WORK_PACKET **ID:** ARGOS-SYNC-0001 **Fecha:** 2026-04-09 **Solicitante:** Codex por...
ROLE_REQUESTED: Cualquiera
OWNER: Cualquiera
STATUS: open
REPORTED_BY: Argos Dispatcher
REPORTED_AT: 2026-04-10 18:06

[CONTENIDO ORIGINAL]
# WORK_PACKET

**ID:** ARGOS-SYNC-0001
**Fecha:** 2026-04-09
**Solicitante:** Codex por instruccion del Capitan
**Rol solicitado:** Antigravity / Codex local con escritura real sobre el filesystem sincronizado
**Estado:** Inbox

## Objetivo
Cerrar la sincronizacion total de Argos pre-`1.1` para que `ARGOS_RUNTIME` sea la unica fuente de verdad operativa y todo log o backlog que aun viva en `gdocs`/`gsheets` quede integrado o degradado a vista, snapshot o legado.

## Dependencias
- `Argos/ARGOS_RUNTIME/README.md`
- `Argos/ARGOS_RUNTIME/INTER_AI_PROTOCOL.md`
- `Argos/ARGOS_RUNTIME/ARGOS_GLOBAL_LOG.md`
- `Argos/ARGOS_RUNTIME/ARGOS_GLOBAL_SHADOW_LOG.md`
- `Argos/ARGOS_RUNTIME/state/argos.state.json`
- `Argos/ARGOS_RUNTIME/events/argos.events.jsonl`
- `Argos/ARGOS__root_logs.gsheet`
- `Argos/ARGOS__shadow_log.gsheet`
- `Argos/ARGOS__00_registry__registry_1_0_1.yaml.gdoc`
- `Argos/ARGOS__03_protocols__inter_ai_protocol_1_0_1.md.gdoc`
- `Argos/ARGOS_ROUTER/`
- `Argos/02_RESPUESTA_A_01_PROPUESTA_MIGRACION_ANTIGRAVITY.md`
- `Argos/03_RESPUESTA_A_01_PROPUESTA_MIGRACION_ANTIGRAVITY.md`

## Contexto
- `ARGOS_RUNTIME` ya existe fisicamente y contiene `schemas/`, `state/`, `events/`, `work_packets/`, `views/`, `locks/` y `legacy/`.
- La ley viva actual dice que `md`, `yaml`, `json` y `jsonl` son canon y que `Sheets` es solo vista humana.
- Aun persisten cuatro desalineaciones raiz:
  - `ARGOS_RUNTIME/INTER_AI_PROTOCOL.md` sigue enviando handoffs a `ARGOS_ROUTER/` mientras el runtime ya tiene `work_packets/`.
  - `ARGOS__root_logs` y `ARGOS__shadow_log` siguen alojando memoria viva que no ha sido absorbida por completo por el runtime.
  - El registry y el protocol 1.0.1 en Google Docs siguen funcionando como gobierno paralelo.
  - La futura UI local y cualquier automatizacion por API aun no tienen un contrato unico de lectura y escritura.

## Tarea exacta
1. Inventariar todos los artefactos raiz de Argos y clasificarlos como `canonical`, `view`, `snapshot`, `adapter` o `legacy`.
2. Integrar el contenido vivo de `ARGOS__root_logs`:
   - `LOG_GENERAL` -> `ARGOS_RUNTIME/ARGOS_GLOBAL_LOG.md` + `ARGOS_RUNTIME/events/argos.events.jsonl`
   - `INTERACTIONS_LOG` -> `ARGOS_RUNTIME/events/argos.events.jsonl` solo para interacciones que cambian criterio; export bruto a `ARGOS_RUNTIME/views/sheets_export/argos_root_logs.interactions.json`
   - `PENDIENTES_GENERALES` -> paquetes reales en `ARGOS_RUNTIME/work_packets/inbox/`, `in_progress/`, `done/` o `archived/` segun estado
   - `GLITCH_LOG_GENERAL` -> `ARGOS_RUNTIME/ARGOS_GLOBAL_SHADOW_LOG.md` o export estructurado a `ARGOS_RUNTIME/views/sheets_export/`
   - `SCHEMA_ARGOS` -> vista/adaptador en `ARGOS_RUNTIME/views/sheets_export/argos_root_logs.schema.json`
3. Integrar el contenido vivo de `ARGOS__shadow_log`:
   - `SHADOW_EVENTS` -> `ARGOS_RUNTIME/ARGOS_GLOBAL_SHADOW_LOG.md`
   - `PATTERNS` y `ETHICS_LIMITS` -> export estructurado en `ARGOS_RUNTIME/views/sheets_export/argos_shadow_log.json`
   - `SCHEMA_SHADOW` -> vista/adaptador en `ARGOS_RUNTIME/views/sheets_export/argos_shadow_log.schema.json`
4. Resolver la duplicidad de handoff:
   - declarar `ARGOS_RUNTIME/work_packets/` como inbox canonico
   - degradar `ARGOS_ROUTER/` a adaptador temporal o moverlo a `ARGOS_RUNTIME/legacy/`
   - actualizar `ARGOS_RUNTIME/INTER_AI_PROTOCOL.md` para que no mande a dos rutas distintas
5. Resolver la duplicidad de gobierno:
   - mantener `ARGOS__00_registry__registry_1_0_1.yaml` y `ARGOS__03_protocols__inter_ai_protocol_1_0_1.md` solo como snapshots `1.0.1`
   - dejar el gobierno operativo actual en `ARGOS_RUNTIME/README.md`, `ARGOS_RUNTIME/INTER_AI_PROTOCOL.md`, `state/`, `events/` y `work_packets/`
   - mover o marcar como `legacy` los docs raiz obsoletos cuando la herramienta lo permita
6. Dejar lista la frontera para la interfaz local:
   - la UI HTML local debe leer y escribir solo sobre `ARGOS_RUNTIME`
   - si hay automatizacion por API, debe actuar como adaptador externo; no como fuente de verdad
   - no tratar la app de escritorio de ChatGPT como endpoint automatizable canonico

## Entregables esperados
- `ARGOS_GLOBAL_LOG.md` y `ARGOS_GLOBAL_SHADOW_LOG.md` sincronizados con la historia raiz relevante
- `argos.events.jsonl` actualizado con los eventos de gobernanza y migracion
- `work_packets/` poblado con los pendientes raiz que sigan vivos
- `views/sheets_export/` con exportes estructurados de las hojas raiz
- `ARGOS_ROUTER/` ya degradado a adaptador o trasladado a `legacy`
- una nota breve de verificacion indicando:
  - que hojas y pestañas fueron absorbidas
  - que artefactos quedan solo como vista o snapshot
  - que bloquea declarar `Argos 1.1`

## Restricciones
- No destruir historia; mover, congelar o etiquetar, no borrar.
- No devolver a `gdocs`/`gsheets` el papel de backend.
- No colapsar `log`, `interaction` y `shadow` en una sola capa.
- No sustituir `shadow_log` por KI canonico.
- No tratar la app de escritorio de ChatGPT como puerto de escucha.
- Si algo no puede moverse fisicamente, dejarlo registrado como `snapshot` o `legacy_pending_move`, no como canon.

## Criterio de exito
La sincronizacion pre-`1.1` se considera cerrada cuando:
- `ARGOS_RUNTIME` sea la unica fuente de verdad operativa;
- `ARGOS__root_logs` y `ARGOS__shadow_log` queden como espejo humano, snapshot o adaptador;
- `ARGOS_ROUTER` deje de competir con `work_packets/`;
- los docs raiz 1.0.1 de Google queden explicitamente fuera del circuito canonico vivo;
- la UI local pueda leer Argos sin consultar Google nativo como backend.

## Nota de criterio sobre automatizacion
La lectura de Gemini es basicamente correcta:
- la API de OpenAI permite automatizacion externa;
- la app de escritorio de ChatGPT no es un canal limpio de recepcion automatica;
- el camino elegante para Argos sigue siendo `UI local -> ARGOS_RUNTIME -> agente ejecutor`, no `UI local -> secuestro de la app visible`.

[/WORK_PACKET]