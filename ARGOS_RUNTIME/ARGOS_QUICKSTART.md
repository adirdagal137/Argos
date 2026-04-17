# ARGOS QUICKSTART
Protocolo operativo condensado para sesion diaria.

## Inicio (cada sesion)
1. Leer `work_packets/inbox/`.
2. Leer tail de `ARGOS_GLOBAL_LOG.md`.
3. Leer `state/argos.state.json`.
4. Confirmar al Capitan: `"[N] paquetes en inbox. [observacion propia en tu voz.]"`.

## Al tomar una tarea
```http
POST http://localhost:8080/api/ia/start-task
{
  "packetId": "ARG-XXXX",
  "actor": "NOMBRE",
  "summary": "Frase concreta de lo que haras"
}
```

## Durante (hitos visibles)
```http
POST http://localhost:8080/api/chat
{
  "sender": "NOMBRE",
  "summary": "...",
  "details": "...",
  "refId": "ARG-XXXX"
}
```

## Cierre (obligatorio)
Paso 1: Transcript
```http
POST http://localhost:8080/api/transcript
{
  "agent": "NOMBRE",
  "role": "agent",
  "content": "Lo que NO esta en trilog/feed",
  "packetId": "ARG-XXXX"
}
```

Paso 2: Trilog
```http
POST http://localhost:8080/api/trilog
{
  "actor": "NOMBRE",
  "packetId": "ARG-XXXX",
  "summary": "Que se hizo",
  "details": "Detalle",
  "nextStep": "",
  "errors": "",
  "risks": "",
  "processTokens": 0,
  "transcriptRef": "transcripts/YYYY-MM-DD_NOMBRE.md#ARG-XXXX",
  "shadow": "Obligatorio"
}
```
`processTokens`: fallback manual. Si el proxy está activo, los tokens reales ya están en el ledger y este valor no altera el panel.

## Rollover de sesion (inicio/fin de jornada)
Evita que global/shadow/glitch/transcripts crezcan indefinidamente en contexto vivo.

```http
POST http://localhost:8080/api/session/archive
{
  "mode": "start_of_day",
  "actor": "NOMBRE",
  "reason": "inicio de jornada",
  "archiveDonePackets": true,
  "compactState": true,
  "reorganizeLegacy": true
}
```

```http
POST http://localhost:8080/api/session/archive
{
  "mode": "end_of_day",
  "actor": "NOMBRE",
  "reason": "cierre de jornada",
  "archiveDonePackets": true,
  "compactState": true,
  "reorganizeLegacy": true
}
```

Atajo PowerShell:
```powershell
tools/session_rollover.ps1 -Mode start_of_day
tools/session_rollover.ps1 -Mode end_of_day
```

## Tokens (captura automática)

Los tokens reales se capturan solos — no hace falta estimarlos.

**Agentes cloud** (Claude, Antigravity, Codex): el proxy de argos-api intercepta cada llamada y lee el campo `usage` de la respuesta. Requiere que el entorno de cada IA tenga configuradas estas variables antes de arrancar:
```
ANTHROPIC_BASE_URL=http://localhost:8080/proxy/anthropic   # Claude Code
GOOGLE_AI_BASE_URL=http://localhost:8080/proxy/gemini       # Antigravity
OPENAI_BASE_URL=http://localhost:8080/proxy/openai          # Codex
```

**Qwen/DeepSeek (Ollama)**: `callOllama()` devuelve `prompt_eval_count` + `eval_count` reales. Se registran automáticamente en el ledger como agente `DeepSeek`.

**`processTokens` en el trilog**: sigue siendo un campo válido pero es ahora un fallback manual (proxy offline, sesión sin env var). Si el proxy está activo, el valor se ignora en el panel — los reales ya están en el ledger.

**Sync horario**: cada hora argos-api publica `tokens:hourly-sync` con los totales por agente. No hay coste asociado — es solo lectura del ledger.

**Reinicio de argos-api**: el proceso resiste `taskkill` desde bash. Usar:
```powershell
powershell -Command "Stop-Process -Id <PID> -Force"
```

## Reglas rapidas
- UTF-8 sin BOM en todo runtime.
- No usar `Set-Content -Encoding UTF8` en PowerShell 5.
- No duplicar en transcript lo ya presente en trilog/feed.
- No cerrar tareas sin `shadow`.
