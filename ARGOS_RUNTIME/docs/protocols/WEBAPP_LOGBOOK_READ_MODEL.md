---
doc_id: webapp-logbook-read-model
title: ARGOS Webapp Logbook Read Model
version: 1.0.0
status: active
last_updated: 2026-04-27
owner: Codex
change_type: minor
summary_of_changes: Canoniza la vista tabular de Bitacora Trilog en 8 columnas y deja nota de deuda sobre rutas logs/current.
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

La superficie canonica legible es `ARGOS_RUNTIME/bitacora/`. Durante la fase de compatibilidad, la API conserva escritura primaria en `ARGOS_RUNTIME/logs/current/` y sincroniza los alias canonicos al arrancar, cada minuto y con `POST /api/runtime/canonical-sync`.

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
