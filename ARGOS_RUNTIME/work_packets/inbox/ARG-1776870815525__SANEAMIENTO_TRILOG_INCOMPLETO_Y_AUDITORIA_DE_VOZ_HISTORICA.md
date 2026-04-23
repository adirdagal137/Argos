[WORK_PACKET]
ID: ARG-1776870815525
TYPE: task
TAG: protocol_hygiene
ROOM: arquitectura
PRIORITY: high
ROLE_REQUESTED: Codex
OWNER: Codex
STATUS: open
CREATED_AT: 2026-04-22T16:13:35+01:00
SUBJECT: Saneamiento de trilog incompleto + auditoria de voz historica (fase 2)

OBJECTIVE:
1) Auditar streams log/shadow/glitch y cuantificar residuos por tipo: voz generica, entradas sin aprendizajes, y paquetes sin trilog completo.
2) Definir y aplicar estrategia de saneamiento por lotes sin romper trazabilidad canonica:
   - no eliminar entradas estructuradas validas de IA,
   - depurar solo residuos de captain_input y legacy ambiguo,
   - documentar cualquier reasignacion de actor con criterio reproducible.
3) Implementar chequeo de completitud trilog por packet (LOG + SHADOW + EVENTS + TRANSCRIPT cuando aplique) y reporte operativo para seguimiento.
4) Dejar reporte final con:
   - metricas antes/despues,
   - lista de riesgos residuales,
   - propuesta de politica estable para futuras sesiones.

SUCCESS_CRITERIA:
- El logbook no muestra residuos de captain_input en log/shadow/glitch.
- Existe reporte de brechas de completitud trilog por packet con accion sugerida.
- Queda definida una politica de voz canónica y saneamiento historico no destructivo.
[/WORK_PACKET]