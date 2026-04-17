[WORK_PACKET]
ID: ARG-BUG-012
TYPE: bug
TAG: bug, css, layout, webapp
ROLE_REQUESTED: Codex
SUBJECT: Layout monitor roto â€” sidebar-top-row aparece entre chat y vector
PRIORITY: P1
STATUS: done
RESOLVED_AT: 2026-04-11T10:11 Atlantic/Canary
RESOLVED_BY: Antigravity â€” consolidacion CSS, eliminacion de duplicados .vector-panel/.vector-content
CREATED_AT: 2026-04-11 Atlantic/Canary
CREATED_BY: Claude (Orfeo)
REPORTED_BY: CapitÃ¡n RubÃ©n Thor
TOKENS_SPENT: 0

DESCRIPCION:
El sidebar derecho de la vista MonitorizaciÃ³n (tokens + misiones/alertas + vector)
perdiÃ³ su layout. Los widgets de tokens y ops aparecen entre el chat y el vector
en lugar de estar en columna derecha con vector debajo.

CAUSA PROBABLE:
Orfeo editÃ³ ARGOS_VECTOR.md con formato nuevo (mÃ¡s secciones, mÃ¡s contenido),
lo que hizo crecer el vector-panel mÃ¡s allÃ¡ del lÃ­mite del sidebar.
IntentÃ³ corregir con CSS pero no resolviÃ³ el problema. Servidor reiniciado
y tampoco volviÃ³ a su sitio.

ARCHIVOS TOCADOS (a revisar y revertir si necesario):
- argos-dashboard/styles.css â†’ segunda definiciÃ³n .vector-panel (height: 100% eliminado)
  y .vector-content (overflow-y: auto aÃ±adido), .monitor-sidebar (min-height: 0 aÃ±adido)
- c:/Users/Widox/Desktop/ARGOS/ARGOS_RUNTIME/ARGOS_VECTOR.md â†’ ya restaurado al formato original

PASOS PARA REPRODUCIR:
1. Abrir dashboard en http://localhost:8080
2. Vista MonitorizaciÃ³n â€” sidebar derecho roto

HIPOTESIS PARA CODEX:
- Revisar si el segundo bloque CSS de .vector-panel y .vector-content
  (lÃ­nea ~1667 de styles.css) interfiere con el primero (lÃ­nea ~334)
- Puede que .monitor-sidebar necesite height: 100% explÃ­cito como hijo de grid
- Comparar con un git diff o snapshot de styles.css antes de los cambios de hoy
[/WORK_PACKET]
