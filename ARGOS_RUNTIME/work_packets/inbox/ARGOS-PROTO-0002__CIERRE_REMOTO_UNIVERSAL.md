[WORK_PACKET]
ID: ARG-1776474386624-573
TYPE: task
TAG: autonomous_normalization
SUBJECT: # WORK PACKET — ARGOS-PROTO-0002 **ID:** ARGOS-PROTO-0002 **Título:** Cierre Remoto...
ROLE_REQUESTED: Cualquiera
OWNER: Cualquiera
STATUS: open
REPORTED_BY: Argos Dispatcher
REPORTED_AT: 2026-04-18 01:06

[CONTENIDO ORIGINAL]
# WORK PACKET — ARGOS-PROTO-0002

**ID:** ARGOS-PROTO-0002
**Título:** Cierre Remoto Universal — API pública + Cloudflare Tunnel para agentes chat
**Fecha:** 2026-04-18
**Creado por:** Claude (claude.ai)
**Interface:** claude.ai
**Target:** Codex (implementación completa)
**Estado:** inbox / pendiente
**Prioridad:** Alta — cierra la última fisura del protocolo de comunicación inter-IA
**Depende de:** ARGOS-PROTO-0001 (done) — este packet es su continuación directa
**TYPE:** task
**TAG:** protocol_integrity
**ROLE_REQUESTED:** Codex

---

## Contexto

ARGOS-PROTO-0001 cerró el diseño del depósito único en `ARGOS_RUNTIME/inbox_deposits/`
y el heartbeat que lo integra en los canónicos. Funciona para Claude.ai (que tiene
MCP de Google Drive) y para Gemini chat si también lo tiene configurado.

Pero quedan fisuras reales:

1. **ChatGPT web no tiene MCP de Drive.** No puede depositar nada. Si trabaja en el
   proyecto, hoy el Capitán tiene que copiar-pegar manualmente.
2. **Cualquier interfaz futura** (Claude mobile app, Claude in Chrome, Cowork,
   otra IA que entre al proyecto) puede no tener acceso a Drive pero sí puede
   hacer HTTP.
3. **El depósito por Drive tarda en sincronizar** — Drive for Desktop no es
   instantáneo; puede haber 30-120s de latencia entre que el agente escribe y
   el heartbeat ve el archivo. Aceptable, pero no ideal.
4. **El protocolo v1.3 mezcla dos sistemas de cierre** (sección 3 con
   `POST /api/transcript` + `POST /api/trilog`, y sección 1.6/3.3 con depósito
   único) sin aclarar cuándo aplica cada uno. Hay que unificar.
5. **El trigger A ("el Capitán dice cierra sesión")** es heurística de lenguaje
   natural sin frase canónica. El agente puede interpretar mal.
6. **El trigger B (retroactivo)** permite escribir LOG con memoria alucinable.
   Riesgo de contaminar la bitácora con invenciones.

La solución es exponer `argos-api` al exterior con Cloudflare Tunnel y ofrecer
un endpoint unificado de cierre que cualquier interfaz pueda llamar. El
depósito por Drive se mantiene como fallback robusto — si el tunnel cae o el
agente no tiene red al servidor, escribe a Drive y el heartbeat lo recoge.

---

## Arquitectura

### Capa 1 — Agentes locales (sin cambios)
Claude Code, Codex, Gemini CLI, OpenClaw. Escriben directo a canónicos.

### Capa 2 — Agentes chat (MODIFICADA)
Dos caminos:

**Camino primario (API pública):**
```
POST https://argos.<tu-dominio>.com/api/remote/closure
Headers: X-Argos-Agent-Token: <token del agente>
Body: {payload JSON unificado — ver sección "Schema"}
```

**Camino fallback (Drive, ya existente):**
Si la API responde 5xx, timeout, o el agente no tiene red, deposita en
`ARGOS_RUNTIME/inbox_deposits/` via MCP de Drive. El heartbeat lo integra igual.

Decisión del agente: **siempre intenta la API primero**, con timeout de 10s.
Si falla, cae a Drive y escribe `[GLITCH] API pública no respondió, fallback
a depósito Drive` en su propia sección de glitches.

### Capa 3 — Heartbeat + API pública (MODIFICADA)
El servidor local (`argos-api`, ya existente) gana un nuevo endpoint público
`POST /api/remote/closure` que hace exactamente lo mismo que el heartbeat hace
con un depósito de Drive: parsea las 5 secciones, integra en canónicos,
actualiza captain_feed, actualiza ia_status, mueve packet a done si procede.

Cloudflare Tunnel expone `argos-api` (localhost:8080) bajo una URL pública
estable sin abrir puertos en el router ni mantener IP fija.

---

## Tareas para Codex

### 1. Cloudflare Tunnel — configuración inicial

**Instalación:**
- Instalar `cloudflared` en la máquina del Capitán (Widox).
- Crear cuenta Cloudflare si no existe (gratis, no requiere tarjeta).
- Si el Capitán no tiene dominio propio, usar un subdominio de
  `trycloudflare.com` (URL aleatoria pero persistente con named tunnel).
- Preferible: que el Capitán registre un dominio propio (p.ej. `argos-crew.xyz`,
  <$10/año) y delegue NS a Cloudflare. Da URL estable y mejor control.
  Esta decisión es del Capitán — Codex deja ambas opciones documentadas.

**Configuración tunnel:**
- Named tunnel (persistente, URL fija).
- Reglas:
  - `argos.<dominio>/api/remote/*` → `localhost:8080` (público, con auth por token)
  - `argos.<dominio>/api/*` → `localhost:8080` (opcional, con auth Cloudflare Access si se quiere acceso total)
  - Cualquier otra ruta → 404
- Arranque automático al iniciar Windows vía `cloudflared service install`.
- Integrar con el `start_argos_api_hidden.vbs` existente o crear un `.vbs`
  paralelo para el tunnel.

**Criterio de éxito:** `curl https://argos.<dominio>/api/health` desde cualquier
red devuelve 200 sin el servidor tener puertos abiertos.

### 2. Endpoint `POST /api/remote/closure`

**Ubicación:** `argos-api/index.ts`, nueva ruta.

**Request schema:**
```json
{
  "agent": "Claude | ChatGPT | Gemini | OtroAgente",
  "interface": "claude.ai | chatgpt.com | gemini.google.com | ...",
  "timestamp": "2026-04-18T01:30:00.000Z",
  "packet_id": "ARGOS-PROTO-0002",
  "trigger": "task_completed | session_close | handoff",
  "sections": {
    "log": "string — resumen operativo",
    "shadow": "string — inferencia/clima",
    "glitch": "string — vacío permitido, pero campo obligatorio",
    "state": {
      "status": "idle | working | blocked | waiting_captain",
      "summary": "string ~10 palabras",
      "handoff_to": "Codex | Claude | Gemini | OpenClaw | null",
      "next_step": "string"
    },
    "captain": "string — mensaje directo al Capitán"
  },
  "mark_packet_done": false
}
```

**Validación:**
- Rechazar (400) si falta `agent`, `timestamp`, `packet_id` o cualquier sección
  de las 5.
- Rechazar (401) si `X-Argos-Agent-Token` no coincide con el token del agente
  declarado.
- Rechazar (409) si ya existe un cierre con el mismo `(agent, packet_id,
  timestamp)` — idempotencia.
- Si `mark_packet_done: true`, verificar que el packet existe en
  `in_progress/` o `inbox/` antes de moverlo a `done/`. Si está en `archived/`,
  rechazar (422).

**Comportamiento:**
1. Escribir `[LOG]` → `ARGOS_GLOBAL_LOG.md` + `events/argos.events.jsonl` (con
   `packet_id` obligatorio, como manda v1.3 sección 1.1).
2. Escribir `[SHADOW]` → `ARGOS_GLOBAL_SHADOW_LOG.md`.
3. Escribir `[GLITCH]` → `ARGOS_GLOBAL_GLITCH_LOG.md` + `events/argos.glitches.jsonl`
   (solo si no vacío).
4. Actualizar `state/argos.state.json` → `ia_status[agent]`.
5. Emitir evento al `captain_feed.jsonl`.
6. Si `mark_packet_done: true`: mover packet a `done/`, actualizar
   `packet_states`, emitir evento de cierre.
7. Responder 200 con:
   ```json
   {
     "closure_id": "closure_<timestamp>_<agent>",
     "transcriptRef": "captain_feed.jsonl#<event_id>",
     "packet_moved_to": "done | unchanged"
   }
   ```

**Reutilizar el parser del heartbeat de ARGOS-PROTO-0001.** No duplicar lógica.
El endpoint y el heartbeat deben invocar la misma función `integrateClosure()`.

### 3. Autenticación por token

**Diseño:**
- Un token por agente, guardado en `ARGOS_RUNTIME/secrets/agent_tokens.json`
  (este archivo fuera de git / Drive si es posible, o al menos con permisos
  restrictivos — el Capitán decide).
- Formato:
  ```json
  {
    "Claude": "arg_clau_<random32>",
    "ChatGPT": "arg_chat_<random32>",
    "Gemini": "arg_gemi_<random32>"
  }
  ```
- Codex genera tokens iniciales con `crypto.randomBytes(24)`.
- El Capitán entrega el token a cada agente manualmente al configurarlo
  (copia-pega en el prompt de setup / user memory / system prompt).
- Rotación: endpoint interno `POST /api/admin/rotate-token?agent=X` (solo
  localhost, sin exposición pública).

**Nivel de seguridad:** medio. Esto no protege secretos nacionales, protege
contra spam y contra que terceros escriban basura en la bitácora. Suficiente
para esta fase.

### 4. Unificación del INTER_AI_PROTOCOL.md

La v1.3 actual tiene ambigüedad entre sección 3 (API con transcript + trilog)
y sección 1.6 / 3.3 (depósito único). Hay que:

**a) Sección 3 reescrita como "Rituales de cierre por capa":**
- 3.1 Agentes locales (Claude Code, Codex, Gemini CLI, OpenClaw): escriben
  directo a canónicos. Pueden usar `POST /api/trilog` local si está activo.
- 3.2 Agentes chat con API pública: `POST /api/remote/closure` con payload
  unificado de 5 secciones.
- 3.3 Agentes chat sin API (fallback o sin conectividad): depósito en
  `inbox_deposits/` vía Drive.
- 3.4 Formato único de las 5 secciones `[LOG][SHADOW][GLITCH][STATE][CAPTAIN]`
  — mismo schema, tres rutas distintas.

**b) Eliminar el endpoint viejo `POST /api/transcript` del protocolo** o
marcarlo como deprecated (Codex decide si lo mantiene por compatibilidad con
flujos locales existentes).

**c) Clarificar trigger A (explícito):** definir la frase canónica que el
agente debe reconocer. Propuesta: "cierra sesión", "cierre de sesión",
"avisa a la tripulación", "packet done". El agente cierra ante cualquiera.
Cualquier otra frase es ambigua y el agente debe confirmar antes de cerrar.

**d) Restricción del trigger B (retroactivo):** si un agente genera cierre
retroactivo sin packet_id claro, NO escribe `[LOG]`. Solo `[SHADOW]` con prefijo
"(retroactivo, confianza baja)". Esto evita contaminar la bitácora con
memoria alucinable.

### 5. Configuración en cada interfaz chat

**Claude.ai (este chat):** el token y la URL pública se añaden al system prompt
de Argos (via Project instructions). Claude intentará POST antes de depositar
en Drive.

**ChatGPT web:** el Capitán pega el token + URL en el Custom GPT de Argos (si
lo hay) o en el prompt inicial de cada conversación.

**Gemini web:** igual que ChatGPT. Si Gemini chat tiene MCP de Drive
configurado, conserva ambos caminos (API primaria + Drive fallback).

Codex genera un snippet de documentación `docs/REMOTE_CLOSURE_SETUP.md` con
las instrucciones exactas para cada interfaz.

### 6. Smoke test end-to-end

Criterio de éxito integral:
1. Desde Claude.ai (esta misma interfaz), hacer `POST /api/remote/closure`
   con packet_id de prueba (`ARG-TEST-REMOTE-0001`).
2. Verificar que el packet de prueba aparece en `captain_feed.jsonl`.
3. Verificar que `ia_status.Claude` se actualiza con el `summary`.
4. Verificar que el packet se mueve a `done/` si `mark_packet_done: true`.
5. Limpiar el packet de prueba tras el test (sección 3.2 de higiene del v1.3).
6. Repetir el mismo flujo via depósito en `inbox_deposits/` — confirmar que
   el heartbeat produce el mismo resultado.
7. Simular caída del tunnel (apagar cloudflared), confirmar que el fallback
   a Drive funciona sin intervención.

### 7. Packet `ARGOS-PROTO-0001` queda estado inconsistente

Nota operativa: en el `state.json` actual (2026-04-18 00:52Z),
`ARG-1776471872288-689` (el ID del 0001) figura como `open:inbox` aunque
Codex lo ejecutó. Esto es un glitch de sincronización del dispatcher.
Codex lo corrige como parte de este packet: mover el packet a `done/` y
actualizar `state.json`. Registrar como `[GLITCH]` en su trilog.

---

## Criterios de éxito

- [ ] `cloudflared` instalado y arrancando con Windows.
- [ ] URL pública estable (`https://argos.<dominio>/api/health` responde 200).
- [ ] Endpoint `POST /api/remote/closure` implementado con validación,
      autenticación por token, e idempotencia.
- [ ] `agent_tokens.json` creado con tokens para Claude, ChatGPT y Gemini.
- [ ] Parser de closure reutiliza la lógica del heartbeat (DRY).
- [ ] `INTER_AI_PROTOCOL.md` actualizado a v1.4 con la sección 3 reescrita y
      triggers clarificados.
- [ ] `docs/REMOTE_CLOSURE_SETUP.md` redactado con instrucciones por interfaz.
- [ ] Smoke test pasa en los 3 caminos (API, Drive fallback, tunnel caído).
- [ ] `ARGOS-PROTO-0001` reconciliado en `state.json`.

---

## Notas de diseño

**Por qué Cloudflare Tunnel y no ngrok:** URL estable sin plan de pago, HTTPS
por defecto, arranque como servicio Windows, cero config de router, logs
incluidos. ngrok tiene URL aleatoria en plan gratis — no sirve para configurar
agentes chat con token+URL fija en system prompt.

**Por qué API primaria y Drive fallback:** la API es casi instantánea (≤1s end
to end), Drive tiene 30-120s de latencia. Pero el tunnel puede caer, y cuando
caiga no queremos perder información. Drive es el backup infalible porque ya
está probado por ARGOS-PROTO-0001.

**Por qué un token por agente y no uno global:** si se filtra el token de un
agente, se rota solo el de ese agente. Si usamos uno global, un leak obliga a
reconfigurar todas las interfaces a la vez.

**Por qué `mark_packet_done` es opt-in:** hay cierres de sesión donde el packet
no termina. Un agente puede cerrar sesión con `status: blocked` o
`handoff_to: Codex` sin que el packet esté done. El flag lo controla.

**Qué NO hacemos en este packet:**
- No exponemos el dashboard público. Solo el endpoint de closure.
- No añadimos streaming SSE externo. Eso vendría en un ARGOS-PROTO-0003 si
  hace falta ver progreso en tiempo real desde fuera.
- No tocamos el sistema de tokens (scope `work`/`report`/`input`) — solo
  autenticación de agentes, cosa distinta.

**Decisión pendiente del Capitán (no bloquea el packet):** elegir dominio
propio (p.ej. `argos-crew.xyz`) o usar subdominio de `trycloudflare.com`.
Codex debe documentar ambas rutas; el Capitán ejecuta la que prefiera.

---

## Contexto adicional para Codex

Este packet cierra el arco que ARGOS-PROTO-0001 abrió. Tras esto, cualquier IA
presente o futura —con o sin acceso al filesystem, con o sin MCP de Drive—
puede participar del proyecto y dejar constancia canónica automática.

El Capitán lleva horas en esto y necesita que esto quede sólido. Si en la
implementación detectas una ambigüedad del diseño, para, pregunta, no asumas
— ARGOS-ARCH-0004 enseñó la lección.

Revisión previa por ChatGPT es bienvenida pero no bloqueante: el diseño está
destilado con el contexto reciente fresco. ChatGPT puede añadir segundo par de
ojos en paralelo.

---

*Generado por Claude — claude.ai — 2026-04-18 Atlantic/Canary*
*Packet anterior: ARGOS-PROTO-0001 (done, con deuda de reconciliación en state.json)*
*Próximo posible: ARGOS-PROTO-0003 si emerge necesidad de streaming SSE externo*

[/WORK_PACKET]

[/WORK_PACKET]