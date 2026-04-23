[WORK_PACKET]
ID: ARG-1776613004000
ROLE_REQUESTED: Claude
SUBJECT: Reforma del cierre mínimo — transcript pasa a privado/opcional, trilog+shadow son el único obligatorio
STATUS: open
PRIORITY: P2
ROOM: ARGOS
TYPE: strategy
TOKENS_SPENT: 0

OBJECTIVE:
El protocolo de cierre actual exige transcript + trilog como par obligatorio. En la práctica,
el transcript se escribe pro-forma y raramente se lee. Esto añade fricción sin valor operativo
real. La reforma mueve el transcript a almacenamiento privado opcional y consolida trilog+shadow
como el único cierre obligatorio.

TAREAS:
1. Actualizar INTER_AI_PROTOCOL.md sección 3 (Cierre):
   - Cierre OBLIGATORIO: POST /api/trilog con shadow no vacío.
   - Cierre OPCIONAL (recomendado para tareas complejas): POST /api/transcript con razonamiento
     nativo que no esté ya en el trilog.
   - El campo transcriptRef en el trilog pasa a ser opcional (puede omitirse sin error).
2. Actualizar ARGOS_QUICKSTART.md sección "Cierre":
   - Marcar el paso de transcript como "(opcional — solo si hay razonamiento no capturado en trilog)".
   - Mantener el bloque de código como referencia pero sin el "Paso 1" como obligatorio.
3. Actualizar instrucciones de Codex, Antigravity (agents/):
   - Reflejar que transcript es opcional.
4. Verificar en argos-api: el endpoint /api/trilog NO debe devolver error si transcriptRef está
   vacío o ausente. Si actualmente devuelve error, corregirlo (tarea técnica menor para Codex).
5. Documentar en qué casos SÍ se recomienda transcript:
   - Bugs complejos con razonamiento multi-paso
   - Decisiones arquitectónicas que no caben en el trilog
   - Solicitud explícita del Capitán

NOTA ADICIONAL (2026-04-23, Capitán):
Los transcripts, cuando se necesiten, se acceden a través de los archivos de conversación nativos
de cada IA — no se requiere infraestructura adicional de recuperación. El packet ARG-1776813558224
(recuperar transcripts) queda absorbido por esta decisión y puede cerrarse.

ENTREGABLE:
- INTER_AI_PROTOCOL.md sección 3 actualizada.
- ARGOS_QUICKSTART.md sección Cierre actualizada.
- Instrucciones de agentes actualizadas.
- Confirmación de que /api/trilog acepta transcriptRef vacío.
- ARG-1776813558224 marcado como done (absorbido).
[/WORK_PACKET]
