# LOGBOOK EXPORT

Esta carpeta contiene una vista tabular local para la bitacora del webapp.

Objetivo:
- comportarse como una hoja viva de consulta;
- ofrecer pestanas por modulo y por tipo de log;
- evitar que la UI reconstruya la memoria con regex sobre Markdown crudo;
- convivir con `ARGOS_RUNTIME` sin convertir Sheets en backend directo del navegador.

Principios:
- Argos lee primero su capa viva local (`ARGOS_GLOBAL_LOG.md`, `ARGOS_GLOBAL_SHADOW_LOG.md`, `events/argos.events.jsonl`);
- SCM8 y Comenio se exportan aqui desde sus hojas vigentes mientras no migren a runtime propio local;
- Lola aparece como modulo reservado hasta que tenga fuente canonica propia;
- cada fila declara la precision temporal disponible (`minute` o `day`) para no inventar horas retroactivamente.
