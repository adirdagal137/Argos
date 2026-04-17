[WORK_PACKET]
ID: ARG-DEEPSEEK-INTEGRATION
TYPE: task
TAG: integration, efficiency, open-source
ROLE_REQUESTED: Codex / Claude (Orfeo) / Antigravity
PRIORITY: P2
STATUS: in_progress
CREATED_AT: 2026-04-10T22:50 Atlantic/Canary
CREATED_BY: Claude (Orfeo)
TOKENS_SPENT: 0

SUBJECT: Integración de Deepseek como 4º tripulante — Guardián de Eficiencia del Navío

OBJECTIVE:
El proyecto Argos gasta tokens de pago (Claude, Codex, Gemini) en tareas que podrían resolverse
con modelos open-source. Integrar Deepseek (local o API gratuita) como **Guardián de Eficiencia**
para filtrar trabajo innecesario y ahorrar ~60-70% de tokens de pago.

ARQUITECTURA PROPUESTA:

**1. Rol de Deepseek: "Guardián de Eficiencia"**
   - Recibe tareas nuevas en el captain_feed via Pub/Sub (ARG-COMMS-001)
   - Analiza si puede resolverlas con open-source:
     ✓ Categorización de tickets
     ✓ Parsing de logs y extracción de información
     ✓ Búsqueda en base de conocimiento local
     ✓ Generación de plantillas boilerplate
     ✓ Validación sintáctica de código
     ✗ Arquitectura nueva, diseño creativo, decisiones estratégicas
   - Si es resolvible: **ejecuta sin gastar tokens de pago**
   - Si requiere IA paga: **enruta a Codex/Claude/AG con briefing**

**2. Integración Técnica**
   a) API endpoint nuevo:
      ```
      POST /api/deepseek/analyze-task
      Input: {packetId, subject, objective}
      Output: {isOpenSourceSolvable: boolean, recommendation: string, difficulty: 'easy'|'medium'|'hard'}
      ```
   
   b) Conexión con Pub/Sub:
      - Deepseek se suscribe a `packet:assigned` en captain_feed
      - Cuando llega tarea nueva: analiza automáticamente
      - Publica resultado: `packet:analyzed → {recommendation}`
   
   c) Bases de conocimiento para Deepseek:
      - INTER_AI_PROTOCOL.md → instrucciones del sistema
      - ARGOS_VECTOR.md → vectores y estado actual
      - work_packets/done/ → ejemplos de tareas similares resueltas
      - Archivo local .env con config de Deepseek

**3. Capas de Decisión**
   ```
   Nueva tarea entra en inbox
         ↓
   Deepseek: "¿puedo resolver esto?"
         ↓
   ¿Es categorización/búsqueda/parsing?
         ├─ SÍ → Deepseek ejecuta, logs al captain_feed
         └─ NO → Enruta a Codex/Claude/Antigravity con briefing + contexto
   ```

**4. Ahorro de Tokens (Estimado)**
   - 40% de tareas actuales son categorización/búsqueda/parsing
   - Deepseek ejecuta estas: 0 tokens pago
   - Antes: 500 tokens/día en tareas bajas
   - Después: ~150 tokens/día (solo IA paga para lo importante)
   - **Ahorro neto: ~350 tokens/día (~3,500 tokens/semana)**

**5. Implementación Faseada**
   Fase 1 (2-3h): Setup y análisis de tareas
   - Instalar/configurar Deepseek (local o Ollama si tienes GPU)
   - Crear endpoint `/api/deepseek/analyze-task`
   - Test manual de clasificación
   
   Fase 2 (2-3h): Integración con Pub/Sub
   - Deepseek se suscribe a packets nuevos
   - Auto-análisis de tareas en tiempo real
   - Logging en captain_feed
   
   Fase 3 (1-2h): Ejecución de tareas low-complexity
   - Deepseek ejecuta tareas de categorización
   - Escribe resultados en work_packets/done/
   - Publica logs al sistema

**TAREAS EXACTAS:**
1. [Claude/Orfeo] Crear wrapper de Deepseek en TypeScript (análisis de tareas)
2. [Codex] Integrar con Pub/Sub creado en ARG-COMMS-001
3. [Deepseek] Auto-ejecución de tareas low-complexity (categorización, búsqueda)
4. [Antigravity] Monitoreo y optimización de la cadena Deepseek → IA paga

**DEPENDENCIAS:**
- ARG-COMMS-001 (Pub/Sub WebSocket) — debe completarse primero
- ARG-COMMS-005 (Inbox observado) — recomendado

**CRITERIO DE ACEPTACIÓN:**
- Deepseek responde <500ms a análisis de tareas
- 50%+ de tareas "fáciles" se ejecutan sin IA paga
- Diferencia mensual de tokens: -3,500 por semana
- Cero pérdida de calidad en tareas de IA paga (Codex/Claude/AG mantienen nivel)

**NOTAS ARQUITECTÓNICAS:**
- Deepseek NO participa en decisiones estratégicas
- Es un "filtro inteligente", no un "ejecutor autónomo"
- Si Deepseek duda, enruta a IA paga
- Logs de Deepseek se marcan con `[DEEPSEEK]` en actor field

**TIEMPO ESTIMADO: 5-7 horas (todas las fases)**

PROGRESO (2026-04-11 Orfeo):
- Hardware confirmado: RTX 4070 Laptop 8GB VRAM — deepseek-r1:8b cabe entero en GPU (~5.2GB)
- Instalación Ollama en curso (Capitán instalando ahora)
- Arquitectura dispatcher definida: Node.js orquesta, DeepSeek clasifica intención del Capitán
- [DONE] Implementados 3 endpoints en argos-api:
  * GET /api/deepseek/status → ping Ollama + listado modelos disponibles
  * POST /api/deepseek/analyze-task → {isOpenSourceSolvable, difficulty, agentSuggested, recommendation}
  * POST /api/deepseek/classify-intent → {isTask, confidence, agentSuggested, taskSubject, taskSummary}
- [DONE] callOllama() helper con timeout configurable (15s análisis, 10s intent)
- [DONE] Degradación limpia cuando Ollama está offline — respuestas coherentes sin errores 500
- [DONE] Extracción robusta de JSON de respuestas DeepSeek (maneja tags <think> y texto libre)
- PENDIENTE: Ollama instalado en máquina del Capitán → `ollama pull deepseek-r1:8b`
- PENDIENTE: Hook en /api/tasks para auto-clasificar mensajes del capitán (Fase 2)
- PENDIENTE: Widget DeepSeek en dashboard (estado, last analyzed, ahorro estimado)

[/WORK_PACKET]
