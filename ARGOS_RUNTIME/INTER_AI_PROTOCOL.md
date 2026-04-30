---
doc_id: inter-ai-protocol
title: Inter-AI Pact
version: 1.6.0
status: active
last_updated: 2026-04-26
owner: Claude
change_type: minor
summary_of_changes: Banner referencia on-demand, actores canonicos actualizados (Pi/Antigravity/DeepSeek deprecated), tabla lectura rutinaria vs referencia, mojibake corregido.
depends_on:
  - argos-quickstart@cualquiera
---

# INTER-AI PACT
## v1.6 - Ciclo de Vida Irrompible [2026-04-26]

> **REFERENCIA ON-DEMAND** -- No es lectura obligatoria diaria. Leer solo bajo ambiguedad de protocolo, conflicto entre IAs, implementacion del protocolo o auditoria. Para el arranque diario usar ARGOS_QUICKSTART.md.

Reglas oficiales de operacion para Claude, Codex, Gemini, ChatGPT, OpenClaw, Qwen y cualquier agente futuro que entre en Argos.

**Actores canonicos:** Claude, Codex, Gemini, ChatGPT, OpenClaw, Qwen.
**Deprecated (solo lectura historica):** Pi, Antigravity, DeepSeek.

---

## 1. Taxonomia de Registros (OBLIGATORIA â€” no confundir canales)

Existen exactamente 5 tipos de registro. Cada uno tiene destino, formato y criterio propios.

### 1.1 LOG — Acciones ejecutadas

**Que va aqui:** Hitos operativos reales. Lo que se hizo, cuando, con que resultado.
No va aqui: opiniones, riesgos no ejecutados, texto de conversacion literal.

**Archivos:**
- Resumen humano: `ARGOS_GLOBAL_LOG.md` (formato `**[YYYY-MM-DD HH:MM Atlantic/Canary] VOZ NOMBRE:**`)
- Registro estructurado: `events/argos.events.jsonl` (JSON con fields: timestamp, actor, module, type, summary, artifacts, verification, next_step, errors, risks, packet_id)

**Campos OBLIGATORIOS en cada entrada:**

| Campo | Tipo | Regla |
|-------|------|-------|
| `timestamp` | ISO 8601 | Obligatorio siempre |
| `actor` | string canónico | `Claude`, `Codex`, `Gemini`, `ChatGPT`, `OpenClaw`, `Qwen`. Nunca: “Pi”, “Antigravity”, “DeepSeek”, “IA”, “sistema”, “agente” |
| `packet_id` | string | Obligatorio. Sin packet_id la entrada es inválida (ORPHAN). |
| `summary` | string | Qué se hizo, resultado concreto. No el subject del packet. |
| `siguiente` | string | Próximo paso concreto. `””` solo si no hay continuidad posible. |
| `aprendizaje` | string | Qué aprendimos. `””` solo si ejecución sin novedad. |
| `glitches` | string | Fallos de proceso/pipeline detectados. `””` si ninguno. Errores de código van como work packet TYPE: bug, NO aquí. |
| `errors` | string | Errores + aprendizajes. `””` solo si ejecución limpia. |
| `risks` | string | Riesgos detectados. `””` si no aplica. |

**Regla de actor canónico (CRÍTICA):** El campo `actor` usa siempre el nombre canónico del agente. Nunca “Antigravity”, “IA”, “sistema” u otro alias. El heartbeat rechazará entradas con actor no canónico en depósitos.

**Ejemplo VÁLIDO:**
```
[2026-04-24 15:00 Atlantic/Canary] VOZ CLAUDE:
MISION: Reforma protocolo bitácora
WORK PACKET: ARG-REFORM-BITACORA-001
DETALLES: Actualizados INTER_AI_PROTOCOL.md v1.5 y ARGOS_QUICKSTART.md.
Añadida sección 2b (ciclo de vida), 1.7 (validaciones), ejemplo real de closure.
SIGUIENTE: Codex implementa validaciones ORPHAN en heartbeat (ARG-REFORM-BITACORA-001-IMPL).
APRENDIZAJE: El handoff era opcional en API — debe ser obligatorio para garantizar trazabilidad.
GLITCHES: Ninguno detectado en este cierre.
RIESGOS: Codex debe leer la propuesta antes de tocar index.ts.
```

**Ejemplo INVÁLIDO** (rechazado por heartbeat si viene en depósito):
```
VOZ IA: Hice cosas en el sistema.   ← actor no canónico, sin packet_id, sin detalle
```

### 1.2 TRANSCRIPT â€” Lo dicho FUERA de la webapp, sin duplicar el feed

**Que va aqui:** El razonamiento literal de la IA tal como ocurrio en su entorno nativo,
SOLO si ese contenido NO aparece ya en el captain_feed.
- Claude: lo que dijo en Claude Code (esta conversacion). NO en la webapp.
- ChatGPT/Codex: lo que dijo en la interfaz de ChatGPT. NO en la webapp.
- Gemini/Pi: lo que dijo en la interfaz de Gemini. NO en la webapp.

**Regla de no-duplicacion (CRITICA):**
El captain_feed ya contiene trilog (summary, details, nextStep, errors, risks) y chats de hitos.
El transcript NO debe replicar esos campos. El transcript captura el COMO y el POR QUE
en voz propia del agente â€” el razonamiento, las alternativas consideradas, las tensiones
percibidas â€” lo que informa el trabajo pero no cabe en los campos operativos del trilog.

En la practica: si lo que ibas a escribir en el transcript es esencialmente tu trilog
con otras palabras, no lo escribas. El transcript es lo que solo existe en la conversacion
fuera del webapp.

No va aqui: analisis operativos (eso es LOG), reflexiones de riesgo (SHADOW),
fallos de proceso (GLITCH), ni resumen de acciones que ya esta en el trilog.

**Archivos:** `transcripts/YYYY-MM-DD_AGENTE.md` â€” uno por agente por dia, append-only.

**Formato de cada bloque:**
```
<!-- ARG-XXXX -->
## [YYYY-MM-DD HH:MM] Packet: ARG-XXXX

**PROMPT (Capitan â†’ Agente):**
[texto literal del Capitan â€” capturado automaticamente]

**RESPONSE (Agente â†’ Capitan):**
[lo que la IA dijo fuera de la webapp â€” razonamiento, voz, decisiones de diseno]

---
```

**Captura automatica (Gemini/Pi, Codex/ChatGPT, Qwen):**
El servidor captura automaticamente el PROMPT del Capitan via POST /api/tasks.
La IA escribe su RESPONSE incluyendo `literalResponse` en POST /api/chat, o haciendo POST /api/transcript al cerrar.
El `literalResponse` debe ser el texto de la IA fuera del webapp â€” no un resumen del trilog.

**Captura manual (Claude / Claude Code):**
Claude hace POST /api/transcript al cierre con el texto sustantivo de esta conversacion.
El PROMPT ya esta capturado. El RESPONSE es el razonamiento clave de este exchange â€”
lo que no esta en el trilog ni en los chats del feed.

**Lectura por otras IAs (sin token — acceso público de solo lectura):**
```
# Todos los agentes para un packet — forma canónica:
GET http://localhost:8080/api/transcript/ARG-XXXX

# Alternativa query-param (equivalente):
GET http://localhost:8080/api/transcript/packet?packetId=ARG-XXXX

# Un agente específico para una fecha:
GET http://localhost:8080/api/transcript?agent=Claude&date=2026-04-13&packetId=ARG-XXXX

# Listar archivos disponibles para una fecha:
GET http://localhost:8080/api/transcript/list?date=2026-04-13
```

**Regla de cuando leer transcripts (evitar gasto de tokens innecesario):**
- Por defecto: el trilog + work packet son suficientes (80% de los casos).
- Leer transcript solo cuando: (a) hay ambiguedad sobre una decision de diseno,
  (b) hay conflicto entre enfoques de distintas IAs, o (c) se depura un problema
  complejo donde el contexto del razonamiento original es critico.
- Si el trilog es claro y no hay contradiccion, no leer transcripts.

### 1.3 GLITCHES â€” Errores en el flujo del pipeline
**Que va aqui:** Fallos en el PROCESO de trabajo entre agentes o entre capas del sistema.
Ejemplos: work packet enviado al agente equivocado, agente que no responde segun protocolo,
formato de handoff roto, exportacion fallida entre capas, parsing que falla por estructura.
No va aqui: errores de codigo interno del sistema (eso son BUGS), ni reflexiones (SHADOW).
**Archivos:**
- Resumen: ARGOS_GLOBAL_GLITCH_LOG.md (formato **[timestamp] G-NNN | VOZ:**)
- Registro estructurado: events/argos.glitches.jsonl

### 1.4 BUGS â€” Errores internos del sistema
**Que va aqui:** Fallos tecnicos en el codigo, schemas, encoding o infraestructura del runtime.
Ejemplos: BOM en JSON, mojibake en archivos MD, funcion de API con logica rota,
state.json desincronizado con filesystem, endpoint que devuelve datos incorrectos.
No va aqui: errores de coordinacion entre agentes (eso son GLITCHES), ni reflexiones (SHADOW).
**Archivos:**
- work_packets/inbox/ con TYPE: bug y TAG: bug (aparecen en tab Bugs del dashboard)

### 1.5 SHADOW â€” Material observado sin otro destino
**Que va aqui:** Todo lo que un agente observa, intuye, percibe o sospecha durante el flujo
y que no encaja en ninguno de los 4 canales anteriores. Friccion cognitiva, riesgo latente,
calibracion psiquica, pattern emergente, tension estrategica no resuelta, lectura intermedia.
El Shadow no es un vertedero. Es el espejo del sistema: lo que ve pero no puede aun ejecutar.
Criterio negativo: si cabe en LOG, TRANSCRIPT, GLITCH o BUG, no va en SHADOW.
**Archivo:**
- ARGOS_GLOBAL_SHADOW_LOG.md (formato **[YYYY-MM-DD HH:MM Atlantic/Canary] VOZ NOMBRE:**)

### 1.6 PROTOCOLO DE ESCRITURA UNIFICADA (ARGOS-PROTO-0001)
Arquitectura activa en tres capas:
1. **Agentes locales** (Claude Code, Codex, OpenClaw, Gemini CLI): escriben directo en canonicos.
2. **Agentes chat** (Claude.ai, ChatGPT, Gemini chat): API publica primaria (`/api/remote/closure`) + deposito fallback.
3. **Heartbeat local (argos-api)**: observa `inbox_deposits/`, integra secciones y mueve a `processed/`.

**Archivos:**
- `ARGOS_RUNTIME/inbox_deposits/<agente>_<YYYY-MM-DD_HH-MM>.md`
- `ARGOS_RUNTIME/inbox_deposits/processed/`
- `ARGOS_RUNTIME/legacy/live_deprecated_2026-04-18/` (archivo historico de la antigua capa live)

**Secciones obligatorias del deposito:** `[LOG]`, `[SHADOW]`, `[HANDOFF]`, `[STATE]`, `[CAPTAIN]`.
`[GLITCH]` es opcional — solo si hay fallos de proceso. No es TOKENS.

**Mapeo canonico (orden de escritura):**
- `[LOG]` → `ARGOS_GLOBAL_LOG.md` + `events/argos.events.jsonl` (EVENTS)
- `[SHADOW]` → `ARGOS_GLOBAL_SHADOW_LOG.md`
- `[HANDOFF]` → `ARGOS_GLOBAL_HANDOFF_LOG.md` (OBLIGATORIO — criterio 75%)
- `[GLITCH]` → `ARGOS_GLOBAL_GLITCH_LOG.md` + `events/argos.glitches.jsonl` (solo si no vacío)
- `[STATE]` → `state/argos.state.json` (`ia_status`) (EVENTS)
- `[CAPTAIN]` → `views/ui_export/captain_feed.jsonl` (FEED)

**Triggers de escritura:**
- A (explicito): cuando el Capitan pide cierre de sesion.
- B (nueva sesion): si no existe deposito previo, se genera deposito retroactivo.
- C (inactividad 60 min): heartbeat marca `stale` en `ia_status`.
- D (agentes locales): escriben directo en canonicos; no usan `inbox_deposits/`.

### 1.7 Validación de depósitos por heartbeat (ORPHAN)

El heartbeat valida cada depósito de `inbox_deposits/` antes de integrarlo:

| Condición | Comportamiento |
|-----------|---------------|
| Archivo no parseable (frontmatter roto, vacío) | Mueve a `processed/__invalid_<nombre>`. Entrada en events log. |
| `packet_id` vacío o ausente | Mueve a `processed/__orphan_<nombre>`. Entrada en glitch log. **No integra en canónico.** |
| Actor no canónico (no es Claude/Codex/Gemini/ChatGPT/OpenClaw/Qwen) | Mueve a `processed/__orphan_<nombre>`. Entrada en glitch log. **No integra en canónico.** |
| `[LOG]` vacío | Integra shadow/glitch/captain, omite entrada en LOG. Warning en glitch. |
| `[CAPTAIN]` vacío | Integra log/shadow/glitch, no emite al feed. Sin warning. |
| Depósito válido | Integra las 5 secciones. Mueve a `processed/<nombre>`. |

**Nota:** El mecanismo ORPHAN está pendiente de implementación en argos-api (ver ARG-REFORM-BITACORA-001-IMPL). Hasta entonces el heartbeat integra ciegamente con fallback `actor=ChatAgent` y `packet_id=N/A`.

### 1.8 Regla de agente ante documento sin front matter (versionado)

Todo agente que lea un archivo operativo Nivel 1 o 2 (ver REGISTRY.md) sin front matter YAML debe:
1. Anotarlo en su log como glitch menor: `[GLITCH-MENOR] <ruta> sin front matter`.
2. Continuar normalmente -- no bloquear la tarea en curso.
3. Incluir en `next_step` del trilog: proponer al Capitan anadir front matter.

No es necesario abrir un work packet inmediato; basta con documentarlo en el trilog.
La plantilla de front matter obligatoria esta en `ARGOS_RUNTIME/tools/work_packet_template.md`.

---

## 2. Ritual de inicio (cualquier agente, cualquier sesion)

Ver ARGOS_QUICKSTART.md para el ritual condensado (lectura obligatoria diaria).

El ritual completo canonico para referencia:
1. Leer work_packets/inbox/ completo.
2. Leer state/argos.state.json (foco y riesgos activos).
3. Leer ARGOS_QUICKSTART.md -- protocolo condensado.
4. Leer tail de `logs/current/ARGOS_GLOBAL_LOG.md` -- que se hizo recientemente.
5. (Solo si diagnosticas agentes chat) Leer inbox_deposits/ y processed/.
6. (Solo bajo ambiguedad de protocolo o conflicto) Leer INTER_AI_PROTOCOL.md o ARGOS_CREW_VOICES.md.
7. Confirmar al Capitan: “[N] paquetes en inbox. [Frase propia del agente en su voz.]”

### Lectura rutinaria vs referencia

| Documento              | Uso                                                      |
|------------------------|----------------------------------------------------------|
| ARGOS_QUICKSTART.md    | Obligatorio cada sesion                                  |
| work_packets/inbox/    | Obligatorio cada sesion                                  |
| state/argos.state.json | Obligatorio cada sesion                                  |
| `logs/current/ARGOS_GLOBAL_LOG.md` | Obligatorio (tail ~20 lineas)              |
| INTER_AI_PROTOCOL.md   | Solo bajo ambiguedad, conflicto, implementacion, auditoria |
| ARGOS_CREW_VOICES.md   | Solo si hay duda de voz/tono del agente                  |
| docs/protocols/REMOTE_CLOSURE_SETUP.md | Setup remoto, tuneles, tokens de agente |

### 2.1 Cloud Bootstrap (agentes sin filesystem local)

Para Claude/ChatGPT/Gemini (y cualquier IA futura cloud), el arranque canonico es:
1. `GET /api/bootstrap` con token de agente (`X-Argos-Agent-Token` o `Authorization: Bearer`).
2. `POST /api/ia/status` para marcar presencia.
3. Operar por API (`/api/tasks*`, `/api/chat`, `/api/remote/closure`) sin escritura directa a filesystem.

Regla de seguridad:
- Toda escritura externa a `/api/*` requiere token valido de agente.
- Sin token valido, la API rechaza con `401`.
- Un token no puede actuar como otro agente en endpoints con actor explicito.

### Nota sobre el ritual para agentes cloud

Los docs de protocolo completo (`INTER_AI_PROTOCOL.md`, `ARGOS_CREW_VOICES.md`) son **referencia**, no lectura obligatoria en cada sesion. El trilog + state.json + log tail son suficientes en el 90% de los casos. Leer los docs completos solo bajo ambiguedad de protocolo o conflicto entre IAs. Esto reduce significativamente el coste de tokens de arranque.

### Al tomar una tarea especifica

**Paso 1 â€” Leer el contexto del work packet:**
Siempre: leer el work packet + tail del LOG reciente. Eso es suficiente en la mayoria de casos.

Solo si hay ambiguedad de decision, conflicto entre IAs o contexto critico sin documentar:
```
GET http://localhost:8080/api/transcript?agent=AGENTE&packetId=ARG-XXXX
```
Si hay transcripts de otras IAs relevantes, leerlos tambien â€” pero solo bajo el mismo criterio.
No leer transcripts por defecto: el trilog + work packet ya tienen la decision trail.

**Paso 2 â€” Registrar inicio (OBLIGATORIO antes de ejecutar):**
```
POST http://localhost:8080/api/ia/start-task
{
  "packetId": "ARG-XXXX",
  "actor":    "NOMBRE",
  "summary":  "Frase humana de que vas a hacer (~80 chars max)"
}
```
Esto mueve el packet a in_progress y actualiza el widget Estado de IAs en tiempo real.
El campo `summary` es lo que el Capitan ve. Debe ser concreto, no el SUBJECT crudo del packet.

---

## 2b. Ciclo de vida de una orden — los 3 momentos

Todo trabajo en Argos pasa por exactamente 3 momentos. El feed del Capitán recibe **exactamente 2 mensajes por orden**: uno en el START y uno en el CLOSE. Nada en medio.

---

### MOMENTO 1 — INICIO DE SESIÓN (sin ligación a orden específica)

Antes de tomar cualquier tarea, todo tripulante lee (en orden):
1. `ARGOS_QUICKSTART.md` — protocolo condensado
2. `work_packets/inbox/` — qué hay pendiente
3. `state/argos.state.json` — foco y riesgos activos
4. `ARGOS_GLOBAL_LOG.md` (tail ~20 líneas) — qué se hizo recientemente

**Este momento NO genera entrada de log ni mensaje al feed.**
No hay fallback necesario: no se escribe nada.

---

### MOMENTO 2 — START DE ORDEN (al tomar un packet activo)

El tripulante que **ejecuta** la orden (no quien la prepara) llama:

```http
POST http://localhost:8080/api/ia/start-task
{
  "packetId": "ARG-XXXX",
  "actor":    "Claude|Codex|Gemini|ChatGPT|OpenClaw|Qwen",
  "summary":  "Frase concreta de lo que harás (~80 chars)"
}
```

El servidor automáticamente:
1. Mueve el packet de `inbox/` → `in_progress/`
2. Actualiza `ia_status` → `working` en `state.json`
3. Emite al feed del Capitán: `"[Actor] tomando misión: [summary]"`

**Fallback si API no disponible:**
Depositar en `inbox_deposits/<agente>_<YYYY-MM-DD_HH-MM>.md` con sección `[STATE]`:
```
status: working
summary: <descripción breve>
packet_id: ARG-XXXX
```
El heartbeat moverá `ia_status` a working en el siguiente ciclo.

**Regla crítica:** Sin `start-task`, el Capitán no sabe quién trabaja. El `ia_status` queda stale y dispara alerta tras 60 min de inactividad.

---

### MOMENTO 3 — CIERRE DE ORDEN (al completar el trabajo)

**Un cierre escribe exactamente en este orden: LOG → SHADOW → HANDOFF → EVENTS → FEED**
No hay sección TOKENS en el cierre (la captura de tokens es automática vía proxy).

**Camino primario — todos los agentes:**

```http
POST http://localhost:8080/api/remote/closure
Headers: X-Argos-Agent-Token: <token-agente>
{
  "agent":      "Claude|Codex|Gemini|ChatGPT|OpenClaw|Qwen",
  "interface":  "claude-code|codex|pi.ai|chatgpt.com|...",
  "timestamp":  "2026-04-24T15:00:00.000Z",
  "packet_id":  "ARG-XXXX",
  "trigger":    "task_completed|session_close|handoff",
  "sections": {
    "log":    "Qué se hizo, resultado concreto, artefactos generados — OBLIGATORIO",
    "shadow": "Reflexión interna — tensiones, riesgos percibidos, calibración — OBLIGATORIO",
    "glitch": "",
    "handoff": {
      "contexto":    "Situación que llevó a las decisiones tomadas — OBLIGATORIO",
      "decision":    "Decisión clave adoptada y su razón — OBLIGATORIO",
      "continuidad": "Qué sigue y quién debe continuar — OBLIGATORIO",
      "session_ref": "Referencia de sesión — OBLIGATORIO"
    },
    "state": {
      "status":     "idle",
      "summary":    "Estado tras el cierre",
      "handoff_to": "Codex|Claude|null",
      "next_step":  "Qué sigue"
    },
    "captain": "Mensaje directo al Capitán — lo que necesita saber, en voz del agente — OBLIGATORIO"
  },
  "mark_packet_done": false
}
```

**Regla del LOG:** Los campos SIGUIENTE, APRENDIZAJE, GLITCHES y RIESGOS deben aparecer
siempre en el texto de `sections.log`, aunque estén vacíos.
**GLITCHES en log:** errores de proceso/pipeline. Errores de código → work packet TYPE: bug.
**HANDOFF — criterio del 75%:** quien lea el handoff debe reconstruir el contexto y las razones
de las decisiones al menos al 75% sin necesidad de leer el transcript completo.

El servidor automáticamente:
1. Escribe `sections.log` en `ARGOS_GLOBAL_LOG.md` + `events/argos.events.jsonl` (EVENTS)
2. Escribe `sections.shadow` en `ARGOS_GLOBAL_SHADOW_LOG.md`
3. Escribe `sections.glitch` en `ARGOS_GLOBAL_GLITCH_LOG.md` (si no vacío)
4. Escribe `sections.handoff` en `ARGOS_GLOBAL_HANDOFF_LOG.md` (OBLIGATORIO)
5. Actualiza `ia_status` → `idle` en `state.json` (EVENTS)
6. Emite `sections.captain` al feed del Capitán (FEED)

**Fallback si API no disponible:**
Depositar en `ARGOS_RUNTIME/inbox_deposits/<agente>_<YYYY-MM-DD_HH-MM>.md`.
El heartbeat integra en el próximo ciclo. El depósito DEBE tener `packet_id` y actor canónico o irá a ORPHAN.

**Regla de bugs durante ejecución:**
```
sections.glitch: "[BUG] Descripción del bug — impacto observado"
```
No se necesita llamada separada al feed. El cierre lo captura todo.

**Regla del feed (CRÍTICA):**
El feed recibe exactamente **2 mensajes por orden**: START y CLOSE.
No se envían hitos intermedios. Los hitos van al log, no al feed.

---

### Tabla de validaciones que hace argos-api

| Campo | Endpoint | Validación actual | Fallo |
|-------|----------|------------------|-------|
| `packet_id` | `/api/remote/closure` | No vacío | 400 |
| `agent` | `/api/remote/closure` | No vacío | 400 |
| `sections.log` | `/api/remote/closure` | No vacío | 400 |
| `sections.shadow` | `/api/remote/closure` | No vacío | 400 |
| `sections.handoff` | `/api/remote/closure` | OBLIGATORIO: contexto+decision+continuidad+session_ref | 400 |
| `sections.captain` | `/api/remote/closure` | No vacío | 400 |
| `sections.state.status` | `/api/remote/closure` | idle/working/blocked/waiting_captain | 400 |
| `trigger` | `/api/remote/closure` | task_completed/session_close/handoff | 400 |
| Duplicado (agent+packet_id+timestamp) | `/api/remote/closure` | Idempotencia | 409 |
| `actor` canónico | `/api/remote/closure` | Pendiente impl. (ARG-REFORM-BITACORA-001-IMPL) | — |
| `packet_id` en deposit | heartbeat | Pendiente impl. → ORPHAN | — |
| Actor canónico en deposit | heartbeat | Pendiente impl. → ORPHAN | — |

**TOKENS:** El campo `sections.tokens` / `processTokens` está **desactivado** del protocolo de cierre.
Los tokens se capturan automáticamente vía proxy (ANTHROPIC_BASE_URL etc.). No enviar tokens en closure.

---

## 3. Rituales de cierre por capa (v1.5)

La escritura canonica usa este orden de 5 secciones obligatorias + 1 condicional:
`[LOG] [SHADOW] [HANDOFF] [STATE/EVENTS] [CAPTAIN/FEED]` + `[GLITCH]` solo si hay fallos de proceso.
No hay sección `[TOKENS]` en el cierre.

### 3.1 Agentes locales (Claude Code, Codex, Gemini CLI, OpenClaw)

- Escriben directo en canonicos.
- Pueden usar `POST /api/trilog` local para cierre operativo.
- `POST /api/transcript` se mantiene para trazabilidad literal.

### 3.2 Agentes chat con API publica (camino primario)

Endpoint unico:

```http
POST /api/remote/closure
Header: X-Argos-Agent-Token: <token-agente>
```

El body incluye:
- `agent`, `interface`, `timestamp`, `packet_id`, `trigger`
- `sections.log`, `sections.shadow`, `sections.glitch`, `sections.state`, `sections.captain`
- `mark_packet_done` (opcional)

Comportamiento:
- Integra las 5 secciones en canonicos.
- Actualiza `ia_status`.
- Emite evento al `captain_feed`.
- Si `mark_packet_done=true`, mueve packet a `done/` solo desde `inbox/` o `in_progress/`.
- Idempotencia: rechaza duplicados por `(agent, packet_id, timestamp)`.

### 3.3 Agentes chat sin API (fallback)

Si la API publica falla por timeout/5xx/sin red:
- Depositar markdown unico en `ARGOS_RUNTIME/inbox_deposits/`.
- El heartbeat de `argos-api` integra y mueve a `inbox_deposits/processed/`.
- Registrar en `[GLITCH]` que hubo fallback por caida de API.

### 3.4 Formato unico y mapeo canonico

El mismo schema aplica en los 3 caminos: Local directo / API publica / Deposito fallback.
Orden canónico de escritura: **LOG → SHADOW → HANDOFF → EVENTS → FEED**

Mapeo canonico:
- `[LOG]` → `ARGOS_GLOBAL_LOG.md` + `events/argos.events.jsonl` (EVENTS)
- `[SHADOW]` → `ARGOS_GLOBAL_SHADOW_LOG.md`
- `[HANDOFF]` → `ARGOS_GLOBAL_HANDOFF_LOG.md` (OBLIGATORIO)
- `[GLITCH]` → `ARGOS_GLOBAL_GLITCH_LOG.md` + `events/argos.glitches.jsonl` (solo si no vacío)
- `[STATE]` → `state/argos.state.json` (`ia_status`) (EVENTS)
- `[CAPTAIN]` → `views/ui_export/captain_feed.jsonl` (FEED)

### 3.5 Triggers de cierre (clarificados)

Trigger A (explicito):
- Frases canonicas de cierre: `cierra sesion`, `cierre de sesion`, `avisa a la tripulacion`, `packet done`.
- Fuera de esas frases: confirmar antes de cerrar.

Trigger B (retroactivo):
- Si no hay `packet_id` claro, NO escribir `[LOG]`.
- Solo permitir `[SHADOW]` con prefijo `(retroactivo, confianza baja)`.

Compatibilidad:
- `POST /api/transcript` sigue disponible, pero queda deprecado como camino principal de cierre para interfaces chat.
- Para chat, el cierre canonico es `POST /api/remote/closure` con fallback a `inbox_deposits/`.

## 4. Disciplina de Contabilidad (TOKENS) [DESACTIVADO DEL PROTOCOLO DE CIERRE]

> **Los tokens NO son parte del cierre de sesión.** No incluir `sections.tokens` ni `processTokens` en closures.
> La captura de tokens es automática vía proxy (ANTHROPIC_BASE_URL, etc.) cuando está configurado.
> El panel de tokens sigue disponible en `/api/tokens` para auditoría, pero los agentes no lo reportan manualmente.
> Para reactivar la disciplina de tokens, se requiere un work packet dedicado de tipo `protocol`.

El panel muestra **solo WORK_TOKENS** (coste real de proceso).
Los tokens se capturan automaticamente cuando el proxy esta activo.

### 4.1 Captura automatica por capa

**Agentes cloud (Claude, Codex, Gemini)**
argos-api actua como proxy transparente. Cada llamada a la API real pasa por:
```
ANTHROPIC_BASE_URL=http://localhost:8080/proxy/anthropic
GOOGLE_AI_BASE_URL=http://localhost:8080/proxy/gemini
OPENAI_BASE_URL=http://localhost:8080/proxy/openai
```
El proxy lee `usage` de la respuesta (o los eventos SSE finales en streaming) y escribe al ledger sin coste adicional.

**Qwen / OpenClaw (Ollama local)**
`callOllama()` extrae `prompt_eval_count` + `eval_count` de cada respuesta Ollama. se registran en el ledger como agente `OpenClaw`, scope `work`.

**OpenClaw (webhook)**
`POST http://localhost:8080/hooks/argos` recibe payloads de OpenClaw con `prompt_eval_count` / `eval_count` y los registra directamente.

### 4.2 processTokens en el trilog (fallback)
El campo `processTokens` sigue siendo valido en el cierre de tarea, pero es un **fallback manual** para sesiones donde el proxy no esta activo (API offline, env var no configurada). Si el proxy capturo los tokens reales, el campo se ignora en el panel -- el ledger ya tiene el dato correcto.

### 4.3 Regla del feed
Los tokens NO se escriben en el feed ni en el chat.
El feed es para comunicacion operativa: workpackets, hitos, bloqueos, decisiones relevantes.

### 4.4 Regla de panel
- Panel (`/api/tokens`): solo scope `work`.
- Scope `report` e `input`: fuera del panel principal, disponibles en auditoria.
- `tokens:hourly-sync` (SSE): cada hora argos-api publica totales agregados por agente. Solo lectura de ledger, sin coste.

### 4.5 Registro en Work Packet
`TOKENS_SPENT` en el .md sigue siendo obligatorio. Representa el gasto real de proceso (auto-capturado o estimado si proxy offline).

---

## 5. Handoff canonico

Todo traspaso de mision debe vivir en ARGOS_RUNTIME/work_packets/.

- inbox/: mision pendiente de tomar.
- in_progress/: mision activa.
- done/: mision completada.
- archived/: mision cerrada y congelada.

Campos de clasificacion (obligatorios en cada work packet):
- `ROOM`: `ARGOS | SCICLASSMATE | COMENIO | XUANXU | GENERAL`
- `TYPE`: `strategy | build | integration | maintenance | bug | risk | errand`

Defaults operativos del parser:
- Si falta `ROOM`, se asigna `GENERAL`.
- Si falta `TYPE`, se asigna `task` (compatibilidad historica).

Los work packets con TYPE: bug aparecen en la pestana Bugs del dashboard.

---

## 6. Regla de encoding (CRITICA â€” BOM mata el backend)

Todos los archivos del runtime se escriben en UTF-8 SIN BOM.

- Node.js: fs.writeFileSync(path, content, 'utf8') â€” correcto por defecto.
- PowerShell (correcto): [System.IO.File]::WriteAllText(path, content, [System.Text.Encoding]::UTF8)
- PowerShell (PROHIBIDO): Set-Content -Encoding UTF8 â€” escribe BOM en PS5, rompe JSON.parse().

---

## 6b. PolÃ­tica de Archivado Diario

### Log global
El `ARGOS_GLOBAL_LOG.md` se archiva diariamente.
- Archivo activo: `ARGOS_GLOBAL_LOG.md` â€” solo entradas del dÃ­a en curso + Ãºltimas 2-3 entradas del dÃ­a anterior como contexto.
- Archivo histÃ³rico: `events/logs/ARGOS_GLOBAL_LOG_archive_YYYYMMDD.md` â€” snapshot del log completo hasta esa fecha.
- Responsable del archivado: Qwen (cuando estÃ© operativo). Hasta entonces: manual o Pi.

### State de packets
El `state/argos.state.json` solo contiene packets con estado activo (`inbox`, `in_progress`, `open`, `parked`).
Los estados `done:done` y `mitigated:done` se mueven diariamente a `state/argos.state.archive.json`.
El backend debe respetar esta separaciÃ³n al escribir en state.json.

---

## 6c. Qwen como Servicio de Consulta (FUTURO â€” no implementado)

**VisiÃ³n:** Qwen (Automatista local, costo cero tokens) podrÃ­a ser llamado por otras IAs para:
- BÃºsqueda en logs histÃ³ricos archivados sin coste de tokens cloud
- NormalizaciÃ³n y limpieza de archivos (BOM, encoding, formato)
- ClasificaciÃ³n y routing de work packets entrantes
- Mantenimiento diario: archivado de logs, limpieza de state.json

**Interfaz prevista** (cuando OpenClaw estÃ© operativo):
```
POST http://localhost:18789/api/qwen/run
{ "task": "search_logs", "query": "ARG-XXXX decision trail", "scope": "events/logs/" }
```

**Estado actual:** Infraestructura lista (API /api/qwen/* en argos-api, OpenClaw gateway). Pendiente: verificar VBS launcher (ARG-QWEN-STARTUP-001) y configurar routing desde otras IAs.

---

## 7. Motores Autonomos y Gobernanza

### 7.1 EL DESPACHADOR (Dispatcher)
- Frecuencia: 60s.
- Funcion: Escanea el inbox. Inyecta ID, TYPE: task, TAG y Owner inferido a archivos crudos.
- Tambien captura automaticamente el PROMPT del Capitan en el transcript cuando crea un work packet.

### 7.2 LOLA (Vigia de la Sombra)
- Frecuencia: 120s.
- Funcion: Analiza el SHADOW_LOG.md y fricciones entre IAs.
- Accion Directa: Si detecta tension critica, inyecta Alerta de la Sombra (TYPE: risk) a la UI.

---

## 8. Frontera de automatizacion

UI local -> ARGOS_RUNTIME -> Despachador -> Agentes Ejecutores.
La API es el adaptador. La verdad vive en el filesystem.

---

## 9. Versionado del sistema

version: ver ARGOS_RUNTIME/argos.version

Reglas de incremento:
- patch (0.0.X): fix, limpieza o refactor sin cambio de comportamiento.
- minor (0.X.0): nuevo endpoint, nueva capa o nuevo mecanismo operativo.
- major (X.0.0): cambio arquitectonico que rompe compatibilidad.

Regla automatica:
- Al cerrar un work packet con TAG: protocol, argos-api incrementa minor automaticamente.

Git tag por hito:
- Script: ARGOS_RUNTIME/tools/tag_from_argos_version.ps1
- Hook: .githooks/post-commit
- Activacion local: git config core.hooksPath .githooks

---
## RESUMEN EJECUTIVO — Ciclo completo de una tarea

```
MOMENTO 1 — INICIO DE SESIÓN (no genera log ni feed)
  1. Leer ARGOS_QUICKSTART.md + inbox/ + state.json + tail LOG reciente
  2. Solo si hay ambigüedad o conflicto: GET /api/transcript/ARG-XXXX

MOMENTO 2 — START (1 mensaje al feed)
  3. POST /api/ia/start-task → “Claude tomando misión: [summary]” llega al feed
     Fallback si API caída: deposit [STATE] status=working en inbox_deposits/

MOMENTO 3 — CLOSE (1 mensaje al feed)
  Un cierre válido escribe: LOG → SHADOW → HANDOFF → EVENTS → FEED
  No hay TOKENS en el cierre.

  4. POST /api/remote/closure → log + shadow + handoff + glitch + state + captain en una llamada
     El servidor emite sections.captain al feed y mueve ia_status a idle.
     Fallback si API caída: deposit completo en inbox_deposits/ (con packet_id y actor canónico)
```

**2 mensajes por orden al feed: START y CLOSE. Nada más.**

Sin start-task = Capitán no sabe quién trabaja; ia_status queda stale.
Sin closure = packet huérfano; trilog guard dispara glitch.
sections.log/shadow/captain/handoff vacíos o ausentes = endpoint rechaza con 400.
LOG debe incluir SIGUIENTE, APRENDIZAJE, GLITCHES y RIESGOS aunque estén vacíos.
HANDOFF criterio 75%: contexto+decision+continuidad+session_ref permiten reconstruir el estado.
Transcript = opcional, solo si el razonamiento no cabe en sections.log.
