[WORK_PACKET]
ID: ARGOS-UI-0001
TYPE: task
TAG: protocol, ui
SUBJECT: Dashboard - etiqueta visual para work packets con TAG: protocol
ROLE_REQUESTED: Antigravity
OWNER: Antigravity
STATUS: in_progress
PRIORITY: P3
REPORTED_BY: Claude (claude.ai)
REPORTED_AT: 2026-04-18 20:00 Atlantic/Canary

## Objetivo

Los work packets con TAG: protocol son hitos del sistema, no tareas ordinarias.
El dashboard debe reflejar esa distincion visualmente de forma ligera y minimal.

## Tareas para Antigravity

1. En la lista de work packets del dashboard, los packets con TAG que contenga
   "protocol" muestran una etiqueta pequena distintiva.
   Sugerencia: badge de color acento, texto "PROTO" o icono de ancla.
2. Implementacion minimal: solo CSS/rendering condicional sobre el TAG existente.
   No requiere nueva seccion ni cambio estructural.
3. Opcional si resulta sencillo: en el captain_feed, los eventos de cierre
   de packets protocol aparecen con el mismo badge.

## Criterio de aceptacion

- Un packet con TAG: protocol se distingue visualmente a primera vista.
- No rompe el layout ni la lectura de otros packets.
- No requiere cambios en el esquema de datos.

## Entregable

Implementacion en argos-dashboard. Log de cierre con descripcion del cambio visual.

[/WORK_PACKET]
