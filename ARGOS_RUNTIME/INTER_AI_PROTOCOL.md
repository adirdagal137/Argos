# INTER-AI PACT
## v1.3 â€” Protocolo de Transcript Universal [2026-04-13]

Reglas oficiales de operacion para Claude, Codex/ChatGPT, Gemini/Antigravity y cualquier agente futuro que entre en Argos.

---

## 1. Taxonomia de Registros (OBLIGATORIA â€” no confundir canales)

Existen exactamente 5 tipos de registro. Cada uno tiene destino, formato y criterio propios.

### 1.1 LOG â€” Acciones ejecutadas
**Que va aqui:** Hitos operativos reales. Lo que se hizo, cuando, con que resultado.
No va aqui: opiniones, riesgos no ejecutados, texto de conversacion literal.
**Archivos:**
- Resumen humano: ARGOS_GLOBAL_LOG.md (formato **[YYYY-MM-DD HH:MM Atlantic/Canary] VOZ NOMBRE:**)
- Registro estructurado: events/argos.events.jsonl (JSON con fields: timestamp, actor, module, type, summary, artifacts, verification, next_step, errors, risks, packet_id)
- **Campo packet_id (OBLIGATORIO):** ID del work packet del que emerge esta entrada de log. Sin ID de referencia, el log queda huerfano.
- **Campo errors:** Errores encontrados y aprendizajes extraidos. Obligatorio si hubo friccion. Vacio ("") solo si ejecucion limpia.
- **Campo risks:** Riesgos detectados. Vacio ("") si no aplica.

### 1.2 TRANSCRIPT â€” Lo dicho FUERA de la webapp, sin duplicar el feed

**Que va aqui:** El razonamiento literal de la IA tal como ocurrio en su entorno nativo,
SOLO si ese contenido NO aparece ya en el captain_feed.
- Claude: lo que dijo en Claude Code (esta conversacion). NO en la webapp.
- ChatGPT/Codex: lo que dijo en la interfaz de ChatGPT. NO en la webapp.
- Gemini/Antigravity: lo que dijo en la interfaz de Gemini. NO en la webapp.

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

**Captura automatica (Gemini/Antigravity, Codex/ChatGPT, Qwen):**
El servidor captura automaticamente el PROMPT del Capitan via POST /api/tasks.
La IA escribe su RESPONSE incluyendo `literalResponse` en POST /api/chat, o haciendo POST /api/transcript al cerrar.
El `literalResponse` debe ser el texto de la IA fuera del webapp â€” no un resumen del trilog.

**Captura manual (Claude / Claude Code):**
Claude hace POST /api/transcript al cierre con el texto sustantivo de esta conversacion.
El PROMPT ya esta capturado. El RESPONSE es el razonamiento clave de este exchange â€”
lo que no esta en el trilog ni en los chats del feed.

**Lectura por otras IAs:**
```
GET http://localhost:8080/api/transcript?agent=Claude&date=2026-04-13
GET http://localhost:8080/api/transcript?agent=Claude&date=2026-04-13&packetId=ARG-XXXX
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
2. **Agentes chat** (Claude.ai, ChatGPT, Gemini chat): depositan un unico markdown por sesion.
3. **Heartbeat local (argos-api)**: observa `inbox_deposits/`, integra secciones y mueve a `processed/`.

**Archivos:**
- `ARGOS_RUNTIME/inbox_deposits/<agente>_<YYYY-MM-DD_HH-MM>.md`
- `ARGOS_RUNTIME/inbox_deposits/processed/`
- `ARGOS_RUNTIME/legacy/live_deprecated_2026-04-18/` (archivo historico de la antigua capa live)

**Secciones obligatorias del deposito:** `[LOG]`, `[SHADOW]`, `[GLITCH]`, `[STATE]`, `[CAPTAIN]`.

**Mapeo canonico:**
- `[LOG]` -> `ARGOS_GLOBAL_LOG.md` + `events/argos.events.jsonl`
- `[SHADOW]` -> `ARGOS_GLOBAL_SHADOW_LOG.md`
- `[GLITCH]` -> `ARGOS_GLOBAL_GLITCH_LOG.md` + `events/argos.glitches.jsonl` (si no vacio)
- `[STATE]` -> `state/argos.state.json` (`ia_status`)
- `[CAPTAIN]` -> `views/ui_export/captain_feed.jsonl`

**Triggers de escritura:**
- A (explicito): cuando el Capitan pide cierre de sesion.
- B (nueva sesion): si no existe deposito previo, se genera deposito retroactivo.
- C (inactividad 60 min): heartbeat marca `stale` en `ia_status`.
- D (agentes locales): escriben directo en canonicos; no usan `inbox_deposits/`.

---

## 2. Ritual de inicio (cualquier agente, cualquier sesion)

Antes de ejecutar cualquier orden:
1. Leer work_packets/inbox/ completo.
2. Leer state/argos.state.json (foco y riesgos activos).
3. Leer este archivo (INTER_AI_PROTOCOL.md).
4. Leer ARGOS_CREW_VOICES.md â€” caracter y tono del navio. **Obligatorio.**
5. Leer tail de ARGOS_GLOBAL_LOG.md â€” que se hizo recientemente.
6. Leer `ARGOS_RUNTIME/inbox_deposits/` y `inbox_deposits/processed/` para estado de agentes chat.
7. Confirmar al Capitan: "[N] paquetes en inbox. [Frase propia del agente en su voz.]"

### Nota sobre el ritual para agentes cloud (Claude, DeepSeek)

Los docs de protocolo completo (`INTER_AI_PROTOCOL.md`, `ARGOS_CREW_VOICES.md`) son **referencia**, no lectura obligatoria en cada sesiÃ³n. El trilog + state.json + log tail son suficientes en el 90% de los casos. Leer los docs completos solo bajo ambigÃ¼edad de protocolo o conflicto entre IAs. Esto reduce significativamente el coste de tokens de arranque.

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

## 3. Ritual de cierre â€” TRANSCRIPT + Tri-Log (obligatorio al terminar toda tarea)

El cierre tiene DOS pasos obligatorios en este orden:

### 3.0 Paso 1 â€” Escribir el Transcript literal

**Para todos los agentes:**
```
POST http://localhost:8080/api/transcript
{
  "agent":    "NOMBRE",
  "role":     "agent",
  "content":  "[texto literal de tu respuesta al Capitan â€” lo que realmente dijiste]",
  "packetId": "ARG-XXXX"
}
```

**Para Gemini/Antigravity y Codex/ChatGPT (via UI de ARGOS):**
El PROMPT del Capitan ya fue capturado automaticamente cuando creo el work packet.
Tu RESPONSE se captura si incluyes `literalResponse` en POST /api/chat, o haciendo el POST /api/transcript separado al cerrar.

**Para Claude (Claude Code):**
El PROMPT ya esta capturado. Claude hace POST /api/transcript con el texto sustantivo de
esta conversacion â€” el razonamiento, las decisiones de diseno, lo que no esta en el trilog.
Si la tarea es rutinaria y el trilog lo dice todo, el transcript puede ser minimo o incluso
limitarse a confirmar que el razonamiento esta en el trilog. No duplicar campos del trilog.

La API devuelve `{ "transcriptRef": "transcripts/YYYY-MM-DD_AGENTE.md#ARG-XXXX" }`.
Usar ese `transcriptRef` en el trilog.

### 3.1 Paso 2 â€” Tri-Log canonico

```
POST http://localhost:8080/api/trilog
{
  "actor":        "NOMBRE",
  "packetId":     "ARG-XXXX",
  "summary":      "Que se hizo",
  "details":      "Detalle de acciones",
  "nextStep":     "Que sigue (opcional)",
  "errors":       "Errores / aprendizajes (opcional)",
  "risks":        "Riesgos detectados (opcional)",
  "processTokens": N,
  "transcriptRef": "transcripts/YYYY-MM-DD_AGENTE.md#ARG-XXXX",
  "shadow":       "OBLIGATORIO â€” lo observado pero no volcado en el log"
}
```

El campo `shadow` devuelve 400 si esta vacio. No hay cierre sin sombra.
El campo `transcriptRef` vincula el LOG al transcript literal.

**Si la API esta offline:** escribir manualmente en GLOBAL_LOG.md + SHADOW_LOG.md + transcript file.

### 3.2 Higiene de pruebas (OBLIGATORIO)
- Ninguna prueba debe quedar persistida en Bitacora ni en Cubierta ni en transcripts.
- Toda prueba debe usar ID claramente temporal (ARG-TEST-*, TMP-*) y limpiarse al finalizar.
- Si una prueba se filtra a produccion visible, se registra como glitch de higiene operativa.

### 3.3 Paso final de cierre — deposito chat (obligatorio para interfaces chat)
Al cerrar una intervencion sustantiva desde una interfaz chat (Claude.ai/ChatGPT/Gemini chat),
generar un unico archivo en `ARGOS_RUNTIME/inbox_deposits/` con formato:
```
---
agent: NOMBRE
interface: chat_ui
timestamp: YYYY-MM-DD HH:MM Atlantic/Canary
packet_id: ARG-XXXX
---

[LOG]
...
[SHADOW]
...
[GLITCH]
...
[STATE]
status: idle|working|blocked|waiting_captain
summary: ...
handoff_to: Codex|Claude|Gemini|OpenClaw|null
next_step: ...
packet_id: ARG-XXXX
[CAPTAIN]
...
```
El heartbeat de `argos-api` integra y archiva el deposito automaticamente.

---

## 4. Disciplina de Contabilidad (TOKENS)

El panel muestra **solo WORK_TOKENS** (coste real de proceso).
Los tokens se capturan automÃ¡ticamente â€” no se estiman.

### 4.1 Captura automÃ¡tica por capa

**Agentes cloud (Claude, Antigravity, Codex)**
argos-api actÃºa como proxy transparente. Cada llamada a la API real pasa por:
```
ANTHROPIC_BASE_URL=http://localhost:8080/proxy/anthropic
GOOGLE_AI_BASE_URL=http://localhost:8080/proxy/gemini
OPENAI_BASE_URL=http://localhost:8080/proxy/openai
```
El proxy lee `usage` de la respuesta (o los eventos SSE finales en streaming) y escribe al ledger sin coste adicional.

**Qwen / DeepSeek (Ollama local)**
`callOllama()` extrae `prompt_eval_count` + `eval_count` de cada respuesta Ollama. Se registran en el ledger como agente `DeepSeek`, scope `work`.

**OpenClaw (webhook)**
`POST http://localhost:8080/hooks/argos` recibe payloads de OpenClaw con `prompt_eval_count` / `eval_count` y los registra directamente.

### 4.2 processTokens en el trilog (fallback)
El campo `processTokens` sigue siendo vÃ¡lido en el cierre de tarea, pero es un **fallback manual** para sesiones donde el proxy no estÃ¡ activo (API offline, env var no configurada). Si el proxy capturÃ³ los tokens reales, el campo se ignora en el panel â€” el ledger ya tiene el dato correcto.

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

- inbox/: mision pendiente de tomar. (TYPE: task | bug | note | parked)
- in_progress/: mision activa.
- done/: mision completada.
- archived/: mision cerrada y congelada.

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
- Responsable del archivado: Qwen (cuando estÃ© operativo). Hasta entonces: manual o Antigravity.

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

## RESUMEN EJECUTIVO â€” Ciclo completo de una tarea

```
INICIO
  1. Leer inbox + state + LOG reciente + work packet
  2. Solo si hay ambiguedad o conflicto: GET /api/transcript?packetId=ARG-XXXX
  3. POST /api/ia/start-task  â†’ widget se actualiza, packet va a in_progress

DURANTE
  â†’ POST /api/chat para hitos intermedios visibles al Capitan

CIERRE
  4. POST /api/transcript  â†’ solo lo dicho FUERA de la webapp, sin duplicar trilog ni feed
  5. POST /api/trilog      â†’ LOG + SHADOW + FEED + mueve packet a done
```

Sin start-task = el Capitan no sabe que estas trabajando.
Sin trilog = el packet queda huerfano y dispara glitch de integridad.
Transcript vacio = aceptable si el trilog ya lo dice todo. No-duplicacion es la regla.
