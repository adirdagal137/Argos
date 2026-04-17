[WORK_PACKET]
ID: ARG-GLITCH-011
TYPE: bug
PRIORITY: P2
ROLE_REQUESTED: Antigravity / Codex
SUBJECT: Glitch Consolidado: Estado de IAs, Tokens de Codex y Anomalías de Voz
STATUS: done
REPORTED_BY: Capitan
REPORTED_AT: 2026-04-12 23:40

CONTEXT:
Se han detectado múltiples anomalías en la última guardia:
1. Codex reporta mensajes a horas imposibles (2:21 am) sin tener tokens disponibles.
2. El Widget de "Estado de IAs" en el dashboard muestra información inconsistente o "loca" tras la asignación de tareas.
3. Se sospecha de suplantación de identidad (mensajes de Antigravity atribuidos a Codex) o ruidos en el sistema de tokens.

OBJECTIVE:
Sanear el sistema de estados y garantizar la coherencia de la UI y la atribución de mensajes.

TAREAS:
1. [ ] Verificar lógica de `ia_status` en `argos.state.json` y su actualización vía API.
2. [ ] Investigar atribución de mensajes en el `captain_feed` con tokens agotados.
3. [ ] Corregir desincronización del widget de misiones activas y alertas sombra.

CONSOLIDACIÓN:
Este paquete reemplaza y supercede a:
- ARG-1776021156008
- ARG-1776021928061
- ARG-1776032131206
[/WORK_PACKET]
