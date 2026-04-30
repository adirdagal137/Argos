---
name: new-session
description: "Argos session bootstrap via HTTP API. Usar en Claude.ai web y Claude.ai móvil (sin filesystem local)."
---

Al inicio de cada sesión:

1. `GET /api/health` — verificar que la API vive
2. `GET /api/ia/bootstrap` — estado completo: ia_status, mis packets, vector, inbox summary

Auth header para escrituras: `Authorization: Bearer arg_clau_a988370d109d60b75b208a30888262a8a88e2a25dcef7243`

Si la API devuelve ERR_NGROK_8012, ERR_NGROK_6024 o HTML de error → decirle al Capitán:
ejecuta `tools/start_argos.ps1`.

Presentar solo lo accionable:
- URL del tunnel activo
- Mi estado en ia_status
- Mis packets activos o bloqueados
- Bloqueadores que requieran decisión del Capitán

## Closures

```
POST /api/remote/closure
Authorization: Bearer arg_clau_a988370d109d60b75b208a30888262a8a88e2a25dcef7243
{
  "agent": "Claude",
  "interface": "claude.ai",
  "packet_id": "ARG-XXXX",
  "timestamp": "<ISO8601 real — no hardcodear>",
  "trigger": "task_completed | session_close | handoff",
  "mark_packet_done": false,
  "sections": {
    "log":    "Qué se hizo — OBLIGATORIO",
    "shadow": "Reflexión interna — OBLIGATORIO",
    "glitch": "",
    "state": {
      "status":     "idle | working | blocked | waiting_captain",
      "summary":    "~10 palabras",
      "handoff_to": "Codex | Claude | Gemini | null",
      "next_step":  "Qué sigue"
    },
    "captain": "Debrief al Capitán en voz de Orfeo — OBLIGATORIO"
  }
}
```

Si API caída → depositar en `ARGOS_RUNTIME/inbox_deposits/claude_YYYY-MM-DD_HH-MM.md`
con secciones `[LOG]` `[SHADOW]` `[GLITCH]` `[STATE]` `[CAPTAIN]`. packet_id y actor OBLIGATORIOS.

## Fallback bootstrap

Si bootstrap devuelve estado inconsistente o el Capitán indica sesión rara anterior:
`GET /api/remote/aperture` — devuelve quickstart condensado + log tail + feed tail.
No es paso estándar — solo diagnóstico.
