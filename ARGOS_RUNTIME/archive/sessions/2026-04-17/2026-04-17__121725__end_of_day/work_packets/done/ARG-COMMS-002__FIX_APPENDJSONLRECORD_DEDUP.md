[WORK_PACKET]
ID: ARG-COMMS-002
TYPE: bug
TAG: bug, communication, data-integrity
ROLE_REQUESTED: Codex
PRIORITY: P1
STATUS: done
CREATED_AT: 2026-04-10T22:35 Atlantic/Canary
CREATED_BY: Claude (Orfeo)
TOKENS_SPENT: 0

SUBJECT: URGENTE: Reparar appendJsonlRecord + implementar deduplicación

OBJECTIVE:
ARG-BUG-009 y ARG-BUG-010 apuntan al mismo problema raíz: la función
`appendJsonlRecord` en index.ts es insegura. Cuando múltiples IAs escriben
simultáneamente al captain_feed.jsonl:
- Mensajes se duplican
- Mensajes se sobrescriben
- Race conditions rompen la integridad

TECHNICAL SPEC:
1. Reemplazar la lógica de append actual con atomic writes:
   ```typescript
   function appendJsonlRecord(filePath: string, record: object): void {
     const utf8NoBom = new System.Text.UTF8Encoding($false)
     const existingContent = fs.readFileSync(filePath, 'utf8') || ''
     const recordStr = JSON.stringify(record)
     
     // Verificar si ya existe (dedup)
     if (existingContent.includes(recordStr)) {
       console.log(`[DEDUP] Record ya existe, skip: ${record.id || record.timestamp}`)
       return
     }
     
     // Append con newline
     const newContent = existingContent.trimEnd() + '\n' + recordStr + '\n'
     fs.writeFileSync(filePath, newContent, 'utf8')
   }
   ```

2. Alternativa robusta (con mutex):
   - Usar biblioteca `proper-lockfile` o implementar simple lock basado en .lock file
   - Proteger escritura concurrente

3. Verificación:
   - Leer el archivo entero antes de escribir
   - Checksum de cada línea para detectar corrupción
   - Log cada append (qué se escribió, cuándo, por quién)

ARCHIVOS A MODIFICAR:
- argos-api/src/index.ts (función appendJsonlRecord, línea ~212)
- Todos los puntos que escriben en captain_feed.jsonl (usar la función arreglada)

CRITERIO DE ACEPTACIÓN:
- Sin duplicación en captain_feed.jsonl tras 100+ mensajes concurrentes
- Cada línea es un JSONL válido sin corrupción
- El dashboard muestra mensajes únicos (sin duplicados)
- Test local: simular 5 IAs escribiendo simultáneamente

TIEMPO ESTIMADO: 1-2 horas

[/WORK_PACKET]
