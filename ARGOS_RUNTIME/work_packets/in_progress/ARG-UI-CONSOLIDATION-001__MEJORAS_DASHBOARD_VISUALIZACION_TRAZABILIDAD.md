[WORK_PACKET]
ID: ARG-UI-CONSOLIDATION-001
TYPE: task
TAG: ui, dashboard, ux, trazabilidad
SUBJECT: Consolidacion de mejoras visuales y trazabilidad en el Dashboard
ROLE_REQUESTED: Antigravity
OWNER: Antigravity
STATUS: in_progress
PRIORITY: P3
REPORTED_BY: Antigravity (via Capitán)
REPORTED_AT: 2026-04-22 13:00 Atlantic/Canary

## Objetivo

Implementar un conjunto de mejoras en la interfaz de usuario (Dashboard) para elevar la densidad de informacion, facilitar el seguimiento de misiones y robustecer el visor de eventos (Hermeneutica).

## Tareas Sugeridas (Backlog)

1. **Visor de Eventos (Hermeneutica) Enriquecido**:
   - Agrupacion cronologica/origen de los hallazgos.
   - Opcion "Ver contexto" para mostrar lineas adyacentes en los resultados.
   - Inyeccion de una "Ficha del Packet" (Estado, Dueño, Tokens) cuando la busqueda sea un ID de mision.

2. **Evolucion de la Bitacora**:
   - Implementar un switch para vista "Timeline" (flujo cronologico con iconos de agentes) vs "Tabla".
   - Añadir barra de filtrado rapido por Agente, Estado o Texto en tiempo real.
   - Resaltado visual de entradas con "Errores/Aprendizajes" o "Riesgos".

3. **Vector de Ruta Inteligente**:
   - Tooltips con resumen de la ultima actividad al pasar sobre un item del vector.
   - Barras de progreso visuales para items vinculados a IDs de work packets.

4. **Experiencia de Usuario (UX)**:
   - Persistencia del estado de la UI (tab activa, filtros) mediante `localStorage`.
   - Efectos visuales de "resonancia" (glow/brillo) en widgets cuando se detecta actividad SSE relacionada.

## Criterio de Aceptacion

- Las mejoras se implementan de forma modular sin comprometer el rendimiento del dashboard.
- Se mantiene la estetica "Glass-Panel / LEET" del Navio Argos.
- La trazabilidad de los Work Packets es mas intuitiva y requiere menos clics.

## Entregable

Actualizacion de `argos-dashboard` (app.js, styles.css). Registro de cambios en la bitacora global tras la implementacion de cada modulo.

[/WORK_PACKET]
