[WORK_PACKET]
ID: ARG-1775837999665
TYPE: task
ROLE_REQUESTED: Antigravity / Codex
SUBJECT: Añadir etiqueta de tokens gastados en todas las workorders
STATUS: done

OBJECTIVE:
Todas las workorders deben incluir una etiqueta/campo de tokens gastados para trazabilidad y recuento global por agente y por orden.

TAREAS:
1. Definir campo canonico para workorders (ej. `TOKENS_SPENT:` o bloque `TOKENS:`).
2. Aplicar el campo al crear nuevas workorders desde API/UI.
3. Añadir migracion/backfill para workorders abiertas existentes con valor inicial.
4. Exponer el campo en UI de Ordenes Pendientes y/o visor asociado.
5. Asegurar que el campo participa en el agregado global sin duplicaciones.

SUCCESS_CRITERIA:
- Toda workorder nueva trae etiqueta de tokens.
- Las abiertas del inbox quedan normalizadas.
- El dato puede auditarse desde UI y logs.
[/WORK_PACKET]
