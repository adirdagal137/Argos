---
doc_id: remote-closure-setup
title: Remote Closure Setup
version: 1.1.0
status: active
last_updated: 2026-04-27
owner: Codex
change_type: minor
summary_of_changes: Gemini web documentado como carril Drive Bridge V2 en vez de HTTP/fallback filesystem.
---

# Remote Closure Setup (ARGOS-PROTO-0002)

This document configures remote session closure for chat interfaces using:
- Primary path: `POST /api/remote/closure`
- Fallback path: `ARGOS_RUNTIME/inbox_deposits/`

Exception: Gemini web uses Gemini Drive Bridge V2 as its primary practical path when HTTP is unreliable. It creates a Google Doc in the visible `ARGOS/` root and the local Node bridge exports/processes it.

## 1. Endpoint Summary

- URL (local): `http://localhost:8080/api/remote/closure`
- URL (public via tunnel): `https://argos.<your-domain>/api/remote/closure`
- Header: `X-Argos-Agent-Token: <agent-token>`
- Behavior:
  - Validates payload and token
  - Integrates `[LOG][SHADOW][GLITCH][STATE][CAPTAIN]`
  - Optional `mark_packet_done` moves packet to `done/`
  - Enforces idempotency on `(agent, packet_id, timestamp)`

## 2. Payload Example

Un cierre válido escribe: **LOG → SHADOW → HANDOFF → EVENTS → FEED** (sin TOKENS).

```json
{
  "agent": "Claude",
  "interface": "claude.ai",
  "timestamp": "2026-04-18T01:30:00.000Z",
  "packet_id": "ARG-TEST-REMOTE-0001",
  "trigger": "task_completed",
  "sections": {
    "log": "Implemented remote closure endpoint. SIGUIENTE: Codex validates. APRENDIZAJE: handoff must be mandatory. GLITCHES: ninguno. RIESGOS: ninguno.",
    "shadow": "The system is coherent, but token rotation should stay local-only.",
    "glitch": "",
    "handoff": {
      "contexto": "Se implementó el endpoint /api/remote/closure para agentes sin filesystem",
      "decision": "Separar handoff como sección obligatoria garantiza trazabilidad del 75%",
      "continuidad": "Codex debe validar el smoke test y confirmar idempotencia",
      "session_ref": "claude.ai 2026-04-18"
    },
    "state": {
      "status": "idle",
      "summary": "Remote closure executed",
      "handoff_to": "Codex",
      "next_step": "Captain validates smoke test"
    },
    "captain": "Remote closure completed. Handoff a Codex para smoke test."
  },
  "mark_packet_done": false
}
```

**Campos obligatorios en sections:** `log`, `shadow`, `handoff` (con los 4 sub-campos), `captain`.
**LOG debe incluir:** SIGUIENTE, APRENDIZAJE, GLITCHES, RIESGOS (aunque estén vacíos).
**HANDOFF criterio 75%:** quien lea contexto+decision+continuidad debe poder reconstruir el estado.

## 3. Agent Tokens

Token storage path:
- `ARGOS_RUNTIME/secrets/agent_tokens.json`

Initial keys:
- `Claude`
- `ChatGPT`
- `Gemini`

Rotate token (localhost only):
- `POST http://localhost:8080/api/admin/rotate-token?agent=Claude`

## 4. Cloudflare Tunnel

### 4.1 Stable URL (recommended)

1. Install cloudflared (already available in this workstation via winget).
2. Login:
   - `cloudflared tunnel login`
3. Create named tunnel:
   - `cloudflared tunnel create argos-remote`
4. Route DNS (requires a Cloudflare-managed domain):
   - `cloudflared tunnel route dns argos-remote argos.<your-domain>`
5. Use config file template:
   - `ARGOS_RUNTIME/tools/cloudflared_config.example.yml`
6. Run tunnel:
   - `cloudflared tunnel --config <path-to-config> run argos-remote`
7. Optional Windows service:
   - `cloudflared service install`

### 4.2 Quick tunnel (temporary URL)

Use only for smoke tests when no domain is configured:
- `cloudflared tunnel --url http://localhost:8080`

Note: quick tunnel URLs are not stable enough for long-lived agent prompts.

## 5. Interface Setup Snippets

### Claude.ai project instructions

- Set endpoint URL and token.
- On closure triggers, try `POST /api/remote/closure` first (timeout 10s).
- If API fails, write fallback deposit to `inbox_deposits/` and include glitch note.

### ChatGPT custom GPT

- Add:
  - `ARGOS_REMOTE_URL=https://argos.<your-domain>/api/remote/closure`
  - `ARGOS_AGENT_TOKEN=<ChatGPT token>`
- Same API-first/fallback-to-Drive policy.

### Gemini chat

- Gemini web does not assume HTTP or filesystem access.
- Create a Google Doc in root `ARGOS/` named `gemini_ARGOS_<YYYYMMDDTHHMMSSZ>`.
- Use Markdown sections `[LOG][SHADOW][GLITCH][STATE][FEED]`.
- Local bridge: `ARGOS_RUNTIME/tools/gemini_drive_bridge.js`.
- See `ARGOS_RUNTIME/docs/protocols/GEMINI_DRIVE_BRIDGE_V2.md`.

## 6. Smoke Test Checklist

1. Call `/api/health` from external network through tunnel.
2. Send one closure for `ARG-TEST-REMOTE-0001`.
3. Verify:
   - `captain_feed.jsonl` has new record ID
   - `state/argos.state.json` reflects agent summary
4. Re-send same `(agent, packet_id, timestamp)` and verify `409`.
5. Test `mark_packet_done: true` with a packet in `inbox/`.
6. Disable tunnel and verify fallback deposit path still integrates.
