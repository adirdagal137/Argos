ARGOS-ANTIGRAV-0001
Título: Mejoras UX bitácora — expansión horizontal de logs y reflexión sobre campos vacíos
Asignado a: Antigravity
Prioridad: Media
Estado: inbox
Descripción:
La bitácora presenta dos fricciones de usabilidad que se piden resolver:
Mejora 1 — Expansión horizontal al expandir un registro
Actualmente cuando se expande una burbuja/fila de log larga, crece verticalmente empujando el resto del contenido hacia abajo. La lectura de registros largos es incómoda.
Se pide que al expandir un registro, este también crezca horizontalmente — contrayendo, ocultando o solapando los campos adyacentes de esa fila — de forma que el contenido expandido ocupe más ancho de pantalla y sea más legible. El comportamiento exacto (colapsar columnas vecinas, overlay, modal, etc.) queda a criterio de implementación, priorizando legibilidad.
Mejora 2 — Nota de reflexión en campos vacíos
Con frecuencia los campos "Siguientes pasos", "Error/Aprendizaje" y similares quedan vacíos en los registros. Esto no es visible ni se señala.
Se pide añadir, cuando estos campos estén vacíos, algún indicador visual o nota que llame la atención sobre su ausencia — puede ser un texto placeholder, un icono, un color distinto, o similar. El objetivo es que el vacío no sea invisible sino que invite a la reflexión o al completado posterior.
Criterios de aceptación:

 Al expandir un log largo, el área expandida gana anchura de forma notoria (no solo altura)
 Los campos adyacentes se contraen, ocultan o quedan en segundo plano durante la expansión
 Campos reflexivos vacíos muestran algún indicador visual distinguible del campo simplemente no-aplicable
 El comportamiento es consistente en los registros existentes y los nuevos

Notas:

No romper el layout base de la bitácora para registros normales/cortos
La solución de expansión horizontal debe funcionar en la vista actual de la bitácora (webapp)
