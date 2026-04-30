---
name: new-session-cowork
description: "Argos session bootstrap via filesystem. Usar en Cowork y Claude Code (con acceso local a ARGOS_RUNTIME)."
---

## Bootstrap — filesystem directo, sin llamadas HTTP

Leer en este orden:

1. `C:/Users/Widox/Desktop/ARGOS/ARGOS_RUNTIME/state/argos.state.json`
   → foco actual, ia_status, in_progress_packets, active_risks

2. Glob `C:/Users/Widox/Desktop/ARGOS/ARGOS_RUNTIME/work_packets/inbox/*.md`
   → contar y nombrar packets pendientes

3. Tail (~40 líneas) de `C:/Users/Widox/Desktop/ARGOS/ARGOS_RUNTIME/logs/current/ARGOS_GLOBAL_LOG.md`
   → qué se hizo recientemente

4. Confirmar al Capitán: "[N] paquetes en inbox. [observación en voz de Orfeo]."

**No llamar a la API para bootstrap.** `web_fetch` no soporta headers custom
→ ngrok bloquea con interstitial → pérdida de tiempo.

## Bash — no asumir disponibilidad

El sandbox Linux puede no arrancar en Cowork. No depender de bash.
Usar siempre `Read` / `Write` / `Edit` como canal primario de filesystem.

---

## Closures — escribir directo al filesystem

### 1. LOG → `logs/current/ARGOS_GLOBAL_LOG.md` (append al final)

```
---
**[YYYY-MM-DD HH:MM Atlantic/Canary] VOZ CLAUDE:**
**MISION:** <resumen breve>
**WORK PACKET:** ARG-XXXX

**DETALLES:**
<qué se hizo y resultado>

**SIGUIENTE:** <next_step>

**RIESGOS:** <glitch si lo hay, o vacío>
```

### 2. SHADOW → `logs/current/ARGOS_GLOBAL_SHADOW_LOG.md` (append al final)

```
**[YYYY-MM-DD HH:MM Atlantic/Canary] VOZ CLAUDE:**
<reflexión interna: tensiones, intuiciones, riesgos observados>
```

### 3. GLITCH → `logs/current/ARGOS_GLOBAL_GLITCH_LOG.md` (append, solo si no vacío)

```
**[YYYY-MM-DD HH:MM Atlantic/Canary] G-NNN | VOZ CLAUDE:**
<descripción del fallo de proceso o pipeline>
```

### 4. EVENTS → `events/argos.events.jsonl` (append, una línea JSON)

```json
{"timestamp":"<ISO8601>","timestamp_label":"<YYYY-MM-DD HH:MM>","actor":"Claude","module":"argos","type":"session_close","packet_id":"ARG-XXXX","refId":"ARG-XXXX","status":"done","summary":"<resumen>","details":"<detalle>","next_step":"<siguiente>","errors":"","risks":"","tokens":0,"transcriptRef":"transcripts/YYYY-MM-DD_Claude.md#ARG-XXXX","source":"local:filesystem"}
```

---

## Timestamp

Usar fecha/hora real del sistema. El contexto provee `currentDate` (día).
Para la hora: estimar según contexto de conversación o indicar aproximación.
**Nunca hardcodear un timestamp fijo.** Si hay incertidumbre de minutos, indicarlo.

---

## Rutas canónicas ARGOS_RUNTIME

```
C:/Users/Widox/Desktop/ARGOS/ARGOS_RUNTIME/
  state/argos.state.json          ← estado canónico
  work_packets/inbox/             ← packets pendientes
  work_packets/in_progress/       ← en curso
  work_packets/done/              ← completados
  logs/current/
    ARGOS_GLOBAL_LOG.md           ← trilog visible activo
    ARGOS_GLOBAL_SHADOW_LOG.md    ← reflexiones de agentes
    ARGOS_GLOBAL_GLITCH_LOG.md    ← fallos de pipeline
  events/
    argos.events.jsonl            ← eventos estructurados
    argos.glitches.jsonl          ← glitches estructurados
  inbox_deposits/                 ← fallback si API local caída
```
