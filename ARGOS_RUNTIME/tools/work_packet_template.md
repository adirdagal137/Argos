---
doc_id: argos-work-packet-template
title: ARGOS Work Packet Template
version: 2.0.0
status: active
last_updated: 2026-04-26
owner: Claude
change_type: major
summary_of_changes: Plantilla actualizada con campos canonicos actuales. Elimina campos legacy. Actores canonicos: Claude, Codex, Gemini, ChatGPT, OpenClaw, Qwen.
---

# WORK PACKET TEMPLATE

Copiar y rellenar. Eliminar secciones opcionales que no apliquen.

```
[WORK_PACKET]
ID: ARG-YYYYMMDD-TEMA  (o ID numerico asignado por dispatcher)
ROOM: ARGOS | SCICLASSMATE | COMENIO | XUANXU | GENERAL
TYPE: strategy | build | integration | maintenance | bug | risk | errand
TAG: tag1, tag2
SUBJECT: Titulo breve y descriptivo del objetivo
ROLE_REQUESTED: Claude | Codex | Gemini | ChatGPT | OpenClaw | Qwen
OWNER: Claude | Codex | Gemini | ChatGPT | OpenClaw | Qwen
STATUS: open
PRIORITY: high | medium | low
REPORTED_BY: Claude | Codex | Capitan | Dispatcher
REPORTED_AT: YYYY-MM-DD

[OBJETIVO]
Que se quiere conseguir. Breve y directo.

[CONTEXTO]
Por que existe este packet. Informacion de fondo necesaria para ejecutarlo.
Solo lo que no es derivable del codigo o del log reciente.

[TAREAS]
- [ ] Tarea 1: descripcion concreta
- [ ] Tarea 2: descripcion concreta
(usar subtareas si la tarea es compleja)

[CRITERIOS DE CIERRE]
- [ ] Criterio verificable 1
- [ ] Criterio verificable 2

[RIESGOS]
- Riesgo 1: descripcion y mitigacion
(omitir seccion si no hay riesgos identificados)

[NOTAS]
(opcional) Notas adicionales, decisiones de diseno, contexto extra.

[/WORK_PACKET]
```

## Reglas de uso

- **ID**: Si el dispatcher no lo asigna, usar formato `ARG-YYYYMMDD-TEMA` en mayusculas.
- **ROOM**: Obligatorio. `ARGOS` para trabajo de sistema, proyectos especificos en su room.
- **TYPE**: `bug` hace que aparezca en el tab Bugs del dashboard.
- **STATUS**: El dispatcher mueve `open` -> `in_progress` -> `done`. No editar manualmente salvo fallback.
- **ROLE_REQUESTED vs OWNER**: `ROLE_REQUESTED` es quien debe ejecutarlo. `OWNER` es quien es responsable del cierre.
- **Actores canonicos**: Claude, Codex, Gemini, ChatGPT, OpenClaw, Qwen. **No usar** Pi, Antigravity, DeepSeek.

## Regla de agente ante documento sin front matter (version 2.0+)

Todo agente que lea un archivo operativo Nivel 1 o 2 sin front matter YAML debe:
1. Anotarlo en su log como glitch menor: `[GLITCH-MENOR] <ruta> sin front matter`.
2. Continuar normalmente (no bloquear la tarea).
3. Incluir en su `next_step` del trilog: proponer añadir front matter al Capitan.

No es necesario abrir un work packet inmediato -- basta con documentarlo en el trilog.
