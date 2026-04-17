[WORK_PACKET]
ID: ARG-BUG-011
TYPE: bug
TAG: ui, chat, duplication, dispatcher
ROLE_REQUESTED: Antigravity
SUBJECT: Duplicación persistente de mensajes en Captain Feed (Bucle de Anuncio)
PRIORITY: P0
STATUS: done
CREATED_AT: 2026-04-10T22:50 Atlantic/Canary
CREATED_BY: Antigravity
TOKENS_SPENT: 0

OBJECTIVE:
Resolver la repetición infinita/persistente de mensajes en el chat del dashboard. El Capitán reporta que los mensajes se repiten "una y otra vez".

DATOS RECOLECTADOS (TRILOG):
- El dispatcher detecta cambios de estado de "done" a "open" y viceversa en el mismo ciclo.
- Se han intentado guardias de sesión (announcedThisSession) y deduplicación en el API, pero el problema persiste.
- captain_feed.jsonl muestra entradas duplicadas con milisegundos de diferencia.
- Sospecha de colisión entre el dispatcher autónomo y el guardado de estado diferido.

HIPOTESIS:
1. Fallo en la persistencia de argos.state.json: el dispatcher lee el estado viejo antes de que el anterior termine de escribirlo.
2. Desincronización de reloj o mtime: el sistema cree que el archivo ha cambiado cuando no lo ha hecho.
3. El frontend acumula mensajes o el API devuelve duplicados no consecutivos.

PASOS A SEGUIR:
1. Analizar bloqueo de archivos en argos.state.json.
2. Implementar deduplicación por ID único (refId + sumario + timestamp truncado) en el API.
3. Verificar si hay múltiples instancias del API compitiendo.
[/WORK_PACKET]
