param(
    [string]$RuntimeDir = 'c:\Users\Widox\Desktop\ARGOS\ARGOS_RUNTIME'
)

$ErrorActionPreference = 'Stop'

function Get-JsonFile {
    param([string]$Path)
    return Get-Content -LiteralPath $Path -Raw -Encoding utf8 | ConvertFrom-Json
}

function Get-JsonLines {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return @() }

    $items = @()
    foreach ($line in Get-Content -LiteralPath $Path -Encoding utf8) {
        if ($line.Trim() -eq '') { continue }
        $items += ($line | ConvertFrom-Json)
    }
    return $items
}

function Normalize-Text {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return '' }

    $tmp = $Value.ToLowerInvariant()
    $tmp = [regex]::Replace($tmp, '[^a-z0-9]+', ' ')
    return $tmp.Trim()
}

function Get-TimestampPrecision {
    param([string]$Label)
    if ($Label -match '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}') { return 'minute' }
    if ($Label -match '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}') { return 'minute' }
    return 'day'
}

function Get-TimestampLabel {
    param([string]$Label)
    if ($Label -match '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}') { return ($matches[0] -replace 'T', ' ') }
    if ($Label -match '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}') { return $matches[0] }
    if ($Label -match '^\d{4}-\d{2}-\d{2}') { return $matches[0] }
    return $Label
}

function Get-SortDate {
    param([string]$Label)
    if ($Label -match '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}') {
        return [datetime]::ParseExact($matches[0], 'yyyy-MM-ddTHH:mm', $null)
    }
    if ($Label -match '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}') {
        return [datetime]::ParseExact($matches[0], 'yyyy-MM-dd HH:mm', $null)
    }
    if ($Label -match '^\d{4}-\d{2}-\d{2}') {
        return [datetime]::ParseExact($matches[0], 'yyyy-MM-dd', $null)
    }
    return [datetime]::MinValue
}

function Convert-LabelToIso {
    param([string]$Label)
    if ($Label -match '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}') {
        return ('{0}:00+01:00' -f ($matches[0] -replace ' ', 'T'))
    }
    if ($Label -match '^\d{4}-\d{2}-\d{2}') {
        return ('{0}T00:00:00+01:00' -f $matches[0])
    }
    return $null
}

function Add-TimelineEntry {
    param(
        [System.Collections.Generic.List[object]]$Collection,
        [hashtable]$Index,
        [hashtable]$Entry
    )

    $stream = $Entry.stream
    $timestampLabel = $Entry.timestamp_label
    $actor = $Entry.actor
    $summary = Normalize-Text $Entry.summary
    $key = '{0}|{1}|{2}|{3}' -f $stream, $timestampLabel, $actor, $summary
    if ($Index.ContainsKey($key)) { return }

    $Collection.Add([pscustomobject]$Entry)
    $Index[$key] = $true
}

$legacyRootPath = Join-Path $RuntimeDir 'archive\v1_0_x_google_native_snapshot_2026-04-09\argos_root_logs.snapshot.json'
$legacyShadowPath = Join-Path $RuntimeDir 'archive\v1_0_x_google_native_snapshot_2026-04-09\argos_shadow_log.snapshot.json'
$googleTailPath = Join-Path $RuntimeDir 'archive\v1_0_x_google_native_snapshot_2026-04-09\google_native_tail_import_2026-04-10.json'
$logbookPath = Join-Path $RuntimeDir 'views\logbook_export\logbook.snapshot.json'
$eventsPath = Join-Path $RuntimeDir 'events\argos.events.jsonl'
$glitchesPath = Join-Path $RuntimeDir 'events\argos.glitches.jsonl'
$logsCurrentDir = Join-Path $RuntimeDir 'logs\current'
$glitchMarkdownPath = Join-Path $logsCurrentDir 'ARGOS_GLOBAL_GLITCH_LOG.md'
$historyDir = Join-Path $RuntimeDir 'views\history_export'
$historyTimelinePath = Join-Path $historyDir 'argos.timeline.jsonl'
$historyMarkdownPath = Join-Path $historyDir 'ARGOS_CANONICAL_HISTORY.md'
$historyManifestPath = Join-Path $historyDir 'current_history_manifest.json'
$activeGlobalLogPath = Join-Path $logsCurrentDir 'ARGOS_GLOBAL_LOG.md'
$activeShadowLogPath = Join-Path $logsCurrentDir 'ARGOS_GLOBAL_SHADOW_LOG.md'
$donePacketsDir = Join-Path $RuntimeDir 'work_packets\done'

New-Item -ItemType Directory -Force -Path $historyDir | Out-Null

$legacyRoot = Get-JsonFile -Path $legacyRootPath
$legacyShadow = Get-JsonFile -Path $legacyShadowPath
$googleTail = Get-JsonFile -Path $googleTailPath
$logbook = Get-JsonFile -Path $logbookPath
$currentEvents = Get-JsonLines -Path $eventsPath
$activeGlobalLog = if (Test-Path $activeGlobalLogPath) { Get-Content $activeGlobalLogPath -Raw -Encoding utf8 } else { "" }
$activeShadowLog = if (Test-Path $activeShadowLogPath) { Get-Content $activeShadowLogPath -Raw -Encoding utf8 } else { "" }

$timeline = [System.Collections.Generic.List[object]]::new()
$timelineIndex = @{}

$manualDraftGlobals = @(
    @{ timestamp = '2026-04-09'; actor = 'Antigravity'; module = 'Argos'; status = 'ejecutado_y_luego_deprecado'; summary = 'Implementacion fisica de ARGOS_ROUTER y espejo hibrido'; details = 'Importado desde AG_log_2026-04-09.md'; next_step = ''; source = 'drive:AG_log_2026-04-09.md' },
    @{ timestamp = '2026-04-09'; actor = 'Antigravity'; module = 'Argos'; status = 'en_espera'; summary = 'Pivot a arquitectura API-first (scaffolding local)'; details = 'Importado desde AG_log_2026-04-09.md'; next_step = ''; source = 'drive:AG_log_2026-04-09.md' },
    @{ timestamp = '2026-04-09'; actor = 'Antigravity'; module = 'Argos'; status = 'finalizado'; summary = 'Analisis del documento Antonio_Explanation'; details = 'Importado desde AG_log_2026-04-09.md'; next_step = ''; source = 'drive:AG_log_2026-04-09.md' },
    @{ timestamp = '2026-04-09'; actor = 'Antigravity'; module = 'Argos'; status = 'finalizado'; summary = 'Correccion de la trazabilidad historica'; details = 'Importado desde AG_log_2026-04-09.md'; next_step = ''; source = 'drive:AG_log_2026-04-09.md' }
)

$manualDraftShadows = @(
    @{ timestamp = '2026-04-09'; actor = 'Antigravity'; module = 'Argos'; status = 'active'; summary = 'Revelacion sobre API-First vs local'; details = 'El acceso local a J:/ cambia la necesidad de un backend cloud complejo.'; next_step = 'Asignar roles correctos entre planificacion y ejecucion local.'; source = 'drive:AG_shadow_log_2026-04-09.md'; stream = 'shadow' },
    @{ timestamp = '2026-04-09'; actor = 'Antigravity'; module = 'Argos'; status = 'active'; summary = 'Falsa causalidad narrativa en la lectura de Antonio'; details = 'El draft reconoce un sesgo de compresion narrativa y exige separar literalidad, tactica y mito operativo.'; next_step = 'Mantener trazabilidad quirurgica entre hechos e inferencias.'; source = 'drive:AG_shadow_log_2026-04-09.md'; stream = 'glitch' }
)

$legacyGlitches = @(
    @{ id = 'G-001'; timestamp = '2026-04-07 14:12 Atlantic/Canary'; actor = 'ChatGPT'; module = 'Argos raiz'; status = 'mitigado'; summary = 'mezcla de niveles documentales'; details = 'El protocolo raiz contenia incrustado el protocolo antiguo de SCM8.'; next_step = 'Mantener separacion logica y documental entre raiz y modulos.'; source = 'google_sheet:ARGOS__root_logs/GLITCH_LOG_GENERAL' },
    @{ id = 'G-002'; timestamp = '2026-04-07 23:40 Atlantic/Canary'; actor = 'Codex'; module = 'Argos / SCM8'; status = 'mitigado'; summary = 'confusion de capacidad del conector Drive'; details = 'El conector de Drive no sirve como via canonica para escribir Markdown crudo.'; next_step = 'Usar filesystem local para .md y conector solo para Docs/Sheets/Slides.'; source = 'google_sheet:ARGOS__root_logs/GLITCH_LOG_GENERAL' },
    @{ id = 'G-003'; timestamp = '2026-04-07 23:40 Atlantic/Canary'; actor = 'Codex'; module = 'Argos / SCM8'; status = 'mitigado'; summary = 'lectura incorrecta de placeholders .gdoc/.gsheet'; details = 'Intentar leer placeholders de Google Drive como texto plano produjo errores de sistema.'; next_step = 'Tratar .gdoc/.gsheet como punteros y leerlos con el conector adecuado.'; source = 'google_sheet:ARGOS__root_logs/GLITCH_LOG_GENERAL' },
    @{ id = 'G-004'; timestamp = '2026-04-07 23:40 Atlantic/Canary'; actor = 'Codex'; module = 'Argos / SCM8'; status = 'mitigado'; summary = 'friccion de codificacion en plantillas Markdown'; details = 'Aparecio mojibake y fallaron parches grandes por no coincidir el texto esperado.'; next_step = 'Normalizar a UTF-8 al crear archivos nuevos y preferir parches pequenos en legados.'; source = 'google_sheet:ARGOS__root_logs/GLITCH_LOG_GENERAL' },
    @{ id = 'G-005'; timestamp = '2026-04-07 23:40 Atlantic/Canary'; actor = 'Codex'; module = 'Argos'; status = 'mitigado'; summary = 'respuesta no alineada con intencion operativa'; details = 'Se respondio con coordinacion textual cuando el Capitan esperaba ejecucion sobre Drive y backlog.'; next_step = 'Si el Capitan habla de backlog/bitacora, inspeccionar antes de solo coordinar.'; source = 'google_sheet:ARGOS__root_logs/GLITCH_LOG_GENERAL' },
    @{ id = 'G-006'; timestamp = '2026-04-10 00:45'; actor = 'Antigravity'; module = 'Argos UI'; status = 'active'; summary = 'colision inter-IA y falso trigger automatico'; details = 'La UI y el backend sugirieron automatismos que no despertaban por si solos a un agente real.'; next_step = 'Separar mejor feed visible, adaptador y agente realmente activo.'; source = 'runtime:ARGOS_GLOBAL_SHADOW_LOG.md' },
    @{ id = 'G-007'; timestamp = '2026-04-10 00:54'; actor = 'Codex'; module = 'Argos UI'; status = 'active'; summary = 'work packet mal enrutado por ruteo nominal'; details = 'Un paquete para Antigravity/Gemini acabo asignado a Codex por simple deteccion nominal en texto libre.'; next_step = 'Endurecer parser de destinatario y no decidir por menciones sueltas.'; source = 'runtime:argos.events.jsonl' },
    @{ id = 'G-008'; timestamp = '2026-04-10 03:06'; actor = 'Codex'; module = 'Argos UI'; status = 'mitigado'; summary = 'hook de riesgos fuera de scope en app.js'; details = 'El bloque del visor y de loadRisks quedo fuera de DOMContentLoaded y podia disparar un ReferenceError al arrancar el frontend.'; next_step = 'Anadir smoke-test local o comprobacion sintactica antes de dar por valido un parche UI.'; source = 'runtime:ARGOS_GLOBAL_SHADOW_LOG.md + local:argos-dashboard/app.js' }
)

$lateRuntimeGlobals = @(
    @{ timestamp = '2026-04-10 02:14'; actor = 'Antigravity'; module = 'Argos'; status = 'finalizado_en_espera'; summary = 'Congelacion operativa y borrador de 6 ejes'; details = 'Se pausan ejecuciones y se inyectan seis paquetes de trabajo sobre mascaras, sombra y refactor de interfaces.'; next_step = 'Esperar activacion o redistribucion de esos frentes.'; source = 'runtime:ARGOS_GLOBAL_LOG.md' },
    @{ timestamp = '2026-04-10 02:21'; actor = 'Antigravity'; module = 'Argos UI'; status = 'finalizado'; summary = 'Revision del parche de Codex y encolamiento de 3 tareas UI'; details = 'Se reconoce el paso a /api/logbook y se derivan tres tareas UI sin tocar codigo vivo en ese momento.'; next_step = 'Ejecutar el patchset UI cuando la cubierta lo active.'; source = 'runtime:ARGOS_GLOBAL_LOG.md' },
    @{ timestamp = '2026-04-10 02:26'; actor = 'Antigravity'; module = 'Argos UI'; status = 'latente'; summary = 'Encolamiento de tarea estructural sobre glitches y refactorizacion del inbox'; details = 'Se formula la separacion del glitch log y el rediseÃ±o profundo de la pestana Cartas.'; next_step = 'Materializarlo en el patchset UI canonicamente asignado.'; source = 'runtime:ARGOS_GLOBAL_LOG.md' },
    @{ timestamp = '2026-04-10 02:44'; actor = 'Antigravity'; module = 'Argos UI'; status = 'finalizado'; summary = 'Construccion del Visor de Eventos y Burbujas de Alerta'; details = 'Se registran endpoints /api/risks y /api/events y un primer visor transversal de riesgos/eventos.'; next_step = 'Verificar que la UI y la historia consolidada alimenten bien ese visor.'; source = 'runtime:ARGOS_GLOBAL_LOG.md' }
)

$lateRuntimeShadows = @(
    @{ timestamp = '2026-04-10 02:14'; actor = 'Antigravity'; module = 'Argos'; status = 'active'; summary = 'Calibracion psiquica ante riesgo de dispersion'; details = 'Se explicita que el Capitan detecta peligro de diversificacion sin asentar output y pide una Sombra Organizacional.'; next_step = 'Traducir la intuicion en taxonomia util de riesgos y prioridades.'; source = 'runtime:ARGOS_GLOBAL_SHADOW_LOG.md' },
    @{ timestamp = '2026-04-10 02:21'; actor = 'Antigravity'; module = 'Argos'; status = 'active'; summary = 'Convergencia de Codex y Antigravity sobre la fragilidad narrativa'; details = 'La intuicion sombreada de un agente fue neutralizada por la solucion estructural del otro via snapshot y backend.'; next_step = 'Mantener la inteligencia de enjambre sin duplicar nomenclaturas ni acciones.'; source = 'runtime:ARGOS_GLOBAL_SHADOW_LOG.md' },
    @{ timestamp = '2026-04-10 02:26'; actor = 'Antigravity'; module = 'Argos'; status = 'active'; summary = 'La escision del glitch log es conceptualmente sana'; details = 'No conviene mezclar fallos binarios o de CSS con resto interpretativo profundo en la misma sombra.'; next_step = 'Dar al glitch su propio carril en la arquitectura y la UI.'; source = 'runtime:ARGOS_GLOBAL_SHADOW_LOG.md' },
    @{ timestamp = '2026-04-10 02:44'; actor = 'Antigravity'; module = 'Argos UI'; status = 'active'; summary = 'El Visor de Eventos hace navegable la Sombra'; details = 'La intuicion junguiana pasa a interfaz cruzable entre logs, feed y tareas.'; next_step = 'Alinear el visor con la historia consolidada y no solo con regex de textos vivos.'; source = 'runtime:ARGOS_GLOBAL_SHADOW_LOG.md' }
)

$streamOrder = @{
    global = 1
    interaction = 2
    glitch = 3
    shadow = 4
}

foreach ($row in $legacyRoot.tabs.LOG_GENERAL) {
    Add-TimelineEntry -Collection $timeline -Index $timelineIndex -Entry @{
        timestamp_label = Get-TimestampLabel $row.timestamp
        timestamp_precision = Get-TimestampPrecision $row.timestamp
        sort_date = Get-SortDate $row.timestamp
        stream = 'global'
        actor = $row.ia
        module = $row.proyecto
        status = $row.estado
        summary = $row.accion
        details = 'Importado desde ARGOS__root_logs / LOG_GENERAL.'
        next_step = ''
        source = 'archive:v1_0_x_google_native_snapshot_2026-04-09/argos_root_logs.snapshot.json#LOG_GENERAL'
    }
}

foreach ($row in $googleTail.log_general_delta) {
    Add-TimelineEntry -Collection $timeline -Index $timelineIndex -Entry @{
        timestamp_label = Get-TimestampLabel $row.timestamp
        timestamp_precision = Get-TimestampPrecision $row.timestamp
        sort_date = Get-SortDate $row.timestamp
        stream = 'global'
        actor = $row.ia
        module = $row.proyecto
        status = $row.estado
        summary = $row.accion
        details = $row.resumen
        next_step = $row.siguiente_paso
        source = 'archive:v1_0_x_google_native_snapshot_2026-04-09/google_native_tail_import_2026-04-10.json#log_general_delta'
    }
}

foreach ($row in $legacyRoot.tabs.INTERACTIONS_LOG) {
    Add-TimelineEntry -Collection $timeline -Index $timelineIndex -Entry @{
        timestamp_label = Get-TimestampLabel $row.timestamp
        timestamp_precision = Get-TimestampPrecision $row.timestamp
        sort_date = Get-SortDate $row.timestamp
        stream = 'interaction'
        actor = $row.ia
        module = $row.proyecto
        status = $row.estado
        summary = $row.prompt
        details = 'Importado desde ARGOS__root_logs / INTERACTIONS_LOG.'
        next_step = ''
        source = 'archive:v1_0_x_google_native_snapshot_2026-04-09/argos_root_logs.snapshot.json#INTERACTIONS_LOG'
    }
}

foreach ($row in $googleTail.interactions_log_delta) {
    Add-TimelineEntry -Collection $timeline -Index $timelineIndex -Entry @{
        timestamp_label = Get-TimestampLabel $row.timestamp
        timestamp_precision = Get-TimestampPrecision $row.timestamp
        sort_date = Get-SortDate $row.timestamp
        stream = 'interaction'
        actor = $row.ia
        module = $row.proyecto
        status = $row.estado
        summary = $row.prompt_usuario
        details = $row.respuesta_ia
        next_step = $row.follow_up
        source = 'archive:v1_0_x_google_native_snapshot_2026-04-09/google_native_tail_import_2026-04-10.json#interactions_log_delta'
    }
}

foreach ($entry in $manualDraftGlobals) {
    Add-TimelineEntry -Collection $timeline -Index $timelineIndex -Entry @{
        timestamp_label = Get-TimestampLabel $entry.timestamp
        timestamp_precision = Get-TimestampPrecision $entry.timestamp
        sort_date = Get-SortDate $entry.timestamp
        stream = 'global'
        actor = $entry.actor
        module = $entry.module
        status = $entry.status
        summary = $entry.summary
        details = $entry.details
        next_step = $entry.next_step
        source = $entry.source
    }
}

foreach ($row in $legacyShadow.tabs.SHADOW_EVENTS) {
    Add-TimelineEntry -Collection $timeline -Index $timelineIndex -Entry @{
        timestamp_label = Get-TimestampLabel $row.timestamp
        timestamp_precision = Get-TimestampPrecision $row.timestamp
        sort_date = Get-SortDate $row.timestamp
        stream = 'shadow'
        actor = $row.voice
        module = $row.project
        status = $row.status
        summary = $row.visible_trigger
        details = 'Importado desde ARGOS__shadow_log / SHADOW_EVENTS.'
        next_step = ''
        source = 'archive:v1_0_x_google_native_snapshot_2026-04-09/argos_shadow_log.snapshot.json#SHADOW_EVENTS'
    }
}

foreach ($row in $googleTail.shadow_events_delta) {
    Add-TimelineEntry -Collection $timeline -Index $timelineIndex -Entry @{
        timestamp_label = Get-TimestampLabel $row.timestamp
        timestamp_precision = Get-TimestampPrecision $row.timestamp
        sort_date = Get-SortDate $row.timestamp
        stream = 'shadow'
        actor = $row.voice
        module = $row.project
        status = $row.status
        summary = $row.visible_trigger
        details = $row.shadow_signal
        next_step = $row.next_question
        source = 'archive:v1_0_x_google_native_snapshot_2026-04-09/google_native_tail_import_2026-04-10.json#shadow_events_delta'
    }
}

foreach ($entry in $manualDraftShadows) {
    Add-TimelineEntry -Collection $timeline -Index $timelineIndex -Entry @{
        timestamp_label = Get-TimestampLabel $entry.timestamp
        timestamp_precision = Get-TimestampPrecision $entry.timestamp
        sort_date = Get-SortDate $entry.timestamp
        stream = $entry.stream
        actor = $entry.actor
        module = $entry.module
        status = $entry.status
        summary = $entry.summary
        details = $entry.details
        next_step = $entry.next_step
        source = $entry.source
    }
}

$argosModule = $logbook.modules | Where-Object { $_.id -eq 'argos' }
foreach ($stream in $argosModule.streams) {
    $mappedStream = switch ($stream.id) {
        'log' { 'global' }
        'interactions' { 'interaction' }
        'shadow' { 'shadow' }
        default { $null }
    }
    if (-not $mappedStream) { continue }

    foreach ($entry in $stream.entries) {
        Add-TimelineEntry -Collection $timeline -Index $timelineIndex -Entry @{
            timestamp_label = Get-TimestampLabel $entry.timestamp_label
            timestamp_precision = $entry.timestamp_precision
            sort_date = Get-SortDate $entry.timestamp_label
            stream = $mappedStream
            actor = $entry.actor
            module = 'Argos'
            status = $entry.status
            summary = $entry.summary
            details = $entry.details
            next_step = $entry.next_step
            source = ('runtime:views/logbook_export/logbook.snapshot.json#{0}' -f $stream.id)
        }
    }
}

foreach ($entry in $lateRuntimeGlobals) {
    Add-TimelineEntry -Collection $timeline -Index $timelineIndex -Entry @{
        timestamp_label = Get-TimestampLabel $entry.timestamp
        timestamp_precision = Get-TimestampPrecision $entry.timestamp
        sort_date = Get-SortDate $entry.timestamp
        stream = 'global'
        actor = $entry.actor
        module = $entry.module
        status = $entry.status
        summary = $entry.summary
        details = $entry.details
        next_step = $entry.next_step
        source = $entry.source
    }
}

foreach ($entry in $lateRuntimeShadows) {
    Add-TimelineEntry -Collection $timeline -Index $timelineIndex -Entry @{
        timestamp_label = Get-TimestampLabel $entry.timestamp
        timestamp_precision = Get-TimestampPrecision $entry.timestamp
        sort_date = Get-SortDate $entry.timestamp
        stream = 'shadow'
        actor = $entry.actor
        module = $entry.module
        status = $entry.status
        summary = $entry.summary
        details = $entry.details
        next_step = $entry.next_step
        source = $entry.source
    }
}

# --- EXTRACT FROM ACTIVE ROOT LOGS ---
if ($activeGlobalLog -ne "") {
    $blocks = $activeGlobalLog -split '\r?\n---'
    foreach ($blockRaw in $blocks) {
        $block = $blockRaw.Trim()
        if ($block -match '\[(\d{1,4}[-/\.\s]\d{1,2}[-/\.\s]\d{1,4}(?:\s+\d{2}:\d{2}(?::\d{2})?)?.*?)\]') {
            $tsLabel = $matches[1]
            
            # 1. DetecciÃ³n por Cabecera EstÃ¡ndar: **[TS] ID | Actor:**
            $headerActor = ""
            if ($block -match '\*\*\[[^\]]+\]\s*([A-Z0-9-]*)\s*\|\s*([^:\n\*]+):\*\*') {
                $headerActor = $matches[2].Trim()
            }

            $actor = if ($block -match '(?m)^\s*VOZ\s+([^:\n\*]+)') { $matches[1].Trim() } 
                     elseif ($block -match '(?m)^\s*ACTOR\s*:\s*([^:\n\*]+)') { $matches[1].Trim() }
                     elseif ($headerActor -ne "") { $headerActor }
                     else { "Sistema" }
            
            $lines = $block.Split("`n") | Where-Object { $_ -notmatch '\[\d{4}|VOZ\s+|ACTOR\s*:' }
            
            $summary = if ($block -match '(?m)^\s*(?:\*\*|#)?(?:ACCION|ACCIÃ“N|MISION|MISIÃ“N|MISSION|SUBJECT|ASUNTO)\s*[:\*]+\s*([^:\n\*]+)') { $matches[1].Trim() } 
                       elseif ($block -match '\*\*([^\*\n]+)\*\*') { $matches[1].Trim() }
                       elseif ($lines.Count -gt 0) { ($lines[0] -replace '[\*#\[\]]', '').Trim() }
                       else { "Registro actualizado" }
            
            $status = if ($block -match '\*\*ESTADO\s*:\*\*\s*([^\n]+)') { $matches[1].Trim() } else { "done" }
            
            $details = if ($block -match '\*\*DETALLES\s*:\*\*([\s\S]*?)(?:\n\*\*|---|$|RIESGO)') { $matches[1].Trim() } 
                       else { 
                           $lines = $block.Split("`n") | Where-Object { $_ -notmatch '\[\d|VOZ|MISION|MISI[Ã“O]N|MISSION|ACCION' }
                           ($lines -join "`n").Trim() 
                       }
            
            Add-TimelineEntry -Collection $timeline -Index $timelineIndex -Entry @{
                timestamp_label = Get-TimestampLabel $tsLabel
                timestamp_precision = Get-TimestampPrecision $tsLabel
                sort_date = Get-SortDate $tsLabel
                stream = 'global'
                actor = $actor
                module = 'Argos'
                status = $status
                summary = $summary
                details = $details
                next_step = ""
                source = "runtime:ARGOS_GLOBAL_LOG.md"
            }
        }
    }
}

# --- EXTRACT FROM COMPLETED WORK PACKETS ---
if (Test-Path $donePacketsDir) {
    $packetFiles = Get-ChildItem -LiteralPath $donePacketsDir -Filter "*.md"
    $groups = $packetFiles | Group-Object { $_.Name -replace '__RESULTADO.*\.md$', '' -replace '\.md$', '' }

    foreach ($group in $groups) {
        $packetId = $group.Name
        $bestFile = $group.Group | Where-Object { $_.Name -like "*__RESULTADO*" } | Select-Object -First 1
        if (-not $bestFile) { $bestFile = $group.Group[0] }

        $content = Get-Content -LiteralPath $bestFile.FullName -Raw -Encoding utf8
        
        $tsLabel = if ($content -match 'COMPLETED_AT:\s*(\d{4}-\d{2}-\d{2}(?:T|\s+)\d{2}:\d{2})') { $matches[1] }
                   elseif ($content -match 'REPORTED_AT:\s*(\d{4}-\d{2}-\d{2}(?:T|\s+)\d{2}:\d{2})') { $matches[1] }
                   else { $bestFile.LastWriteTime.ToString("yyyy-MM-dd HH:mm") }

        $actor = if ($content -match 'EXECUTED_BY:\s*([^:\n\*]+)') { $matches[1].Trim() }
                 elseif ($content -match 'ROLE_REQUESTED:\s*([^:\n\*]+)') { $matches[1].Trim() }
                 else { "IAT" }

        $summary = if ($content -match 'SUMMARY:([\s\S]*?)(?:\n\w+:|\[\/|$)') { $matches[1].Trim().Split("`n")[0].Trim("- ").Trim() }
                   elseif ($content -match 'SUBJECT:\s*([^:\n\*]+)') { $matches[1].Trim() }
                   else { "Tarea completada: $packetId" }

        $details = if ($content -match 'SUMMARY:([\s\S]*?)(?:\n\w+:|\[\/|$)') { $matches[1].Trim() }
                   elseif ($content -match 'OBJECTIVE:([\s\S]*?)(?:\n\w+:|\[\/|$)') { $matches[1].Trim() }
                   else { "Paquete de trabajo $packetId marcado como hecho." }

        Add-TimelineEntry -Collection $timeline -Index $timelineIndex -Entry @{
            timestamp_label = Get-TimestampLabel $tsLabel
            timestamp_precision = Get-TimestampPrecision $tsLabel
            sort_date = Get-SortDate $tsLabel
            stream = 'global'
            actor = $actor
            module = 'Argos'
            status = 'done'
            summary = $summary
            details = $details
            next_step = ""
            source = ("runtime:work_packets/done/$($bestFile.Name)")
        }
    }
}

foreach ($entry in $legacyGlitches) {
    Add-TimelineEntry -Collection $timeline -Index $timelineIndex -Entry @{
        timestamp_label = Get-TimestampLabel $entry.timestamp
        timestamp_precision = Get-TimestampPrecision $entry.timestamp
        sort_date = Get-SortDate $entry.timestamp
        stream = 'glitch'
        actor = $entry.actor
        module = $entry.module
        status = $entry.status
        summary = $entry.summary
        details = $entry.details
        next_step = $entry.next_step
        source = $entry.source
    }
}

$timelineSorted = $timeline | Sort-Object `
    @{ Expression = { $_.sort_date } ; Ascending = $true }, `
    @{ Expression = { $streamOrder[$_.stream] } ; Ascending = $true }, `
    @{ Expression = { $_.actor } ; Ascending = $true }

$timelineJsonl = foreach ($entry in $timelineSorted) {
    $line = [ordered]@{
        timestamp_label = $entry.timestamp_label
        timestamp_precision = $entry.timestamp_precision
        stream = $entry.stream
        actor = $entry.actor
        module = $entry.module
        status = $entry.status
        summary = $entry.summary
        details = $entry.details
        next_step = $entry.next_step
        source = $entry.source
    }
    ($line | ConvertTo-Json -Compress)
}
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllLines($historyTimelinePath, @($timelineJsonl), $utf8NoBom)

$historyLines = @(
    '# ARGOS CANONICAL HISTORY',
    '',
    'Cronologia consolidada de la memoria de Argos dentro de la arquitectura actual.',
    '',
    'Fuentes absorbidas:',
    '- `legacy/v1_0_x_google_native_snapshot_2026-04-09/argos_root_logs.snapshot.json`',
    '- `legacy/v1_0_x_google_native_snapshot_2026-04-09/argos_shadow_log.snapshot.json`',
    '- `legacy/v1_0_x_google_native_snapshot_2026-04-09/google_native_tail_import_2026-04-10.json`',
    '- `drive:AG_log_2026-04-09.md`',
    '- `drive:AG_shadow_log_2026-04-09.md`',
    '- `views/logbook_export/logbook.snapshot.json`',
    '- `events/argos.events.jsonl`',
    '',
    '## TIMELINE'
)

foreach ($entry in $timelineSorted) {
    $historyLines += ('- `{0}` | `{1}` | `{2}` | `{3}` | {4} | `{5}`' -f $entry.timestamp_label, $entry.stream, $entry.actor, $entry.module, $entry.summary, $entry.status)
    if (-not [string]::IsNullOrWhiteSpace($entry.details)) {
        $historyLines += ('  Detalle: {0}' -f $entry.details)
    }
    if (-not [string]::IsNullOrWhiteSpace($entry.next_step)) {
        $historyLines += ('  Siguiente: {0}' -f $entry.next_step)
    }
}
[System.IO.File]::WriteAllLines($historyMarkdownPath, @($historyLines), $utf8NoBom)

$liveGlitches = Get-JsonLines -Path $glitchesPath
$allGlitches = @()
$glitchIdIndex = @{}

# Priorizar el archivo vivo
foreach ($g in $liveGlitches) {
    $allGlitches += $g
    $glitchIdIndex[$g.id] = $true
}

# AÃ±adir legacy si no estan en el vivo (fallback/hidratacion inicial)
foreach ($lg in $legacyGlitches) {
    if (-not $glitchIdIndex.ContainsKey($lg.id)) {
        $allGlitches += $lg
    }
}

$glitchSorted = $allGlitches | Sort-Object { Get-SortDate $_.timestamp }
$glitchJsonl = foreach ($entry in $glitchSorted) {
    $obj = [ordered]@{
        id = $entry.id
        timestamp = Convert-LabelToIso $entry.timestamp
        timestamp_label = Get-TimestampLabel $entry.timestamp
        timestamp_precision = Get-TimestampPrecision $entry.timestamp
        actor = $entry.actor
        module = $entry.module
        status = $entry.status
        summary = $entry.summary
        details = $entry.details
        next_step = $entry.next_step
        source = $entry.source
    }
    ($obj | ConvertTo-Json -Compress)
}
[System.IO.File]::WriteAllLines($glitchesPath, @($glitchJsonl), $utf8NoBom)

$glitchLines = @(
    '# ARGOS GLOBAL GLITCH LOG',
    '',
    'Registro estructural de fallas sistemicas, errores de integracion y fricciones tecnicas reutilizables.',
    ''
)
foreach ($entry in $glitchSorted) {
    $glitchLines += '---'
    $glitchLines += ('**[{0}] {1} | {2}:**' -f (Get-TimestampLabel $entry.timestamp), $entry.id, $entry.actor)
    $glitchLines += ('**TIPO:** {0}' -f $entry.summary)
    $glitchLines += ('**ESTADO:** {0}' -f $entry.status)
    $glitchLines += ('**DETALLE:** {0}' -f $entry.details)
    $glitchLines += ('**PREVENCION / SIGUIENTE:** {0}' -f $entry.next_step)
}
[System.IO.File]::WriteAllLines($glitchMarkdownPath, @($glitchLines), $utf8NoBom)

$existingEventIndex = @{}
$mergedEvents = [System.Collections.Generic.List[object]]::new()
foreach ($event in $currentEvents) {
    $key = '{0}|{1}|{2}|{3}' -f $event.timestamp, $event.actor, $event.type, (Normalize-Text $event.summary)
    if ($existingEventIndex.ContainsKey($key)) { continue }
    
    $eventObj = [ordered]@{
        timestamp = $event.timestamp
        actor = $event.actor
        module = $event.module
        type = $event.type
        summary = $event.summary
        artifacts = @($event.artifacts)
        verification = $event.verification
        next_step = $event.next_step
        sort_date = (Get-SortDate $event.timestamp)
    }
    $mergedEvents.Add([pscustomobject]$eventObj)
    $existingEventIndex[$key] = $true

    # INYECCIÃ“N EN BITÃCORA GLOBAL (STREAM GLOBAL)
    # Solo eventos de alto valor para no saturar la bitÃ¡cora con ruido de sistema
    if ($event.type -match 'session_close|repair|error|critical|milestone|deployment') {
        $eventDetails = if ($event.verification) { $event.verification } elseif ($event.next_step) { $event.next_step } else { 'Accion automatica registrada por el sistema.' }
        $eventNextStep = if ($event.next_step) { $event.next_step } else { "" }

        Add-TimelineEntry -Collection $timeline -Index $timelineIndex -Entry @{
            timestamp_label = Get-TimestampLabel $event.timestamp
            timestamp_precision = Get-TimestampPrecision $event.timestamp
            sort_date = (Get-SortDate $event.timestamp)
            stream = 'global'
            actor = $event.actor
            module = 'Instrumental'
            status = 'auto'
            summary = $event.summary
            details = ("Tipo: $($event.type). $eventDetails")
            next_step = $eventNextStep
            source = "runtime:argos.events.jsonl"
        }
    }
}

foreach ($row in $legacyRoot.tabs.INTERACTIONS_LOG) {
    $iso = Convert-LabelToIso $row.timestamp
    $eventKey = '{0}|{1}|{2}|{3}' -f $iso, $row.ia, 'legacy_interaction_imported', (Normalize-Text $row.prompt)
    if ($existingEventIndex.ContainsKey($eventKey)) { continue }

    $mergedEvents.Add([pscustomobject]([ordered]@{
        timestamp = $iso
        actor = $row.ia
        module = 'argos_history'
        type = 'legacy_interaction_imported'
        summary = $row.prompt
        artifacts = @('archive:v1_0_x_google_native_snapshot_2026-04-09/argos_root_logs.snapshot.json#INTERACTIONS_LOG')
        verification = 'Importado desde la hoja legacy de interacciones y normalizado en la arquitectura actual.'
        next_step = 'Preservado tambien en views/history_export/argos.timeline.jsonl.'
        sort_date = (Get-SortDate $row.timestamp)
    }))
    $existingEventIndex[$eventKey] = $true
}

foreach ($row in $googleTail.interactions_log_delta) {
    $iso = Convert-LabelToIso $row.timestamp
    $eventKey = '{0}|{1}|{2}|{3}' -f $iso, $row.ia, 'legacy_interaction_imported', (Normalize-Text $row.prompt_usuario)
    if ($existingEventIndex.ContainsKey($eventKey)) { continue }

    $mergedEvents.Add([pscustomobject]([ordered]@{
        timestamp = $iso
        actor = $row.ia
        module = 'argos_history'
        type = 'legacy_interaction_imported'
        summary = $row.prompt_usuario
        artifacts = @('archive:v1_0_x_google_native_snapshot_2026-04-09/google_native_tail_import_2026-04-10.json#interactions_log_delta')
        verification = 'Importado desde la cola viva de Google-native y normalizado en la arquitectura actual.'
        next_step = 'Preservado tambien en views/history_export/argos.timeline.jsonl.'
        sort_date = (Get-SortDate $row.timestamp)
    }))
    $existingEventIndex[$eventKey] = $true
}

$eventsSorted = $mergedEvents | Sort-Object { $_.sort_date }
$eventLines = foreach ($event in $eventsSorted) {
    $obj = [ordered]@{
        timestamp = $event.timestamp
        actor = $event.actor
        module = $event.module
        type = $event.type
        summary = $event.summary
        artifacts = $event.artifacts
        verification = $event.verification
        next_step = $event.next_step
    }
    ($obj | ConvertTo-Json -Compress)
}
[System.IO.File]::WriteAllLines($eventsPath, @($eventLines), $utf8NoBom)

$timelineDesc = $timelineSorted | Sort-Object { $_.sort_date } -Descending

$logStreamEntries = foreach ($entry in ($timelineDesc | Where-Object { $_.stream -eq 'global' })) {
    [ordered]@{
        timestamp_label = $entry.timestamp_label
        timestamp_precision = $entry.timestamp_precision
        actor = $entry.actor
        status = $entry.status
        summary = $entry.summary
        details = $entry.details
        next_step = $entry.next_step
    }
}

$intStreamEntries = foreach ($entry in ($timelineDesc | Where-Object { $_.stream -eq 'interaction' })) {
    [ordered]@{
        timestamp_label = $entry.timestamp_label
        timestamp_precision = $entry.timestamp_precision
        actor = $entry.actor
        status = $entry.status
        summary = $entry.summary
        details = $entry.details
    }
}

$shadowStreamEntries = foreach ($entry in ($timelineDesc | Where-Object { $_.stream -eq 'shadow' })) {
    [ordered]@{
        timestamp_label = $entry.timestamp_label
        timestamp_precision = $entry.timestamp_precision
        actor = $entry.actor
        status = $entry.status
        summary = $entry.summary
        details = $entry.details
        next_step = $entry.next_step
    }
}

$glitchStreamEntries = foreach ($entry in ($glitchSorted | Sort-Object { Get-SortDate $_.timestamp } -Descending)) {
    [ordered]@{
        id = $entry.id
        timestamp_label = Get-TimestampLabel $entry.timestamp
        timestamp_precision = Get-TimestampPrecision $entry.timestamp
        actor = $entry.actor
        status = $entry.status
        summary = $entry.summary
        details = $entry.details
        next_step = $entry.next_step
    }
}

$argosModule = $logbook.modules | Where-Object { $_.id -eq 'argos' }
$argosModule.streams = @(
    [ordered]@{ id = 'log'; label = 'Log'; source = 'ARGOS_GLOBAL_LOG.md'; entries = $logStreamEntries },
    [ordered]@{ id = 'interactions'; label = 'Interacciones'; source = 'ARGOS_EVENTS'; entries = $intStreamEntries },
    [ordered]@{ id = 'shadow'; label = 'Sombra'; source = 'ARGOS_GLOBAL_SHADOW_LOG.md'; entries = $shadowStreamEntries },
    [ordered]@{ id = 'glitch'; label = 'Glitch'; source = 'ARGOS_GLOBAL_GLITCH_LOG.md'; entries = $glitchStreamEntries }
)
$logbook.updated_at = (Get-Date -Format 'o')
$logbookJson = $logbook | ConvertTo-Json -Depth 12
[System.IO.File]::WriteAllText($logbookPath, $logbookJson, $utf8NoBom)

$manifest = [ordered]@{
    generated_at = (Get-Date -Format 'o')
    sources = @(
        'legacy/v1_0_x_google_native_snapshot_2026-04-09/argos_root_logs.snapshot.json',
        'legacy/v1_0_x_google_native_snapshot_2026-04-09/argos_shadow_log.snapshot.json',
        'legacy/v1_0_x_google_native_snapshot_2026-04-09/google_native_tail_import_2026-04-10.json',
        'drive:AG_log_2026-04-09.md',
        'drive:AG_shadow_log_2026-04-09.md',
        'views/logbook_export/logbook.snapshot.json',
        'events/argos.events.jsonl'
    )
    timestamp_policy = [ordered]@{
        minute = 'Se conserva cuando existe en la fuente.'
        day = 'Se mantiene como precision day cuando no existe hora fiable.'
        timezone = 'Atlantic/Canary para etiquetas legacy y locales.'
    }
    outputs = @(
        'views/history_export/ARGOS_CANONICAL_HISTORY.md',
        'views/history_export/argos.timeline.jsonl',
        'ARGOS_GLOBAL_GLITCH_LOG.md',
        'events/argos.glitches.jsonl',
        'events/argos.events.jsonl',
        'views/logbook_export/logbook.snapshot.json'
    )
    counts = [ordered]@{
        timeline_entries = @($timelineSorted).Count
        glitch_entries = @($glitchSorted).Count
        event_entries = @($eventsSorted).Count
    }
    notes = @(
        'La capa viva (ARGOS_GLOBAL_LOG.md y ARGOS_GLOBAL_SHADOW_LOG.md) sigue siendo operativa.',
        'La memoria consolidada completa vive en ARGOS_CANONICAL_HISTORY.md y argos.timeline.jsonl.',
        'Los drafts locales de Antigravity se absorben como fuentes historicas con precision day.',
        'La cola final de Google-native posterior al snapshot inicial queda preservada en google_native_tail_import_2026-04-10.json.'
    )
}
$manifestJson = $manifest | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText($historyManifestPath, $manifestJson, $utf8NoBom)

# Cierre de consistencia: sincroniza state.json contra filesystem de work_packets.
$syncStateScript = Join-Path $RuntimeDir 'tools\sync_state.ps1'
if (-not (Test-Path -LiteralPath $syncStateScript)) {
    throw "sync_state.ps1 no encontrado en $syncStateScript"
}

& $syncStateScript -RuntimeDir $RuntimeDir | Out-Null

Write-Output ('history_timeline=' + $historyTimelinePath)
Write-Output ('history_markdown=' + $historyMarkdownPath)
Write-Output ('glitches_jsonl=' + $glitchesPath)
Write-Output ('glitches_markdown=' + $glitchMarkdownPath)
