[WORK_PACKET]
ID: ARG-1776613000001
ROLE_REQUESTED: Codex
SUBJECT: Podar glitch log de duplicados masivos y añadir ventana de dedup al TriLog Guard
STATUS: open
PRIORITY: P1
ROOM: ARGOS
TYPE: maintenance
TOKENS_SPENT: 0

OBJECTIVE:
ARGOS_GLOBAL_GLITCH_LOG.md está contaminado por duplicados masivos del tipo "TriLog incompleto"
que se generan cada vez que el dispatcher escanea packets sin cierre. No representan glitches
reales — son ruido acumulado que degrada la legibilidad y el rendimiento del sistema.

TAREAS:
1. Leer ARGOS_GLOBAL_GLITCH_LOG.md e identificar los patrones duplicados (mínimo: "TriLog incompleto"
   con mismo packetId repetido N veces).
2. Deduplicar: conservar solo la primera ocurrencia por (packetId + tipo de glitch). Mover las
   entradas podadas a ARGOS_RUNTIME/archive/glitch_archive_YYYYMMDD.md para no perder historial.
3. En argos-api (src/index.ts): localizar el TriLog Guard / dispatcher que genera estos glitches y
   añadir una ventana temporal de dedup — mínimo 24h entre dos glitches del mismo tipo para el mismo
   packetId. La ventana debe ser configurable como constante (GLITCH_DEDUP_WINDOW_MS).
4. Añadir también poda automática: si un glitch de tipo "TriLog incompleto" lleva más de 7 días
   sin resolverse, se mueve automáticamente a histórico y deja de aparecer en el tablero activo.
5. Compilar, reiniciar (usar PowerShell Stop-Process -Force para el PID en :8080), verificar que
   el glitch log no se vuelve a contaminar en el siguiente ciclo del dispatcher.

ENTREGABLE:
- ARGOS_GLOBAL_GLITCH_LOG.md limpio.
- Constante GLITCH_DEDUP_WINDOW_MS activa en argos-api.
- Archivo de glitches podados en archive/.

CONTEXTO TÉCNICO:
- argos-api: C:/Users/Widox/.gemini/antigravity/scratch/argos-api/src/index.ts
- Para reiniciar: powershell -Command "Stop-Process -Id <PID> -Force" (el PID en :8080)
- El dedup general usa dedupCache con TTL — el mismo patrón puede aplicarse a glitches.
[/WORK_PACKET]
