# INTER-AI PACT
## v1.3 — Protocolo de Transcript Universal [2026-04-13]

Reglas oficiales de operacion para Claude, Codex/ChatGPT, Gemini/Antigravity y cualquier agente futuro que entre en Argos.

---

## 1. Taxonomia de Registros (OBLIGATORIA — no confundir canales)

Existen exactamente 5 tipos de registro. Cada uno tiene destino, formato y criterio propios.

### 1.1 LOG — Acciones ejecutadas
**Que va aqui:** Hitos operativos reales. Lo que se hizo, cuando, con que resultado.
No va aqui: opiniones, riesgos no ejecutados, texto de conversacion literal.
**Archivos:**
- Resumen humano: ARGOS_GLOBAL_LOG.md (formato **[YYYY-MM-DD HH:MM Atlantic/Canary] VOZ NOMBRE:**)
- Registro estructurado: events/argos.events.jsonl (JSON con fields: timestamp, actor, module, type, summary, artifacts, verification, next_step, errors, risks, packet_id)
- **Campo packet_id (OBLIGATORIO):** ID del work packet del que emerge esta entrada de log. Sin ID de referencia, el log queda huerfano.
- **Campo errors:** Errores encontrados y aprendizajes extraidos. Obligatorio si hubo friccion. Vacio ("") solo si ejecucion limpia.
- **Campo risks:** Riesgos detectados. Vacio ("") si no aplica.

### 1.2 TRANSCRIPT — Lo dicho FUERA de la webapp, sin duplicar el feed

**Que va aqui:** El razonamiento literal de la IA tal como ocurrio en su entorno nativo,
SOLO si ese contenido NO aparece ya en el captain_feed.
- Claude: lo que dijo en Claude Code (esta conversacion). NO en la webapp.
- ChatGPT/Codex: lo que dijo en la interfaz de ChatGPT. NO en la webapp.
- Gemini/Antigravity: lo que dijo en la interfaz de Gemini. NO en la webapp.

**Regla de no-duplicacion (CRITICA):**
El captain_feed ya contiene trilog (summary, details, nextStep, errors, risks) y chats de hitos.
El transcript NO debe replicar esos campos. El transcript captura el COMO y el POR QUE
en voz propia del agente — el razonamiento, las alternativas consideradas, las tensiones
percibidas — lo que informa el trabajo pero no cabe en los campos operativos del trilog.

En la practica: si lo que ibas a escribir en el transcript es esencialmente tu trilog
con otras palabras, no lo escribas. El transcript es lo que solo existe en la conversacion
fuera del webapp.

No va aqui: analisis operativos (eso es LOG), reflexiones de riesgo (SHADOW),
fallos de proceso (GLITCH), ni resumen de acciones que ya esta en el trilog.

**Archivos:** `transcripts/YYYY-MM-DD_AGENTE.md` — uno por agente por dia, append-only.

**Formato de cada bloque:**
```
<!-- ARG-XXXX -->
## [YYYY-MM-DD HH:MM] Packet: ARG-XXXX

**PROMPT (Capitan → Agente):**
[texto literal del Capitan — capturado automaticamente]

**RESPONSE (Agente → Capitan):**
[lo que la IA dijo fuera de la webapp — razonamiento, voz, decisiones de diseno]

---
```

**Captura automatica (Gemini/Antigravity, Codex/ChatGPT, Qwen):**
El servidor captura automaticamente el PROMPT del Capitan via POST /api/tasks.
La IA escribe su RESPONSE incluyendo `literalResponse` en POST /api/chat, o haciendo POST /api/transcript al cerrar.
El `literalResponse` debe ser el texto de la IA fuera del webapp — no un resumen del trilog.

**Captura manual (Claude / Claude Code):**
Claude hace POST /api/transcript al cierre con el texto sustantivo de esta conversacion.
El PROMPT ya esta capturado. El RESPONSE es el razonamiento clave de este exchange —
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

### 1.3 GLITCHES — Errores en el flujo del pipeline
**Que va aqui:** Fallos en el PROCESO de trabajo entre agentes o entre capas del sistema.
Ejemplos: work packet enviado al agente equivocado, agente que no responde segun protocolo,
formato de handoff roto, exportacion fallida entre capas, parsing que falla por estructura.
No va aqui: errores de codigo interno del sistema (eso son BUGS), ni reflexiones (SHADOW).
**Archivos:**
- Resumen: ARGOS_GLOBAL_GLITCH_LOG.md (formato **[timestamp] G-NNN | VOZ:**)
- Registro estructurado: events/argos.glitches.jsonl

### 1.4 BUGS — Errores internos del sistema
**Que va aqui:** Fallos tecnicos en el codigo, schemas, encoding o infraestructura del runtime.
Ejemplos: BOM en JSON, mojibake en archivos MD, funcion de API con logica rota,
state.json desincronizado con filesystem, endpoint que devuelve datos incorrectos.
No va aqui: errores de coordinacion entre agentes (eso son GLITCHES), ni reflexiones (SHADOW).
**Archivos:**
- work_packets/inbox/ con TYPE: bug y TAG: bug (aparecen en tab Bugs del dashboard)

### 1.5 SHADOW — Material observado sin otro destino
**Que va aqui:** Todo lo que un agente observa, intuye, percibe o sospecha durante el flujo
y que no encaja en ninguno de los 4 canales anteriores. Friccion cognitiva, riesgo latente,
calibracion psiquica, pattern emergente, tension estrategica no resuelta, lectura intermedia.
El Shadow no es un vertedero. Es el espejo del sistema: lo que ve pero no puede aun ejecutar.
Criterio negativo: si cabe en LOG, TRANSCRIPT, GLITCH o BUG, no va en SHADOW.
**Archivo:**
- ARGOS_GLOBAL_SHADOW_LOG.md (formato **[YYYY-MM-DD HH:MM Atlantic/Canary] VOZ NOMBRE:**)

---

## 2. Ritual de inicio (cualquier agente, cualquier sesion)

Antes de ejecutar cualquier orden:
1. Leer work_packets/inbox/ completo.
2. Leer state/argos.state.json (foco y riesgos activos).
3. Leer este archivo (INTER_AI_PROTOCOL.md).
4. Leer ARGOS_CREW_VOICES.md — caracter y tono del navio. **Obligatorio.**
5. Leer tail de ARGOS_GLOBAL_LOG.md — que se hizo recientemente.
6. Confirmar al Capitan: "[N] paquetes en inbox. [Frase propia del agente en su voz.]"

### Nota sobre el ritual para agentes cloud (Claude, DeepSeek)

Los docs de protocolo completo (`INTER_AI_PROTOCOL.md`, `ARGOS_CREW_VOICES.md`) son **referencia**, no lectura obligatoria en cada sesión. El trilog + state.json + log tail son suficientes en el 90% de los casos. Leer los docs completos solo bajo ambigüedad de protocolo o conflicto entre IAs. Esto reduce significativamente el coste de tokens de arranque.

### Al tomar una tarea especifica

**Paso 1 — Leer el contexto del work packet:**
Siempre: leer el work packet + tail del LOG reciente. Eso es suficiente en la mayoria de casos.

Solo si hay ambiguedad de decision, conflicto entre IAs o contexto critico sin documentar:
```
GET http://localhost:8080/api/transcript?agent=AGENTE&packetId=ARG-XXXX
```
Si hay transcripts de otras IAs relevantes, leerlos tambien — pero solo bajo el mismo criterio.
No leer transcripts por defecto: el trilog + work packet ya tienen la decision trail.

**Paso 2 — Registrar inicio (OBLIGATORIO antes de ejecutar):**
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

## 3. Ritual de cierre — TRANSCRIPT + Tri-Log (obligatorio al terminar toda tarea)

El cierre tiene DOS pasos obligatorios en este orden:

### 3.0 Paso 1 — Escribir el Transcript literal

**Para todos los agentes:**
```
POST http://localhost:8080/api/transcript
{
  "agent":    "NOMBRE",
  "role":     "agent",
  "content":  "[texto literal de tu respuesta al Capitan — lo que realmente dijiste]",
  "packetId": "ARG-XXXX"
}
```

**Para Gemini/Antigravity y Codex/ChatGPT (via UI de ARGOS):**
El PROMPT del Capitan ya fue capturado automaticamente cuando creo el work packet.
Tu RESPONSE se captura si incluyes `literalResponse` en POST /api/chat, o haciendo el POST /api/transcript separado al cerrar.

**Para Claude (Claude Code):**
El PROMPT ya esta capturado. Claude hace POST /api/transcript con el texto sustantivo de
esta conversacion — el razonamiento, las decisiones de diseno, lo que no esta en el trilog.
Si la tarea es rutinaria y el trilog lo dice todo, el transcript puede ser minimo o incluso
limitarse a confirmar que el razonamiento esta en el trilog. No duplicar campos del trilog.

La API devuelve `{ "transcriptRef": "transcripts/YYYY-MM-DD_AGENTE.md#ARG-XXXX" }`.
Usar ese `transcriptRef` en el trilog.

### 3.1 Paso 2 — Tri-Log canonico

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
  "shadow":       "OBLIGATORIO — lo observado pero no volcado en el log"
}
```

El campo `shadow` devuelve 400 si esta vacio. No hay cierre sin sombra.
El campo `transcriptRef` vincula el LOG al transcript literal.

**Si la API esta offline:** escribir manualmente en GLOBAL_LOG.md + SHADOW_LOG.md + transcript file.

### 3.2 Higiene de pruebas (OBLIGATORIO)
- Ninguna prueba debe quedar persistida en Bitacora ni en Cubierta ni en transcripts.
- Toda prueba debe usar ID claramente temporal (ARG-TEST-*, TMP-*) y limpiarse al finalizar.
- Si una prueba se filtra a produccion visible, se registra como glitch de higiene operativa.

---

## 4. Disciplina de Contabilidad (TOKENS)

El panel muestra **solo WORK_TOKENS** (coste real de proceso).
Los tokens se capturan automáticamente — no se estiman.

### 4.1 Captura automática por capa

**Agentes cloud (Claude, Antigravity, Codex)**
argos-api actúa como proxy transparente. Cada llamada a la API real pasa por:
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
El campo `processTokens` sigue siendo válido en el cierre de tarea, pero es un **fallback manual** para sesiones donde el proxy no está activo (API offline, env var no configurada). Si el proxy capturó los tokens reales, el campo se ignora en el panel — el ledger ya tiene el dato correcto.

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

## 6. Regla de encoding (CRITICA — BOM mata el backend)

Todos los archivos del runtime se escriben en UTF-8 SIN BOM.

- Node.js: fs.writeFileSync(path, content, 'utf8') — correcto por defecto.
- PowerShell (correcto): [System.IO.File]::WriteAllText(path, content, [System.Text.Encoding]::UTF8)
- PowerShell (PROHIBIDO): Set-Content -Encoding UTF8 — escribe BOM en PS5, rompe JSON.parse().

---

## 6b. Política de Archivado Diario

### Log global
El `ARGOS_GLOBAL_LOG.md` se archiva diariamente.
- Archivo activo: `ARGOS_GLOBAL_LOG.md` — solo entradas del día en curso + últimas 2-3 entradas del día anterior como contexto.
- Archivo histórico: `events/logs/ARGOS_GLOBAL_LOG_archive_YYYYMMDD.md` — snapshot del log completo hasta esa fecha.
- Responsable del archivado: Qwen (cuando esté operativo). Hasta entonces: manual o Antigravity.

### State de packets
El `state/argos.state.json` solo contiene packets con estado activo (`inbox`, `in_progress`, `open`, `parked`).
Los estados `done:done` y `mitigated:done` se mueven diariamente a `state/argos.state.archive.json`.
El backend debe respetar esta separación al escribir en state.json.

---

## 6c. Qwen como Servicio de Consulta (FUTURO — no implementado)

**Visión:** Qwen (Automatista local, costo cero tokens) podría ser llamado por otras IAs para:
- Búsqueda en logs históricos archivados sin coste de tokens cloud
- Normalización y limpieza de archivos (BOM, encoding, formato)
- Clasificación y routing de work packets entrantes
- Mantenimiento diario: archivado de logs, limpieza de state.json

**Interfaz prevista** (cuando OpenClaw esté operativo):
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

## RESUMEN EJECUTIVO — Ciclo completo de una tarea

```
INICIO
  1. Leer inbox + state + LOG reciente + work packet
  2. Solo si hay ambiguedad o conflicto: GET /api/transcript?packetId=ARG-XXXX
  3. POST /api/ia/start-task  → widget se actualiza, packet va a in_progress

DURANTE
  → POST /api/chat para hitos intermedios visibles al Capitan

CIERRE
  4. POST /api/transcript  → solo lo dicho FUERA de la webapp, sin duplicar trilog ni feed
  5. POST /api/trilog      → LOG + SHADOW + FEED + mueve packet a done
```

Sin start-task = el Capitan no sabe que estas trabajando.
Sin trilog = el packet queda huerfano y dispara glitch de integridad.
Transcript vacio = aceptable si el trilog ya lo dice todo. No-duplicacion es la regla.
