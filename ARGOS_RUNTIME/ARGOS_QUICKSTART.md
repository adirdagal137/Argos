---
doc_id: argos-quickstart
title: ARGOS Quickstart
version: 2.0.1
status: active
last_updated: 2026-04-28
owner: Claude
change_type: major
summary_of_changes: Reescritura completa como tarjeta operativa. Carriles local/remote, actores canonicos, GIT_protocol y VERSION_protocol compactos. Guardarrail Git reforzado.
---

# ARGOS QUICKSTART
Protocolo operativo condensado. Lectura obligatoria al inicio de cada sesion.

---

## INICIO (cada sesion)

1. Leer `work_packets/inbox/` -- que hay pendiente.
2. Leer `state/argos.state.json` -- foco y riesgos activos.
3. Leer tail de `bitacora/log.md` -- que se hizo recientemente. Compat: `logs/current/ARGOS_GLOBAL_LOG.md`.
4. (Solo si diagnosticas agentes chat o cierres remotos) Leer `inbox_deposits/`.
5. Confirmar al Capitan: "[N] paquetes en inbox. [observacion propia en tu voz.]"

---

## ACTORES CANONICOS

| Actor    | Interfaz primaria              |
|----------|-------------------------------|
| Claude   | Claude Code / Cowork           |
| Codex    | Codex CLI                      |
| Gemini   | Gemini CLI / Gemini web        |
| ChatGPT  | ChatGPT web                    |
| OpenClaw | OpenClaw local                 |
| Qwen     | Ollama local                   |

**Deprecated:** Pi, Antigravity, DeepSeek (solo para lectura historica).

---

## CARRILES POR INTERFAZ

**Local filesystem** (Claude Code, Codex, Gemini CLI, OpenClaw):
- Pueden leer/escribir filesystem directamente.
- Usan API para start/closure cuando esta disponible.
- Fallback: deposito en `inbox_deposits/` si API cae.

**Remote API** (Claude web/cowork, ChatGPT web, Gemini web):
- No asumen acceso a filesystem.
- Flujo: `GET /api/bootstrap` -> trabajar -> `POST /api/remote/closure`.
- Fallback: dictar objeto closure al Capitan para que haga el POST.

---

## START (MOMENTO 2)

```http
POST http://localhost:8080/api/ia/start-task
{ "packetId": "ARG-XXXX", "actor": "Claude", "summary": "Frase breve (~80 chars)" }
```

`summary` sigue vivo: visible en UI, inbox, start. No es deprecado.
No enviar nada al feed durante la ejecucion -- los hitos van al log.

---

## CLOSE (MOMENTO 3 -- OBLIGATORIO)

Un cierre escribe exactamente: **LOG → SHADOW → HANDOFF → EVENTS → FEED**
No hay sección TOKENS (captura automática del proxy, no cierre manual).

```http
POST http://localhost:8080/api/remote/closure
Headers: X-Argos-Agent-Token: <token>
{
  "agent": "Claude",
  "interface": "claude-code",
  "timestamp": "2026-04-26T15:00:00.000Z",
  "packet_id": "ARG-XXXX",
  "trigger": "task_completed",
  "sections": {
    "log":    "Que se hizo y resultado -- OBLIGATORIO",
    "shadow": "Reflexion interna: tensiones, riesgos -- OBLIGATORIO",
    "glitch": "",
    "handoff": {
      "contexto":    "Situacion que llevo a las decisiones -- OBLIGATORIO",
      "decision":    "Decision clave adoptada y su razon -- OBLIGATORIO",
      "continuidad": "Que sigue y quien debe continuar -- OBLIGATORIO",
      "session_ref": "cowork YYYY-MM-DD -- OBLIGATORIO"
    },
    "state":  { "status": "idle", "summary": "...", "handoff_to": null, "next_step": "..." },
    "captain": "Mensaje al Capitan en voz propia -- OBLIGATORIO"
  },
  "mark_packet_done": false
}
```

**LOG campos obligatorios (presentes aunque vacíos):** SIGUIENTE, APRENDIZAJE, GLITCHES, RIESGOS.
**GLITCHES en LOG:** fallos de proceso/pipeline. Errores de código → work packet TYPE: bug.
**SHADOW:** no puede estar vacío.
**HANDOFF (OBLIGATORIO):** `{ "contexto", "decision", "continuidad", "session_ref" }`.
Criterio: quien lea el handoff debe reconstruir el contexto al 75% sin leer el transcript.
**EVENTS:** actualización automática de ia_status + events.jsonl via API.
**FEED (CAPTAIN):** 1 mensaje al Capitán por cierre. Nunca mensajes intermedios.
`POST /api/trilog` es alternativa equivalente para agentes locales.

Fallback si API cae: `ARGOS_RUNTIME/inbox_deposits/<agente>_<YYYY-MM-DD_HH-MM>.md`
con secciones `[LOG] [SHADOW] [GLITCH] [STATE] [CAPTAIN]`. `packet_id` y actor son OBLIGATORIOS.

---

## GIT_PROTOCOL (compacto)

| Situacion                                                        | Accion                 |
|------------------------------------------------------------------|------------------------|
| Fix rapido (<50 lineas), docs no constitutivos, packets simples  | Commit directo en main |
| Toca argos-api/src/, frontend, tools, agents, protocols o arch    | Rama obligatoria       |

```powershell
.\ARGOS_RUNTIME\tools\argos_commit.ps1 -Agent Claude -PacketId ARG-XXXX          # commit basico
.\ARGOS_RUNTIME\tools\argos_commit.ps1 -Agent Claude -PacketId ARG-XXXX -Branch  # abrir rama
.\ARGOS_RUNTIME\tools\argos_commit.ps1 -Agent Claude -PacketId ARG-XXXX -Merge   # cerrar rama
.\ARGOS_RUNTIME\tools\argos_commit.ps1 -CleanDesktopIniRefs                      # limpiar refs Git basura
```

`argos_commit.ps1` bloquea commits directos a `main` si detecta cambios protegidos.
`-AllowMain` solo se permite como excepcion explicita y debe quedar explicada en trilog/glitch.
Si se abrio rama con `-Branch`, no cerrar trilog sin `-Merge` o sin documentar glitch.
Claude Code ejecuta `argos_commit.ps1` automaticamente via hook Stop.

---

## VERSION_PROTOCOL (compacto)

- `ARGOS_RUNTIME/argos.version` es la version global (actual: 0.4.0).
- **patch**: limpieza/fix sin cambio de comportamiento.
- **minor**: nuevo mecanismo, protocolo o endpoint compatible.
- **major**: ruptura de contrato.
- Al tocar docs Nivel 1/2, actualizar `versions.json` cuando exista.
- Hook `post-commit` crea tag `argos-vN.N.N` automaticamente.
- No subir version por cada microedicion; subir al cierre del cambio coherente.

---

## REFERENCIA ON-DEMAND (no lectura diaria)

- `INTER_AI_PROTOCOL.md` -- ambiguedad de protocolo o conflicto entre IAs.
- `ARGOS_CREW_VOICES.md` -- voz/tono si hay duda.
- `docs/protocols/REMOTE_CLOSURE_SETUP.md` -- setup remoto, tuneles, tokens de agente.
- `docs/protocols/RUNTIME_CANONICAL_SURFACE.md` -- rutas canonicas bitacora/ y cubierta/.
- `REGISTRY.md` o `versions.json` -- mapa documental.

---

## REGLAS RAPIDAS

- UTF-8 sin BOM en todo runtime.
- No usar `Set-Content -Encoding UTF8` en PowerShell 5.
- No duplicar en transcript lo ya presente en trilog/feed.
- No cerrar tareas sin `shadow`.
- Reiniciar argos-api: `powershell -Command "Stop-Process -Id <PID> -Force"` (bash no alcanza).
