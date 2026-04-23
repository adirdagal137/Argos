[WORK_PACKET]
ID: ARG-1776816000002
ROLE_REQUESTED: Claude Code
SUBJECT: Migrar argos-api de carpeta Antigravity a ARGOS/argos-api/
STATUS: open
PRIORITY: P1
ROOM: ARGOS
TYPE: maintenance
CREATED_AT: 2026-04-22 Atlantic/Canary
DEPENDS_ON: ARG-1776816000001 (hacer después del fix Bearer)

## Contexto

argos-api — el servidor core del navío — vive en:
  C:\Users\Widox\.gemini\antigravity\scratch\argos-api\

Esto es un accidente histórico: Antigravity lo scaffoldeó allí cuando nació.
Riesgo real: si se limpia el workspace de Antigravity, se pierde el servidor core.

Destino correcto:
  C:\Users\Widox\Desktop\ARGOS\argos-api\

## Tareas

1. Parar argos-api (obtener PID con netstat -ano | findstr :8080)
   powershell -Command "Stop-Process -Id <PID> -Force"

2. Copiar la carpeta completa (NO mover aún — primero verificar):
   cp -r "C:\Users\Widox\.gemini\antigravity\scratch\argos-api" \
         "C:\Users\Widox\Desktop\ARGOS\argos-api"

3. Arrancar desde la nueva ubicación:
   cd C:\Users\Widox\Desktop\ARGOS\argos-api
   npm run build
   node dist/index.js

4. Verificar que la API responde:
   curl -s -H "ngrok-skip-browser-warning: true" \
        https://aids-prevail-unguarded.ngrok-free.dev/api/health

5. Si OK — actualizar referencias a la ruta antigua en:
   a. quick_tunnel_start.ps1 (ruta de arranque de argos-api)
   b. session_rollover.ps1
   c. ARGOS_QUICKSTART.md — sección rutas y reinicio
   d. agents/CODEX__SYSTEM_INSTRUCTIONS.md
   e. agents/ANTIGRAVITY__SYSTEM_INSTRUCTIONS.md
   f. Cualquier otro .ps1 o .md en ARGOS_RUNTIME que mencione .gemini\antigravity

6. Buscar referencias con:
   grep -r "antigravity\\\\scratch\\\\argos-api" C:\Users\Widox\Desktop\ARGOS\ --include="*.md" --include="*.ps1" --include="*.json"

7. Una vez confirmado todo OK: eliminar el original
   rm -rf "C:\Users\Widox\.gemini\antigravity\scratch\argos-api"

8. Añadir nota en ARGOS_GLOBAL_LOG.md con la ruta canónica nueva.

## Criterio de DONE

- argos-api corre desde C:\Users\Widox\Desktop\ARGOS\argos-api\
- /api/health responde desde la nueva ubicación
- Ningún script ni documento referencia la ruta antigua
- Original eliminado de la carpeta de Antigravity
- Ruta nueva documentada en ARGOS_QUICKSTART.md y agents/
[/WORK_PACKET]
