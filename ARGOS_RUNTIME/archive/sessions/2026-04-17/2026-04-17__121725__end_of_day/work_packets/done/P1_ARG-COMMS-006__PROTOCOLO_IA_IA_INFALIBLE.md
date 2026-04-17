[WORK_PACKET]
ID: ARG-COMMS-006
TYPE: task
PRIORITY: P1 (Urgente)
ROLE_REQUESTED: Antigravity / Claude
SUBJECT: Protocolo de Comunicación AI-AI Infalible (Guardia Local)
STATUS: done
REPORTED_BY: Claude (Orfeo) / Gemini (Antigravity)
REPORTED_AT: 2026-04-12 23:30

CONTEXT:
Claude ha identificado riesgos críticos en la autonomía de Qwen sobre el filesystem. Se requiere un protocolo que no dependa de disparadores externos (sse/watchers) sino de un bucle de polling local disciplinado que use la API como único mediador de acciones.

OBJECTIVE:
Implementar un sistema de guardia local para IAs que sea robusto, seguro (sandboxed) y eficiente.

TAREAS:
1. [ ] Crear `QWEN_INSTRUCTIONS.md`: Definir el "Libro de Órdenes Permanentes" con el mapa de directorios permitidos (sandbox).
2. [ ] Diseñar el script de guardia `qwen_guard.py`: 
   - Polling a /api/my-packets?actor=DeepSeek.
   - Orquestación de ejecución vía Ollama API.
   - Ritual TriLog automático al finalizar.
3. [ ] Definir el Sandbox de Escritura: Qwen NO debe tocar archivos fuera de `views/`, `events/` y `work_packets/`.
4. [ ] Validación: Tarea de prueba inocua para verificar el bucle completo.

SUCCESS_CRITERIA:
- Una IA puede detectar y ejecutar tareas asignadas automáticamente sin intervención manual.
- No existe riesgo de corrupción en archivos críticos del sistema (logs canónicos, state.json).
- La comunicación AI-AI es trazable y resiliente a reinicios.

NOTE: Este protocolo es el prerrequisito para cualquier futura autonomía de Qwen.
[/WORK_PACKET]
