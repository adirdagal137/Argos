---
doc_id: webapp-logbook-read-model
title: ARGOS Webapp Logbook Read Model
version: 1.1.0
status: active
last_updated: 2026-04-29
owner: Codex
change_type: minor
summary_of_changes: Canoniza bitacora/cubierta como rutas primarias y legacy como fuente historica de lectura.
---

# ARGOS WEBAPP LOGBOOK READ MODEL

Referencia on-demand para cambios en la vista `Bitacora Trilog` del dashboard.

---

## Fuentes

La webapp lee la bitacora desde `/api/logbook`, que fusiona entradas de:

- `bitacora/log.md` para `Log`
- `bitacora/shadowlog.md` para `Sombra`
- `bitacora/handoffs.md` para `Handoff`
- `argos.glitches.jsonl` para `Glitches`
- `bitacora/legacy/ARGOS_GLOBAL_*.md` como historico de lectura

La superficie canonica de escritura es `ARGOS_RUNTIME/bitacora/`. `ARGOS_RUNTIME/bitacora/legacy/` solo conserva archivos historicos para que el API los siga cargando sin ensuciar los logs nuevos.

El feed visible de cubierta se escribe en `ARGOS_RUNTIME/cubierta/feed.jsonl`; la vista legible `ARGOS_RUNTIME/cubierta/feed.md` se genera desde `cubierta/feed.jsonl` y `cubierta/legacy/captain_feed.jsonl`.

---

## Columnas canonicas

La tabla visible de la webapp debe tener exactamente este orden:

1. `Timestamp`
2. `ID`
3. `Voz`
4. `Mision`
5. `Log`
6. `Sombra`
7. `Handoff`
8. `Detalles`

`Timestamp`, `ID` y `Voz` son columnas estrechas. Las cinco restantes tienen mayor ancho relativo, pero la tabla completa debe caber dentro del recuadro de bitacora sin scroll horizontal.

---

## Columna Detalles

`Detalles` no es un stream separado. Es una columna compuesta que lista, como parrafos sucesivos solo cuando existan:

- `Siguiente`
- `Aprendizaje`
- `Riesgos`
- `Glitches`

Si ninguno existe, la celda muestra un placeholder reflexivo (`sin detalles`).

---

## Interaccion

- Click en una fila: selecciona la fila y la expande verticalmente sin modificar anchuras.
- Click en una celda de la fila seleccionada: abre una burbuja anclada a esa celda y orientada hacia el centro visual del recuadro.
- La burbuja adapta su tamano al texto, con limites maximos para no salir del recuadro.
- Click en la burbuja: vuelve al estado de fila seleccionada.
- Click en otra fila: cambia la seleccion.
- Click en `ID`: abre el visor transversal; no debe activar expansion de fila/celda.
