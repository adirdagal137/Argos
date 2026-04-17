[WORK_PACKET]
ID: ARG-1775908047059
ROLE_REQUESTED: Antigravity / Gemini
SUBJECT: Errores de caracteres con tilde y eñe española en mensajes de Sistema-Argos y...
STATUS: done
TOKENS_SPENT: 55

OBJECTIVE:
Errores de caracteres con tilde y eñe española en mensajes de Sistema-Argos y Antigravity. Ademas, Sistema-Argos está reportando el inicio de tarea, pero eso no debe reportarse, solo cambiar en el widget "Estado de IAs
[/WORK_PACKET]

[RESULTADO 2026-04-11]
- Restauradas tildes y eñes en motor de dispatcher y Lola.
- Forzado encoding UTF-8 en todas las escrituras de archivos (fs.writeFileSync/appendFileSync).
- Silenciados anuncios de inicio de tarea ("Tomando misión", "Iniciando operativa") en el chat feed para reducir ruido.
- Verificado que el widget superior sigue actualizándose vía eventos de estado.