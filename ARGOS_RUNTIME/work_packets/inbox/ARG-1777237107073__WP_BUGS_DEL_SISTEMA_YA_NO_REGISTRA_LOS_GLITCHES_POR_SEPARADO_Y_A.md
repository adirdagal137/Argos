[WORK_PACKET]
ID: ARG-1777237107073
ROLE_REQUESTED: Cualquiera
SUBJECT: WP: Bugs del sistema ya no registra los glitches por separado, y además está vacío...
STATUS: open
ROOM: GENERAL
TYPE: task
TOKENS_SPENT: 174

OBJECTIVE:
WP: Bugs del sistema ya no registra los glitches por separado, y además está vacío porque no tiene historial de bugs resueltos. Falta implementar. Los glitches van por un log a parte, pero no están siendo visualizados en bitácora: Añadir columna "glitches" para cada entrada con resumen del Glitch leído directamente del summary de ese glitch_log.
Como tenemos IDs canónicas por cada workpacket, y nada existe sin una ID que lo localice, hay que estudiar si la bitácora podría absorber funcionar mejor absorbiendo por ID. ¿Cóomo se está escribiendo ahora cada fila del log? Archivo a archivo leído desde el API? No hay forma mejor para minimizar peso de registros? Nuevamente, hay que estudiarlo.
[/WORK_PACKET]