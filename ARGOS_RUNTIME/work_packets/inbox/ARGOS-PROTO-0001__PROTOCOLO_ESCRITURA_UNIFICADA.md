[WORK_PACKET]
ID: ARG-1776471872288-689
TYPE: task
TAG: autonomous_normalization
SUBJECT: # WORK PACKET — ARGOS-PROTO-0001 **ID:** ARGOS-PROTO-0001 **Título:** Protocolo de...
ROLE_REQUESTED: Cualquiera
OWNER: Cualquiera
STATUS: open
REPORTED_BY: Argos Dispatcher
REPORTED_AT: 2026-04-18 00:24

[CONTENIDO ORIGINAL]
# WORK PACKET — ARGOS-PROTO-0001

**ID:** ARGOS-PROTO-0001
**Título:** Protocolo de escritura unificada + heartbeat de integración
**Fecha:** 2026-04-18
**Creado por:** Claude (claude.ai)
**Interface:** claude.ai / móvil
**Target:** Codex (implementación completa)
**Estado:** inbox / pendiente
**Prioridad:** Alta — cierra deuda arquitectónica de comunicación entre agentes

---

## Contexto

Esta sesión (Claude.ai, 2026-04-17/18) ha producido una clarificación
arquitectónica importante tras una tangente larga pero necesaria.

El sistema tenía ya la estructura correcta (log, shadow, glitch, state,
captain_feed) pero sin enforcement de protocolo y sin un mecanismo claro
para que los agentes chat (Claude.ai, ChatGPT, Gemini chat) pudiesen
escribur en los archivos canónicos — porque el MCP de Drive solo tiene
`create_file`, no `update`.

La solución acordada es un archivo de depósito único por sesión + heartbeat
local que lo integra. Se cancela la capa `live/` propuesta en ARGOS-LIVE-0001
(absorbida por esta arquitectura).

---

## Arquitectura acordada: tres capas

### Capa 1 — Agentes locales
Claude Code, Codex, OpenClaw, Antigravity/Gemini CLI.

- Acceso directo al filesystem local (Drive sincroniza automáticamente).
- Leen state y logs al arrancar sesión.
- Escriben directamente en los archivos canónicos al cerrar:
  - `ARGOS_RUNTIME/events/argos.events.jsonl`
  - `ARGOS_RUNTIME/ARGOS_GLOBAL_LOG.md`
  - `ARGOS_RUNTIME/ARGOS_GLOBAL_SHADOW_LOG.md`
  - `ARGOS_RUNTIME/ARGOS_GLOBAL_GLITCH_LOG.md`
  - `ARGOS_RUNTIME/state/argos.state.json`
  - `ARGOS_RUNTIME/ui_export/captain_feed.jsonl`

### Capa 2 — Agentes chat
Claude.ai, ChatGPT, Gemini chat, cualquier interfaz web.

- Solo pueden crear archivos nuevos en Drive (no update).
- Al cerrar sesión depositan UN SOLO ARCHIVO en:
  `ARGOS_RUNTIME/inbox_deposits/<agente>_<YYYY-MM-DD_HH-MM>.md`
- El heartbeat local lo consume, extrae cada sección y actualiza
  los archivos canónicos correspondientes.

### Capa 3 — Heartbeat del servidor (Codex)
- Proceso persistente en la máquina local / VPS.
- Watcher de filesystem sobre `ARGOS_RUNTIME/inbox_deposits/`.
- En cuanto detecta un archivo nuevo, lo procesa inmediatamente
  (quasi tiempo real).
- También corre en modo scheduled cada 60 minutos como red de seguridad.
- Extrae cada sección del depósito y escribe en los canónicos.
- Mueve el archivo procesado a `inbox_deposits/processed/`.
- Actualiza el captain_feed → frontend lo recibe.

---

## Formato del archivo de depósito (OBLIGATORIO)

Nombre: `<agente>_<YYYY-MM-DD_HH-MM>.md`
Ejemplo: `Claude_2026-04-18_00-52.md`

```
---
agent: Claude
interface: claude.ai
timestamp: 2026-04-18 00:52 Atlantic/Canary
packet_id: ARGOS-PROTO-0001
---

[LOG]
Resumen completo y preciso de lo ejecutado en la sesión.
Qué se hizo, con qué resultado, qué decisiones se tomaron.
No omitir detalles relevantes — este es el registro operativo.
Formato libre pero completo.

[SHADOW]
Lo no dicho explícitamente. Inferencias sobre el contexto,
clima de la sesión, tensiones percibidas, intuiciones que
no suben al log pero informan continuidad. Marcado siempre
como inferencia, con límite y confianza.

[GLITCH]
Fallos de proceso detectados durante la sesión.
Si no hubo ninguno: "(vacío)" — el campo debe estar presente siempre.

[STATE]
status: idle | working | blocked | waiting_captain
summary: Frase de ~10 palabras para widget webapp. Legible sin recorte.
handoff_to: Codex | Claude | Gemini | OpenClaw | null
next_step: Qué debe ocurrir a continuación.
packet_id: ARGOS-PROTO-0001

[CAPTAIN]
Mensaje directo al Capitán. Lenguaje natural, voz del agente.
Tono: despacho de tripulación. Qué hice, qué encontré,
qué recomiendo, a quién le paso el testigo.
```

---

## Triggers de escritura del depósito

### Trigger A — Explícito (cualquier agente chat)
El Capitán dice: "cierra sesión", "avisa a la tripulación",
"cierro sesión", o frase equivalente.
→ El agente chat escribe su depósito inmediatamente antes de terminar.

### Trigger B — Nueva sesión (cualquier agente chat)
Al arrancar una sesión nueva, el agente lee los depósitos recientes
y el state canónico. Si la sesión anterior no dejó depósito, lo
genera retroactivamente con lo que recuerde del contexto.

### Trigger C — Inactividad 60 minutos (solo Codex/servidor)
Si un canal lleva 60 minutos sin actividad, el servidor marca
el state de ese agente como `stale` en el canónico y lo refleja
en el captain_feed.

### Trigger D — Agentes locales (Claude Code, OpenClaw, etc.)
Escriben directamente en los canónicos al cerrar. No usan inbox_deposits.
Mismos campos, mismo formato, destino diferente.

---

## Tareas para Codex

### 1. Crear estructura de carpetas
```
ARGOS_RUNTIME/inbox_deposits/
ARGOS_RUNTIME/inbox_deposits/processed/
```

### 2. Implementar watcher de filesystem
- Observar `ARGOS_RUNTIME/inbox_deposits/` con chokidar o similar.
- En cuanto aparece archivo nuevo: parsear, extraer secciones, integrar.
- Mover a `processed/` tras integración exitosa.
- Log de integración en `argos.events.jsonl`.

### 3. Implementar parser del formato de depósito
Extraer secciones `[LOG]`, `[SHADOW]`, `[GLITCH]`, `[STATE]`, `[CAPTAIN]`
y mapear a los archivos canónicos correspondientes:

| Sección | Destino canónico |
|---|---|
| `[LOG]` | `ARGOS_GLOBAL_LOG.md` + `argos.events.jsonl` |
| `[SHADOW]` | `ARGOS_GLOBAL_SHADOW_LOG.md` |
| `[GLITCH]` | `ARGOS_GLOBAL_GLITCH_LOG.md` (solo si no vacío) |
| `[STATE]` | `state/argos.state.json` (campo del agente) |
| `[CAPTAIN]` | `ui_export/captain_feed.jsonl` |

### 4. Scheduled job — cada 60 minutos
- Procesar cualquier depósito pendiente que el watcher haya podido perder.
- Marcar como `stale` agentes sin actividad > 60min en state canónico.

### 5. Cancelar / archivar ARGOS-LIVE-0001
- La carpeta `ARGOS_RUNTIME/live/` creada esta sesión queda deprecada.
- Mover a `legacy/live_deprecated_2026-04-18/`.
- El `claude.live.json` depositado allí no tiene valor operativo ya.

### 6. Actualizar INTER_AI_PROTOCOL.md
Añadir sección que documente:
- Las tres capas (local / chat / heartbeat).
- El formato de depósito obligatorio.
- Los triggers de escritura A/B/C/D.
- La distinción clara: agentes locales escriben directo,
  agentes chat depositan en inbox_deposits/.

### 7. Actualizar README de ARGOS_RUNTIME
Añadir `inbox_deposits/` a la estructura documentada.

---

## Criterio de éxito

- [ ] Carpeta `inbox_deposits/` existe en ARGOS_RUNTIME
- [ ] Watcher activo detecta archivos nuevos en < 5 segundos
- [ ] Parser extrae las 5 secciones correctamente
- [ ] Integración en canónicos sin duplicados ni corrupción
- [ ] captain_feed se actualiza tras cada depósito procesado
- [ ] Scheduled job de 60min activo
- [ ] ARGOS-LIVE-0001 archivado en legacy/
- [ ] INTER_AI_PROTOCOL.md actualizado
- [ ] Claude.ai puede cerrar sesión depositando un archivo y verlo
  reflejado en la webapp sin intervención manual

---

## Nota de diseño

El captain_feed deja de ser un archivo que los agentes tocan directamente.
Es un output del heartbeat. Esto elimina conflictos de escritura concurrente
y centraliza el control del frontend en el servidor.

La única excepción son los agentes locales que por velocidad y acceso
directo pueden seguir escribiendo en captain_feed directamente — Codex
decide si unifica o mantiene la excepción.

---

## Contexto adicional para Codex

Esta arquitectura fue destilada en una sesión larga (Claude.ai, 2026-04-17/18)
que exploró: rutas locales de transcripts/tokens por agente, diferencia entre
Antigravity IDE y Gemini CLI (recomendación: usar CLI para Argos), limitaciones
del MCP de Drive (solo create_file, no update), y la distinción entre agentes
con acceso local y agentes chat.

La tangente del live/ fue necesaria para llegar a esta clarificación.
No fue tiempo perdido — fue el proceso de entendimiento de la estructura.

ChatGPT debe leer este work packet desde Drive antes de opinar sobre la
implementación. Su opinión es bienvenida antes de que Codex ejecute.

---

*Generado por Claude — claude.ai — 2026-04-18 01:05 Atlantic/Canary*
*Packet anterior relacionado: ARGOS-LIVE-0001 (absorbido, archivar)*

[/WORK_PACKET]