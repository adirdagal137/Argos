[WORK_PACKET]
ID: ARGOS-TIFIS-0001
ROOM: arquitectura
TYPE: feature
TAG: bootstrap, api, chatgpt, ngrok
PRIORITY: P1
ROLE_REQUESTED: Claude
STATUS: in_progress
CREATED_AT: 2026-04-23T16:00:00Z
AUTHORED_BY: Claude (Orfeo)

SUBJECT: Implementar GET /api/ia/bootstrap en Tifis — ChatGPT no recibe JSON desde ngrok

OBJECTIVE:
El endpoint /api/bootstrap (y /api/ia/bootstrap) devuelve HTML del frontend en lugar
de JSON cuando se accede desde ngrok. ChatGPT Actions no puede contextualizarse.
Localmente la ruta responde JSON correcto.

CONTEXT:
- /api/bootstrap implementado y build OK
- GET /api/ia/bootstrap implementado en esta sesión, build OK
- Desde ngrok ambas rutas devuelven el HTML de la SPA (fallback del frontend)
- /api/ping también devuelve HTML desde ngrok
- En localhost:8080 las rutas responden correctamente con JSON
- Conclusión inicial: el proceso expuesto por ngrok NO es argos-api, o hay un
  proxy/middleware que intercepta /api/* antes del router

TAREAS:
1. [x] Implementar GET /api/ia/bootstrap (done — build OK, test local OK)
2. [ ] Diagnosticar qué proceso escucha en el puerto que expone ngrok
3. [ ] Confirmar que ngrok apunta a localhost:8080 (argos-api) y no a otro puerto
4. [ ] Verificar que no hay conflicto con argos-dashboard en el mismo puerto
5. [ ] Test externo: curl ngrok URL /api/ping → debe devolver JSON, no HTML
6. [ ] Marcar done cuando ChatGPT reciba JSON correcto desde ngrok

SUCCESS_CRITERIA:
- /api/bootstrap vía ngrok → JSON 200 con token válido
- /api/ia/bootstrap vía ngrok → JSON 200 con todos los campos
- /api/ping vía ngrok → JSON 200 {"ok":true}
- Sin token → 401 JSON (no HTML)
[/WORK_PACKET]
