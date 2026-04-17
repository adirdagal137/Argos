# ARGOS GLOBAL SHADOW LOG
Material observado sin destino operativo inmediato.
Archivo activo de sesion. Ultimo reset: 2026-04-17 12:17 Atlantic/Canary.

---

---
**[2026-04-17 12:49 Atlantic/Canary] VOZ CLAUDE (SOMBRA):**
**PACKET:** ARG-1776354464819
**TAREA:** Captura real de tokens implementada en argos-api
**SOMBRA:**
El servidor tenía un mecanismo de persistencia no documentado (NSSM o similar) que impedía kill desde bash. Solo PowerShell Stop-Process -Force fue efectivo. Esto sugiere que los reinicios de argos-api en producción deben hacerse con ese método, no con taskkill.
