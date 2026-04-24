[WORK_PACKET]
ID: ARG-REFORM-BITACORA-001-IMPL
ROOM: arquitectura
TYPE: build
TAG: protocol_hygiene, reliability, api
PRIORITY: P1
ROLE_REQUESTED: Codex
OWNER: Codex
STATUS: open
CREATED_AT: 2026-04-24T15:00:00Z
PARENT: ARG-REFORM-BITACORA-001
SUBJECT: Implementar validaciones ORPHAN en heartbeat y actor canónico en /api/remote/closure

CONTEXT:
Este packet es el hijo técnico de ARG-REFORM-BITACORA-001. La propuesta fue auditada y aprobada
por el Capitán. Claude completó el protocolo (INTER_AI_PROTOCOL.md v1.5, ARGOS_QUICKSTART.md).
Codex implementa las validaciones en argos-api/src/index.ts.

La rama debe llamarse: codex/arg-reform-bitacora-001-impl

OBJETIVO:
Reforzar argos-api para que los depósitos malformados no contaminen los canónicos,
y que /api/remote/closure rechace agentes no canónicos.

---

TAREA 1 — Validación ORPHAN en heartbeat (processSingleInboxDeposit)

Archivo: argos-api/src/index.ts
Función: processSingleInboxDeposit (línea ~2531)

Después de parseChatDepositFile, antes de llamar integrateClosure, añadir:

```typescript
// Validar packet_id
if (!parsed.packetId || parsed.packetId.trim() === '') {
  const orphanDest = path.join(
    INBOX_DEPOSITS_PROCESSED_DIR,
    `__orphan_${path.basename(filePath)}`
  );
  moveFileWithFallback(filePath, orphanDest);
  appendJsonlRecord(ARGOS_GLITCHES_PATH, {
    id: nextGlitchId(),
    timestamp: nowIso(),
    timestamp_label: canaryTimestampLabelFromIso(nowIso()),
    actor: 'Dispatcher',
    module: 'argos_deposit_guard',
    type: 'orphan_deposit',
    status: 'open',
    summary: `Depósito ORPHAN: packet_id vacío — ${path.basename(filePath)}`,
    details: `El deposit no tiene packet_id. Movido a __orphan. Revisar depósito.`,
    next_step: 'Agente que generó el depósito debe hacer closure correcta con packet_id.',
    source: 'deposit_heartbeat'
  });
  return false;
}

// Validar actor canónico
const CANONICAL_ACTORS = ['Claude', 'Codex', 'Pi', 'ChatGPT', 'DeepSeek', 'Qwen'];
if (!CANONICAL_ACTORS.includes(parsed.actorCanonical)) {
  const orphanDest = path.join(
    INBOX_DEPOSITS_PROCESSED_DIR,
    `__orphan_${path.basename(filePath)}`
  );
  moveFileWithFallback(filePath, orphanDest);
  appendJsonlRecord(ARGOS_GLITCHES_PATH, {
    id: nextGlitchId(),
    timestamp: nowIso(),
    timestamp_label: canaryTimestampLabelFromIso(nowIso()),
    actor: 'Dispatcher',
    module: 'argos_deposit_guard',
    type: 'orphan_deposit',
    status: 'open',
    summary: `Depósito ORPHAN: actor no canónico "${parsed.actorCanonical}" — ${path.basename(filePath)}`,
    details: `Actor detectado: "${parsed.actorCanonical}". Canónicos: ${CANONICAL_ACTORS.join(', ')}.`,
    next_step: 'Corregir nombre de agente en el depósito. Actores válidos: ' + CANONICAL_ACTORS.join(', '),
    source: 'deposit_heartbeat'
  });
  return false;
}
```

Nota: verificar que ARGOS_GLITCHES_PATH ya está definido en el scope (sí, es una constante global).
Verificar que nextGlitchId() existe o usar un contador similar al del trilog guard.

---

TAREA 2 — Validación de actor canónico en /api/remote/closure

Archivo: argos-api/src/index.ts
Función: parseRemoteClosurePayload (línea ~1875)

Después de `if (agent === '') return { payload: null, error: 'agent es obligatorio' };`
Añadir:

```typescript
const CANONICAL_AGENTS = ['Claude', 'Codex', 'Pi', 'ChatGPT', 'DeepSeek', 'Qwen'];
const normalizedAgent = normalizeAgentName(agent);
if (!normalizedAgent || !CANONICAL_AGENTS.includes(normalizedAgent)) {
  return {
    payload: null,
    error: `agent debe ser un nombre canónico. Válidos: ${CANONICAL_AGENTS.join(', ')}`
  };
}
```

Usar `normalizedAgent` en lugar de `agent` para el resto de la función si aplica.

---

TAREA 3 — [Opcional pero recomendado] Warning en glitch cuando [LOG] vacío en deposit

En processSingleInboxDeposit, después de las validaciones ORPHAN, antes de integrateClosure:

```typescript
const logText = normaliseText(parsed.sections.LOG || '');
if (logText === '') {
  appendJsonlRecord(ARGOS_GLITCHES_PATH, {
    id: nextGlitchId(),
    timestamp: nowIso(),
    timestamp_label: canaryTimestampLabelFromIso(nowIso()),
    actor: 'Dispatcher',
    module: 'argos_deposit_guard',
    type: 'deposit_warning',
    status: 'open',
    summary: `Deposit con [LOG] vacío — ${path.basename(filePath)} (packet: ${parsed.packetId})`,
    details: 'Se integrará shadow/glitch/captain pero no habrá entrada en GLOBAL_LOG.',
    next_step: 'El agente debe incluir [LOG] con contenido en futuros depósitos.',
    source: 'deposit_heartbeat'
  });
  // NO retornar false — integrar igualmente
}
```

---

TAREA 4 — Tests mínimos (si el proyecto tiene test runner)

Si existe infraestructura de tests:
- Test: deposit sin packet_id → mueve a __orphan, no integra en LOG
- Test: deposit con actor "Antigravity" → mueve a __orphan
- Test: POST /api/remote/closure con agent="Antigravity" → 400
- Test: POST /api/remote/closure con agent="Claude" → 200

Si no hay test runner, verificar manualmente contra instancia local.

---

SUCCESS_CRITERIA:
- Un deposit sin packet_id va a __orphan y genera glitch. No aparece en ARGOS_GLOBAL_LOG.md.
- Un deposit con actor "Antigravity" o "IA" va a __orphan y genera glitch.
- POST /api/remote/closure con agent="ChatAgent" devuelve 400.
- Depósitos válidos (actor canónico + packet_id) siguen integrándose normalmente.
- Los logs de glitch generados son legibles en el dashboard tab Bugs.

CONSTRAINT:
- NO tocar la lógica de integrateClosure ni parseChatDepositFile.
- Solo añadir validaciones antes de llamar a integrateClosure.
- Rama obligatoria: codex/arg-reform-bitacora-001-impl. Merge a main solo tras verificación.

REFERENCIA:
- INTER_AI_PROTOCOL.md v1.5 sección 1.7 — especificación completa de ORPHAN
- ARG-REFORM-BITACORA-001 — análisis y propuesta de diseño (absorbido)
[/WORK_PACKET]
