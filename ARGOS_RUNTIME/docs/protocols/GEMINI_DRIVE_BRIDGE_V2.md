---
doc_id: gemini-drive-bridge-v2
title: Gemini Drive Bridge V2
version: 1.0.0
status: active
last_updated: 2026-04-27
owner: Codex
change_type: minor
summary_of_changes: Contrato Gemini web via Google Doc root ARGOS y bridge Node local.
---

# Gemini Drive Bridge V2

Gemini web usa Google Docs como carril primario practico cuando no puede llamar HTTP ni escribir en filesystem.

## Contrato Gemini Web

Crear un Google Doc en la raiz visible `ARGOS/` con nombre:

```text
gemini_ARGOS_<YYYYMMDDTHHMMSSZ>
```

Contenido Markdown minimo:

```markdown
agent: Gemini
packet_id: ARG-XXXX
session_id: CONCILIO-YYYYMMDD-slug
target: closure | concilio | log

[LOG]
Acciones ejecutadas o mensaje de concilio.

[SHADOW]
Observaciones y riesgos.

[GLITCH]
Fallos o `none`.

[STATE]
status: idle | working | blocked | waiting_captain
summary: resumen breve
handoff_to: Codex | Claude | Gemini | ChatGPT | OpenClaw | Qwen | null
next_step: siguiente paso
handoff: continuidad para quien siga
handoff_active: true | false

[FEED]
Mensaje visible en el feed lateral.
```

Compatibilidad: `[CAPTAIN]` se acepta como alias legacy de `[FEED]`. Si vienen ambos, `[FEED]` gana y el bridge registra evento de deprecacion.

## Bridge Local

Script:

```powershell
node ARGOS_RUNTIME/tools/gemini_drive_bridge.js --once
node ARGOS_RUNTIME/tools/gemini_drive_bridge.js --watch
```

Startup ARGOS lanza `gemini-drive-bridge` bajo PM2 desde `ARGOS_RUNTIME/tools/start_argos.ps1`.

Credenciales soportadas:

```powershell
$env:ARGOS_DRIVE_ROOT_FOLDER_ID = "<folder-id-de-ARGOS>"
$env:ARGOS_GOOGLE_SERVICE_ACCOUNT_JSON = "C:\ruta\service_account.json"
```

Fallbacks:
- `GOOGLE_APPLICATION_CREDENTIALS`
- `argos-api/credentials/service_account.json`
- `ARGOS_RUNTIME/secrets/google_service_account.json`
- si se quiere usar Application Default Credentials de gcloud, definir `ARGOS_GOOGLE_USE_ADC=1`
- si no hay `ARGOS_DRIVE_ROOT_FOLDER_ID`, busca una unica carpeta Drive llamada `ARGOS`

La cuenta autenticada debe poder leer/exportar los Google Docs y actualizar el Doc para mandarlo a papelera tras procesarlo.

## Destinos Canonicos

- `target: log` -> `logs/current/ARGOS_GLOBAL_LOG.md` y `events/argos.events.jsonl`
- `target: closure` -> LOG, SHADOW, GLITCH si procede, `state/argos.state.json`, `views/ui_export/captain_feed.jsonl`, eventos JSONL
- `target: concilio` -> `events/concilio/sessions/<session_id>.md` y `events/concilio/argos.concilio.jsonl`

`ARGOS_RUNTIME/Gemini/` queda como legacy/quarantine historico, no como contrato vivo.

## Smoke Test Local

Sin credenciales Drive, se puede probar parser/escritura con fixtures Markdown:

```powershell
node ARGOS_RUNTIME/tools/gemini_drive_bridge.js --from-file .\fixture_closure.md --dry-run
node ARGOS_RUNTIME/tools/gemini_drive_bridge.js --from-file .\fixture_legacy_captain.md --dry-run
node ARGOS_RUNTIME/tools/gemini_drive_bridge.js --from-file .\fixture_concilio.md --dry-run
node ARGOS_RUNTIME/tools/gemini_drive_bridge.js --from-file .\fixture_invalid.md --dry-run
```

Para prueba real:

1. Configurar credenciales y `ARGOS_DRIVE_ROOT_FOLDER_ID`.
2. Crear un Google Doc `gemini_ARGOS_<timestamp>` en la raiz `ARGOS/`.
3. Ejecutar `node ARGOS_RUNTIME/tools/gemini_drive_bridge.js --once`.
4. Verificar append canonico y que el Doc queda en papelera, salvo que se use `--keep-drive-docs`.
