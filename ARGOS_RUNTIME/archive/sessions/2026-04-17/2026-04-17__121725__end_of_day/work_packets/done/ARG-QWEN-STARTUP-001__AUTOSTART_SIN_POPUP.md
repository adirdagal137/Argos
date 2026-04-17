[WORK_PACKET]
ID: ARG-QWEN-STARTUP-001
TYPE: task
PRIORITY: P1
TAG: infrastructure, openclaw, startup
ROLE_REQUESTED: Capitan
OWNER: Capitan
STATUS: done
REPORTED_BY: Claude (Orfeo)
REPORTED_AT: 2026-04-16

CONTEXT:
Se ha creado el lanzador VBScript C:\Users\Widox\start_openclaw_hidden.vbs que inicia
OpenClaw gateway llamando a Node directamente (sin cmd/ps wrapper) con ventana oculta (vbHide).
Esto elimina los popups de PowerShell al iniciar OpenClaw.

OBJECTIVE:
Verificar que el VBScript funciona sin popups y configurar arranque automático al inicio de Windows.

TAREAS (el Capitán ejecuta manualmente):
1. [ ] Detener OpenClaw si está corriendo: abrir Task Manager → buscar node.exe con openclaw.mjs → End task
2. [ ] Doble clic en C:\Users\Widox\start_openclaw_hidden.vbs
3. [ ] Verificar: esperar ~30s → abrir Firefox → http://localhost:18789
       Debe cargar la interfaz de OpenClaw sin ningún popup de consola.
4. [ ] Si hay popups: escalar a Codex para solución NSSM (servicio Windows)
5. [ ] Si funciona: para arranque automático al inicio:
       - Pulsar Win+R → shell:startup
       - Copiar start_openclaw_hidden.vbs a esa carpeta (o crear acceso directo)
6. [ ] Confirmar al crew que OpenClaw está en "modo silencioso permanente"

ALTERNATIVA SI VBS NO FUNCIONA (escalar a Codex):
Usar NSSM para envolver OpenClaw como servicio Windows:
- Descargar NSSM de https://nssm.cc/release/nssm-2.24.zip
- Como admin: nssm install "ARGOS-OpenClaw" "C:\Program Files\nodejs\node.exe"
- Parámetros: "C:\Users\Widox\AppData\Roaming\npm\node_modules\openclaw\openclaw.mjs" gateway start
- nssm start ARGOS-OpenClaw
Esto garantiza cero popups + arranque automático + reinicio si cae.

SUCCESS_CRITERIA:
- OpenClaw arranca sin ninguna ventana de consola visible
- http://localhost:18789 responde tras el arranque
- Se inicia solo cuando el Capitán abre sesión en Windows
[/WORK_PACKET]
