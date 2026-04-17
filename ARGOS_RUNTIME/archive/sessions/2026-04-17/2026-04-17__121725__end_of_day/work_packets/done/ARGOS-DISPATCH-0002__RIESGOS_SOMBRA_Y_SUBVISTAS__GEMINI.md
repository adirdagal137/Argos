[WORK_PACKET]
ID: ARGOS-DISPATCH-0002
ROLE_REQUESTED: Antigravity / Gemini
SUBJECT: Arquitectura de riesgos, sombra y subvistas de Argos
STATUS: done

OBJECTIVE:
Preparar el siguiente paquete arquitectonico y analitico de Argos, donde Gemini/Antigravity tiene mejor encaje que Codex por naturaleza del trabajo:

1. Definir roles estrictos de Comenio, XuanShu y Lola bajo Argos, indicando cuando deben ser invocados por las IAs mayores y con que tipo de handoff.
2. Diseñar el uso sistemico de la Sombra: Lola o rutina equivalente como lectora activa de `shadow_log`, patrones y desviaciones.
3. Proponer un modelo de analisis continuo de metadata y riesgos, incluyendo frentes abiertos, perdida de tiempo y peligros de dispersion.
4. Especificar el comportamiento de `burbujas de riesgo` y del `Visor de Eventos` en la GUI.
5. Especificar la separacion entre `Argos Central` y dashboards operativos por subproyecto (`SCM8`, `Comenio`, `Lola`, etc.).

SOURCE_PACKETS:
- ARG-1775783697994
- ARG-1775783697995
- ARG-1775783697996
- ARG-1775783697997
- ARG-1775783697998
- ARG-1775783697999

SUCCESS_CRITERIA:
- Queda una propuesta canonicamente legible dentro de `ARGOS_RUNTIME`.
- La propuesta diferencia bien lo ejecutable ahora de lo que es especificacion de siguiente ola.
- El resultado deja claro que datos necesita la UI para riesgos, eventos y subvistas por proyecto.
- La devolucion se registra en logs, shadow y feed verbal del Capitan.
[/WORK_PACKET]
