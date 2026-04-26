[WORK_PACKET]
ID: ARG-1777110000001
ROOM: GENERAL
TYPE: task
PRIORITY: P3
TAG: tokens, proxy, cowork, ledger, anthropic
ROLE_REQUESTED: Capitán / Claude Code
OWNER: pendiente
STATUS: open
REPORTED_BY: Claude (Cowork)
REPORTED_AT: 2026-04-24

CONTEXT:
El ledger de tokens en ARGOS (events/argos.tokens.jsonl) no registra las sesiones de
Cowork. La última entrada de Claude es del 2026-04-23 — todas las sesiones de Cowork
posteriores están sin contabilizar.

El proxy de argos-api captura tokens automáticamente cuando la variable de entorno
ANTHROPIC_BASE_URL=http://localhost:8080/proxy/anthropic está configurada en el entorno
de lanzamiento. Esto funciona para Claude Code (CLI) pero no para Cowork, que arranca
como aplicación desktop independiente sin esa variable.

OBJETIVO:
Configurar el entorno de lanzamiento de Cowork para que sus sesiones queden
contabilizadas en el ledger de tokens de ARGOS sin intervención manual.

TAREAS:
1. [ ] CAPITÁN: Verificar cómo arranca Cowork en Windows — ¿shortcut, .exe directo,
       servicio? Identificar si acepta variables de entorno en el lanzador.

2. [ ] CLAUDE CODE: Investigar si Cowork lee ANTHROPIC_BASE_URL del entorno del sistema
       o solo del proceso padre. Si lee del sistema: añadir la variable a las variables
       de entorno de usuario en Windows (Panel de control → Variables de entorno).

3. [ ] CLAUDE CODE / CAPITÁN: Si Cowork no acepta proxy externo, evaluar alternativa:
       webhook desde Cowork al cierre de sesión con estimación manual de tokens
       (fallback — menos preciso pero mejor que nada).

4. [ ] CLAUDE CODE: Una vez configurado, verificar que aparece entrada en
       events/argos.tokens.jsonl con agent="Claude" tras una sesión de Cowork.

SUCCESS_CRITERIA:
- Sesiones de Cowork aparecen en el ledger de tokens con agent="Claude"
- El widget de tokens del dashboard muestra datos de Cowork
- No requiere intervención manual por sesión

TOKENS_SPENT: 0
[/WORK_PACKET]
