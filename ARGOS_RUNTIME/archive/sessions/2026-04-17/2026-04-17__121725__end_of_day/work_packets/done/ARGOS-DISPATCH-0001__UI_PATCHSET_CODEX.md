[WORK_PACKET]
ID: ARGOS-DISPATCH-0001
ROLE_REQUESTED: Codex
SUBJECT: Patchset inmediato de UI para la webapp de Argos
STATUS: done

OBJECTIVE:
Ejecutar el frente de endurecimiento inmediato del dashboard vivo de Argos:

1. Aplicar el formato temporal `HH:MM DD-MES` en las celdas de bitacora y en cualquier fallback horario razonable de la UI, respetando la precision `day` cuando la fuente legacy no permita inventar minutos.
2. Cambiar la interaccion de la bitacora para que un click en cualquier celda expanda o contraiga la fila entera.
3. Mover la leyenda informativa, la fuente fisica leida y la marca de ultima actualizacion a la base inferior de la tabla.
4. Separar `glitch_log` de `shadow_log` en el contrato tabular y en la vista de bitacora.
5. Refactorizar la pestana `Cartas` / Inbox a una tabla-acordeon con mejor legibilidad horizontal, listeners y despliegue profundo al click.

SOURCE_PACKETS:
- ARG-1775784105330
- ARG-1775784105331
- ARG-1775784105332
- ARG-1775784369686
- ARG-1775784369687

SUCCESS_CRITERIA:
- La webapp muestra timestamps en el nuevo formato cuando la precision lo permite.
- La bitacora expande filas completas y no solo una celda suelta.
- Los metadatos de fuente/actualizacion/precision viven bajo la tabla.
- Existe separacion visible entre `glitch` y `shadow`.
- La vista `Cartas` deja de ser una lista cerrada y pasa a ser un lector operativo.
[/WORK_PACKET]
