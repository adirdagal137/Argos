# WORK_PACKET PARA ANTIGRAVITY

**ID:** ARGOS-RUNTIME-0001
**Fecha:** 2026-04-09
**Solicitante:** Codex por instruccion del Capitan
**Rol solicitado:** Antigravity / ejecutor local con escritura real sobre Drive
**Estado:** Pendiente de ejecucion

## Objetivo
Materializar la capa canonica `ARGOS_RUNTIME` en formatos crudos portables y sacar del circuito critico cualquier dependencia de `gdocs`/`gsheets` para la comunicacion entre IAs.

## Contexto
En esta sesion se ha cerrado la decision arquitectonica siguiente:

- `ARGOS_RUNTIME` sera la capa comun de comunicacion entre Claude, Gemini/Antigravity y Codex.
- Los formatos canónicos seran `md`, `yaml`, `json` y `jsonl`.
- `Sheets` quedara como vista humana, no como backend.
- `GAS` quedara como adaptador minimo, no como cerebro total.
- La UI local llegara despues, leyendo esta capa comun.

La materializacion no se ha podido hacer desde la sesion actual porque aqui no hay herramienta para crear archivos crudos en la carpeta de Drive objetivo ni para mover artefactos arbitrarios a `legacy`.

## Tarea exacta
Crear esta estructura minima en Drive dentro de `ARGOS_RUNTIME/`:

```text
ARGOS_RUNTIME/
  README.md
  state/
    argos.state.json
    modules/
      SCM8.state.json
      Comenio.state.json
  work_packets/
    inbox/
    in_progress/
    done/
    archived/
  events/
    argos.events.jsonl
    modules/
      SCM8.events.jsonl
      Comenio.events.jsonl
  handoffs/
    pending/
    accepted/
    closed/
  views/
    sheets_export/
    ui_export/
  schemas/
    work_packet.schema.json
    event.schema.json
    state.schema.json
  locks/
  legacy/
```

## Contenido minimo requerido
### `README.md`
Debe explicar:
- que `ARGOS_RUNTIME` es la capa canonica comun;
- que `gdocs` y `gsheets` no son fuente de verdad operativa;
- que `Sheets` es vista humana;
- que `GAS` es adaptador minimo;
- que la UI local leera esta capa mas adelante.

### `schemas/work_packet.schema.json`
Schema minimo con estos campos:
- `id`
- `created_at`
- `created_by`
- `target`
- `module`
- `title`
- `objective`
- `inputs`
- `constraints`
- `expected_output`
- `status`
- `next_step`
- `evidence`

### `schemas/event.schema.json`
Schema minimo con estos campos:
- `timestamp`
- `actor`
- `module`
- `type`
- `summary`
- `artifacts`
- `verification`
- `next_step`

### `schemas/state.schema.json`
Schema minimo con estos campos:
- `module`
- `updated_at`
- `current_focus`
- `status`
- `open_packets`
- `active_risks`
- `next_step`
- `owner_hint`

### `state/argos.state.json`
Debe reflejar un estado minimo coherente con la decision actual:
- foco actual: materializacion de `ARGOS_RUNTIME`
- estado: `active`
- siguiente paso: crear schemas y primeros artefactos

### `events/argos.events.jsonl`
Debe contener al menos un primer evento que registre la institucion de `ARGOS_RUNTIME` como capa comun.

## Legacy / movimientos
Mover el contenido previo de `logs_cache/` a una ruta de legado dentro de `ARGOS_RUNTIME/legacy/` sin borrarlo.

Minimo esperado:
- `AG_log_2026-04-09.md`
- `AG_shadow_log_2026-04-09.md`
- `logs_cache/README.md`

Si prefieres conservar la carpeta completa, una solucion valida es:

```text
ARGOS_RUNTIME/legacy/logs_cache_2026-04-09/
```

con esos tres archivos dentro.

## Restricciones
- No reemplazar la nueva capa canonica por Google Docs o Google Sheets.
- No destruir historia: mover a `legacy`, no borrar.
- No introducir una estructura por voz; la capa debe ser comun.
- No asumir que Gemini puede habitar `gdocs`/`gsheets` como backend.

## Criterio de exito
La tarea se considera completa cuando exista en Drive:
- la estructura minima de carpetas;
- los schemas crudos;
- el primer `state`;
- el primer `events.jsonl`;
- y el legado anterior recolocado en `legacy/`.

## Entrega esperada
Dejar un artefacto de respuesta breve indicando:
- que se creo;
- que se movio a `legacy`;
- y cualquier desajuste encontrado entre lo esperado y lo materializado.

## Nota final
No hace falta aun construir la webapp local. Primero se consolida la capa que la UI leera.

