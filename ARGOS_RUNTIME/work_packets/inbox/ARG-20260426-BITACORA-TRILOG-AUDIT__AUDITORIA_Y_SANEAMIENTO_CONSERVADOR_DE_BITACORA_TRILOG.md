[WORK_PACKET]
ID: ARG-20260426-BITACORA-TRILOG-AUDIT
ROOM: ARGOS
TYPE: maintenance
TAG: bitacora, trilog, audit, shadow, handoff, legacy_cleanup
SUBJECT: Auditoria y saneamiento conservador de bitacora trilog historica
ROLE_REQUESTED: Claude
OWNER: Claude
STATUS: open
PRIORITY: high
REPORTED_BY: Codex
REPORTED_AT: 2026-04-26

[OBJETIVO]
Auditar y sanear de forma conservadora la bitacora historica de ARGOS para reducir falsos "trilog incompleto", normalizar nombres actuales y detectar cierres de workpackets finalizados con campos obligatorios vacios.

Este packet se separa de ARG-20260426-DOC-CONTEXT-HYGIENE. Aquel trata higiene documental y quickstart. Este trata datos historicos de bitacora/logs/events.

[DEFINICION CANONICA A USAR]
Un cierre finalizado de workpacket debe tener trilog:
1. LOG
2. SOMBRA
3. HANDOFF

El LOG finalizado debe contener o poder mapear estos campos:
- voz
- ID / packet_id
- mision
- detalles
- siguiente
- aprendizaje
- riesgos

Notas:
- En logs "in_progress", "working", "meta" o lifecycle no-final no hace falta completar todos los campos.
- "summary" NO esta deprecated globalmente. Sigue siendo valido para Inbox, start-task y UI. Solo debe marcarse como legacy si se usa como sustituto ambiguo de "mission/mision" en un cierre finalizado.
- "transcript" no es cierre ni handoff. Puede existir como transcripcion literal opcional, separada del trilog.
- "relevo" y nombres similares deben quedar deprecated como forma de handoff, salvo lectura historica.
- "Pi", "Antigravity" y "DeepSeek" no deben ser actores canonicos vivos. Gemini es el actor canonico para esa voz/interfaz. DeepSeek/Qwen/OpenClaw deben revisarse segun origen antes de migrar.

[ALCANCE]
Auditar:
- ARGOS_RUNTIME/ARGOS_GLOBAL_LOG.md
- ARGOS_RUNTIME/ARGOS_GLOBAL_SHADOW_LOG.md
- ARGOS_RUNTIME/ARGOS_GLOBAL_GLITCH_LOG.md
- ARGOS_RUNTIME/ARGOS_GLOBAL_HANDOFF_LOG.md si existe
- ARGOS_RUNTIME/events/argos.events.jsonl
- ARGOS_RUNTIME/events/argos.glitches.jsonl
- ARGOS_RUNTIME/views/ui_export/captain_feed.jsonl solo como evidencia auxiliar
- ARGOS_RUNTIME/work_packets/done, archived, inbox, in_progress si existen y son necesarios para cruzar estados
- ARGOS_RUNTIME/state/argos.state.json y state archive si existe para determinar finalizados

No auditar en esta fase salvo necesidad justificada:
- archives de mas de 3 dias
- transcripts literales completos
- Drive externo

[FASE 0 - PRECAUCIONES]
Antes de tocar nada:
- Ejecutar git status.
- No revertir cambios ajenos.
- No reescribir logs masivamente sin backup.
- Crear snapshot local de los archivos que se vayan a modificar, preferiblemente en ARGOS_RUNTIME/archive/legacy/bitacora_trilog_audit_YYYYMMDD_HHMM/.
- Si hay duda, producir reporte y parar antes de modificar.

[FASE 1 - INVENTARIO Y METRICAS]
Construir un reporte inicial con conteos:
- total de entradas LOG por packet_id
- total de entradas SHADOW por packet_id
- total de entradas HANDOFF por packet_id
- total de eventos JSONL por packet_id
- packets finalizados detectados
- finalizados sin LOG
- finalizados sin SOMBRA
- finalizados sin HANDOFF
- finalizados con mision vacia o inferida desde summary
- finalizados con aprendizaje vacio
- finalizados con riesgos vacio
- entradas con actor legacy: Pi, Antigravity, DeepSeek, IA, sistema, agente, ChatAgent
- entradas con nombres legacy: transcript usado como cierre, relevo, errors como aprendizaje, errores + aprendizajes mezclado
- entradas ORPHAN: sin packet_id o packet_id N/A/PROBE cuando no proceda

Salida esperada:
- ARGOS_RUNTIME/reports/bitacora_trilog_audit_YYYYMMDD.md
  o, si reports no existe, crear ARGOS_RUNTIME/reports/.

[FASE 2 - CLASIFICACION]
Clasificar cada problema en:
- AUTO_FIX: correccion inequívoca sin inventar contenido.
- NEEDS_CAPTAIN: falta contexto y requiere decision del Capitan.
- LEGACY_KEEP: historico antiguo que se conserva y solo se marca como legacy/deprecated.
- IGNORE: falso positivo, por ejemplo in_progress o session/meta no-final.

Reglas AUTO_FIX:
- Actor "Antigravity" o "Pi" en fecha/contexto donde el sistema ya decidio Gemini como canonico, y la entrada no corresponde a una voz historica deliberadamente preservada: normalizar a Gemini.
- Mojibake mecanico claro en headers o labels, si no cambia significado.
- Campo "ERRORES + APRENDIZAJES" puede mapearse a aprendizaje solo si contiene aprendizaje real; si solo contiene error, no inventar.
- "summary" puede mapearse a mission si la entrada es de remote_closure y el propio payload marco legacy_summary_used o si no hay otro campo de mission.
- Handoff estructurado existente en handoff log puede enlazarse a la fila por packet_id sin duplicar texto.

Reglas que NO son AUTO_FIX:
- Aprendizaje vacio: no inventar. Usar "Sin aprendizaje registrado en cierre original" solo si el Capitan acepta normalizacion de placeholder.
- Sombra vacia: no inventar. Marcar brecha.
- Riesgos vacios: no inventar salvo que el cierre diga explicitamente que no hay riesgos.
- Packet sin handoff: no fabricar handoff retrospectivo si no hay decision trail.

[FASE 3 - SANEAMIENTO CONSERVADOR]
Aplicar solo AUTO_FIX con backup previo.

Posibles cambios:
- Normalizar labels en markdown:
  - WORK PACKET / PACKET / ID hacia ID o packet_id segun formato destino.
  - MISION con acento/encoding correcto si se corrige mojibake.
  - ERRORES + APRENDIZAJES hacia APRENDIZAJE si el contenido aplica.
- Normalizar actores legacy inequívocos.
- Marcar entradas legacy con nota corta de deprecation si no conviene reescribir:
  - "LEGACY: transcript/relevo no es cierre canonico; consultar handoff si existe."
- Añadir reporte de brechas, no rellenar contenido inventado.

No hacer:
- No borrar entradas historicas.
- No mezclar captain_feed con global log.
- No convertir transcripts literales en handoff.
- No editar archives antiguos salvo que el Capitan lo pida.

[FASE 4 - VALIDACION POSTERIOR]
Reejecutar auditoria y comparar antes/despues:
- Conteos iniciales vs finales.
- Numero de AUTO_FIX aplicados.
- Numero de NEEDS_CAPTAIN pendientes.
- Numero de LEGACY_KEEP.
- Cualquier archivo modificado.

Actualizar reporte:
- ARGOS_RUNTIME/reports/bitacora_trilog_audit_YYYYMMDD.md
Debe incluir:
- Resumen ejecutivo.
- Tabla por packet_id con estado trilog.
- Lista de correcciones aplicadas.
- Lista de pendientes que requieren Capitan.
- Riesgos residuales.

[FASE 5 - WORKPACKETS DERIVADOS]
Crear workpackets futuros si aparecen temas fuera de alcance:
- Migracion tecnica de logs vivos a ARGOS_RUNTIME/logs/current/.
- Edicion de visor de eventos para estandarizar handoff.
- Ajuste UI de tabla de bitacora: Detalles ancho, Sombra igual que Detalles, Handoff minimo sin cortar header.
- Validaciones backend estrictas para impedir nuevos cierres incompletos.
- Saneamiento de archives historicos mas antiguos.

[VERIFICACION SUGERIDA]
Comandos orientativos:
- rg -n "VOZ (PI|ANTIGRAVITY|DEEPSEEK)|VOZ IA|ChatAgent|packet_id.: N/A|WORK PACKET.: PROBE" ARGOS_RUNTIME
- rg -n "transcript|relevo|ERRORES \\+ APRENDIZAJES|APRENDIZAJE|SOMBRA|HANDOFF" ARGOS_RUNTIME/ARGOS_GLOBAL_LOG.md ARGOS_RUNTIME/ARGOS_GLOBAL_SHADOW_LOG.md
- node -e "const fs=require('fs'); for (const f of ['ARGOS_RUNTIME/events/argos.events.jsonl','ARGOS_RUNTIME/events/argos.glitches.jsonl']) { if (!fs.existsSync(f)) continue; fs.readFileSync(f,'utf8').split(/\\r?\\n/).filter(Boolean).forEach((l,i)=>{try{JSON.parse(l)}catch(e){console.log(f+':'+(i+1))}}) }"

[CRITERIOS DE CIERRE]
- Existe reporte de auditoria con metricas antes/despues.
- No se han inventado sombras, aprendizajes, riesgos ni handoffs.
- Se aplicaron solo correcciones inequívocas o se dejo todo como reporte si no habia seguridad.
- Actores legacy detectados quedan normalizados o listados con justificacion.
- Nombres legacy como transcript/relevo quedan marcados como deprecated o listados para migracion.
- Quedan identificados packets finalizados con brechas reales de trilog.
- Se crea cierre de bitacora completo para este packet: log + sombra + handoff.
- Se avisa por cubierta al Capitan al cerrar.

[RIESGOS]
- Riesgo alto de falsificar historia si se rellenan campos ausentes por intuicion. Prohibido.
- Riesgo medio de romper parsers markdown si se reescriben headers sin conocer el formato. Hacer backup y cambios minimos.
- Riesgo medio de contar como incompleto un packet finalizado antes de que existiera el protocolo trilog. Clasificar como LEGACY_KEEP si corresponde.
- Riesgo bajo de duplicar handoff si ya existe en handoff log y tambien en events. Enlazar, no duplicar.

[/WORK_PACKET]
