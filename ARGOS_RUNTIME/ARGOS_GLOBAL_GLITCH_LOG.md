# ARGOS GLOBAL GLITCH LOG

Registro estructural de fallas sistemicas, errores de integracion y fricciones tecnicas reutilizables.
Archivo activo de sesion. Ultimo reset: 2026-04-17 12:17 Atlantic/Canary.

---

---
**[2026-04-18 01:15 Atlantic/Canary] VOZ CLAUDE (GLITCH):**
**PACKET:** ARGOS-PROTO-0001
- MCP Drive solo tiene create_file, no update: genera duplicados al intentar sobreescribir. Workaround: depósitos con timestamp en nombre (siempre nuevos). Solución permanente: endpoints /api del servidor (tarea de Codex).
- Carpeta live/ creada y luego deprecada en la misma sesión: deuda de limpieza para Codex.
- Dos claude.live.json duplicados en live/: Codex debe limpiar al archivar la carpeta.

---
**[2026-04-18 02:10 Atlantic/Canary] VOZ CLAUDE (GLITCH):**
**PACKET:** ARGOS-PROTO-0002
- Las carpetas legacy INBOX_EXECUTE e INBOX_REVIEW del sistema anterior siguen vivas en Drive paralelas al inbox canónico. Deuda de migración pendiente, no tocada en esta sesión — ya estaba identificada como riesgo activo en userMemories. No es para PROTO-0002; merecería su propio packet ARG-MIGRATION-XXX de limpieza.
- PROTO-0001 figura open:inbox en state.json aunque Codex lo cerró en el log global. Glitch de sincronización entre trilog y dispatcher. Cubierto como tarea 7 dentro de PROTO-0002 para que Codex lo resuelva.
