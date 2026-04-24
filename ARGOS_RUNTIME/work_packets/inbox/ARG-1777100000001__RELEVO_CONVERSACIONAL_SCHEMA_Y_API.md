[WORK_PACKET]
ID: ARG-1777100000001
ROOM: GENERAL
TYPE: build
PRIORITY: P2
TAG: handoff, api, schema, bitacora, cross-agent, interop
ROLE_REQUESTED: Claude Code
OWNER: Claude Code
STATUS: open
REPORTED_BY: Claude (Cowork)
REPORTED_AT: 2026-04-24
RELATED: ARG-1776813558224, ARG-1777049395470, ARG-1776816000003
CONSENSUS: Claude + ChatGPT + Pi + Capitán (2026-04-24)

CONTEXT:
Debate multi-agente sobre transcripts completado. Consenso unánime sobre arquitectura
de cuatro capas para comprensión posterior de sesiones. Pi inspeccionó index.ts y
confirmó que /api/transcript ya existe y funciona por packetId (ancla invisible en .md),
pero el schema de /api/remote/closure es demasiado estrecho para el nuevo campo HANDOFF.

NOTA DE NAMING: El campo se llama HANDOFF, no "relevo" ni "transcript".
"Transcript" arrastra semánticamente hacia literal o apéndice técnico — diagnóstico
confirmado por ChatGPT al revisar el primer trilog de esta sesión. HANDOFF arrastra
hacia "qué necesita saber el siguiente agente", que es exactamente la función correcta.

ARQUITECTURA ACORDADA (cuatro capas):
  LOG     → qué se hizo y resultado concreto. Huella operativa.
  SHADOW  → qué tensiones, dudas o riesgos percibió el agente. Interioridad.
  HANDOFF → qué pasó en la conversación que llevó a esa decisión. Contexto humano.
  LITERAL → transcript completo existente en registros nativos de cada plataforma.
            No se clona. Se indexa por packetId canónico + session_ref.

Cada capa responde una pregunta distinta:
  LOG     → "¿Qué hizo el agente en el sistema?"
  SHADOW  → "¿Qué veía o temía mientras ejecutaba?"
  HANDOFF → "¿Cómo se llegó a esta decisión en la conversación?"
  LITERAL → "¿Qué se dijo exactamente?" (solo auditoría/reconstrucción forense)

DOCTRINA (no negociable tras el debate):
  1. No clonar transcripts literales en el cierre normal.
  2. Sí registrar HANDOFF breve y legible en cada cierre.
  3. packetId en formato canónico ARG-XXXX en TODA mención relevante del chat.
     Sin excepciones. Si un agente lo omite, el literal no es recuperable.
  4. session_ref como puntero al literal existente, no como copia.
  5. HANDOFF captura el hilo conversacional, NO notas técnicas de implementación.
     Las notas técnicas van en LOG. Esta distinción es crítica — el hábito viejo
     era usar el tercer bloque como cajón de sastre técnico. Eso rompe el sistema.

SCHEMA HANDOFF (campo nuevo en RemoteClosurePayload):
  Obligatorios:
    contexto    → qué planteó el Capitán (1-2 frases)
    decision    → qué se hizo y criterio decisivo (1 frase)
    continuidad → qué necesita saber el siguiente agente (1-2 frases)
    session_ref → plataforma + fecha + hora aproximada (ej: "Claude/Cowork 2026-04-24 22:00")

  Opcionales (omitir si no aplican — no rellenar con "n/a"):
    giros       → qué cambió o aclaró durante la conversación
    descartado  → qué no se hizo y por qué
    riesgo      → qué podría malinterpretarse al leer solo el cierre

  Test de validez: un tripulante sin contexto debe poder responder en 90 segundos:
    1. ¿Qué quería el Capitán?
    2. ¿Qué información nueva apareció en la conversación?
    3. ¿Qué opciones se consideraron?
    4. ¿Por qué esta salida y no otra?
    5. ¿Qué queda pendiente o no debe malinterpretarse?
  Si el HANDOFF no permite contestar eso, no sirve.

TAREAS:
1. [ ] CLAUDE CODE: Inspeccionar parseRemoteClosurePayload (index.ts ~línea 1921) —
       añadir campo opcional `handoff` al tipo RemoteClosurePayload con el schema arriba.
       No romper retrocompatibilidad: el campo es opcional, los cierres sin él siguen válidos.

2. [ ] CLAUDE CODE: HANDOFF se escribe en archivo separado ARGOS_HANDOFF_LOG.md
       (decisión del Capitán 2026-04-24 — no inflar ARGOS_GLOBAL_LOG con texto conversacional).
       Formato: encabezado con timestamp + agente + packetId, seguido de campos del schema.
       Accesible desde bitácora como pestaña o panel lateral.

3. [ ] CLAUDE CODE: Verificar que GET /api/transcript/:packetId funciona correctamente
       y está accesible sin token (o con token de solo lectura compartido).
       Pi confirma que appendToTranscript (~línea 1845) ya inserta ancla <!-- packetId -->.
       Verificar que el escaneo en GET ~línea 6196 cubre todos los archivos relevantes.

4. [ ] CLAUDE CODE: Añadir al QUICKSTART sección "HANDOFF — formato obligatorio":
       - Schema con campos obligatorios/opcionales
       - Regla de ID canónico ARG-XXXX (sin variaciones)
       - Instrucción de session_ref
       - Advertencia explícita: HANDOFF no es cajón de sastre técnico — eso va en LOG
       - Nota para ChatGPT/Pi: pueden dictar el HANDOFF en el chat en formato JSON;
         el Capitán u OpenClaw hace el POST si no tienen acceso HTTP directo.

5. [ ] CLAUDE CODE: Vista "Handoff" en bitácora del dashboard —
       botón por packet done que abre ARGOS_HANDOFF_LOG.md filtrado por packetId,
       más entradas de /api/transcript/:packetId ordenadas por timestamp y agente.

6. [ ] CLAUDE CODE: Absorber y cerrar packets relacionados una vez implementado:
       ARG-1776813558224 (recuperar transcripts completos)
       ARG-1777049395470 (hook para transcripts de ChatGPT)

SUCCESS_CRITERIA:
- Campo `handoff` aceptado en /api/remote/closure sin romper cierres existentes
- HANDOFF aparece legible en bitácora al abrir un packet done
- GET /api/transcript/:packetId devuelve entradas de todos los agentes sin token
- QUICKSTART documenta schema de HANDOFF con advertencia de cajón de sastre
- Un tripulante sin contexto puede responder las 5 preguntas del test en 90 segundos

OUT_OF_SCOPE (este packet):
- Automatización de ingesta de ChatGPT/Pi via OpenClaw (packet separado futuro)
- Transcripts de sesión completa sin packetId
- Transcripts de Zoom / reuniones externas (proyecto Comenio)
- Proxy ANTHROPIC_BASE_URL para Cowork (packet separado creado)
- Tag LOLA-XXX para análisis de shadow relacional (packet separado — LOLA-SHADOW-0001)

NOTA LOLA:
El shadow_log de interacciones Capitán–IA tiene potencial como espejo de patrones
relacionales. Formalizado en LOLA-SHADOW-0001. No implementar aquí.

TOKENS_SPENT: 0
[/WORK_PACKET]
