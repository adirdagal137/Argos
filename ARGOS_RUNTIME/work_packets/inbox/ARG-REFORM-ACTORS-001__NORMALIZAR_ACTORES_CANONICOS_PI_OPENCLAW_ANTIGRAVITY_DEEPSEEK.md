[WORK_PACKET]
ID: ARG-REFORM-ACTORS-001
ROOM: arquitectura
TYPE: build
TAG: protocol_hygiene, reliability
PRIORITY: P1
ROLE_REQUESTED: Codex
STATUS: open
CREATED_AT: 2026-04-24T15:00:00Z
SUBJECT: Normalizar actores canónicos en index.ts — Pi sustituye a Antigravity, OpenClaw sustituye a DeepSeek

OBJECTIVE:
La función normalizeAgentName y todas las estructuras de tipo que dependen de ella usan
'Antigravity' y 'DeepSeek' como actores canónicos. Ambos están obsoletos:
- Antigravity → reemplazado por Pi (misma voz, nuevo alias)
- DeepSeek → reemplazado por OpenClaw (la plataforma local que envía datos al sistema)

Este packet es una cirugía de renombrado en index.ts. No cambia lógica de negocio,
solo actualiza los literales de string y los tipos TypeScript para que el sistema
reconozca correctamente a los actores activos de la tripulación.

RAMA OBLIGATORIA: codex/arg-reform-actors-001

CAMBIOS REQUERIDOS EN src/index.ts:

1. FUNCIÓN normalizeAgentName (línea ~620)
   Cambiar la firma de retorno y la lógica interna:

   ANTES:
     function normalizeAgentName(rawName: string): 'Claude' | 'Antigravity' | 'Codex' | 'DeepSeek' | null
     if (v.includes('antigravity') || v.includes('gemini')) return 'Antigravity';
     if (v.includes('orfeo') || v.includes('deepseek') || v.includes('contramaestre') || v.includes('openclaw') || v.includes('qwen')) return 'DeepSeek';

   DESPUÉS:
     function normalizeAgentName(rawName: string): 'Claude' | 'Pi' | 'Codex' | 'OpenClaw' | null
     if (v.includes('pi') || v.includes('antigravity') || v.includes('gemini')) return 'Pi';
     if (v.includes('openclaw') || v.includes('deepseek') || v.includes('contramaestre') || v.includes('qwen') || v.includes('orfeo')) return 'OpenClaw';

   NOTA: mantener 'antigravity', 'gemini', 'deepseek' como alias de entrada (backward compat)
   para que depósitos históricos sigan normalizándose correctamente — solo cambia el output.
   'orfeo' pasa a ser alias de Claude, no de OpenClaw — corregir:
     if (v.includes('claude') || v.includes('orfeo')) return 'Claude';

2. TIPO IaStatusMap (línea ~1568)
   ANTES:
     type IaStatusMap = { Claude: IaAgentStatus; Antigravity: IaAgentStatus; Codex: IaAgentStatus; DeepSeek: IaAgentStatus };
     return { Claude: blank(), Antigravity: blank(), Codex: blank(), DeepSeek: blank() };
     DeepSeek: { ...d.DeepSeek, ...(raw.DeepSeek || {}) }

   DESPUÉS:
     type IaStatusMap = { Claude: IaAgentStatus; Pi: IaAgentStatus; Codex: IaAgentStatus; OpenClaw: IaAgentStatus };
     return { Claude: blank(), Pi: blank(), Codex: blank(), OpenClaw: blank() };
     Pi:       { ...d.Pi,       ...(raw.Pi       || raw.Antigravity || {}) }
     OpenClaw: { ...d.OpenClaw, ...(raw.OpenClaw || raw.DeepSeek    || {}) }

   El fallback raw.Antigravity y raw.DeepSeek permite leer el state.json actual sin
   perder datos hasta que se migre el fichero en disco.

3. FUNCIÓN resolveCanonicalCrewVoice (línea ~1297)
   Actualizar firma y fallback por defecto:
   ANTES:  function resolveCanonicalCrewVoice(rawName: string, fallback: 'Claude' | 'Antigravity' | 'Codex' | 'DeepSeek' = 'DeepSeek')
   DESPUÉS: function resolveCanonicalCrewVoice(rawName: string, fallback: 'Claude' | 'Pi' | 'Codex' | 'OpenClaw' = 'OpenClaw')

4. SET canonicalAgents en parseTrilogs/parseLogbook (línea ~3925)
   ANTES:  new Set(['Claude', 'Antigravity', 'Codex', 'DeepSeek'])
   DESPUÉS: new Set(['Claude', 'Pi', 'Codex', 'OpenClaw', 'Antigravity', 'DeepSeek'])
   (mantener los deprecated en el set para que el histórico no quede marcado como ORPHAN)

5. FUNCIONES isTaskAssignedToAgent y assignTask (línea ~4589)
   ANTES:  'Codex' | 'Antigravity' | 'Claude' | 'DeepSeek'
   DESPUÉS: 'Codex' | 'Pi' | 'Claude' | 'OpenClaw'
   Actualizar los forEach con los nuevos nombres.

6. REFERENCIAS A 'Antigravity' en postToCrewFeed / start-task (línea ~6521)
   La voz que sale al feed cuando Pi hace start-task:
   ANTES:  voiceName = normalizeAgentName(actor) === 'Claude' ? 'Orfeo (Claude)' : actor
   DESPUÉS: añadir: normalizeAgentName(actor) === 'Pi' ? 'Pi' : ...
   (si ya es genérico por normalizeAgentName, verificar que el output es 'Pi' no 'Antigravity')

7. MOJIBAKE en start-task (línea ~6521) — bug adicional detectado por Orfeo
   ANTES:
     `Tomando misiÃ³n: ${subject}`
     `ID: ${packetId} â€" en progreso.`
   DESPUÉS:
     `Tomando misión: ${subject}`
     `ID: ${packetId} — en progreso.`
   Causa: string literal con encoding incorrecto en el source. Corregir directamente.

8. REFERENCIAS MENORES a limpiar (no bloquean, pero hacen el código consistente):
   - Línea ~278/285: tipo del campo agent/handoff_to en RemoteClosurePayload — añadir 'Pi', 'OpenClaw'
   - Línea ~1645: restricted_agents incluye 'DeepSeek' → cambiar a 'OpenClaw'
   - Línea ~2718/2719: agentName: 'DeepSeek', owner: 'OpenClaw' → agentName: 'OpenClaw'
   - Línea ~2964: actor = 'OpenClaw/Antigravity' → actor = 'OpenClaw'
   - Línea ~7501: actor fallback 'OpenClaw/Antigravity' → 'OpenClaw'

9. MIGRACIÓN DE state/argos.state.json
   Tras el build y antes de reiniciar argos-api, ejecutar este one-liner PowerShell
   para migrar las keys del ia_status sin perder datos:
   ```powershell
   $f = 'C:\Users\Widox\Desktop\ARGOS\ARGOS_RUNTIME\state\argos.state.json'
   $s = Get-Content $f -Raw | ConvertFrom-Json
   if ($s.ia_status.Antigravity) { $s.ia_status | Add-Member -NotePropertyName 'Pi' -NotePropertyValue $s.ia_status.Antigravity -Force }
   if ($s.ia_status.DeepSeek)    { $s.ia_status | Add-Member -NotePropertyName 'OpenClaw' -NotePropertyValue $s.ia_status.DeepSeek -Force }
   $s.ia_status.PSObject.Properties.Remove('Antigravity')
   $s.ia_status.PSObject.Properties.Remove('DeepSeek')
   $s | ConvertTo-Json -Depth 10 | Set-Content $f -Encoding UTF8NoBOM
   ```
   Verificar después que el fichero tiene las keys Pi y OpenClaw y no tiene Antigravity ni DeepSeek.

CONTEXTO Y DEPENDENCIAS:
- ARG-REFORM-VOICES-001 (tarea 4): este packet implementa la parte técnica de ese packet
- ARG-REFORM-UI-001: el widget Estado de IAs también muestra Antigravity/DeepSeek — tras
  este cambio en index.ts el widget ya leerá Pi y OpenClaw del ia_status migrado
- ARG-REFORM-ACTORS-001 no toca INTER_AI_PROTOCOL.md ni ARGOS_CREW_VOICES.md — eso
  sigue siendo tarea de Claude en ARG-REFORM-VOICES-001

SUCCESS_CRITERIA:
- normalizeAgentName('pi') === 'Pi'
- normalizeAgentName('antigravity') === 'Pi'  (backward compat)
- normalizeAgentName('gemini') === 'Pi'
- normalizeAgentName('openclaw') === 'OpenClaw'
- normalizeAgentName('deepseek') === 'OpenClaw'  (backward compat)
- normalizeAgentName('orfeo') === 'Claude'
- IaStatusMap tiene keys Claude, Pi, Codex, OpenClaw
- state.json migrado sin keys Antigravity ni DeepSeek
- El feed de start-task muestra "Tomando misión:" sin mojibake
- tsc compila sin errores
- argos-api arranca y responde /api/ping

ENTREGABLE:
- src/index.ts con los 8 cambios aplicados
- dist/index.js rebuildeado (tsc)
- state/argos.state.json migrado (PowerShell one-liner)
- Commit en rama codex/arg-reform-actors-001
- Merge a main tras verificar success criteria
[/WORK_PACKET]
