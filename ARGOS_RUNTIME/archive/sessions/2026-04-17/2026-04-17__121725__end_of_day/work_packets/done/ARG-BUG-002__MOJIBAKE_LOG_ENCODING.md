[WORK_PACKET]
ID: ARG-BUG-002
TYPE: bug
TAG: bug
SEVERITY: high
ROLE_REQUESTED: Codex / Antigravity
SUBJECT: Mojibake en ARGOS_GLOBAL_LOG.md y ARGOS_GLOBAL_SHADOW_LOG.md
STATUS: done
REPORTED_BY: Antigravity
REPORTED_AT: 2026-04-10T11:28 Atlantic/Canary

CONTEXT:
Los archivos de log vivos muestran caracteres corruptos. Ejemplos confirmados:
- o con tilde (o) aparece como A^3 (secuencia Latin-1 leida como UTF-8)
- e con tilde (e) como A(C)
- n con tilde (n) como A+-
Esto ocurre porque alguna escritura se hizo con codificacion Latin-1/CP1252 sobre
un archivo guardado en UTF-8, o viceversa. El 00_ARGOS_MANIFESTO.md tiene el mismo
problema parcialmente (mezcla de codificaciones en el mismo archivo).

EFECTO:
- El Visor de Eventos muestra texto ilegible en entradas con tildes.
- Busqueda textual puede fallar sobre palabras accentuadas.
- Experiencia de lectura del Capitan degradada.

ARCHIVOS AFECTADOS:
- ARGOS_GLOBAL_LOG.md (confirmado: entradas del 10-ABR con mojibake)
- ARGOS_GLOBAL_SHADOW_LOG.md (confirmado: mismas entradas)
- 00_ARGOS_MANIFESTO.md (parcial)

TAREAS:
1. Leer cada archivo con Get-Content -Encoding Latin1 y reescribir con UTF8NoBOM.
2. Verificar manualmente que el contenido legible no se haya perdido.
3. Anadir regla en ARGOS_BOOT_PROTOCOL.md: escritura siempre con UTF-8 sin BOM.

SUCCESS_CRITERIA:
- ARGOS_GLOBAL_LOG.md y SHADOW_LOG.md muestran tildes correctas en el Visor de Eventos.
- Ninguna entrada nueva introduce mojibake.
[/WORK_PACKET]
