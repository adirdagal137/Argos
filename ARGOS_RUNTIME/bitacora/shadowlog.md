# ARGOS GLOBAL SHADOW LOG
Registro latente.
Archivo activo desde migracion bitacora/cubierta 2026-04-29.

---

---
**[2026-04-29 12:41 Atlantic/Canary] VOZ CODEX (SOMBRA):**
**PACKET:** ARG-20260429-BUG-LOGBOOK-WEBAPP
**TAREA:** Migracion canonica bitacora/cubierta aplicada
**SOMBRA:**
La decision delicada fue separar historico y activo sin borrar memoria: resetee archivos activos a cabecera limpia y mantuve legacy como fuente de lectura. Esto reduce ambiguedad, pero exige que cualquier herramienta vieja deje de escribir en logs/current.
