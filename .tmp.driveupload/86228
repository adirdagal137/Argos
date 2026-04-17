import express, { Request, Response } from 'express';
import cors from 'cors';
import fs from 'fs';
import path from 'path';
import { spawnSync } from 'child_process';
import zoomRoutes from './routes/zoom.routes';
import { manualDraftGlobals, manualDraftShadows, legacyGlitches, lateRuntimeGlobals, lateRuntimeShadows } from './legacy_history_data';

const app = express();
app.use(cors());
app.use(express.json());

const RUNTIME_DIR = 'c:/Users/Widox/Desktop/ARGOS/ARGOS_RUNTIME';
const TOOLS_DIR = path.join(RUNTIME_DIR, 'tools');
const LOGBOOK_SNAPSHOT_PATH = path.join(RUNTIME_DIR, 'views', 'logbook_export', 'logbook.snapshot.json');
const ARGOS_STATE_PATH = path.join(RUNTIME_DIR, 'state', 'argos.state.json');
const DASHBOARD_DIR = path.join(__dirname, '..', '..', 'argos-dashboard');
const ARGOS_GLOBAL_LOG_PATH = path.join(RUNTIME_DIR, 'ARGOS_GLOBAL_LOG.md');
const ARGOS_GLOBAL_SHADOW_PATH = path.join(RUNTIME_DIR, 'ARGOS_GLOBAL_SHADOW_LOG.md');
const ARGOS_GLOBAL_GLITCH_PATH = path.join(RUNTIME_DIR, 'ARGOS_GLOBAL_GLITCH_LOG.md');
const ARGOS_EVENTS_PATH = path.join(RUNTIME_DIR, 'events', 'argos.events.jsonl');
const ARGOS_GLITCHES_PATH = path.join(RUNTIME_DIR, 'events', 'argos.glitches.jsonl');
const ARGOS_TOKENS_PATH = path.join(RUNTIME_DIR, 'events', 'argos.tokens.jsonl');
const CAPTAIN_FEED_PATH = path.join(RUNTIME_DIR, 'views', 'ui_export', 'captain_feed.jsonl');
const STATE_ARCHIVE_PATH = path.join(RUNTIME_DIR, 'state', 'argos.state.archive.json');
const SESSION_ARCHIVE_ROOT = path.join(RUNTIME_DIR, 'archive', 'sessions');
const LEGACY_ARCHIVE_ROOT = path.join(RUNTIME_DIR, 'archive', 'legacy');
const ANTIGRAVITY_PROTO_PACKET_NAME = 'ARG-PROTO-AG-001__ANTIGRAVITY_RITUAL_DE_CIERRE_OBLIGATORIO.md';
const ANTIGRAVITY_PROTO_PACKET_PATH = path.join(RUNTIME_DIR, 'work_packets', 'inbox', ANTIGRAVITY_PROTO_PACKET_NAME);
const PENDING_ACTIONS_PATH = path.join(RUNTIME_DIR, 'locks', 'pending_actions.jsonl');
const TRANSCRIPTS_DIR = path.join(RUNTIME_DIR, 'transcripts');
const DESKTOP_SOURCES_CONFIG_PATH = path.join(RUNTIME_DIR, 'state', 'desktop_sources.json');
const DESKTOP_INGEST_STATE_PATH = path.join(RUNTIME_DIR, 'state', 'desktop_ingest.state.json');
const EXTERNAL_TRANSCRIPTS_DIR = path.join(TRANSCRIPTS_DIR, 'external');

app.use(express.static(DASHBOARD_DIR));
app.use('/api/zoom', zoomRoutes);

// ============ PUB/SUB INFRASTRUCTURE (SSE-based) ============
type PubSubEvent = {
  timestamp: string;
  topic: string;
  payload: Record<string, unknown>;
};

type SSEClient = {
  module: string;
  response: Response;
  senderId: string;
};

const sseClients: Map<string, SSEClient[]> = new Map();
let clientIdCounter = 0;

function publishEvent(topic: string, payload: Record<string, unknown>, excludeModule?: string): void {
  const event: PubSubEvent = {
    timestamp: new Date().toISOString(),
    topic,
    payload
  };

  const eventStr = `data: ${JSON.stringify(event)}\n\n`;
  const timestamp = new Date().toLocaleString('es-ES', { timeZone: 'Atlantic/Canary' });
  console.log(`[PUBSUB-PUBLISH] ${timestamp} | topic: ${topic} | clients: ${sseClients.size} modules`);

  // Enviar a todos los mÃ³dulos suscritos
  sseClients.forEach((clients, module) => {
    if (excludeModule && module === excludeModule) return; // Opcional: excluir mÃ³dulo origen

    clients.forEach(client => {
      try {
        client.response.write(eventStr);
      } catch (error) {
        console.warn(`[PUBSUB] Error enviando a cliente ${client.senderId}:`, error);
        // Cliente desconectado, se limpia en el close handler
      }
    });
  });
}

function subscribeToModule(module: string, res: Response): string {
  const senderId = `${module}-${++clientIdCounter}-${Date.now()}`;

  if (!sseClients.has(module)) {
    sseClients.set(module, []);
  }

  const client: SSEClient = { module, response: res, senderId };
  sseClients.get(module)!.push(client);

  console.log(`[PUBSUB-SUBSCRIBE] ${module} | cliente: ${senderId} | total: ${sseClients.get(module)!.length}`);

  // Setup SSE
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.setHeader('Access-Control-Allow-Origin', '*');

  // Enviar heartbeat inicial
  res.write(`:heartbeat-${Date.now()}\n\n`);

  // Cleanup cuando el cliente se desconecta
  res.on('close', () => {
    const clients = sseClients.get(module);
    if (clients) {
      const idx = clients.findIndex(c => c.senderId === senderId);
      if (idx >= 0) {
        clients.splice(idx, 1);
        console.log(`[PUBSUB-DISCONNECT] ${module} | cliente: ${senderId}`);
      }
      if (clients.length === 0) {
        sseClients.delete(module);
      }
    }
  });

  return senderId;
}

type CaptainFeedRecord = {
  id?: string;
  timestamp?: string;
  kind?: string;
  speaker?: string;
  sender_name?: string;
  sender_role?: string;
  audience?: string;
  source?: string;
  summary?: string;
  details?: string;
  status?: string;
  actor?: string;
  tokens?: number;
  refId?: string;
  edited_at?: string;
};

type LogbookColumn = {
  id: string;
  label: string;
};

type LogbookEntry = {
  id?: string;
  timestamp_label?: string;
  timestamp_precision?: string;
  timestamp?: string;
  actor?: string;
  status?: string;
  summary?: string;
  details?: string;
  next_step?: string;
  errors?: string;
  risks?: string;
  source?: string;
};

type LogbookStream = {
  id: string;
  label: string;
  source?: string;
  empty_state?: string;
  entries?: LogbookEntry[];
};

type LogbookModule = {
  id: string;
  label: string;
  status?: string;
  description?: string;
  streams?: LogbookStream[];
};

type LogbookSnapshot = {
  updated_at?: string;
  timezone?: string;
  timestamp_policy?: {
    markdown_rule?: string;
    structured_rule?: string;
    legacy_precision_note?: string;
  };
  columns?: LogbookColumn[];
  modules?: LogbookModule[];
};

type TaskRecord = {
  id: string;
  title: string;
  owner: string;
  status: string;
  time: string;
  zone: 'inbox' | 'in_progress' | 'done';
  type: string;
  priority: string;
  tokens_spent: number;
  mtimeMs: number;
  created_at: string;
  estimated_time: string;
};

type TokenRecord = {
  timestamp: string;
  agent: string;
  tokens: number;
  ref: string;
  module?: string; // e.g., 'argos', 'comenio', 'xuanshu'
  refId?: string;  // e.g., 'ACCION 34', 'ARG-123'
  scope?: 'work' | 'report' | 'input';
  channel?: string;
};

type TokenStats = {
  total: number;
  daily: number;
  weekly: number;
  agents: Record<string, { total: number; daily: number; weekly: number }>;
  costEstimate: number;
};

type DesktopSourceDefinition = {
  id: string;
  enabled: boolean;
  rootPath: string;
  transcriptGlobs: string[];
  tokenGlobs: string[];
  parser: string;
  agentName: string;
  owner: string;
  timezone?: string;
};

type DesktopSourcesConfig = {
  version: number;
  updated_at: string;
  notes: string;
  sources: DesktopSourceDefinition[];
};

type DesktopIngestState = {
  version: number;
  updated_at: string;
  files: Record<string, { mtimeMs: number; size: number; hash: string; importedAt: string }>;
  importedTokenKeys: string[];
  importedTranscriptKeys: string[];
  lastRun: {
    startedAt?: string;
    finishedAt?: string;
    mode?: 'tokens' | 'transcripts' | 'all';
    actor?: string;
    summary?: {
      sources: number;
      tokenFilesScanned: number;
      tokensImported: number;
      transcriptFilesScanned: number;
      transcriptsMirrored: number;
      errors: number;
      warnings: string[];
    };
  };
};

type DesktopImportRunSummary = {
  startedAt: string;
  finishedAt: string;
  mode: 'tokens' | 'transcripts' | 'all';
  actor: string;
  sources: number;
  tokenFilesScanned: number;
  tokensImported: number;
  transcriptFilesScanned: number;
  transcriptsMirrored: number;
  errors: number;
  warnings: string[];
};

type ParsedTimestampLabel = { label: string; precision: 'minute' | 'day'; sortMs: number };

function parseTimestampLabel(rawValue: string): ParsedTimestampLabel {
  const trimmed = normaliseText(rawValue);
  if (trimmed === '') return { label: '--', precision: 'day', sortMs: 0 };

  const parsedIso = Date.parse(trimmed);
  if (!Number.isNaN(parsedIso)) {
    const isoMatch = trimmed.match(/^(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2})/);
    if (isoMatch) {
      const label = `${isoMatch[1]} ${isoMatch[2]}`;
      return { label, precision: 'minute', sortMs: parsedIso };
    }
    // Formato "YYYY-MM-DD HH:MM" — Date.parse lo acepta pero no tiene T, hay que extraer la hora antes del dayMatch
    const minuteMatchInIso = trimmed.match(/^(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2})/);
    if (minuteMatchInIso) {
      const label = `${minuteMatchInIso[1]} ${minuteMatchInIso[2]}`;
      return { label, precision: 'minute', sortMs: parsedIso };
    }
    const dayMatch = trimmed.match(/^(\d{4}-\d{2}-\d{2})/);
    if (dayMatch) {
      return { label: dayMatch[1], precision: 'day', sortMs: Date.parse(`${dayMatch[1]}T00:00:00`) || parsedIso };
    }
    return { label: trimmed, precision: 'minute', sortMs: parsedIso };
  }

  const minuteMatch = trimmed.match(/^(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2})/);
  if (minuteMatch) {
    const label = `${minuteMatch[1]} ${minuteMatch[2]}`;
    return { label, precision: 'minute', sortMs: Date.parse(`${minuteMatch[1]}T${minuteMatch[2]}:00`) || 0 };
  }

  const dayMatch = trimmed.match(/^(\d{4}-\d{2}-\d{2})/);
  if (dayMatch) {
    return { label: dayMatch[1], precision: 'day', sortMs: Date.parse(`${dayMatch[1]}T00:00:00`) || 0 };
  }

  return { label: '--', precision: 'day', sortMs: 0 };
}

function buildEmptyLogbook(): LogbookSnapshot {
  return {
    updated_at: new Date().toISOString(),
    timezone: 'Atlantic/Canary',
    timestamp_policy: {
      markdown_rule: 'Si hay hora, usar YYYY-MM-DD HH:MM. Si no, solo fecha.',
      structured_rule: 'timestamp ISO8601 en JSONL.',
      legacy_precision_note: 'Entradas legacy pueden no incluir hora.'
    },
    columns: [
      { id: 'timestamp_label', label: 'Tiempo' },
      { id: 'actor', label: 'Voz' },
      { id: 'status', label: 'Estado' },
      { id: 'summary', label: 'Misión' },
      { id: 'details', label: 'Detalles' },
      { id: 'next_step', label: 'Siguiente' },
      { id: 'errors', label: 'Errores+Aprendizajes' },
      { id: 'risks', label: 'Riesgos' },
      { id: 'id', label: 'ID' },
      { id: 'transcriptRef', label: '📄' }
    ],
    modules: [
      {
        id: 'argos',
        label: 'ARGOS',
        status: 'active',
        description: 'Bitácora operativa y trazabilidad.',
        streams: [
          { id: 'log',    label: 'Log',      source: 'ARGOS_GLOBAL_LOG.md',        empty_state: 'Sin entradas en el log.' },
          { id: 'shadow', label: 'Shadow',   source: 'ARGOS_GLOBAL_SHADOW_LOG.md', empty_state: 'Sin entradas en shadow.' },
          { id: 'glitch', label: 'Glitches', source: 'argos.glitches.jsonl',       empty_state: 'Sin glitches.' }
        ]
      },
      {
        id: 'sciclass',
        label: 'SCICLASS-M8',
        status: 'active',
        description: 'Misiones de investigación científica.',
        streams: [
          { id: 'log',    label: 'Log',      source: 'ARGOS_GLOBAL_LOG.md',        empty_state: 'Sin entradas en el log.' },
          { id: 'shadow', label: 'Shadow',   source: 'ARGOS_GLOBAL_SHADOW_LOG.md', empty_state: 'Sin entradas en shadow.' },
          { id: 'glitch', label: 'Glitches', source: 'argos.glitches.jsonl',       empty_state: 'Sin glitches.' }
        ]
      },
      {
        id: 'comenio',
        label: 'COMENIO',
        status: 'active',
        description: 'Protocolos de aprendizaje y educación.',
        streams: [
          { id: 'log',    label: 'Log',      source: 'ARGOS_GLOBAL_LOG.md',        empty_state: 'Sin entradas en el log.' },
          { id: 'shadow', label: 'Shadow',   source: 'ARGOS_GLOBAL_SHADOW_LOG.md', empty_state: 'Sin entradas en shadow.' },
          { id: 'glitch', label: 'Glitches', source: 'argos.glitches.jsonl',       empty_state: 'Sin glitches.' }
        ]
      },
      {
        id: 'lola',
        label: 'LOLA',
        status: 'active',
        description: 'Escáner de sombra y gestión de riesgos.',
        streams: [
          { id: 'log',    label: 'Log',      source: 'ARGOS_GLOBAL_LOG.md',        empty_state: 'Sin entradas en el log.' },
          { id: 'shadow', label: 'Shadow',   source: 'ARGOS_GLOBAL_SHADOW_LOG.md', empty_state: 'Sin entradas en shadow.' },
          { id: 'glitch', label: 'Glitches', source: 'argos.glitches.jsonl',       empty_state: 'Sin glitches.' }
        ]
      },
      {
        id: 'xuanshu',
        label: 'XUANSHU',
        status: 'active',
        description: 'Algoritmos avanzados y forja de código.',
        streams: [
          { id: 'log',    label: 'Log',      source: 'ARGOS_GLOBAL_LOG.md',        empty_state: 'Sin entradas en el log.' },
          { id: 'shadow', label: 'Shadow',   source: 'ARGOS_GLOBAL_SHADOW_LOG.md', empty_state: 'Sin entradas en shadow.' },
          { id: 'glitch', label: 'Glitches', source: 'argos.glitches.jsonl',       empty_state: 'Sin glitches.' }
        ]
      }
    ]
  };
}

type ChatMessage = {
  id: string;
  type: 'sent' | 'received';
  sender: string;
  text: string;
  summary: string;
  details: string;
  senderRole: string;
  speaker: string;
  time: string;
  tokens: number;
  refId: string;
  timestamp: string;
  editedAt: string;
};

function generateStableHash(seed: string): string {
  let hash = 2166136261;
  for (let i = 0; i < seed.length; i += 1) {
    hash ^= seed.charCodeAt(i);
    hash = Math.imul(hash, 16777619);
  }
  return (hash >>> 0).toString(16);
}

function nextFeedMessageId(): string {
  return `FEED-${Date.now()}-${Math.floor(Math.random() * 1000000)}`;
}

function resolveFeedRecordId(record: CaptainFeedRecord): string {
  const explicit = normaliseText(record.id);
  if (explicit !== '') return explicit;
  const seed = [
    normaliseText(record.timestamp),
    inferSenderName(record),
    normaliseText(record.summary),
    normaliseText(record.details),
    normaliseText(record.refId)
  ].join('|');
  return `FEEDLEG-${generateStableHash(seed || 'legacy')}`;
}

function buildChatMessage(record: CaptainFeedRecord): ChatMessage {
  const timestamp = normaliseText(record.timestamp) || new Date().toISOString();
  const id = resolveFeedRecordId(record);
  const sender = inferSenderName(record) || 'Tripulacion';
  const speaker = normaliseText(record.speaker).toLowerCase();
  const senderRole = normaliseText(record.sender_role).toLowerCase();
  const type: 'sent' | 'received' = speaker === 'crew' || senderRole === 'agent' ? 'received' : 'sent';
  const tokens = Number(record.tokens) || 0;
  const summary = normaliseText(record.summary);
  const details = normaliseText(record.details);
  const editedAt = normaliseText(record.edited_at);
  const text = [summary, details].filter((p) => p !== '').join('\n');
  const refId = normaliseText(record.refId);
  const time = new Date(timestamp).toLocaleTimeString('es-ES', { timeZone: 'Atlantic/Canary', hour: '2-digit', minute: '2-digit' });
  return { id, type, sender, text, summary, details, senderRole, speaker, time, tokens, refId, timestamp, editedAt };
}

type CaptainFeedLine = {
  raw: string;
  parsed: CaptainFeedRecord | null;
};

function readCaptainFeedLines(feedPath: string): CaptainFeedLine[] {
  if (!fs.existsSync(feedPath)) return [];
  const data = fs.readFileSync(feedPath, 'utf-8').replace(/^\uFEFF/, '');
  return data.split(/\r?\n/).map((line) => {
    const trimmed = line.trim();
    if (!trimmed.startsWith('{')) return { raw: line, parsed: null };
    try {
      return { raw: line, parsed: JSON.parse(trimmed) as CaptainFeedRecord };
    } catch {
      return { raw: line, parsed: null };
    }
  });
}

function writeCaptainFeedLines(feedPath: string, lines: CaptainFeedLine[]): void {
  const serialized = lines.map((line) => (line.parsed ? JSON.stringify(line.parsed) : line.raw)).join('\n');
  if (serialized === '') {
    fs.writeFileSync(feedPath, '', 'utf-8');
    return;
  }
  fs.writeFileSync(feedPath, serialized.endsWith('\n') ? serialized : `${serialized}\n`, 'utf-8');
}

function ensureCaptainFeedRecordId(record: CaptainFeedRecord): CaptainFeedRecord {
  const withId = { ...record };
  if (normaliseText(withId.id) === '') {
    withId.id = resolveFeedRecordId(withId);
  }
  return withId;
}

// ============ AGENT NAME NORMALIZATION ============
function normalizeAgentName(rawName: string): 'Claude' | 'Antigravity' | 'Codex' | 'DeepSeek' | null {
  if (!rawName) return null;

  const v = rawName.trim().toLowerCase()
    .replace(/\*\*/g, '').replace(/__/g, '').replace(/\[/g, '').replace(/\]/g, '');

  if (v.includes('claude')) return 'Claude';
  if (v.includes('antigravity') || v.includes('gemini')) return 'Antigravity';
  if (v.includes('codex')) return 'Codex';
  if (v.includes('orfeo') || v.includes('deepseek') || v.includes('contramaestre')) return 'DeepSeek';

  return null;
}

// --- SOPORTE PARA SISTEMA VOCAL (V2) ---

function postToCrewFeed(sender: string, summary: string, details: string = '', kind: string = 'crew_update', tokens: number = 0, refId: string = '') {
  const feedPath = path.join(RUNTIME_DIR, 'views', 'ui_export', 'captain_feed.jsonl');
  const numericTokens = Number(tokens) || 0;
  const canonicalSender = normalizeAgentName(sender) || sender;
  const record: CaptainFeedRecord = {
    id: nextFeedMessageId(),
    timestamp: new Date().toISOString(),
    kind,
    speaker: 'crew',
    sender_name: canonicalSender,
    sender_role: 'agent',
    audience: 'captain',
    source: 'autonomous_vocal_system',
    summary,
    details,
    status: 'recorded',
    tokens: 0,
    refId
  };

  try {
    appendJsonlRecord(feedPath, record);
    if (numericTokens > 0) {
      const tokensPath = path.join(RUNTIME_DIR, 'events', 'argos.tokens.jsonl');
      appendJsonlRecord(tokensPath, {
        timestamp: record.timestamp,
        agent: canonicalSender,
        tokens: numericTokens,
        module: 'argos',
        refId: refId || '',
        ref: `Vocal: ${summary.substring(0, 60)}`,
        scope: 'report',
        channel: 'feed'
      });
      publishEvent('tokens:updated', {
        agent: canonicalSender,
        tokens: numericTokens,
        timestamp: record.timestamp,
        refId: refId || '',
        scope: 'report'
      });
    }
    console.log(`[VOCAL] ${canonicalSender}: ${summary} [${numericTokens} tokens, ID: ${refId}]`);
  } catch (e) {
    console.error(`[VOCAL] Error publicando mensaje de ${canonicalSender}`, e);
  }
}

// ============ TRANSCRIPT SYSTEM ============

function transcriptDateStr(): string {
  return new Date().toLocaleDateString('sv-SE', { timeZone: 'Atlantic/Canary' }); // YYYY-MM-DD
}

function transcriptFilePath(agent: string): string {
  if (!fs.existsSync(TRANSCRIPTS_DIR)) fs.mkdirSync(TRANSCRIPTS_DIR, { recursive: true });
  const date = transcriptDateStr();
  const safeName = (agent || 'unknown').replace(/[^a-zA-Z0-9_-]/g, '_');
  return path.join(TRANSCRIPTS_DIR, `${date}_${safeName}.md`);
}

/**
 * Escribe un bloque de exchange en el transcript del agente.
 * role: 'captain' | 'agent'
 * El bloque queda anclado con el packetId para recuperación directa.
 */
function appendToTranscript(agent: string, role: 'captain' | 'agent', content: string, packetId: string = ''): string {
  try {
    const filePath = transcriptFilePath(agent);
    const ts = new Date().toISOString();
    const canaryTs = new Date().toLocaleString('sv-SE', {
      timeZone: 'Atlantic/Canary', year: 'numeric', month: '2-digit',
      day: '2-digit', hour: '2-digit', minute: '2-digit'
    }).slice(0, 16);

    const roleLabel = role === 'captain' ? `PROMPT (Capitán → ${agent})` : `RESPONSE (${agent} → Capitán)`;
    const anchor = packetId ? `<!-- ${packetId} -->` : '';
    const packetLine = packetId ? `**Packet:** ${packetId}` : '';

    const block = [
      anchor,
      `## [${canaryTs}]${packetId ? ` Packet: ${packetId}` : ''}`,
      packetLine,
      '',
      `**${roleLabel}:**`,
      content.trim(),
      '',
      '---',
      ''
    ].filter(l => l !== undefined).join('\n');

    fs.appendFileSync(filePath, block, 'utf-8');
    const date = transcriptDateStr();
    const safeName = (agent || 'unknown').replace(/[^a-zA-Z0-9_-]/g, '_');
    return `transcripts/${date}_${safeName}.md${packetId ? `#${packetId}` : ''}`;
  } catch (e) {
    console.error('[TRANSCRIPT] Error escribiendo transcript', e);
    return '';
  }
}

/**
 * Lee el bloque de transcript para un packetId específico dentro de un archivo.
 * Devuelve el bloque completo entre el anchor y el siguiente '---'.
 */
function readTranscriptBlock(agent: string, date: string, packetId: string): string | null {
  try {
    const safeName = agent.replace(/[^a-zA-Z0-9_-]/g, '_');
    const filePath = path.join(TRANSCRIPTS_DIR, `${date}_${safeName}.md`);
    if (!fs.existsSync(filePath)) return null;
    const content = fs.readFileSync(filePath, 'utf-8');
    const anchor = `<!-- ${packetId} -->`;
    const start = content.indexOf(anchor);
    if (start === -1) return null;
    // Encontrar el siguiente bloque o fin de archivo
    const afterAnchor = content.indexOf('\n---\n', start);
    const end = afterAnchor !== -1 ? afterAnchor + 5 : content.length;
    return content.slice(start, end).trim();
  } catch (e) {
    return null;
  }
}

type ArgosState = {
  open_packets: string[];
  packet_states?: Record<string, string>; // ID -> Status:Zone
  [key: string]: any;
};

function readArgosState(): ArgosState {
  try {
    if (!fs.existsSync(ARGOS_STATE_PATH)) return { open_packets: [] };
    return JSON.parse(fs.readFileSync(ARGOS_STATE_PATH, 'utf-8'));
  } catch (e) {
    return { open_packets: [] };
  }
}

function writeArgosState(state: ArgosState) {
  try {
    state.updated_at = new Date().toISOString();
    fs.writeFileSync(ARGOS_STATE_PATH, JSON.stringify(state, null, 4));
  } catch (e) {
    console.error('[STATE] Error guardando estado de Argos', e);
  }
}

type SessionArchiveMode = 'start_of_day' | 'end_of_day';

type SessionArchiveRequest = {
  mode: SessionArchiveMode;
  actor: string;
  reason: string;
  dryRun: boolean;
  archiveDonePackets: boolean;
  compactState: boolean;
  reorganizeLegacy: boolean;
};

type SessionArchiveReport = {
  status: 'ok' | 'dry_run';
  mode: SessionArchiveMode;
  actor: string;
  reason: string;
  archiveRoot: string;
  sessionStamp: string;
  movedFiles: Array<{ from: string; to: string }>;
  createdFiles: string[];
  notes: string[];
  compactedDoneStates: number;
  archivedDonePackets: number;
  archivedTranscriptFiles: number;
};

type StateArchiveShape = {
  _note: string;
  _policy: string;
  archived_at: string;
  packet_states: Record<string, string>;
  done_packets_summary: {
    total: number;
    tasks: number;
    bugs: number;
    latest_ids: string[];
  };
};

function ensureDirSync(dirPath: string): void {
  if (!fs.existsSync(dirPath)) fs.mkdirSync(dirPath, { recursive: true });
}

function canaryDateStamp(now = new Date()): string {
  return new Intl.DateTimeFormat('sv-SE', {
    timeZone: 'Atlantic/Canary',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  }).format(now);
}

function canaryTimeStamp(now = new Date()): string {
  const hhmmss = new Intl.DateTimeFormat('en-GB', {
    timeZone: 'Atlantic/Canary',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: false
  }).format(now);
  return hhmmss.replace(/:/g, '');
}

function canaryLabel(now = new Date()): string {
  const date = canaryDateStamp(now);
  const hhmm = new Intl.DateTimeFormat('en-GB', {
    timeZone: 'Atlantic/Canary',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  }).format(now);
  return `${date} ${hhmm} Atlantic/Canary`;
}

function uniqueDestinationPath(destinationPath: string): string {
  if (!fs.existsSync(destinationPath)) return destinationPath;
  const dir = path.dirname(destinationPath);
  const ext = path.extname(destinationPath);
  const base = path.basename(destinationPath, ext);
  let idx = 1;
  while (true) {
    const candidate = path.join(dir, `${base}__dup${idx}${ext}`);
    if (!fs.existsSync(candidate)) return candidate;
    idx += 1;
  }
}

function moveFileWithFallback(sourcePath: string, destinationPath: string): void {
  ensureDirSync(path.dirname(destinationPath));
  const finalDestination = uniqueDestinationPath(destinationPath);
  try {
    fs.renameSync(sourcePath, finalDestination);
  } catch {
    fs.copyFileSync(sourcePath, finalDestination);
    fs.unlinkSync(sourcePath);
  }
}

function writeUtf8FileSafe(
  filePath: string,
  content: string,
  dryRun: boolean,
  report: SessionArchiveReport
): void {
  if (dryRun) {
    report.notes.push(`[dry-run] crear archivo: ${filePath}`);
    return;
  }
  ensureDirSync(path.dirname(filePath));
  fs.writeFileSync(filePath, content, 'utf-8');
  report.createdFiles.push(filePath);
}

function moveIfExists(
  sourcePath: string,
  destinationPath: string,
  dryRun: boolean,
  report: SessionArchiveReport
): boolean {
  if (!fs.existsSync(sourcePath)) return false;
  if (dryRun) {
    report.notes.push(`[dry-run] mover ${sourcePath} -> ${destinationPath}`);
    report.movedFiles.push({ from: sourcePath, to: destinationPath });
    return true;
  }
  moveFileWithFallback(sourcePath, destinationPath);
  report.movedFiles.push({ from: sourcePath, to: destinationPath });
  return true;
}

function compactDoneStatesIntoArchive(dryRun: boolean, report: SessionArchiveReport): number {
  const activeState = readArgosState();
  const activePacketStates = activeState.packet_states || {};
  const doneEntries = Object.entries(activePacketStates).filter(([, value]) =>
    normaliseText(value).toLowerCase().includes(':done')
  );

  if (doneEntries.length === 0) return 0;

  const stateArchive = readJsonFile<StateArchiveShape>(STATE_ARCHIVE_PATH, {
    _note: `Archivo de estados completados. Generado el ${canaryDateStamp()}. No modificar manualmente.`,
    _policy: 'Los estados done:done y mitigated:done se mueven aqui por cierre de sesion.',
    archived_at: new Date().toISOString(),
    packet_states: {},
    done_packets_summary: {
      total: 0,
      tasks: 0,
      bugs: 0,
      latest_ids: []
    }
  });

  for (const [packetId, packetState] of doneEntries) {
    const existing = stateArchive.packet_states[packetId];
    if (!existing) {
      stateArchive.packet_states[packetId] = packetState;
      continue;
    }

    if (existing === packetState) continue;

    let suffix = 1;
    while (stateArchive.packet_states[`${packetId}__dup${suffix}`]) suffix += 1;
    stateArchive.packet_states[`${packetId}__dup${suffix}`] = packetState;
  }

  doneEntries.forEach(([packetId]) => {
    delete activePacketStates[packetId];
  });

  const stillActiveEntries = Object.entries(activePacketStates);
  const stillActiveIds = stillActiveEntries.map(([packetId]) => packetId);
  activeState.packet_states = activePacketStates;
  activeState.open_packets = stillActiveEntries
    .filter(([, state]) => {
      const normalized = normaliseText(state).toLowerCase();
      return normalized.startsWith('open:') ||
        normalized.startsWith('inbox:') ||
        normalized.startsWith('parked:') ||
        normalized.startsWith('in_progress:') ||
        normalized.includes(':inbox') ||
        normalized.includes(':in_progress') ||
        normalized.includes(':open') ||
        normalized.includes(':parked');
    })
    .map(([packetId]) => packetId);
  activeState.in_progress_packets = stillActiveEntries
    .filter(([, state]) => normaliseText(state).toLowerCase().includes('in_progress'))
    .map(([packetId]) => packetId);
  activeState.done_packets_summary = {
    total: 0,
    tasks: 0,
    bugs: 0,
    latest_ids: []
  };
  activeState._note = 'Solo contiene packets activos (inbox, in_progress, open, parked). Completados en state.archive.json.';
  stateArchive.archived_at = new Date().toISOString();
  stateArchive._note = `Archivo de estados completados. Actualizado el ${canaryDateStamp()}. No modificar manualmente.`;
  stateArchive.done_packets_summary = {
    total: Object.keys(stateArchive.packet_states).length,
    tasks: 0,
    bugs: 0,
    latest_ids: stillActiveIds.slice(0, 10)
  };

  if (dryRun) {
    report.notes.push(`[dry-run] compactar state activo -> ${STATE_ARCHIVE_PATH} (${doneEntries.length} estados done)`);
    return doneEntries.length;
  }

  fs.writeFileSync(STATE_ARCHIVE_PATH, JSON.stringify(stateArchive, null, 4), 'utf-8');
  writeArgosState(activeState);
  return doneEntries.length;
}

function resetLiveSessionFiles(dryRun: boolean, report: SessionArchiveReport): void {
  const now = new Date();
  const logHeader = [
    '# ARGOS GLOBAL LOG',
    'Registro operativo compartido por la tripulacion.',
    `Archivo activo de sesion. Ultimo reset: ${canaryLabel(now)}.`,
    '',
    '---',
    ''
  ].join('\n');

  const shadowHeader = [
    '# ARGOS GLOBAL SHADOW LOG',
    'Material observado sin destino operativo inmediato.',
    `Archivo activo de sesion. Ultimo reset: ${canaryLabel(now)}.`,
    '',
    '---',
    ''
  ].join('\n');

  const glitchHeader = [
    '# ARGOS GLOBAL GLITCH LOG',
    '',
    'Registro estructural de fallas sistemicas, errores de integracion y fricciones tecnicas reutilizables.',
    `Archivo activo de sesion. Ultimo reset: ${canaryLabel(now)}.`,
    '',
    '---',
    ''
  ].join('\n');

  writeUtf8FileSafe(ARGOS_GLOBAL_LOG_PATH, logHeader, dryRun, report);
  writeUtf8FileSafe(ARGOS_GLOBAL_SHADOW_PATH, shadowHeader, dryRun, report);
  writeUtf8FileSafe(ARGOS_GLOBAL_GLITCH_PATH, glitchHeader, dryRun, report);
  writeUtf8FileSafe(ARGOS_EVENTS_PATH, '', dryRun, report);
  writeUtf8FileSafe(ARGOS_GLITCHES_PATH, '', dryRun, report);
  writeUtf8FileSafe(ARGOS_TOKENS_PATH, '', dryRun, report);
  writeUtf8FileSafe(CAPTAIN_FEED_PATH, '', dryRun, report);

  const transcriptsLegacyDir = path.join(RUNTIME_DIR, 'events', 'transcripts');
  if (dryRun) {
    report.notes.push(`[dry-run] asegurar directorio: ${TRANSCRIPTS_DIR}`);
    report.notes.push(`[dry-run] asegurar directorio: ${transcriptsLegacyDir}`);
  } else {
    ensureDirSync(TRANSCRIPTS_DIR);
    ensureDirSync(transcriptsLegacyDir);
  }
}

function archiveDonePacketsToSession(
  sessionDir: string,
  dryRun: boolean,
  report: SessionArchiveReport
): number {
  const doneDir = path.join(RUNTIME_DIR, 'work_packets', 'done');
  if (!fs.existsSync(doneDir)) return 0;
  const doneFiles = fs.readdirSync(doneDir).filter((name) => name.endsWith('.md'));
  let moved = 0;
  doneFiles.forEach((fileName) => {
    const sourcePath = path.join(doneDir, fileName);
    const destinationPath = path.join(sessionDir, 'work_packets', 'done', fileName);
    const movedNow = moveIfExists(sourcePath, destinationPath, dryRun, report);
    if (movedNow) moved += 1;
  });
  return moved;
}

function archiveTranscriptLanesToSession(
  sessionDir: string,
  dryRun: boolean,
  report: SessionArchiveReport
): number {
  let moved = 0;
  const transcriptFiles = fs.existsSync(TRANSCRIPTS_DIR)
    ? fs.readdirSync(TRANSCRIPTS_DIR).filter((name) => name.endsWith('.md') && name.toLowerCase() !== 'readme.md')
    : [];

  transcriptFiles.forEach((fileName) => {
    const sourcePath = path.join(TRANSCRIPTS_DIR, fileName);
    const destinationPath = path.join(sessionDir, 'transcripts', 'live', fileName);
    const movedNow = moveIfExists(sourcePath, destinationPath, dryRun, report);
    if (movedNow) moved += 1;
  });

  const legacyTranscriptDir = path.join(RUNTIME_DIR, 'events', 'transcripts');
  const legacyFiles = fs.existsSync(legacyTranscriptDir)
    ? fs.readdirSync(legacyTranscriptDir).filter((name) => name.endsWith('.md'))
    : [];
  legacyFiles.forEach((fileName) => {
    const sourcePath = path.join(legacyTranscriptDir, fileName);
    const destinationPath = path.join(sessionDir, 'transcripts', 'legacy_events', fileName);
    const movedNow = moveIfExists(sourcePath, destinationPath, dryRun, report);
    if (movedNow) moved += 1;
  });
  return moved;
}

function reorganizeLegacyArtifacts(dryRun: boolean, report: SessionArchiveReport): void {
  const legacyMappings: Array<{ source: string; destination: string }> = [];
  const eventsDir = path.join(RUNTIME_DIR, 'events');
  if (fs.existsSync(eventsDir)) {
    fs.readdirSync(eventsDir)
      .filter((name) => /argos\.events\.jsonl\.bak/i.test(name))
      .forEach((name) => {
        legacyMappings.push({
          source: path.join(eventsDir, name),
          destination: path.join(LEGACY_ARCHIVE_ROOT, 'events_backups', name)
        });
      });
  }

  legacyMappings.push(
    {
      source: path.join(RUNTIME_DIR, 'ARGOS_GLOBAL_LOG.md.corrupted.bak'),
      destination: path.join(LEGACY_ARCHIVE_ROOT, 'file_backups', 'ARGOS_GLOBAL_LOG.md.corrupted.bak')
    },
    {
      source: path.join(RUNTIME_DIR, 'events', 'logs', 'ARGOS_GLOBAL_LOG_archive_20260416.md'),
      destination: path.join(LEGACY_ARCHIVE_ROOT, 'legacy_global_log_archives', 'ARGOS_GLOBAL_LOG_archive_20260416.md')
    }
  );

  legacyMappings.forEach((mapping) => {
    moveIfExists(mapping.source, mapping.destination, dryRun, report);
  });
}

function runSessionArchive(request: SessionArchiveRequest): SessionArchiveReport {
  const now = new Date();
  const dateStamp = canaryDateStamp(now);
  const timeStamp = canaryTimeStamp(now);
  const sessionStamp = `${dateStamp}__${timeStamp}__${request.mode}`;
  const sessionDir = path.join(SESSION_ARCHIVE_ROOT, dateStamp, sessionStamp);

  const report: SessionArchiveReport = {
    status: request.dryRun ? 'dry_run' : 'ok',
    mode: request.mode,
    actor: request.actor,
    reason: request.reason,
    archiveRoot: sessionDir,
    sessionStamp,
    movedFiles: [],
    createdFiles: [],
    notes: [],
    compactedDoneStates: 0,
    archivedDonePackets: 0,
    archivedTranscriptFiles: 0
  };

  if (!request.dryRun) ensureDirSync(sessionDir);

  const liveFiles = [
    { source: ARGOS_GLOBAL_LOG_PATH, destination: path.join(sessionDir, 'logs', 'ARGOS_GLOBAL_LOG.md') },
    { source: ARGOS_GLOBAL_SHADOW_PATH, destination: path.join(sessionDir, 'shadow', 'ARGOS_GLOBAL_SHADOW_LOG.md') },
    { source: ARGOS_GLOBAL_GLITCH_PATH, destination: path.join(sessionDir, 'glitch', 'ARGOS_GLOBAL_GLITCH_LOG.md') },
    { source: ARGOS_EVENTS_PATH, destination: path.join(sessionDir, 'events', 'argos.events.jsonl') },
    { source: ARGOS_GLITCHES_PATH, destination: path.join(sessionDir, 'events', 'argos.glitches.jsonl') },
    { source: ARGOS_TOKENS_PATH, destination: path.join(sessionDir, 'events', 'argos.tokens.jsonl') },
    { source: CAPTAIN_FEED_PATH, destination: path.join(sessionDir, 'chat', 'captain_feed.jsonl') }
  ];

  liveFiles.forEach(({ source, destination }) => {
    moveIfExists(source, destination, request.dryRun, report);
  });

  report.archivedTranscriptFiles = archiveTranscriptLanesToSession(sessionDir, request.dryRun, report);

  if (request.archiveDonePackets) {
    report.archivedDonePackets = archiveDonePacketsToSession(sessionDir, request.dryRun, report);
  }

  if (request.compactState) {
    report.compactedDoneStates = compactDoneStatesIntoArchive(request.dryRun, report);
  }

  if (request.reorganizeLegacy) {
    reorganizeLegacyArtifacts(request.dryRun, report);
  }

  resetLiveSessionFiles(request.dryRun, report);

  const manifestPath = path.join(sessionDir, 'session.archive.manifest.json');
  writeUtf8FileSafe(
    manifestPath,
    JSON.stringify(
      {
        generated_at: new Date().toISOString(),
        generated_at_canary: canaryLabel(now),
        mode: request.mode,
        actor: request.actor,
        reason: request.reason,
        report: {
          compactedDoneStates: report.compactedDoneStates,
          archivedDonePackets: report.archivedDonePackets,
          archivedTranscriptFiles: report.archivedTranscriptFiles,
          movedCount: report.movedFiles.length
        }
      },
      null,
      2
    ),
    request.dryRun,
    report
  );

  return report;
}

function getVoiceForRole(role: string): string {
  // Si el rol es compuesto ("Antigravity / Codex"), usar solo el agente primario (primero)
  const primary = (role || '').split('/')[0].trim();
  const r = primary.toLowerCase();
  if (r.includes('antigravity') || r.includes('gemini')) return 'Antigravity';
  if (r.includes('codex')) return 'Codex';
  if (r.includes('claude') || r.includes('orfeo')) return 'Orfeo (Claude)';
  if (r.includes('lola')) return 'Lola';
  // Sin voz de sistema — si el rol no es de un agente conocido, no tiene voz en los logs
  return primary || 'Antigravity';
}

function isAntigravityRole(role: string): boolean {
  const value = normaliseText(role).toLowerCase();
  return value.includes('antigravity') || value.includes('gemini');
}

function normaliseText(value: unknown): string {
  return typeof value === 'string' ? value.trim() : '';
}

function cleanMarkdownText(value: string): string {
  return (value || '').replace(/\*\*/g, '').replace(/__/g, '').replace(/\[/g, '').replace(/\]/g, '').trim();
}

/**
 * Normalizador de Identidad: Unifica nombres de agentes para consistencia visual (CSS/Icons)
 */
function normalizeActorName(rawName: string): string {
  const actorLower = cleanMarkdownText(rawName || '').toLowerCase();
  if (actorLower.includes('antigravity')) return 'Antigravity';
  if (actorLower.includes('claude')) return 'Claude';
  if (actorLower.includes('codex')) return 'Codex';
  if (actorLower.includes('capitan')) return 'Capitan';
  if (actorLower === 'dispatcher' || actorLower === 'despachador') return 'Dispatcher';
  if (actorLower === 'lola') return 'Lola';
  return rawName || 'Tripulacion';
}

/**
 * Utility: Robust token estimation (standard ratio: 1 token approx 4 characters)
 */
function estimateTokenCount(text: string): number {
  if (!text) return 0;
  const tokens = Math.ceil(text.length / 4);
  return Math.max(1, tokens);
}

function resolveEstimatedTokens(explicitTokens: unknown, ...parts: unknown[]): number {
  const numeric = Number(explicitTokens);
  if (Number.isFinite(numeric) && numeric > 0) return Math.round(numeric);

  const fallbackText = parts
    .map((part) => normaliseText(part))
    .filter((part) => part !== '')
    .join('\n');

  return estimateTokenCount(fallbackText);
}

function normaliseTokenScope(value: unknown): 'work' | 'report' | 'input' {
  const scope = normaliseText(value).toLowerCase();
  if (scope === 'report') return 'report';
  if (scope === 'input') return 'input';
  return 'work';
}

function inferTokenScope(record: TokenRecord): 'work' | 'report' | 'input' {
  if (record.scope) return normaliseTokenScope(record.scope);

  const ref = normaliseText(record.ref).toLowerCase();
  const channel = normaliseText(record.channel).toLowerCase();
  const agent = normaliseText(record.agent).toLowerCase();

  if (channel === 'captain_input' || ref.startsWith('new task:') || agent.includes('captain')) return 'input';

  // IMPORTANT: Para entradas legacy sin `scope`, inferimos SOLO por `channel`.
  // En el histórico hay entradas sin `channel` (ni `scope`) cuyo `ref` puede empezar por "Chat Rep:",
  // pero se usan como proxy de coste de tarea (work). Clasificarlas como report rompe WORK_TOKENS.
  if (channel === 'chat' || channel === 'feed' || channel === 'trilog') return 'report';

  return 'work';
}

const DEFAULT_WORK_FROM_REPORT_MULTIPLIER = 3;

function looksLikeWorkPacketId(value: string): boolean {
  const v = normaliseText(value);
  if (!v) return false;
  return /^((?:ARG|ARGOS)-[A-Z0-9]+(?:-[A-Z0-9]+)*)$/i.test(v);
}

function hasWorkTokenForPacket(tokensPath: string, agent: string, refId: string): boolean {
  try {
    if (!fs.existsSync(tokensPath)) return false;
    const canonicalAgent = normalizeAgentName(agent) || agent;
    const needleRefId = normaliseText(refId);
    if (!needleRefId) return false;

    const lines = readTextFileSafe(tokensPath)
      .split('\n')
      .map((l) => l.trim())
      .filter((l) => l.startsWith('{'));

    for (let i = lines.length - 1; i >= 0 && i >= lines.length - 2000; i -= 1) {
      try {
        const parsed = JSON.parse(lines[i]) as TokenRecord;
        if (normaliseText(parsed.refId) !== needleRefId) continue;
        const parsedAgent = normalizeAgentName(normaliseText(parsed.agent)) || normaliseText(parsed.agent);
        if (parsedAgent !== canonicalAgent) continue;
        if (inferTokenScope(parsed) === 'work') return true;
      } catch {
        // ignore malformed
      }
    }
    return false;
  } catch {
    return false;
  }
}

function backfillWorkTokensFromReportLedger(): void {
  try {
    const tokensPath = path.join(RUNTIME_DIR, 'events', 'argos.tokens.jsonl');
    if (!fs.existsSync(tokensPath)) return;

    const existingWorkKeys = new Set<string>();
    const reportCandidates: TokenRecord[] = [];

    readTextFileSafe(tokensPath)
      .split('\n')
      .map((line) => line.trim())
      .filter((line) => line.startsWith('{'))
      .forEach((line) => {
        try {
          const rec = JSON.parse(line) as TokenRecord;
          const canonicalAgent = normalizeAgentName(normaliseText(rec.agent));
          if (!canonicalAgent) return;
          const rid = normaliseText(rec.refId);
          if (!rid) return;
          const key = `${canonicalAgent}|${rid}`;
          const scope = inferTokenScope(rec);
          if (scope === 'work') existingWorkKeys.add(key);
          if (scope === 'report' && looksLikeWorkPacketId(rid)) reportCandidates.push(rec);
        } catch {
          // ignore malformed
        }
      });

    let inserted = 0;
    reportCandidates.forEach((rec) => {
      const canonicalAgent = normalizeAgentName(normaliseText(rec.agent));
      if (!canonicalAgent) return;
      const rid = normaliseText(rec.refId);
      const key = `${canonicalAgent}|${rid}`;
      if (existingWorkKeys.has(key)) return;

      const val = Number(rec.tokens) || 0;
      if (val <= 0) return;
      const workTokens = Math.max(1, Math.ceil(val * DEFAULT_WORK_FROM_REPORT_MULTIPLIER));

      appendJsonlRecord(tokensPath, {
        timestamp: rec.timestamp || new Date().toISOString(),
        agent: canonicalAgent,
        tokens: workTokens,
        module: rec.module || 'argos',
        refId: rid,
        ref: `Backfill Work from Report (${rec.channel || 'unknown'}): ${normaliseText(rec.ref).substring(0, 60)}`,
        scope: 'work',
        channel: 'report_work_backfill'
      });

      existingWorkKeys.add(key);
      inserted += 1;
    });

    if (inserted > 0) {
      console.log(`[TOKENS] Backfill work desde report ledger: +${inserted} registros`);
    }
  } catch (error) {
    console.warn('[TOKENS] Fallo en backfill de work tokens desde report ledger:', error);
  }
}

function backfillWorkTokensFromFeed(): void {
  try {
    const feedPath = path.join(RUNTIME_DIR, 'views', 'ui_export', 'captain_feed.jsonl');
    const tokensPath = path.join(RUNTIME_DIR, 'events', 'argos.tokens.jsonl');
    if (!fs.existsSync(feedPath)) return;

    const excludedSources = new Set(['agent_reporting', 'autonomous_vocal_system', 'trilog', 'ui_chat', 'ui_deletion']);
    const existingKeys = new Set<string>();

    if (fs.existsSync(tokensPath)) {
      readTextFileSafe(tokensPath)
        .split('\n')
        .map((line) => line.trim())
        .filter((line) => line.startsWith('{'))
        .forEach((line) => {
          try {
            const parsed = JSON.parse(line) as TokenRecord;
            const key = `${normaliseText(parsed.timestamp)}|${normaliseText(parsed.agent)}|${String((parsed as any).tokens ?? '')}|${normaliseText(parsed.refId)}|${normaliseText(parsed.channel)}`;
            existingKeys.add(key);
          } catch {
            // ignore malformed lines
          }
        });
    }

    let inserted = 0;
    readTextFileSafe(feedPath)
      .split('\n')
      .map((line) => line.trim())
      .filter((line) => line.startsWith('{'))
      .forEach((line) => {
        try {
          const feedRecord = JSON.parse(line) as CaptainFeedRecord;
          const senderRole = normaliseText(feedRecord.sender_role).toLowerCase();
          if (senderRole !== 'agent') return;

          const source = normaliseText(feedRecord.source).toLowerCase();
          if (excludedSources.has(source)) return;

          const canonicalAgent = normalizeAgentName(normaliseText(feedRecord.sender_name));
          if (!canonicalAgent) return;

          const numericTokens = Number(feedRecord.tokens) || 0;
          if (numericTokens <= 0) return;

          const ts = normaliseText(feedRecord.timestamp);
          const refId = normaliseText(feedRecord.refId);
          const dedupKey = `${ts}|${canonicalAgent}|${numericTokens}|${refId}|feed_backfill`;
          if (existingKeys.has(dedupKey)) return;

          appendJsonlRecord(tokensPath, {
            timestamp: ts || new Date().toISOString(),
            agent: canonicalAgent,
            tokens: numericTokens,
            module: 'argos',
            refId,
            ref: `Backfill Feed (${source}): ${normaliseText(feedRecord.summary).substring(0, 60)}`,
            scope: 'work',
            channel: 'feed_backfill'
          });
          existingKeys.add(dedupKey);
          inserted += 1;
        } catch {
          // ignore malformed lines
        }
      });

    if (inserted > 0) {
      console.log(`[TOKENS] Backfill work desde captain_feed: +${inserted} registros`);
    }
  } catch (error) {
    console.warn('[TOKENS] Fallo en backfill de work tokens desde feed:', error);
  }
}

// â”€â”€ Estado de IAs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Eliminado normaliseAgentName por redundancia. Usar normalizeAgentName.

type IaAgentStatus = { status: 'active' | 'standby' | 'restricted'; task: string; task_subject: string; since: string };
type IaStatusMap = { Claude: IaAgentStatus; Antigravity: IaAgentStatus; Codex: IaAgentStatus; DeepSeek: IaAgentStatus };

function defaultIaStatus(): IaStatusMap {
  const blank = (): IaAgentStatus => ({ status: 'standby', task: '', task_subject: '', since: '' });
  return { Claude: blank(), Antigravity: blank(), Codex: blank(), DeepSeek: blank() };
}

function readIaStatus(state: Record<string, unknown>): IaStatusMap {
  const raw = state.ia_status as Partial<IaStatusMap> | undefined;
  const d = defaultIaStatus();
  if (!raw) return d;
  return {
    Claude:      { ...d.Claude,      ...(raw.Claude      || {}) },
    Antigravity: { ...d.Antigravity, ...(raw.Antigravity || {}) },
    Codex:       { ...d.Codex,       ...(raw.Codex       || {}) },
    DeepSeek:    { ...d.DeepSeek,    ...(raw.DeepSeek    || {}) }
  };
}

function setIaActive(actor: string, packetId: string, subject: string): void {
  const agent = normalizeAgentName(actor);
  if (!agent) return;
  const state = readArgosState();
  const ia = readIaStatus(state);
  ia[agent] = { status: 'active', task: packetId, task_subject: subject, since: new Date().toISOString() };
  (state as Record<string, unknown>).ia_status = ia;
  writeArgosState(state);
}

function setIaStandby(actor: string): void {
  const agent = normalizeAgentName(actor);
  if (!agent) return;
  const state = readArgosState();
  const ia = readIaStatus(state);
  ia[agent] = { status: 'standby', task: '', task_subject: '', since: new Date().toISOString() };
  (state as Record<string, unknown>).ia_status = ia;
  writeArgosState(state);
}

// --- HITL SAFEGUARD LOGIC ---

function isAgentRestricted(actor: string): boolean {
  const state = readArgosState();
  const restricted = state.security?.restricted_agents || [];
  const normalized = normalizeAgentName(actor);
  return restricted.includes(normalized);
}

// Comprueba si un agente está marcado como 'restricted' en ia_status.
// Usado para silenciar mensajes de feed en nombre de agentes sin tokens.
function isVoiceRestricted(voice: string): boolean {
  const agent = normalizeAgentName(voice);
  if (!agent) return false;
  const iaStatus = readIaStatus(readArgosState());
  const status = iaStatus[agent]?.status;
  console.log(`[DEBUG-VOCAL] Checking restriction for ${agent} (from ${voice}): ${status}`);
  return status === 'restricted';
}

function interceptAction(req: Request, res: Response, actionType: string, executeFn: () => void) {
  const actor = req.body.actor || 'Unknown';
  if (isAgentRestricted(actor)) {
    const pendingAction = {
      id: `ACT-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
      timestamp: new Date().toISOString(),
      actor,
      action: actionType,
      payload: req.body
    };
    
    if (!fs.existsSync(path.dirname(PENDING_ACTIONS_PATH))) {
      fs.mkdirSync(path.dirname(PENDING_ACTIONS_PATH), { recursive: true });
    }
    
    appendJsonlRecord(PENDING_ACTIONS_PATH, pendingAction);
    
    const state = readArgosState();
    if (!state.security) state.security = { hitl_enabled: true, restricted_agents: ['DeepSeek'], has_pending_actions: false };
    state.security.has_pending_actions = true;
    writeArgosState(state);
    
    console.log(`[SAFEGUARD] Acción interceptada de ${actor}: ${actionType}`);
    return res.status(202).json({ 
      status: 'pending_approval', 
      message: 'Acción interceptada por protocolo HITL. Requiere aprobación del Capitán.',
      actionId: pendingAction.id 
    });
  }
  
  // Si no está restringido, ejecutar normalmente
  executeFn();
}
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

function readTextFileSafe(filePath: string): string {
  try {
    if (!fs.existsSync(filePath)) return '';
    const raw = fs.readFileSync(filePath, 'utf-8');
    return raw.charCodeAt(0) === 0xfeff ? raw.slice(1) : raw;
  } catch (error) {
    return '';
  }
}

function readTextFile(filePath: string, fallback = ''): string {
  return fs.existsSync(filePath) ? fs.readFileSync(filePath, 'utf-8') : fallback;
}

function readJsonFile<T>(filePath: string, fallback: T): T {
  if (!fs.existsSync(filePath)) return fallback;

  try {
    const raw = fs.readFileSync(filePath, 'utf-8');
    // Some runtime exports are UTF-8 with BOM; strip it to keep JSON.parse stable.
    const cleaned = raw.charCodeAt(0) === 0xfeff ? raw.slice(1) : raw;
    return JSON.parse(cleaned) as T;
  } catch (error) {
    return fallback;
  }
}

function writeJsonFileSafe(filePath: string, payload: unknown): void {
  ensureDirSync(path.dirname(filePath));
  fs.writeFileSync(filePath, JSON.stringify(payload, null, 2), 'utf-8');
}

function nowIso(): string {
  return new Date().toISOString();
}

function simpleHash(raw: string): string {
  let h = 2166136261;
  for (let i = 0; i < raw.length; i++) {
    h ^= raw.charCodeAt(i);
    h = Math.imul(h, 16777619);
  }
  return (h >>> 0).toString(16);
}

function defaultDesktopSourcesConfig(): DesktopSourcesConfig {
  return {
    version: 1,
    updated_at: nowIso(),
    notes: 'Define aqui rutas locales sincronizadas desde Drive para lectura de transcripts/tokens por app desktop.',
    sources: [
      {
        id: 'codex',
        enabled: true,
        rootPath: 'C:/Users/Widox/Desktop/ARGOS_DESKTOP_SHARED/Codex',
        transcriptGlobs: ['**/*transcript*.md', '**/*transcript*.json', '**/*.chat.jsonl'],
        tokenGlobs: ['**/*token*.jsonl', '**/*usage*.json', '**/*ledger*.jsonl'],
        parser: 'generic',
        agentName: 'Codex',
        owner: 'Antigravity',
        timezone: 'Atlantic/Canary'
      },
      {
        id: 'claude',
        enabled: true,
        rootPath: 'C:/Users/Widox/Desktop/ARGOS_DESKTOP_SHARED/Claude',
        transcriptGlobs: ['**/*transcript*.md', '**/*conversation*.json', '**/*.jsonl'],
        tokenGlobs: ['**/*token*.jsonl', '**/*usage*.json', '**/*ledger*.jsonl'],
        parser: 'generic',
        agentName: 'Claude',
        owner: 'Antigravity',
        timezone: 'Atlantic/Canary'
      },
      {
        id: 'antigravity',
        enabled: true,
        rootPath: 'C:/Users/Widox/Desktop/ARGOS_DESKTOP_SHARED/Antigravity',
        transcriptGlobs: ['**/*transcript*.md', '**/*chat*.jsonl', '**/*conversation*.json'],
        tokenGlobs: ['**/*token*.jsonl', '**/*usage*.json', '**/*ledger*.jsonl'],
        parser: 'generic',
        agentName: 'Antigravity',
        owner: 'Antigravity',
        timezone: 'Atlantic/Canary'
      },
      {
        id: 'openclaw',
        enabled: true,
        rootPath: 'C:/Users/Widox/Desktop/ARGOS_DESKTOP_SHARED/OpenClaw',
        transcriptGlobs: ['**/*transcript*.md', '**/*session*.json', '**/*.jsonl'],
        tokenGlobs: ['**/*token*.jsonl', '**/*usage*.json', '**/*eval*.json', '**/*webhook*.jsonl'],
        parser: 'generic',
        agentName: 'DeepSeek',
        owner: 'OpenClaw',
        timezone: 'Atlantic/Canary'
      }
    ]
  };
}

function loadDesktopSourcesConfig(): DesktopSourcesConfig {
  const fallback = defaultDesktopSourcesConfig();
  if (!fs.existsSync(DESKTOP_SOURCES_CONFIG_PATH)) {
    writeJsonFileSafe(DESKTOP_SOURCES_CONFIG_PATH, fallback);
    return fallback;
  }
  const cfg = readJsonFile<DesktopSourcesConfig>(DESKTOP_SOURCES_CONFIG_PATH, fallback);
  if (!Array.isArray(cfg.sources)) {
    writeJsonFileSafe(DESKTOP_SOURCES_CONFIG_PATH, fallback);
    return fallback;
  }
  return cfg;
}

function saveDesktopSourcesConfig(config: DesktopSourcesConfig): void {
  writeJsonFileSafe(DESKTOP_SOURCES_CONFIG_PATH, {
    ...config,
    updated_at: nowIso()
  });
}

function emptyDesktopIngestState(): DesktopIngestState {
  return {
    version: 1,
    updated_at: nowIso(),
    files: {},
    importedTokenKeys: [],
    importedTranscriptKeys: [],
    lastRun: {}
  };
}

function loadDesktopIngestState(): DesktopIngestState {
  const fallback = emptyDesktopIngestState();
  if (!fs.existsSync(DESKTOP_INGEST_STATE_PATH)) {
    writeJsonFileSafe(DESKTOP_INGEST_STATE_PATH, fallback);
    return fallback;
  }
  const loaded = readJsonFile<DesktopIngestState>(DESKTOP_INGEST_STATE_PATH, fallback);
  loaded.files = loaded.files || {};
  loaded.importedTokenKeys = Array.isArray(loaded.importedTokenKeys) ? loaded.importedTokenKeys : [];
  loaded.importedTranscriptKeys = Array.isArray(loaded.importedTranscriptKeys) ? loaded.importedTranscriptKeys : [];
  loaded.lastRun = loaded.lastRun || {};
  return loaded;
}

function saveDesktopIngestState(state: DesktopIngestState): void {
  const MAX_IMPORT_KEYS = 150000;
  if (state.importedTokenKeys.length > MAX_IMPORT_KEYS) {
    state.importedTokenKeys = state.importedTokenKeys.slice(state.importedTokenKeys.length - MAX_IMPORT_KEYS);
  }
  if (state.importedTranscriptKeys.length > MAX_IMPORT_KEYS) {
    state.importedTranscriptKeys = state.importedTranscriptKeys.slice(state.importedTranscriptKeys.length - MAX_IMPORT_KEYS);
  }
  state.updated_at = nowIso();
  writeJsonFileSafe(DESKTOP_INGEST_STATE_PATH, state);
}

function wildcardToRegex(pattern: string): RegExp {
  const normalized = pattern.replace(/\\/g, '/');
  const escaped = normalized.replace(/[.+^${}()|[\]\\]/g, '\\$&');
  const regexBody = escaped
    .replace(/\\\*\\\*/g, '.*')
    .replace(/\\\*/g, '[^/]*')
    .replace(/\\\?/g, '.');
  return new RegExp(`^${regexBody}$`, 'i');
}

function listFilesRecursive(rootPath: string, limit = 30000): string[] {
  if (!fs.existsSync(rootPath)) return [];
  const out: string[] = [];
  const stack = [rootPath];
  while (stack.length > 0 && out.length < limit) {
    const current = stack.pop()!;
    let items: fs.Dirent[] = [];
    try {
      items = fs.readdirSync(current, { withFileTypes: true });
    } catch {
      continue;
    }
    for (const item of items) {
      const full = path.join(current, item.name);
      if (item.isDirectory()) {
        stack.push(full);
        continue;
      }
      if (item.isFile()) out.push(full);
      if (out.length >= limit) break;
    }
  }
  return out;
}

function filesMatchingGlobs(rootPath: string, globs: string[]): string[] {
  if (!fs.existsSync(rootPath)) return [];
  const all = listFilesRecursive(rootPath);
  if (globs.length === 0) return all;
  const regexes = globs.map(wildcardToRegex);
  return all.filter((abs) => {
    const rel = path.relative(rootPath, abs).replace(/\\/g, '/');
    return regexes.some((rx) => rx.test(rel));
  });
}

function extractTimestampFromUnknown(input: unknown, fallbackIso: string): string {
  const raw = normaliseText(String(input ?? ''));
  if (raw === '') return fallbackIso;
  const parsed = Date.parse(raw);
  if (!Number.isNaN(parsed)) return new Date(parsed).toISOString();
  return fallbackIso;
}

function extractTokenTotalFromObject(obj: Record<string, unknown>): number {
  const directFields = [
    'tokens',
    'total_tokens',
    'totalTokenCount',
    'token_count',
    'tokenCount',
    'tokens_spent',
    'TOKENS_SPENT'
  ];
  for (const key of directFields) {
    const val = Number(obj[key] ?? 0);
    if (Number.isFinite(val) && val > 0) return Math.round(val);
  }

  const pairCandidates: Array<[string, string]> = [
    ['input_tokens', 'output_tokens'],
    ['inputTokens', 'outputTokens'],
    ['prompt_eval_count', 'eval_count'],
    ['promptTokens', 'completionTokens']
  ];
  for (const [a, b] of pairCandidates) {
    const x = Number(obj[a] ?? 0);
    const y = Number(obj[b] ?? 0);
    if (Number.isFinite(x) && Number.isFinite(y) && (x + y) > 0) return Math.round(x + y);
  }

  const usage = obj.usage as Record<string, unknown> | undefined;
  if (usage && typeof usage === 'object') {
    const nested = extractTokenTotalFromObject(usage);
    if (nested > 0) return nested;
  }

  return 0;
}

function parseTokenRecordsFromFile(filePath: string, source: DesktopSourceDefinition): Array<{ timestamp: string; tokens: number; ref: string; refId: string }> {
  const content = readTextFileSafe(filePath);
  if (content.trim() === '') return [];

  const fallbackIso = new Date(fs.statSync(filePath).mtimeMs).toISOString();
  const lines = content.split(/\r?\n/);
  const out: Array<{ timestamp: string; tokens: number; ref: string; refId: string }> = [];

  for (const lineRaw of lines) {
    const line = lineRaw.trim();
    if (line === '') continue;

    if (line.startsWith('{') && line.endsWith('}')) {
      try {
        const parsed = JSON.parse(line) as Record<string, unknown>;
        const tokens = extractTokenTotalFromObject(parsed);
        if (tokens > 0) {
          const timestamp = extractTimestampFromUnknown(parsed.timestamp ?? parsed.time ?? parsed.date ?? parsed.created_at, fallbackIso);
          const ref = normaliseText(String(parsed.ref ?? parsed.action ?? parsed.type ?? parsed.model ?? path.basename(filePath))).slice(0, 180) || path.basename(filePath);
          const refId = normaliseText(String(parsed.refId ?? parsed.packetId ?? parsed.packet_id ?? ''));
          out.push({ timestamp, tokens, ref, refId });
        }
        continue;
      } catch {
        // sigue con parseo regex
      }
    }

    const regexes = [
      /"total_tokens"\s*:\s*(\d+)/i,
      /"totalTokenCount"\s*:\s*(\d+)/i,
      /\bTOKENS_SPENT\s*[:=]\s*(\d+)/i,
      /\btokens?\s*[:=]\s*(\d+)/i
    ];
    for (const rx of regexes) {
      const match = line.match(rx);
      if (match) {
        const tokenVal = Number(match[1] || 0);
        if (tokenVal > 0) {
          out.push({
            timestamp: fallbackIso,
            tokens: Math.round(tokenVal),
            ref: `${source.id}:${path.basename(filePath)}`.slice(0, 180),
            refId: ''
          });
        }
        break;
      }
    }
  }

  // JSON de objeto/array completo cuando no era JSONL
  if (out.length === 0) {
    try {
      const parsed = JSON.parse(content) as unknown;
      const arr = Array.isArray(parsed) ? parsed : [parsed];
      arr.forEach((entry) => {
        if (!entry || typeof entry !== 'object') return;
        const rec = entry as Record<string, unknown>;
        const tokens = extractTokenTotalFromObject(rec);
        if (tokens <= 0) return;
        out.push({
          timestamp: extractTimestampFromUnknown(rec.timestamp ?? rec.time ?? rec.date ?? rec.created_at, fallbackIso),
          tokens,
          ref: normaliseText(String(rec.ref ?? rec.action ?? rec.type ?? path.basename(filePath))).slice(0, 180) || path.basename(filePath),
          refId: normaliseText(String(rec.refId ?? rec.packetId ?? rec.packet_id ?? ''))
        });
      });
    } catch {
      // no-op
    }
  }

  return out;
}

function sanitiseRelativePath(rawPath: string): string {
  return rawPath
    .replace(/\\/g, '/')
    .split('/')
    .map((chunk) => chunk.replace(/[^a-zA-Z0-9._-]/g, '_'))
    .join('/');
}

function markImportedKey(list: string[], key: string): boolean {
  if (list.includes(key)) return false;
  list.push(key);
  return true;
}

function runDesktopImport(mode: 'tokens' | 'transcripts' | 'all', actor = 'OpenClaw/Antigravity'): DesktopImportRunSummary {
  const startedAt = nowIso();
  const config = loadDesktopSourcesConfig();
  const state = loadDesktopIngestState();
  const enabledSources = config.sources.filter((s) => s.enabled);

  const summary: DesktopImportRunSummary = {
    startedAt,
    finishedAt: startedAt,
    mode,
    actor,
    sources: enabledSources.length,
    tokenFilesScanned: 0,
    tokensImported: 0,
    transcriptFilesScanned: 0,
    transcriptsMirrored: 0,
    errors: 0,
    warnings: []
  };

  state.lastRun.startedAt = startedAt;
  state.lastRun.mode = mode;
  state.lastRun.actor = actor;

  enabledSources.forEach((source) => {
    if (!fs.existsSync(source.rootPath)) {
      summary.warnings.push(`[${source.id}] Ruta no existe: ${source.rootPath}`);
      return;
    }

    if (mode === 'tokens' || mode === 'all') {
      const tokenFiles = filesMatchingGlobs(source.rootPath, source.tokenGlobs);
      summary.tokenFilesScanned += tokenFiles.length;

      tokenFiles.forEach((filePath) => {
        try {
          const stat = fs.statSync(filePath);
          const raw = readTextFileSafe(filePath);
          const hash = simpleHash(raw);
          const stateKey = `token:${filePath}`;
          const prev = state.files[stateKey];
          if (prev && prev.mtimeMs === stat.mtimeMs && prev.size === stat.size && prev.hash === hash) return;

          const rows = parseTokenRecordsFromFile(filePath, source);
          rows.forEach((row, idx) => {
            const key = simpleHash(`${source.id}|${filePath}|${row.timestamp}|${row.tokens}|${row.ref}|${row.refId}|${idx}`);
            if (!markImportedKey(state.importedTokenKeys, key)) return;
            appendJsonlRecord(ARGOS_TOKENS_PATH, {
              timestamp: row.timestamp,
              agent: normalizeAgentName(source.agentName) || source.agentName,
              tokens: row.tokens,
              module: 'desktop_import',
              refId: row.refId,
              ref: `Desktop ${source.id}: ${row.ref}`.slice(0, 200),
              scope: 'work',
              channel: `desktop:${source.id}`
            });
            summary.tokensImported += 1;
          });

          state.files[stateKey] = {
            mtimeMs: stat.mtimeMs,
            size: stat.size,
            hash,
            importedAt: nowIso()
          };
        } catch (error) {
          summary.errors += 1;
          summary.warnings.push(`[${source.id}] Error tokens ${filePath}: ${String(error)}`);
        }
      });
    }

    if (mode === 'transcripts' || mode === 'all') {
      const transcriptFiles = filesMatchingGlobs(source.rootPath, source.transcriptGlobs);
      summary.transcriptFilesScanned += transcriptFiles.length;

      transcriptFiles.forEach((filePath) => {
        try {
          const stat = fs.statSync(filePath);
          const raw = readTextFileSafe(filePath);
          const hash = simpleHash(raw);
          const rel = sanitiseRelativePath(path.relative(source.rootPath, filePath));
          const destination = path.join(EXTERNAL_TRANSCRIPTS_DIR, source.id, rel);
          const stateKey = `transcript:${filePath}`;
          const prev = state.files[stateKey];
          if (prev && prev.mtimeMs === stat.mtimeMs && prev.size === stat.size && prev.hash === hash) return;

          ensureDirSync(path.dirname(destination));
          fs.writeFileSync(destination, raw, 'utf-8');

          const transcriptKey = simpleHash(`${source.id}|${filePath}|${hash}`);
          if (markImportedKey(state.importedTranscriptKeys, transcriptKey)) {
            appendJsonlRecord(ARGOS_EVENTS_PATH, {
              timestamp: nowIso(),
              actor: normalizeAgentName(source.agentName) || source.agentName,
              module: 'desktop_import',
              type: 'external_transcript_mirrored',
              status: 'done',
              summary: `Transcript externo espejo (${source.id})`,
              details: `${filePath} -> ${destination}`,
              source: 'desktop-import'
            });
          }

          summary.transcriptsMirrored += 1;
          state.files[stateKey] = {
            mtimeMs: stat.mtimeMs,
            size: stat.size,
            hash,
            importedAt: nowIso()
          };
        } catch (error) {
          summary.errors += 1;
          summary.warnings.push(`[${source.id}] Error transcript ${filePath}: ${String(error)}`);
        }
      });
    }
  });

  summary.finishedAt = nowIso();
  state.lastRun.finishedAt = summary.finishedAt;
  state.lastRun.summary = {
    sources: summary.sources,
    tokenFilesScanned: summary.tokenFilesScanned,
    tokensImported: summary.tokensImported,
    transcriptFilesScanned: summary.transcriptFilesScanned,
    transcriptsMirrored: summary.transcriptsMirrored,
    errors: summary.errors,
    warnings: summary.warnings
  };
  saveDesktopIngestState(state);
  publishEvent('desktop-import:updated', {
    mode: summary.mode,
    actor: summary.actor,
    tokensImported: summary.tokensImported,
    transcriptsMirrored: summary.transcriptsMirrored,
    errors: summary.errors,
    timestamp: summary.finishedAt
  });
  return summary;
}

function findArchivedFiles(filename: string, dirPath: string = SESSION_ARCHIVE_ROOT): string[] {
  const results: string[] = [];
  try {
    if (!fs.existsSync(dirPath)) return results;
    const items = fs.readdirSync(dirPath, { withFileTypes: true });
    for (const item of items) {
      const fullPath = path.join(dirPath, item.name);
      if (item.isDirectory()) {
        results.push(...findArchivedFiles(filename, fullPath));
      } else if (item.name === filename) {
        results.push(fullPath);
      }
    }
  } catch (error) {
    // Ignore errors for unreadable dirs
  }
  return results;
}

// ── Dedup cache: prevents identical records being written within the TTL window ──
// key = filePath + : + dedup_key -> value = timestamp (ms) of last write
const dedupCache = new Map<string, number>();
const DEDUP_TTL_MS = 8000;       // 8 s for general records
const DEDUP_HEARTBEAT_TTL_MS = 4 * 60 * 1000; // 4 min for heartbeats

function appendJsonlRecord(filePath: string, record: object): void {
  const rec = record as Record<string, unknown>;
  const now = Date.now();
  const isHeartbeat = rec.kind === 'system_heartbeat';
  const dedupKind = String(rec.kind ?? rec.type ?? '');
  const dedupActor = String(rec.agent ?? rec.sender_name ?? rec.actor ?? '');
  const dedupSummary = String(rec.summary ?? '').substring(0, 120);
  const dedupDetails = String(rec.details ?? rec.verification ?? '').substring(0, 120);
  const dedupRefId = String(rec.refId ?? rec.packet_id ?? '');
  const dedupTimestamp = String(rec.timestamp ?? rec.timestamp_label ?? '');
  const dedupFingerprint =
    (dedupKind !== '' || dedupSummary !== '')
      ? `${dedupKind}:${dedupActor}:${dedupSummary}:${dedupDetails}:${dedupRefId}:${dedupTimestamp}`
      : `${dedupActor}:${String(rec.tokens ?? '')}:${String(rec.ref ?? '')}:${dedupRefId}:${String(rec.module ?? '')}:${String(rec.channel ?? '')}:${dedupTimestamp}`;
  const dedupKey = `${filePath}:${dedupFingerprint}`;
  const ttl = isHeartbeat ? DEDUP_HEARTBEAT_TTL_MS : DEDUP_TTL_MS;
  const lastWrite = dedupCache.get(dedupKey) ?? 0;
  if (now - lastWrite < ttl) return;
  dedupCache.set(dedupKey, now);

  // SanitizaciÃ³n de codificaciÃ³n: Convertir a UTF-8 limpio
  const serialised = JSON.stringify(record);
  
  try {
    // Si el archivo existe, nos aseguramos de que termine en newline para no romper el JSONL
    if (fs.existsSync(filePath) && fs.statSync(filePath).size > 0) {
      const tail = readFileTail(filePath, 4);
      const endsWithNewline = tail.includes('\n');
      const separator = endsWithNewline ? '' : '\n';
      fs.appendFileSync(filePath, `${separator}${serialised}\n`, 'utf-8');
    } else {
      // Crear archivo nuevo (asegurando UTF-8 sin BOM)
      fs.writeFileSync(filePath, `${serialised}\n`, 'utf-8');
    }
  } catch (e) {
    console.error(`[FS] Error escribiendo en ${filePath}`, e);
  }
}

function recordTokensInternal(
  agent: string,
  tokens: number,
  ref: string,
  refId: string = '',
  scope: 'work' | 'report' = 'work'
): void {
  if (tokens <= 0) return;
  const record: TokenRecord = {
    timestamp: new Date().toISOString(),
    agent,
    tokens,
    ref,
    module: 'argos',
    refId,
    scope,
    channel: 'proxy',
  };
  appendJsonlRecord(ARGOS_TOKENS_PATH, record);
  publishEvent('tokens:updated', {
    agent: normalizeAgentName(agent) || agent,
    tokens,
    scope,
  });
}

function composeShadowNote(params: {
  shadow: unknown;
  discarded: unknown;
  ignored: unknown;
  suppressed: unknown;
  errors: unknown;
  details: unknown;
}): string {
  const explicitShadow = normaliseText(params.shadow);
  if (explicitShadow !== '') return explicitShadow;

  const lines: string[] = [];
  const discarded = normaliseText(params.discarded);
  const ignored = normaliseText(params.ignored);
  const suppressed = normaliseText(params.suppressed);
  const errors = normaliseText(params.errors);
  const details = normaliseText(params.details);

  if (discarded !== '') lines.push(`Descartado: ${discarded}`);
  if (ignored !== '') lines.push(`Ignorado: ${ignored}`);
  if (suppressed !== '') lines.push(`Suprimido: ${suppressed}`);
  if (errors !== '') lines.push(`Aprendizajes: ${errors}`);

  if (lines.length > 0) return lines.join('\n');
  if (details !== '') return `Observación no priorizada en LOG: ${details}`;
  return 'Cierre de sesión registrado via /api/trilog. Sin observaciones adicionales.';
}

/** Read last `bytes` bytes of a file without loading the whole thing. */
function readFileTail(filePath: string, bytes: number): string {
  try {
    const stat = fs.statSync(filePath);
    const start = Math.max(0, stat.size - bytes);
    const fd = fs.openSync(filePath, 'r');
    const buf = Buffer.alloc(Math.min(bytes, stat.size));
    fs.readSync(fd, buf, 0, buf.length, start);
    fs.closeSync(fd);
    return buf.toString('utf-8');
  } catch {
    return '';
  }
}

function getNextGlitchId(): string {
  const raw = readTextFileSafe(ARGOS_GLITCHES_PATH);
  if (raw === '') return 'G-001';

  let maxId = 0;
  raw
    .split('\n')
    .map((line) => line.trim())
    .filter((line) => line !== '')
    .forEach((line) => {
      try {
        const parsed = JSON.parse(line) as Record<string, unknown>;
        const match = normaliseText(parsed.id).match(/^G-(\d+)$/i);
        if (!match) return;
        const numeric = Number(match[1]);
        if (Number.isFinite(numeric)) maxId = Math.max(maxId, numeric);
      } catch {
        // Ignore malformed entries.
      }
    });

  return `G-${String(maxId + 1).padStart(3, '0')}`;
}

function normalisePacketId(raw: unknown): string {
  return normaliseText(raw).toUpperCase();
}

function hasPacketIdInMarkdownLane(filePath: string, packetId: string): boolean {
  const needle = normalisePacketId(packetId);
  if (needle === '') return false;
  const content = readTextFileSafe(filePath);
  if (content === '') return false;

  const tagRegexes = [
    /\*\*WORK\s*PACKET(?:\s*ID)?\s*:\*\*\s*([A-Z0-9-]+)/gi,
    /\*\*PACKET\s*:\*\*\s*([A-Z0-9-]+)/gi
  ];

  for (const tagRegex of tagRegexes) {
    let match: RegExpExecArray | null = tagRegex.exec(content);
    while (match) {
      if (normalisePacketId(match[1]) === needle) return true;
      match = tagRegex.exec(content);
    }
  }

  return false;
}

function hasPacketIdInEventsLane(packetId: string): boolean {
  const needle = normalisePacketId(packetId);
  if (needle === '') return false;

  const lines = readTextFileSafe(ARGOS_EVENTS_PATH)
    .split('\n')
    .map((line) => line.trim())
    .filter((line) => line.startsWith('{'));

  for (const line of lines) {
    try {
      const parsed = JSON.parse(line) as Record<string, unknown>;
      const summaryAndDetails = [
        normaliseText(parsed.summary),
        normaliseText(parsed.details),
        normaliseText(parsed.verification),
        normaliseText(parsed.next_step),
        normaliseText(parsed.nextStep)
      ].join(' ');
      const candidates = [
        normalisePacketId(parsed.packet_id),
        normalisePacketId(parsed.packetId),
        normalisePacketId(parsed.refId),
        normalisePacketId(extractPacketIdFromArtifacts(parsed.artifacts)),
        normalisePacketId(extractPacketId(summaryAndDetails))
      ].filter((candidate) => candidate !== '');
      if (candidates.includes(needle)) return true;
    } catch {
      // Ignora lineas corruptas para no bloquear el guard.
    }
  }

  return false;
}

function hasPacketIdInTranscriptLane(packetId: string): boolean {
  const needle = normalisePacketId(packetId);
  if (needle === '') return false;
  
  const transcriptDir = path.join(RUNTIME_DIR, 'transcripts');
  if (!fs.existsSync(transcriptDir)) return false;

  const files = fs.readdirSync(transcriptDir).filter(f => f.endsWith('.md'));
  for (const file of files) {
    const content = fs.readFileSync(path.join(transcriptDir, file), 'utf-8');
    // Busca <!-- ID --> o el ID pelado
    if (content.includes(`<!-- ${needle} -->`) || content.includes(`Packet: ${needle}`)) {
      return true;
    }
  }
  return false;
}

function getTriLogMissingLanes(packetId: string): string[] {
  const id = normaliseText(packetId);
  if (id === '') return ['LOG', 'EVENTS', 'SHADOW', 'TRANSCRIPT'];

  const hasLog = hasPacketIdInMarkdownLane(ARGOS_GLOBAL_LOG_PATH, id);
  const hasEvents = hasPacketIdInEventsLane(id);
  const hasShadow = hasPacketIdInMarkdownLane(ARGOS_GLOBAL_SHADOW_PATH, id);
  const hasTranscript = hasPacketIdInTranscriptLane(id);

  const missing: string[] = [];
  if (!hasLog) missing.push('LOG');
  if (!hasEvents) missing.push('EVENTS');
  if (!hasShadow) missing.push('SHADOW');
  if (!hasTranscript) missing.push('TRANSCRIPT');
  return missing;
}

function ensureAntigravityProtocolPacketExists(): void {
  if (fs.existsSync(ANTIGRAVITY_PROTO_PACKET_PATH)) return;
  // No recrear si ya estÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡ resuelto en done/
  const donePacketPath = path.join(RUNTIME_DIR, 'work_packets', 'done', ANTIGRAVITY_PROTO_PACKET_NAME);
  if (fs.existsSync(donePacketPath)) return;

  const timestamp = new Date().toISOString();
  const content = `[WORK_PACKET]
ID: ARG-PROTO-AG-001
TYPE: note
TAG: protocol, antigravity, calibration
PRIORITY: P1
ROLE_REQUESTED: ANTIGRAVITY
SUBJECT: Ritual de cierre Tri-Log obligatorio tras cada sesion
STATUS: open
CREATED_AT: ${timestamp}
CREATED_BY: Argos Dispatcher
TOKENS_SPENT: 0

OBJECTIVE:
Reforzar disciplina de cierre para Antigravity. Ningun paquete puede cerrarse sin Tri-Log completo y Registro de Transcripcion Literal.

ACCIONES REQUERIDAS:
1. Registrar transcripcion literal en transcripts/YYYY-MM-DD_AGENTE.md (via /api/transcript).
2. Registrar cierre en ARGOS_GLOBAL_LOG.md (LOG lane).
3. Registrar evento estructurado en events/argos.events.jsonl (EVENTS lane).
4. Registrar sombra en ARGOS_GLOBAL_SHADOW_LOG.md (SHADOW lane).
5. Sincronizar state despues del cierre.
[/WORK_PACKET]
`;

  try {
    fs.writeFileSync(ANTIGRAVITY_PROTO_PACKET_PATH, content, 'utf-8');
  } catch (error) {
    console.warn('[TRILOG-GUARD] No se pudo crear ARG-PROTO-AG-001:', error);
  }
}

function recordTriLogViolation(packetId: string, subject: string, owner: string, missingLanes: string[]): void {
  const missing = missingLanes.join(', ');
  const now = new Date();
  const isoTs = now.toISOString();
  const canaryTs = now
    .toLocaleString('sv-SE', {
      timeZone: 'Atlantic/Canary',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
    .slice(0, 16);
  const glitchId = getNextGlitchId();
  const canonicalOwner = normalizeAgentName(owner) || owner || 'Sistema';
  const details = `Lane(s) ausentes: ${missing}. Owner detectado: ${canonicalOwner}. Subject: ${subject}`;
  const nextStep = 'Registrar cierre via /api/trilog con packetId y verificar LOG + EVENTS + SHADOW.';

  appendJsonlRecord(ARGOS_GLITCHES_PATH, {
    id: glitchId,
    timestamp: isoTs,
    timestamp_label: canaryTs,
    actor: 'Dispatcher',
    module: 'argos_trilog_guard',
    type: 'trilog_violation',
    status: 'open',
    summary: `TriLog incompleto en ${packetId}`,
    details,
    next_step: nextStep,
    packet_id: packetId,
    refId: packetId,
    owner: canonicalOwner,
    missing_lanes: missingLanes,
    source: 'dispatcher:trilog_guard'
  });

  const glitchEntry =
    `\n---\n` +
    `**[${canaryTs} Atlantic/Canary] ${glitchId} | TRILOG GUARD:**\n` +
    `**WORK PACKET:** ${packetId}\n` +
    `**TIPO:** TriLog incompleto\n` +
    `**ESTADO:** open\n` +
    `**OWNER:** ${canonicalOwner}\n` +
    `**DETALLE:** ${details}\n` +
    `**SIGUIENTE:** ${nextStep}\n`;

  const existingGlitchLog = fs.existsSync(ARGOS_GLOBAL_GLITCH_PATH)
    ? fs.readFileSync(ARGOS_GLOBAL_GLITCH_PATH, 'utf-8')
    : '# ARGOS GLOBAL GLITCH LOG\nRegistro estructural de fallas sistemicas.\n';
  fs.writeFileSync(ARGOS_GLOBAL_GLITCH_PATH, existingGlitchLog + glitchEntry, 'utf-8');

  console.info(`[TRILOG-GUARD] ${packetId} cerrado sin lanes: ${missing}. Owner: ${canonicalOwner}. Subject: ${subject}. Glitch: ${glitchId}`);
  publishEvent('glitch:recorded', { id: glitchId, packetId, missingLanes, owner: canonicalOwner });
}

type ScriptRunResult = {
  ok: boolean;
  code: number | null;
  stdout: string;
  stderr: string;
};

let logbookRefreshInFlight = false;
let lastLogbookRefreshAttemptMs = 0;

function runPowerShellScript(scriptName: string, timeoutMs: number): ScriptRunResult {
  const scriptPath = path.join(TOOLS_DIR, scriptName);
  if (!fs.existsSync(scriptPath)) {
    return {
      ok: false,
      code: -1,
      stdout: '',
      stderr: `No existe ${scriptPath}`
    };
  }

  const result = spawnSync(
    'powershell.exe',
    ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', scriptPath, '-RuntimeDir', RUNTIME_DIR],
    { encoding: 'utf-8', timeout: timeoutMs, windowsHide: true }
  );

  return {
    ok: result.status === 0,
    code: result.status,
    stdout: (result.stdout || '').trim(),
    stderr: [result.stderr || '', result.error ? result.error.message : ''].filter(Boolean).join(' | ').trim()
  };
}

function runSyncState(): ScriptRunResult {
  try {
    const statePath = path.join(RUNTIME_DIR, 'state', 'argos.state.json');
    const workPacketsDir = path.join(RUNTIME_DIR, 'work_packets');
    
    // 1. Cargar estado actual
    const defaultState = {
      module: 'argos_core',
      updated_at: new Date().toISOString(),
      current_focus: '',
      status: 'active',
      open_packets: [] as string[],
      in_progress_packets: [] as string[],
      active_risks: [] as string[],
      next_step: '',
      owner_hint: 'Codex / Antigravity / Capitan',
      done_packets_summary: { total: 0, tasks: 0, bugs: 0, latest_ids: [] as string[] }
    };
    const state = readJsonFile<any>(statePath, defaultState);

    // 2. Escaneo de zonas
    const getPackets = (zone: string) => {
      const zonePath = path.join(workPacketsDir, zone);
      if (!fs.existsSync(zonePath)) return [];
      return fs.readdirSync(zonePath)
        .filter(f => f.endsWith('.md') && !f.includes('__RESULTADO'))
        .map(f => {
          const content = fs.readFileSync(path.join(zonePath, f), 'utf-8');
          if (!content.includes('[WORK_PACKET]')) return null;
          const id = (content.match(/^ID:\s*(.+)$/m) || [])[1]?.trim() || f.replace('.md', '');
          const type = (content.match(/^TYPE:\s*(.+)$/m) || [])[1]?.trim()?.toLowerCase() || 'task';
          const tag = (content.match(/^TAG:\s*(.+)$/m) || [])[1]?.trim()?.toLowerCase() || '';
          return { id, isBug: type === 'bug' || tag === 'bug' };
        })
        .filter((p): p is { id: string, isBug: boolean } => p !== null);
    };

    const inbox = getPackets('inbox');
    const inProgress = getPackets('in_progress');
    const done = getPackets('done');

    const openPackets = [...new Set(inbox.filter(p => !p.isBug).map(p => p.id))];
    const inProgressPackets = [...new Set(inProgress.map(p => p.id))];
    const doneAll = [...new Set(done.map(p => p.id))];
    const doneTasks = [...new Set(done.filter(p => !p.isBug).map(p => p.id))];
    const doneBugs = [...new Set(done.filter(p => p.isBug).map(p => p.id))];

    // 3. Actualizar objeto state
    state.updated_at = new Date().toISOString();
    state.open_packets = openPackets;
    state.in_progress_packets = inProgressPackets;
    state.done_packets_summary = {
      total: doneAll.length,
      tasks: doneTasks.length,
      bugs: doneBugs.length,
      latest_ids: doneAll.slice(-10)
    };

    // 4. Escribir Atomicamente (o casi)
    fs.writeFileSync(statePath, JSON.stringify(state, null, 2), 'utf-8');

    return {
      ok: true,
      code: 0,
      stdout: `Native sync complete. ${openPackets.length} open, ${inProgressPackets.length} in_progress.`,
      stderr: ''
    };
  } catch (e) {
    return {
      ok: false,
      code: 1,
      stdout: '',
      stderr: String(e)
    };
  }
}

function runMergeHistory(): ScriptRunResult {
  try {
    const historyDir = path.join(RUNTIME_DIR, 'views', 'history_export');
    const historyTimelinePath = path.join(historyDir, 'argos.timeline.jsonl');
    const historyMarkdownPath = path.join(historyDir, 'ARGOS_CANONICAL_HISTORY.md');
    const historyManifestPath = path.join(historyDir, 'current_history_manifest.json');
    
    if (!fs.existsSync(historyDir)) fs.mkdirSync(historyDir, { recursive: true });

    const timeline: any[] = [];
    const timelineIndex = new Set<string>();

    const addEntry = (entry: any, stream: string) => {
      const ts = entry.timestamp_label || entry.timestamp || '';
      const actor = entry.actor || '';
      const summary = (entry.summary || '').toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim();
      const key = `${stream}|${ts}|${actor}|${summary}`;
      if (timelineIndex.has(key)) return;
      timelineIndex.add(key);
      timeline.push({ ...entry, stream });
    };

    // 1. Absorber Legacy Data (de legacy_history_data.ts)
    manualDraftGlobals.forEach(e => addEntry(e, 'global'));
    manualDraftShadows.forEach(e => addEntry(e, 'shadow'));
    legacyGlitches.forEach(e => addEntry(e, 'glitch'));
    lateRuntimeGlobals.forEach(e => addEntry(e, 'global'));
    lateRuntimeShadows.forEach(e => addEntry(e, 'shadow'));

    // 2. Leer Logbook actual
    const logbook = readJsonFile<LogbookSnapshot>(LOGBOOK_SNAPSHOT_PATH, buildEmptyLogbook());
    logbook.modules?.forEach(mod => {
      if (mod.id !== 'argos') return;
      mod.streams?.forEach(stream => {
        const mapped = stream.id === 'log' ? 'global' : (stream.id === 'interactions' ? 'interaction' : (stream.id === 'shadow' ? 'shadow' : null));
        if (!mapped) return;
        stream.entries?.forEach(e => addEntry(e, mapped));
      });
    });

    // 3. Procesar ARGOS_GLOBAL_LOG.md vivo
    if (fs.existsSync(ARGOS_GLOBAL_LOG_PATH)) {
      const content = fs.readFileSync(ARGOS_GLOBAL_LOG_PATH, 'utf-8');
      const blocks = content.split(/\n---/).map(b => b.trim()).filter(b => b.length > 0);
      blocks.forEach(block => {
        const tsMatch = block.match(/\[(\d{4}[-/\.]\d{1,2}[-/\.]\d{1,2}(?:\s+\d{2}:\d{2})?.*?)\]/);
        if (tsMatch) {
          const tsLabel = tsMatch[1];
          const actorMatch = block.match(/VOZ\s+([^:\n\*]+)/) || block.match(/ACTOR\s*:\s*([^:\n\*]+)/);
          const actor = actorMatch ? actorMatch[1].trim() : 'Sistema';
          const summaryMatch = block.match(/(?:ACCION|ACCIÓN|MISION|MISIÓN|MISSION|SUBJECT)\s*[:\*]+\s*([^:\n\*]+)/);
          const summary = summaryMatch ? summaryMatch[1].trim() : 'Registro';
          addEntry({ timestamp_label: tsLabel, actor, summary, status: 'done', source: 'ARGOS_GLOBAL_LOG.md' }, 'global');
        }
      });
    }

    // 4. Procesar work_packets/done
    const doneDir = path.join(RUNTIME_DIR, 'work_packets', 'done');
    if (fs.existsSync(doneDir)) {
      const files = fs.readdirSync(doneDir).filter(f => f.endsWith('.md'));
      files.forEach(f => {
        const content = fs.readFileSync(path.join(doneDir, f), 'utf-8');
        const tsMatch = content.match(/COMPLETED_AT:\s*(\d{4}-\d{2}-\d{2}(?:T|\s+)\d{2}:\d{2})/);
        const ts = tsMatch ? tsMatch[1] : fs.statSync(path.join(doneDir, f)).mtime.toISOString().slice(0, 16).replace('T', ' ');
        const actorMatch = content.match(/EXECUTED_BY:\s*([^:\n\*]+)/);
        const actor = actorMatch ? actorMatch[1].trim() : 'Tripulacion';
        const summaryMatch = content.match(/SUMMARY:([^\n]+)/) || content.match(/SUBJECT:\s*([^\n]+)/);
        const summary = summaryMatch ? summaryMatch[1].trim() : `Tarea completada: ${f}`;
        addEntry({ timestamp_label: ts, actor, summary, status: 'done', source: `work_packets/done/${f}` }, 'global');
      });
    }

    // 5. Ordenar y Guardar
    timeline.sort((a, b) => (a.timestamp_label || '').localeCompare(b.timestamp_label || ''));
    
    const timelineJsonl = timeline.map(e => JSON.stringify(e)).join('\n');
    fs.writeFileSync(historyTimelinePath, timelineJsonl, 'utf-8');

    // Actualizar Logbook Object
    const argosMod = logbook.modules?.find(m => m.id === 'argos');
    if (argosMod) {
      argosMod.streams = [
        { id: 'log', label: 'Log', source: 'ARGOS_GLOBAL_LOG.md', entries: timeline.filter(e => e.stream === 'global').reverse().slice(0, 100) },
        { id: 'interactions', label: 'Interacciones', source: 'ARGOS_EVENTS', entries: timeline.filter(e => e.stream === 'interaction').reverse() },
        { id: 'shadow', label: 'Sombra', source: 'ARGOS_GLOBAL_SHADOW_LOG.md', entries: timeline.filter(e => e.stream === 'shadow').reverse() },
        { id: 'glitch', label: 'Glitch', source: 'ARGOS_GLOBAL_GLITCH_LOG.md', entries: timeline.filter(e => e.stream === 'glitch').reverse() }
      ];
    }
    logbook.updated_at = new Date().toISOString();
    fs.writeFileSync(LOGBOOK_SNAPSHOT_PATH, JSON.stringify(logbook, null, 2), 'utf-8');

    // Run sync state at the end
    runSyncState();

    return { ok: true, code: 0, stdout: 'Native history merge complete.', stderr: '' };
  } catch (e) {
    return { ok: false, code: 1, stdout: '', stderr: String(e) };
  }
}

function getMtimeMs(targetPath: string): number {
  try {
    return fs.statSync(targetPath).mtimeMs;
  } catch (error) {
    return 0;
  }
}

function shouldRefreshLogbookSnapshot(): boolean {
  const sourcePaths = [
    path.join(RUNTIME_DIR, 'ARGOS_GLOBAL_LOG.md'),
    path.join(RUNTIME_DIR, 'ARGOS_GLOBAL_SHADOW_LOG.md'),
    path.join(RUNTIME_DIR, 'events', 'argos.events.jsonl'),
    path.join(RUNTIME_DIR, 'events', 'argos.glitches.jsonl'),
    path.join(RUNTIME_DIR, 'views', 'ui_export', 'captain_feed.jsonl'),
    path.join(RUNTIME_DIR, 'work_packets', 'inbox'),
    path.join(RUNTIME_DIR, 'work_packets', 'in_progress'),
    path.join(RUNTIME_DIR, 'work_packets', 'done')
  ];

  const latestSourceMtime = sourcePaths.reduce((max, currentPath) => Math.max(max, getMtimeMs(currentPath)), 0);
  if (!fs.existsSync(LOGBOOK_SNAPSHOT_PATH)) return true;
  return getMtimeMs(LOGBOOK_SNAPSHOT_PATH) < latestSourceMtime;
}

function maybeRefreshLogbookSnapshot(force = false): ScriptRunResult | null {
  const now = Date.now();
  if (logbookRefreshInFlight) return null;

  const minIntervalMs = 5000;
  if (!force && now - lastLogbookRefreshAttemptMs < minIntervalMs) return null;
  if (!force && !shouldRefreshLogbookSnapshot()) return null;

  logbookRefreshInFlight = true;
  lastLogbookRefreshAttemptMs = now;
  try {
    return runMergeHistory();
  } finally {
    logbookRefreshInFlight = false;
  }
}

function inferSenderName(record: CaptainFeedRecord): string {
  const explicitName = normaliseText(record.sender_name);
  if (explicitName !== '') return explicitName;

  const actorName = normaliseText(record.actor);
  if (actorName !== '') return actorName;

  const source = normaliseText(record.source).toLowerCase();
  if (source.includes('captain')) return 'Capitan';
  if (source.includes('agent')) return 'Tripulacion';
  return '';
}

// Extrae el primer ID de work packet mencionado en un bloque de texto
// Patrón: ARG-XXXX o ARGOS-XXXX (con guiones, sin guiones bajos para no capturar nombres de archivo)
const WP_ID_RE = /\b((?:ARG|ARGOS)-[A-Z0-9]+(?:-[A-Z0-9]+)*)\b/gi;
function extractPacketId(text: string): string {
  const matches = text.match(WP_ID_RE);
  if (!matches) return '';
  return matches[0];
}

function extractPacketIdFromArtifacts(artifacts: unknown): string {
  if (!Array.isArray(artifacts)) return '';
  const wpPath = (artifacts as Array<unknown>).find((a) => typeof a === 'string' && a.includes('work_packets'));
  if (!wpPath || typeof wpPath !== 'string') return '';
  const filename = wpPath.split('/').pop() || '';
  const match = filename.match(/^([A-Z0-9-]+?)(?:__|\.md)/i);
  return match ? match[1] : '';
}

function parseArgosMarkdownStream(filePath: string, idPrefix: string): LogbookEntry[] {
  if (!fs.existsSync(filePath)) return [];
  const content = fs.readFileSync(filePath, 'utf-8');

  const rawBlocks = content.split('\n---');
  const blocks = rawBlocks.map((b) => b.trim()).filter((b) => b !== '');
  const parsed: Array<LogbookEntry & { sortMs: number }> = [];

  blocks.forEach((block, index) => {
    // 1. Detección por Cabecera Estándar: **[TS] ID | Actor:**
    const headerMatch = block.match(/\*\*\[[^\]]+\]\s*([A-Z0-9-]*)\s*\|\s*([^:\n*]+):\*\*/i);
    const headerId = headerMatch?.[1]?.trim() || '';
    const headerActor = headerMatch?.[2]?.trim() || '';

    // 2. Extracción de ID del Paquete
    const explicitPacketId =
      block.match(/^\s*\*\*WORK\s*PACKET:\*\*\s*([^\n]+)/im)?.[1]?.trim() ||
      block.match(/^\s*\*\*PACKET:\*\*\s*([^\n]+)/im)?.[1]?.trim() ||
      headerId;

    const timestampRaw =
      block.match(/\[(\d{4}-\d{2}-\d{2}(?:\s+\d{2}:\d{2})?)/)?.[1] ||
      block.match(/\[(\d{4}-\d{2}-\d{2})/)?.[1] ||
      '';
    const ts = parseTimestampLabel(timestampRaw);

    // 3. Extracción de Voz (Actor)
    const rawActor =
      block.match(/^\s*VOZ\s+([^:\n*]+)/im)?.[1]?.trim() ||
      headerActor ||
      (block.includes('CAPITAN') ? 'Capitan' : 'Sistema');
    const actor = normalizeActorName(rawActor);

    // 4. Extracción de Estado
    const status =
      block.match(/^\s*\*\*ESTADO(?:\s+\d+)?\s*:\*\*\s*([^\n]+)/im)?.[1]?.trim() ||
      'done';

    // 5. Extracción de Resumen (Misión/Subject)
    const summary =
      block.match(/\*\*(?:ACCION|ACCIÓN|MISION|MISIÓN|MISSION|SUBJECT|ASUNTO)\s*:\*\*\s*([^\n]+)/i)?.[1]?.trim() ||
      block.match(/\*\*(?:CATEGORIA|TAREA|OBJETIVO)\s*:\*\*\s*([^\n]+)/i)?.[1]?.trim() ||
      block.split('\n')[0].replace(/[\*\[\]]/g, '').trim() ||
      'Registro actualizado';

    const detailsRaw =
      block.match(/\*\*(?:DETALLES|DETAILS)(?:\s+\d+)?\s*:\*\*([\s\S]*?)(?:\n\*\*|\n---|$)/i)?.[1] ||
      block.match(/\*\*ACCIONES(?:\s+EJECUTADAS)?\s*:\*\*([\s\S]*?)(?:\n\*\*|\n---|$)/i)?.[1] ||
      block.match(/\*\*SOMBRA\s*:\*\*([\s\S]*?)(?:\n\*\*|\n---|$)/i)?.[1] ||
      block.match(/\*\*NOTA\s*:\*\*([\s\S]*?)(?:\n\*\*|\n---|$)/i)?.[1] ||
      '';

    const nextStep =
      block.match(/\*\*(?:SIGUIENTE PASO|SIGUIENTE|NEXT STEP|Paso Siguiente)\s*:\*\*\s*([^\n]+)/i)?.[1]?.trim() ||
      '';

    const errorsRaw =
      block.match(/\*\*(?:ERRORES[^:]*|APRENDIZAJE|ERROR BASE|Lecciones)\s*:\*\*([\s\S]*?)(?:\n\*\*|\n---|$)/i)?.[1] ||
      '';

    const risksRaw =
      block.match(/\*\*RIESGO[S]?|Peligros\s*:\*\*([\s\S]*?)(?:\n\*\*|\n---|$)/i)?.[1] ||
      '';

    parsed.push({
      id: explicitPacketId || extractPacketId(block),
      timestamp_label: ts.label,
      timestamp_precision: ts.precision,
      timestamp: timestampRaw,
      actor: cleanMarkdownText(actor),
      status: cleanMarkdownText(status),
      summary: cleanMarkdownText(summary),
      details: cleanMarkdownText(detailsRaw),
      next_step: cleanMarkdownText(nextStep),
      errors: cleanMarkdownText(errorsRaw),
      risks: cleanMarkdownText(risksRaw),
      source: idPrefix,
      sortMs: ts.sortMs + index
    });
  });

  parsed.sort((a, b) => b.sortMs - a.sortMs);
  return parsed.map(({ sortMs, ...entry }) => entry);
}

function parseArgosEventsStream(filePath: string, idPrefix: string): LogbookEntry[] {
  if (!fs.existsSync(filePath)) return [];
  const lines = fs.readFileSync(filePath, 'utf-8').split('\n').map((l) => l.trim()).filter((l) => l !== '');
  const parsed: Array<LogbookEntry & { sortMs: number }> = [];

  lines.forEach((line, index) => {
    try {
      const record = JSON.parse(line) as Record<string, unknown>;
      const timestampRaw = normaliseText(record.timestamp) || normaliseText(record.timestamp_label);
      if (timestampRaw === '') return;
      const ts = parseTimestampLabel(timestampRaw);
      const packetId = normaliseText(record.packet_id) ||
        normaliseText(record.packetId) ||
        normaliseText(record.refId) ||
        extractPacketIdFromArtifacts(record.artifacts) ||
        extractPacketId(
          [
            normaliseText(record.summary),
            normaliseText(record.details),
            normaliseText(record.verification),
            normaliseText(record.next_step),
            normaliseText(record.nextStep)
          ].join(' ')
        );
      parsed.push({
        id: packetId,
        timestamp_label: ts.label,
        timestamp_precision: ts.precision,
        timestamp: normaliseText(record.timestamp),
        actor: normalizeActorName(normaliseText(record.actor) || normaliseText(record.sender_name)),
        status: normaliseText(record.status) || 'done',
        summary: normaliseText(record.summary) || normaliseText(record.type) || 'Evento',
        details: normaliseText(record.verification) || normaliseText(record.details),
        next_step: normaliseText(record.next_step) || normaliseText(record.nextStep) || normaliseText(record.follow_up) || normaliseText(record.next_action),
        errors: normaliseText(record.errors) || normaliseText(record.learnings) || normaliseText(record.bug_details) || normaliseText(record.error_base),
        risks: normaliseText(record.risks) || normaliseText(record.dangers),
        source: idPrefix,
        sortMs: ts.sortMs + index
      });
    } catch (error) {
      // Ignora lineas corruptas para no romper la vista.
    }
  });

  parsed.sort((a, b) => b.sortMs - a.sortMs);
  return parsed.map(({ sortMs, ...entry }) => entry);
}

function parseCaptainFeedStream(filePath: string, idPrefix: string): LogbookEntry[] {
  if (!fs.existsSync(filePath)) return [];
  const lines = fs.readFileSync(filePath, 'utf-8').split('\n').map((l) => l.trim()).filter((l) => l !== '');
  const parsed: Array<LogbookEntry & { sortMs: number }> = [];

  lines.forEach((line, index) => {
    try {
      const record = JSON.parse(line) as CaptainFeedRecord;
      const timestampRaw = normaliseText(record.timestamp);
      if (timestampRaw === '') return;
      const ts = parseTimestampLabel(timestampRaw);
      const summary = normaliseText(record.summary);
      const details = normaliseText(record.details);
      const packetId = normaliseText(record.refId) || extractPacketId(`${summary} ${details}`);

      parsed.push({
        id: packetId,
        timestamp_label: ts.label,
        timestamp_precision: ts.precision,
        timestamp: timestampRaw,
        actor: normalizeActorName(normaliseText(record.sender_name) || normaliseText(record.actor)),
        status: normaliseText(record.status) || 'recorded',
        summary: summary || normaliseText(record.kind) || 'Interaccion',
        details,
        next_step: '',
        errors: '',
        risks: '',
        source: idPrefix,
        sortMs: ts.sortMs + index
      });
    } catch (error) {
      // Ignora lineas corruptas para no romper la vista.
    }
  });

  parsed.sort((a, b) => b.sortMs - a.sortMs);
  return parsed.map(({ sortMs, ...entry }) => entry);
}

function buildWorkPacketCache(): Map<string, { subject: string; owner: string }> {
  const cache = new Map<string, { subject: string; owner: string }>();
  const zones: WorkPacketZone[] = ['inbox', 'in_progress', 'done'];

  for (const zone of zones) {
    const zonePath = path.join(RUNTIME_DIR, 'work_packets', zone);
    if (!fs.existsSync(zonePath)) continue;

    try {
      const files = fs.readdirSync(zonePath).filter((f) => f.endsWith('.md'));
      for (const file of files) {
        const content = fs.readFileSync(path.join(zonePath, file), 'utf-8');
        const idMatch = content.match(/ID:\s*([^\n]+)/i);
        const subjectMatch = content.match(/SUBJECT:\s*([^\n]+)/i);
        const ownerMatch =
          content.match(/ROLE_REQUESTED:\s*([^\n]+)/i) ||
          content.match(/OWNER:\s*([^\n]+)/i);

        if (idMatch) {
          const id = normaliseText(idMatch[1]);
          if (id) {
            cache.set(id, {
              subject: (subjectMatch ? subjectMatch[1].trim() : '').replace(/\r/g, ''),
              owner: (ownerMatch ? ownerMatch[1].trim() : '').replace(/\r/g, '')
            });
          }
        }
      }
    } catch (e) {
      console.error(`[WP-CACHE] Error en zona ${zone}:`, e);
    }
  }
  return cache;
}

function enrichArgosStreams(snapshot: LogbookSnapshot): LogbookSnapshot {
  const clone = JSON.parse(JSON.stringify(snapshot || buildEmptyLogbook())) as LogbookSnapshot;
  clone.columns = buildEmptyLogbook().columns;
  const modules = clone.modules || [];
  const argos = modules.find((module) => module.id === 'argos');
  if (!argos) return clone;

  const wpCache = buildWorkPacketCache();

  const streamMap = new Map((argos.streams || []).map((stream) => [stream.id, stream]));
  
  const loadStreamEntries = (filename: string, streamType: string, parser: (f: string, id: string) => LogbookEntry[]) => {
    const livePath = streamType === 'glitch' 
       ? path.join(RUNTIME_DIR, 'events', filename) 
       : path.join(RUNTIME_DIR, filename);
       
    const allPaths = [livePath, ...findArchivedFiles(filename)];
    const combined: LogbookEntry[] = [];
    allPaths.forEach(fp => {
       if (fs.existsSync(fp)) {
         combined.push(...parser(fp, `argos-${streamType}-live`));
       }
    });
    return combined;
  };

  const liveLogEntries = loadStreamEntries('ARGOS_GLOBAL_LOG.md', 'log', parseArgosMarkdownStream);
  const liveShadowEntries = loadStreamEntries('ARGOS_GLOBAL_SHADOW_LOG.md', 'shadow', parseArgosMarkdownStream);
  const liveGlitchEntries = loadStreamEntries('argos.glitches.jsonl', 'glitch', parseArgosEventsStream);

  const processEntries = (entries: LogbookEntry[], streamId: string) => {
    return entries.map((entry) => {
      const id = normaliseText(entry.id || '');
      const wp = id ? wpCache.get(id) : null;
      const currentSummary = entry.summary || '';
      const currentActor = entry.actor || '';

      // 1. Enriquecimiento de Asunto (Summary)
      if (wp && wp.subject && (currentSummary === 'Registro actualizado' || currentSummary.includes('|'))) {
        entry.summary = wp.subject;
      }

      // 2. Enriquecimiento de Voz (Actor)
      if (wp && wp.owner && (currentActor === 'Sistema' || currentActor === 'Dispatcher' || currentActor === 'Tripulacion' || currentActor === 'IAT')) {
        entry.actor = normalizeActorName(wp.owner);
      }

      // 3. Dispatcher Log Guard (Solo en Log stream)
      const finalActor = entry.actor || currentActor;
      const finalSummary = entry.summary || currentSummary;

      if (streamId === 'log' && finalActor === 'Dispatcher') {
        const isHeartbeat = finalSummary.toLowerCase().includes('heartbeat') || 
                          finalSummary.toLowerCase().includes('sync') ||
                          finalSummary.toLowerCase().includes('refresh');
        if (!isHeartbeat) {
           entry.status = 'GLITCH';
           entry.summary = `[Voz No Autorizada] ${finalSummary}`;
        }
      }

      return entry;
    });
  };

  const applyEntries = (streamId: string, entries: LogbookEntry[]) => {
    const processed = processEntries(entries, streamId);
    if (processed.length === 0) return;
    const stream = streamMap.get(streamId);
    if (!stream) return;
    
    const combined = [...processed, ...(stream.entries || [])];
    const seen = new Set<string>();
    const deduplicated = combined.filter(e => {
       const key = `${e.timestamp_label || ''}|${e.actor || ''}|${e.summary || ''}|${e.id || ''}`;
       if (seen.has(key)) return false;
       seen.add(key);
       return true;
    });
    
    deduplicated.sort((a, b) => {
       const msA = (a as any).sortMs || Date.parse(a.timestamp || a.timestamp_label || '1970-01-01') || 0;
       const msB = (b as any).sortMs || Date.parse(b.timestamp || b.timestamp_label || '1970-01-01') || 0;
       return msB - msA;
    });
    
    stream.entries = deduplicated;
  };

  applyEntries('log', liveLogEntries);
  applyEntries('shadow', liveShadowEntries);
  applyEntries('glitch', liveGlitchEntries);

  argos.streams = Array.from(streamMap.values()).filter((s) => s.id !== 'interactions');
  clone.modules = (clone.modules || []).map((m) => ({
    ...m,
    streams: (m.streams || []).filter((s) => s.id !== 'interactions')
  }));

  clone.updated_at = new Date().toISOString();
  return clone;
}

function inferTaskOwner(rawText: string): string {
  const trimmed = rawText.trim();

  const explicitPatterns: Array<{ owner: string; regex: RegExp }> = [
    { owner: 'Codex', regex: /^(codex|para codex|orden para codex|ordenes para codex)\b[\s,:-]*/i },
    { owner: 'Claude', regex: /^(claude|para claude|orden para claude|ordenes para claude|orfeo)\b[\s,:-]*/i },
    { owner: 'Antigravity / Gemini', regex: /^(antigravity|gemini|para antigravity|para gemini|orden para antigravity|orden para gemini|ordenes para antigravity|ordenes para gemini)\b[\s,:-]*/i }
  ];

  for (const candidate of explicitPatterns) {
    if (candidate.regex.test(trimmed)) return candidate.owner;
  }

  const mentions: string[] = [];
  if (/\bcodex\b/i.test(trimmed)) mentions.push('Codex');
  if (/\b(claude|orfeo)\b/i.test(trimmed)) mentions.push('Claude');
  if (/\b(antigravity|gemini)\b/i.test(trimmed)) mentions.push('Antigravity / Gemini');

  if (mentions.length === 1) return mentions[0];
  return 'Cualquiera';
}

function inferTaskSubject(rawText: string): string {
  const collapsed = rawText.replace(/\r/g, '').replace(/\n+/g, ' ').replace(/\s+/g, ' ').trim();
  if (collapsed === '') return 'Conversacion Viva Mapeada';

  const withoutDirectAddress = collapsed.replace(
    /^(codex|claude|orfeo|antigravity|gemini|capitan|jason|thor)\b[\s,:-]*/i,
    ''
  ).trim();
  const base = withoutDirectAddress || collapsed;
  const clean = base.replace(/^[\-"'.:;!?]+|[\-"'.:;!?]+$/g, '').trim();
  if (clean === '') return 'Conversacion Viva Mapeada';

  const maxChars = 88;
  if (clean.length <= maxChars) return clean;
  const truncated = clean.slice(0, maxChars);
  const cut = truncated.lastIndexOf(' ');
  return `${(cut > 20 ? truncated.slice(0, cut) : truncated).trim()}...`;
}

function subjectToPacketSuffix(subject: string): string {
  const normalized = subject.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
  const upper = normalized.toUpperCase();
  const underscored = upper.replace(/[^A-Z0-9]+/g, '_').replace(/^_+|_+$/g, '');
  const safe = underscored === '' ? 'CONVERSACION_VIVA_MAPEADA' : underscored;
  return safe.slice(0, 64);
}

function formatRelativeAge(mtimeMs: number): string {
  const elapsed = Date.now() - mtimeMs;
  const hours = Math.floor(elapsed / 3600000);
  const mins = Math.floor(elapsed / 60000);

  if (hours > 0) return `Hace ${hours}h`;
  if (mins > 0) return `Hace ${mins}m`;
  return 'Hace un momento';
}

type LolaRiskPacketRecord = {
  id: string;
  zone: 'inbox' | 'in_progress';
  reportedAtMs: number;
  mtimeMs: number;
  signalHash: string;
};

const LOLA_RISK_THRESHOLD = 15;
const LOLA_RISK_COOLDOWN_MS = 30 * 60 * 1000;

function getPacketField(content: string, fieldName: string): string {
  const escapedFieldName = fieldName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const match = content.match(new RegExp(`${escapedFieldName}:\\s*(.*)`));
  return match ? match[1].trim() : '';
}

type WorkPacketZone = 'inbox' | 'in_progress' | 'done';

type ResolvedWorkPacket = {
  packetId: string;
  zone: WorkPacketZone;
  fileName: string;
  filePath: string;
  content: string;
};

function escapeRegex(text: string): string {
  return text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function normalizeTaskStatus(status: unknown, fallback: 'open' | 'in_progress' | 'done' = 'open'): 'open' | 'in_progress' | 'done' {
  const raw = normaliseText(status).toLowerCase();
  if (['done', 'closed', 'resolved', 'complete', 'completed'].includes(raw)) return 'done';
  if (['in_progress', 'in-progress', 'progress', 'active', 'doing', 'review'].includes(raw)) return 'in_progress';
  if (['open', 'inbox', 'pending', 'todo', 'queued'].includes(raw)) return 'open';
  return fallback;
}

function statusToZone(status: 'open' | 'in_progress' | 'done'): WorkPacketZone {
  if (status === 'done') return 'done';
  if (status === 'in_progress') return 'in_progress';
  return 'inbox';
}

function extractPacketObjective(content: string): string {
  const match = content.match(/OBJECTIVE:\s*([\s\S]*?)\n\[\/WORK_PACKET\]/);
  return match ? match[1].trim() : '';
}

function upsertPacketField(content: string, fieldName: string, nextValue: string): string {
  const compactValue = nextValue.replace(/\r?\n/g, ' ').trim();
  const fieldPattern = new RegExp(`^${escapeRegex(fieldName)}:\\s*.*$`, 'm');
  if (fieldPattern.test(content)) {
    return content.replace(fieldPattern, `${fieldName}: ${compactValue}`);
  }

  const anchorPattern = /^ID:\s*.*$/m;
  if (anchorPattern.test(content)) {
    return content.replace(anchorPattern, (line) => `${line}\n${fieldName}: ${compactValue}`);
  }

  if (content.includes('[WORK_PACKET]')) {
    return content.replace('[WORK_PACKET]', `[WORK_PACKET]\n${fieldName}: ${compactValue}`);
  }

  return `${fieldName}: ${compactValue}\n${content}`;
}

function replacePacketObjective(content: string, objective: string): string {
  const normalizedObjective = objective.replace(/\r/g, '').trim();
  const nextBlock = `OBJECTIVE:\n${normalizedObjective}`;
  if (/OBJECTIVE:\s*[\s\S]*?\[\/WORK_PACKET\]/.test(content)) {
    return content.replace(/OBJECTIVE:\s*[\s\S]*?\[\/WORK_PACKET\]/, `${nextBlock}\n[/WORK_PACKET]`);
  }
  if (content.includes('[/WORK_PACKET]')) {
    return content.replace('[/WORK_PACKET]', `${nextBlock}\n[/WORK_PACKET]`);
  }
  return `${content}\n${nextBlock}\n[/WORK_PACKET]`;
}

function findWorkPacketById(packetId: string, zones: WorkPacketZone[] = ['inbox', 'in_progress', 'done']): ResolvedWorkPacket | null {
  const targetId = normaliseText(packetId);
  if (targetId === '') return null;

  for (const zone of zones) {
    const zonePath = path.join(RUNTIME_DIR, 'work_packets', zone);
    if (!fs.existsSync(zonePath)) continue;

    const files = fs.readdirSync(zonePath).filter((file) => file.endsWith('.md') && !file.includes('__RESULTADO'));
    for (const fileName of files) {
      const filePath = path.join(zonePath, fileName);
      const content = fs.readFileSync(filePath, 'utf-8');
      if (!content.includes('[WORK_PACKET]')) continue;

      const parsedId = getPacketField(content, 'ID') || fileName.replace(/\.md$/i, '');
      if (normaliseText(parsedId) !== targetId) continue;

      return {
        packetId: parsedId,
        zone,
        fileName,
        filePath,
        content
      };
    }
  }

  return null;
}

function parseLooseTimestampMs(rawValue: string): number {
  const trimmed = normaliseText(rawValue);
  if (trimmed === '') return 0;

  const parsedIso = Date.parse(trimmed);
  if (!Number.isNaN(parsedIso)) return parsedIso;

  const legacyMatch = trimmed.match(/^(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2})$/);
  if (!legacyMatch) return 0;

  const parsedLegacy = Date.parse(`${legacyMatch[1]}T${legacyMatch[2]}:00`);
  return Number.isNaN(parsedLegacy) ? 0 : parsedLegacy;
}

function buildSignalHash(rawText: string): string {
  const normalized = rawText.toLowerCase().replace(/\s+/g, ' ').trim().slice(-1200);
  let hash = 2166136261;
  for (let i = 0; i < normalized.length; i += 1) {
    hash ^= normalized.charCodeAt(i);
    hash = Math.imul(hash, 16777619);
  }
  return (hash >>> 0).toString(16);
}

function extractLolaStressLevel(packetContent: string): number | null {
  const stressField = getPacketField(packetContent, 'STRESS_LEVEL');
  if (stressField !== '') {
    const parsed = Number(stressField);
    if (Number.isFinite(parsed)) return parsed;
  }

  const bodyMatch = packetContent.match(/nivel de estres de\s+(\d+)/i);
  if (!bodyMatch) return null;

  const parsedBody = Number(bodyMatch[1]);
  return Number.isFinite(parsedBody) ? parsedBody : null;
}

function loadOpenLolaRiskPackets(): LolaRiskPacketRecord[] {
  const zones: Array<'inbox' | 'in_progress'> = ['inbox', 'in_progress'];
  const packets: LolaRiskPacketRecord[] = [];

  zones.forEach((zone) => {
    const zonePath = path.join(RUNTIME_DIR, 'work_packets', zone);
    if (!fs.existsSync(zonePath)) return;

    const files = fs.readdirSync(zonePath).filter((file) => file.endsWith('.md'));
    files.forEach((file) => {
      const fullPath = path.join(zonePath, file);
      const content = fs.readFileSync(fullPath, 'utf-8');
      if (!content.includes('[WORK_PACKET]')) return;

      const packetType = getPacketField(content, 'TYPE').toLowerCase();
      const packetTag = getPacketField(content, 'TAG').toLowerCase();
      const packetId = getPacketField(content, 'ID');
      const reportedBy = getPacketField(content, 'REPORTED_BY').toLowerCase();
      const status = getPacketField(content, 'STATUS').toLowerCase();
      const isLolaRisk =
        packetType === 'risk' &&
        (packetId.startsWith('LOLA-RISK-') || packetTag.includes('shadow_alert') || reportedBy.includes('lola'));

      if (!isLolaRisk) return;
      if (status === 'done' || status === 'closed' || status === 'resolved') return;

      const reportedAtMs = parseLooseTimestampMs(getPacketField(content, 'REPORTED_AT'));
      const mtimeMs = fs.statSync(fullPath).mtimeMs;

      packets.push({
        id: packetId || file.replace(/\.md$/i, ''),
        zone,
        reportedAtMs,
        mtimeMs,
        signalHash: getPacketField(content, 'SIGNAL_HASH')
      });
    });
  });

  return packets;
}

type BugRecord = {
  id: string;
  severity: string;
  subject: string;
  status: string;
  reportedBy: string;
  reportedAt: string;
  zone: string;
  type: 'bug' | 'glitch';
};

const SEVERITY_RANK: Record<string, number> = { critical: 0, high: 1, medium: 2, low: 3 };

function loadTasksFromZone(zone: 'inbox' | 'in_progress' | 'done'): TaskRecord[] {
  const zonePath = path.join(RUNTIME_DIR, 'work_packets', zone);
  if (!fs.existsSync(zonePath)) return [];

  const files = fs.readdirSync(zonePath).filter((file) => file.endsWith('.md') && !file.includes('__RESULTADO'));
  const tasks = files.map((file) => {
    const fullPath = path.join(zonePath, file);
    const content = fs.readFileSync(fullPath, 'utf-8');
    if (!content.includes('[WORK_PACKET]')) return null;

    const idMatch = content.match(/ID:\s*(.*)/);
    const roleMatch = content.match(/ROLE_REQUESTED:\s*(.*)/);
    const ownerMatch = content.match(/OWNER:\s*(.*)/);
    const subjectMatch = content.match(/SUBJECT:\s*(.*)/);
    const statusMatch = content.match(/STATUS:\s*(.*)/);
    const typeMatch = content.match(/TYPE:\s*(.*)/);
    const priorityMatch = content.match(/PRIORITY:\s*(.*)/);
    const stat = fs.statSync(fullPath);

    let priority = priorityMatch ? priorityMatch[1].trim().toLowerCase() : '';
    if (priority === '') {
      const pMatch = file.match(/^P([1-3])_/i);
      if (pMatch) {
        const level = pMatch[1];
        priority = level === '1' ? 'high' : level === '2' ? 'mid' : 'low';
      } else {
        priority = 'low'; // Default
      }
    } else {
      // Normalize direct PRIORITY: P1/P2/P3 or text
      if (priority.includes('p1') || priority.includes('high')) priority = 'high';
      else if (priority.includes('p2') || priority.includes('mid')) priority = 'mid';
      else priority = 'low';
    }

    let status = statusMatch ? statusMatch[1].trim().toLowerCase() : zone;
    if (status === 'parked') status = 'open';
    if (zone === 'in_progress') status = 'in_progress';
    if (zone === 'done') status = 'done';
    if (zone === 'inbox' && status === '') status = 'open';

    const packetType = typeMatch ? typeMatch[1].trim().toLowerCase() : 'task';
    const tokensMatch = content.match(/TOKENS_SPENT:\s*(\d+)/);
    const createdAtMatch = content.match(/CREATED_AT:\s*(.*)/);
    const estimatedTimeMatch = content.match(/ESTIMATED_TIME:\s*(.*)/);

    return {
      id: idMatch ? idMatch[1].trim() : file.replace(/\.md$/i, ''),
      title: subjectMatch ? subjectMatch[1].trim() : 'Destello Verbal',
      owner: roleMatch ? roleMatch[1].trim() : ownerMatch ? ownerMatch[1].trim() : 'Cualquiera',
      status,
      time: formatRelativeAge(stat.mtimeMs),
      zone,
      type: packetType,
      priority,
      tokens_spent: tokensMatch ? Number(tokensMatch[1]) : 0,
      mtimeMs: stat.mtimeMs,
      created_at: createdAtMatch ? createdAtMatch[1].trim() : new Date(stat.birthtimeMs).toISOString(),
      estimated_time: estimatedTimeMatch ? estimatedTimeMatch[1].trim() : ''
    };
  });

  return tasks.filter((task): task is TaskRecord => task !== null);
}

function isIaGenericOwner(ownerText: string): boolean {
  const owner = normaliseText(ownerText).toLowerCase();
  return owner.includes('cualquiera') || owner.includes('codex / antigravity') || owner.includes('antigravity / codex');
}

function isTaskAssignedToAgent(task: TaskRecord, agentName: 'Codex' | 'Antigravity' | 'Claude' | 'DeepSeek'): boolean {
  return normalizeAgentName(task.owner) === agentName;
}

function inferIaStatusFromTasks(base: IaStatusMap): IaStatusMap {
  // Solo in_progress cuenta como trabajo activo — inbox es pendiente, no en ejecución
  const activeTasks = loadTasksFromZone('in_progress')
    .filter((task) => task.status === 'in_progress' || task.status === 'open')
    .sort((a, b) => b.mtimeMs - a.mtimeMs);

  const genericQueue = activeTasks.filter((task) => isIaGenericOwner(task.owner));
  let genericIndex = 0;

  const assignTask = (agentName: 'Codex' | 'Antigravity' | 'Claude' | 'DeepSeek'): TaskRecord | null => {
    const direct = activeTasks.find((task) => isTaskAssignedToAgent(task, agentName));
    if (direct) return direct;
    if (genericIndex < genericQueue.length) {
      const sharedTask = genericQueue[genericIndex];
      genericIndex += 1;
      return sharedTask;
    }
    return null;
  };

  // Índice de packets realmente en in_progress/ — validación rápida por nombre de fichero
  const inProgressDir = path.join(RUNTIME_DIR, 'work_packets', 'in_progress');
  const inProgressFiles = fs.existsSync(inProgressDir) ? fs.readdirSync(inProgressDir) : [];
  const isActuallyInProgress = (packetId: string): boolean =>
    !!packetId && inProgressFiles.some(f => f.includes(packetId));

  const enriched: IaStatusMap = {
    Claude: { ...base.Claude },
    Antigravity: { ...base.Antigravity },
    Codex: { ...base.Codex },
    DeepSeek: { ...base.DeepSeek }
  };

  // Cross-check: si una IA está marcada "active" pero su packet ya no está en in_progress/,
  // el status es stale — se limpia automáticamente a standby.
  // Los estados 'restricted' se mantienen as-is ya que son bloqueos externos, no tareas en ejecución.
  (['Codex', 'Antigravity', 'Claude', 'DeepSeek'] as const).forEach((agentName) => {
    const current = enriched[agentName];
    if (current.status === 'active' && current.task && !isActuallyInProgress(current.task)) {
      enriched[agentName] = { status: 'standby', task: '', task_subject: '', since: current.since };
    }
  });

  // Enriquecer IAs en standby con tareas activas detectadas en el filesystem
  (['Codex', 'Antigravity', 'Claude', 'DeepSeek'] as const).forEach((agentName) => {
    const current = enriched[agentName];
    if (current.status !== 'standby') return; // ya tiene status válido (active o restricted)
    const task = assignTask(agentName);
    if (!task) return;

    enriched[agentName] = {
      status: 'active',
      task: task.id,
      task_subject: task.title,
      since: current.since || new Date().toISOString()
    };
  });

  return enriched;
}

function loadGlitchesFromJsonl(): BugRecord[] {
  const glitchesPath = path.join(RUNTIME_DIR, 'events', 'argos.glitches.jsonl');
  if (!fs.existsSync(glitchesPath)) return [];

  try {
    const lines = fs.readFileSync(glitchesPath, 'utf-8').split('\n').filter(l => l.trim());
    return lines.map(line => {
      try {
        const g = JSON.parse(line);
        return {
          id: g.id,
          severity: 'medium',
          subject: g.summary,
          status: g.status || 'open',
          reportedBy: g.actor || 'System',
          reportedAt: g.timestamp_label || g.timestamp,
          zone: 'inbox',
          type: 'glitch'
        };
      } catch (e) { return null; }
    }).filter(g => g !== null) as BugRecord[];
  } catch(e) { return []; }
}

function loadBugsFromAllZones(): BugRecord[] {
  const bugs: BugRecord[] = [];
  const zones: Array<'inbox' | 'in_progress' | 'done'> = ['inbox', 'in_progress', 'done'];

  for (const zone of zones) {
    const zonePath = path.join(RUNTIME_DIR, 'work_packets', zone);
    if (!fs.existsSync(zonePath)) continue;

    const files = fs.readdirSync(zonePath).filter((f) => f.endsWith('.md') && !f.includes('__RESULTADO'));
    for (const file of files) {
      const fullPath = path.join(zonePath, file);
      const content = fs.readFileSync(fullPath, 'utf-8');
      if (!content.includes('[WORK_PACKET]')) continue;

      const typeMatch = content.match(/TYPE:\s*(.*)/);
      const tagMatch = content.match(/TAG:\s*(.*)/);
      const packetType = typeMatch ? typeMatch[1].trim().toLowerCase() : '';
      const packetTag = tagMatch ? tagMatch[1].trim().toLowerCase() : '';
      
      const isBugOrGlitch = packetType === 'bug' || packetTag === 'bug' || packetType === 'glitch' || packetTag === 'glitch';
      if (!isBugOrGlitch) continue;

      const idMatch = content.match(/ID:\s*(.*)/);
      const severityMatch = content.match(/SEVERITY:\s*(.*)/);
      const subjectMatch = content.match(/SUBJECT:\s*(.*)/);
      const statusMatch = content.match(/STATUS:\s*(.*)/);
      const reportedByMatch = content.match(/REPORTED_BY:\s*(.*)/);
      const reportedAtMatch = content.match(/REPORTED_AT:\s*(.*)/);

      bugs.push({
        id: idMatch ? idMatch[1].trim() : file.replace(/\.md$/i, ''),
        severity: severityMatch ? severityMatch[1].trim().toLowerCase() : 'medium',
        subject: subjectMatch ? subjectMatch[1].trim() : 'Bug sin descripcion',
        status: statusMatch ? statusMatch[1].trim().toLowerCase() : zone,
        reportedBy: reportedByMatch ? reportedByMatch[1].trim() : 'Desconocido',
        reportedAt: reportedAtMatch ? reportedAtMatch[1].trim() : '',
        zone,
        type: packetType === 'glitch' || packetTag === 'glitch' ? 'glitch' : 'bug'
      });
    }
  }

  bugs.sort((a, b) => (SEVERITY_RANK[a.severity] ?? 4) - (SEVERITY_RANK[b.severity] ?? 4));
  return bugs;
}

function parseVectorMarkdown(): any {
  const vectorPath = path.join(RUNTIME_DIR, 'ARGOS_VECTOR.md');
  if (!fs.existsSync(vectorPath)) return { categories: [] };

  const content = fs.readFileSync(vectorPath, 'utf-8');
  const sections = content
    .split(/^##\s+/m)
    .map((section) => section.trim())
    .filter((section) => section !== '');

  const categories = sections
    .map((section) => {
      const lines = section.split('\n').map((line) => line.trim()).filter((line) => line !== '');
      const title = lines[0] || '';
      const goals = lines
        .slice(1)
        .filter((line) => /^-\s*\[[ xX]\]/.test(line))
        .map((line) => {
          const isDone = /\[[xX]\]/.test(line);
          const text = line.replace(/-\s*\[[ xX]\]\s*/, '').trim();
          return { text, status: isDone ? 'done' : 'pending' };
        });

      return { title, goals };
    })
    .filter((category) => category.title !== '' && !category.title.startsWith('#') && category.goals.length > 0);

  return { categories };
}

// ============ MEJORA 3: Heartbeat SSE ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â mantiene conexiones abiertas, sin ruido en chat/log ============
function startHeartbeatLoop(): void {
  const sendHeartbeat = () => {
    // Solo envÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â­a un comentario SSE (lÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â­nea que empieza por ':') a cada cliente suscrito.
    // Los comentarios SSE mantienen la conexiÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n viva pero el navegador/cliente los ignora
    // silenciosamente ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â no llegan al handler de 'message', no se escriben en ningÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Âºn archivo.
    const comment = `:heartbeat-${Date.now()}\n\n`;
    sseClients.forEach(clients => {
      clients.forEach(client => {
        try { client.response.write(comment); } catch { /* cliente desconectado */ }
      });
    });
  };

  setInterval(sendHeartbeat, 30000); // cada 30 s es suficiente para proxies/nginx
  console.log('[HEARTBEAT] SSE keepalive activo (cada 30 s, sin ruido en chat/log)');
}

// ============ MEJORA 4: Dispatcher Mirror ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â replica cambios a ARGOS_GLOBAL_LOG.md ============
let lastPacketStates: Record<string, { zone: string; mtime: number }> = {};

function startDispatcherMirror(): void {
  const workPacketsDir = path.join(RUNTIME_DIR, 'work_packets');
  const zones = ['inbox', 'in_progress', 'done', 'archived'];

  const scanPackets = () => {
    const currentStates: Record<string, { zone: string; mtime: number }> = {};

    zones.forEach(zone => {
      const zonePath = path.join(workPacketsDir, zone);
      if (!fs.existsSync(zonePath)) return;

      const files = fs.readdirSync(zonePath).filter(f => f.endsWith('.md'));
      files.forEach(filename => {
        const fullPath = path.join(zonePath, filename);
        const stat = fs.statSync(fullPath);
        const idMatch = filename.match(/^[A-Z0-9_-]+/);
        const packetId = idMatch ? idMatch[0] : filename.replace('.md', '');

        currentStates[packetId] = { zone, mtime: stat.mtimeMs };
      });
    });

    // Detectar cambios
    Object.entries(currentStates).forEach(([packetId, current]) => {
      const previous = lastPacketStates[packetId];

      if (!previous) {
        // Nuevo paquete
        console.log(`[MIRROR] Nuevo packet detectado: ${packetId} en ${current.zone}`);
      } else if (previous.zone !== current.zone) {
        // Cambio de zona — solo log interno de servidor, sin escribir en GLOBAL_LOG ni SHADOW_LOG
        // (solo los agentes Claude, Antigravity y Codex escriben en logs narrativos)
        console.log(`[MIRROR] ${packetId}: ${previous.zone} -> ${current.zone}`);
        publishEvent('packet:changed', { packetId, from: previous.zone, to: current.zone });
      }
    });

    lastPacketStates = currentStates;
  };

  // Scan inicial
  scanPackets();

  // Luego cada 30 segundos
  setInterval(scanPackets, 30000);
  console.log('[MIRROR] Dispatcher mirror iniciado (cada 30 seg)');
}

app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'ok', message: 'ARGOS API (Tifis) is running', runtime: RUNTIME_DIR });
});

// ============ ENDPOINT: SSE Subscription para Pub/Sub ============
app.get('/api/subscribe/:module', (req: Request, res: Response) => {
  const module = req.params.module || 'argos';
  const clientId = subscribeToModule(module, res);

  // No cerrar la conexiÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â mantenerla abierta para eventos
  req.on('close', () => {
    console.log(`[PUBSUB] Request cerrado para mÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³dulo: ${module}`);
  });
});

app.get('/api/state', (req: Request, res: Response) => {
  const statePath = path.join(RUNTIME_DIR, 'state', 'argos.state.json');
  const fallback = { status: 'ok', message: 'ARGOS API (Tifis) is running', runtime: RUNTIME_DIR };
  res.json(readJsonFile<Record<string, unknown>>(statePath, fallback));
});

app.post('/api/sync-state', (req: Request, res: Response) => {
  interceptAction(req, res, 'sync-state', () => {
    const syncResult = runSyncState();
    if (!syncResult.ok) {
      return res.status(500).json({
        status: 'error',
        code: syncResult.code,
        stdout: syncResult.stdout,
        stderr: syncResult.stderr
      });
    }

    const statePath = path.join(RUNTIME_DIR, 'state', 'argos.state.json');
    return res.json({
      status: 'ok',
      code: syncResult.code,
      stdout: syncResult.stdout,
      state: readJsonFile<Record<string, unknown>>(statePath, {})
    });
  });
});

app.post('/api/refresh-logbook', (req: Request, res: Response) => {
  const refreshResult = maybeRefreshLogbookSnapshot(true);
  if (!refreshResult) {
    return res.status(202).json({
      status: 'accepted',
      message: 'Refresco de bitacora omitido por lock temporal'
    });
  }

  if (!refreshResult.ok) {
    return res.status(500).json({
      status: 'error',
      code: refreshResult.code,
      stdout: refreshResult.stdout,
      stderr: refreshResult.stderr
    });
  }

  return res.json({
    status: 'ok',
    code: refreshResult.code,
    stdout: refreshResult.stdout,
    logbook: enrichArgosStreams(readJsonFile<LogbookSnapshot>(LOGBOOK_SNAPSHOT_PATH, buildEmptyLogbook()))
  });
});

app.post('/api/session/archive', (req: Request, res: Response) => {
  try {
    const {
      mode = 'end_of_day',
      actor = 'Codex',
      reason = 'Rollover de sesion',
      dryRun = false,
      archiveDonePackets = true,
      compactState = true,
      reorganizeLegacy = true
    } = req.body || {};

    const normalizedMode = normaliseText(mode) === 'start_of_day' ? 'start_of_day' : 'end_of_day';

    const report = runSessionArchive({
      mode: normalizedMode,
      actor: normaliseText(actor) || 'Codex',
      reason: normaliseText(reason) || 'Rollover de sesion',
      dryRun: Boolean(dryRun),
      archiveDonePackets: Boolean(archiveDonePackets),
      compactState: Boolean(compactState),
      reorganizeLegacy: Boolean(reorganizeLegacy)
    });

    if (!report.status || report.status === 'ok') {
      appendJsonlRecord(ARGOS_EVENTS_PATH, {
        timestamp: new Date().toISOString(),
        actor: 'Argos',
        module: 'argos_core',
        type: 'session_archive',
        summary: `Rollover ${report.mode} ejecutado`,
        details: `Sesion ${report.sessionStamp}. Movidos: ${report.movedFiles.length}.`,
        next_step: 'Continuar operacion sobre lanes activas limpias.',
        packet_id: '',
        source: 'api:session/archive'
      });
    }

    maybeRefreshLogbookSnapshot(true);
    return res.json(report);
  } catch (error) {
    return res.status(500).json({ error: 'Fallo en archivo de sesion', detail: String(error) });
  }
});

app.get('/api/chat', (req: Request, res: Response) => {
  try {
    const feedPath = path.join(RUNTIME_DIR, 'views', 'ui_export', 'captain_feed.jsonl');
    const allPaths = [feedPath, ...findArchivedFiles('captain_feed.jsonl')];

    const rawMessages: ChatMessage[] = [];
    allPaths.forEach(fp => {
      if (!fs.existsSync(fp)) return;
      readCaptainFeedLines(fp).forEach((line) => {
        if (!line.parsed) return;
        rawMessages.push(buildChatMessage(ensureCaptainFeedRecordId(line.parsed)));
      });
    });

    rawMessages.sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime());

    // Deduplicacion LOCAL (Sliding Window): Solo descarta si es identico a uno de los ultimos 5 mensajes.
    const messages = rawMessages.filter((msg, idx, self) => {
      // Miramos hacia atras hasta 5 posiciones
      for (let i = 1; i <= 5; i++) {
        const prev = self[idx - i];
        if (!prev) break;
        if (msg.sender === prev.sender && msg.text === prev.text) return false;
      }
      return true;
    });

    res.json({ messages });
  } catch (error) {
    res.status(500).json({ error: 'Error parseando el feed verbal' });
  }
});

app.post('/api/chat', (req: Request, res: Response) => {
  try {
    let { sender, summary, details, kind, tokens } = req.body;
    if (!summary) return res.status(400).json({ error: 'Missing summary' });

    const resolvedTokens = resolveEstimatedTokens(tokens, summary, details, req.body.refId, sender);
    const canonicalSender = normalizeAgentName(String(sender || 'Antigravity')) || String(sender || 'Antigravity');

    const feedPath = path.join(RUNTIME_DIR, 'views', 'ui_export', 'captain_feed.jsonl');
    const recordsPath = path.join(RUNTIME_DIR, 'events', 'argos.tokens.jsonl');

    const record: CaptainFeedRecord = {
      id: nextFeedMessageId(),
      timestamp: new Date().toISOString(),
      kind: kind || 'crew_update',
      speaker: 'crew',
      sender_name: canonicalSender,
      sender_role: 'agent',
      audience: 'captain',
      source: 'agent_reporting',
      summary,
      details: details || '',
      status: 'done',
      tokens: 0,
      refId: req.body.refId || ''
    };

    // Transcript: registrar la respuesta literal de la IA
    // Para agentes UI-side (Antigravity, Qwen...) el contenido completo llega en details.
    // Para Claude (Claude Code) el transcript literal se escribe desde el cliente — aquí
    // registramos summary+details como fallback hasta que haya captura directa.
    const transcriptContent = req.body.literalResponse
      || (details ? `${summary}\n\n${details}` : summary);
    const tRef = appendToTranscript(canonicalSender, 'agent', transcriptContent, record.refId || '');
    (record as any).transcriptRef = tRef;

    appendJsonlRecord(feedPath, record);
    const chatCanaryTs = new Date(record.timestamp || new Date().toISOString())
      .toLocaleString('sv-SE', {
        timeZone: 'Atlantic/Canary',
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      })
      .slice(0, 16);
    // interactions_log reemplazado por el sistema de transcripts — ya no se escribe type:interaction
    // al JSONL de eventos; el transcript canónico vive en transcripts/FECHA_AGENTE.md

    // Also record in the token ledger with module and ID linkage
    appendJsonlRecord(recordsPath, {
      timestamp: record.timestamp,
      agent: record.sender_name,
      tokens: resolvedTokens,
      module: 'argos',
      refId: record.refId || '',
      ref: `Chat Rep: ${summary.substring(0, 30)}...`,
      scope: 'report',
      channel: 'chat'
    });

    // WORK_TOKENS fallback (Orden Ejecutiva):
    // Si el agente solo usa /api/chat (y olvida /api/trilog), el panel WORK_TOKENS quedaria "casi a cero".
    // - Si llega `processTokens` / `workTokens`, se confia.
    // - Si no llega, se deriva una estimacion conservadora desde el tamaño del reporte.
    const packetRefId = normaliseText(record.refId);
    if (looksLikeWorkPacketId(packetRefId) && !hasWorkTokenForPacket(recordsPath, canonicalSender, packetRefId)) {
      const explicitWork = Number(req.body.processTokens ?? req.body.workTokens ?? req.body.work_tokens ?? 0);
      const workTokens =
        Number.isFinite(explicitWork) && explicitWork > 0
          ? Math.round(explicitWork)
          : Math.max(1, Math.ceil(resolvedTokens * DEFAULT_WORK_FROM_REPORT_MULTIPLIER));

      appendJsonlRecord(recordsPath, {
        timestamp: record.timestamp,
        agent: record.sender_name,
        tokens: workTokens,
        module: 'argos',
        refId: packetRefId,
        ref: `Work Est from Chat Rep: ${summary.substring(0, 60)}`,
        scope: 'work',
        channel: 'chat_work_est'
      });

      publishEvent('tokens:updated', {
        agent: canonicalSender,
        tokens: workTokens,
        timestamp: record.timestamp,
        refId: packetRefId,
        scope: 'work'
      });
    }

    publishEvent('tokens:updated', {
      agent: canonicalSender,
      tokens: resolvedTokens,
      timestamp: record.timestamp,
      refId: record.refId || '',
      scope: 'report'
    });

    // Publicar evento a todos los suscritos
    publishEvent('chat:message', {
      id: record.id,
      actor: record.sender_name,
      summary: summary.substring(0, 100),
      timestamp: record.timestamp,
      tokens: 0
    });

    res.json({ status: 'ok', record });
  } catch (error) {
    res.status(500).json({ error: 'Fallo al grabar transmision radial' });
  }
});

app.post('/api/chat/edit', (req: Request, res: Response) => {
  try {
    const messageId = normaliseText(req.body.messageId);
    const summary = normaliseText(req.body.summary);
    const details = normaliseText(req.body.details);

    if (messageId === '') return res.status(400).json({ error: 'messageId requerido' });
    if (summary === '') return res.status(400).json({ error: 'summary requerido' });

    const feedPath = path.join(RUNTIME_DIR, 'views', 'ui_export', 'captain_feed.jsonl');
    if (!fs.existsSync(feedPath)) return res.status(404).json({ error: 'No existe captain_feed.jsonl' });

    const lines = readCaptainFeedLines(feedPath);
    const editedAt = new Date().toISOString();
    let updatedRecord: CaptainFeedRecord | null = null;
    let found = false;

    const nextLines = lines.map((line) => {
      if (!line.parsed) return line;
      const current = ensureCaptainFeedRecordId(line.parsed);
      if (resolveFeedRecordId(current) !== messageId) {
        return { ...line, parsed: current };
      }

      found = true;
      updatedRecord = {
        ...current,
        summary,
        details,
        edited_at: editedAt,
        status: 'edited'
      };
      return { ...line, parsed: updatedRecord };
    });

    if (!found || !updatedRecord) {
      return res.status(404).json({ error: `Mensaje ${messageId} no encontrado` });
    }
    const finalRecord = updatedRecord as CaptainFeedRecord;

    writeCaptainFeedLines(feedPath, nextLines);

    const canaryTs = new Date(editedAt).toLocaleString('sv-SE', {
      timeZone: 'Atlantic/Canary',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    }).slice(0, 16);
    const packetRef = normaliseText(finalRecord.refId);
    appendJsonlRecord(ARGOS_EVENTS_PATH, {
      timestamp: editedAt,
      timestamp_label: canaryTs,
      actor: inferSenderName(finalRecord),
      module: 'argos',
      type: 'interaction_edit',
      status: 'edited',
      packet_id: packetRef,
      refId: packetRef,
      summary,
      details,
      source: 'api:chat/edit'
    });

    publishEvent('chat:message_edited', {
      id: messageId,
      actor: inferSenderName(finalRecord),
      refId: packetRef,
      timestamp: editedAt
    });

    return res.json({
      status: 'ok',
      record: buildChatMessage(finalRecord)
    });
  } catch (error) {
    return res.status(500).json({ error: 'Fallo al editar mensaje del chat', detail: String(error) });
  }
});

app.get('/api/logbook', (req: Request, res: Response) => {
  try {
    const snapshot = readJsonFile<LogbookSnapshot>(LOGBOOK_SNAPSHOT_PATH, buildEmptyLogbook());
    res.json(enrichArgosStreams(snapshot));
  } catch (error) {
    res.status(500).json({ error: 'Fallo levantando el snapshot tabular de la bitacora' });
  }
});

app.get('/api/logs', (req: Request, res: Response) => {
  try {
    const globalLogPath = path.join(RUNTIME_DIR, 'ARGOS_GLOBAL_LOG.md');
    const shadowLogPath = path.join(RUNTIME_DIR, 'ARGOS_GLOBAL_SHADOW_LOG.md');
    const interactionsPath = path.join(RUNTIME_DIR, 'events', 'argos.events.jsonl');

    const globalStr = readTextFile(globalLogPath, 'Bitacora global desaparecida.');
    const shadowStr = readTextFile(shadowLogPath, 'Shadow log desaparecido.');
    const interactionsStr = readTextFile(interactionsPath, '');

    res.json({ global: globalStr, shadow: shadowStr, interactions: interactionsStr });
  } catch (error) {
    res.status(500).json({ error: 'Fallo exhumando los textos de bitacora profunda' });
  }
});

app.get('/api/tokens', (req: Request, res: Response) => {
  try {
    const tokensPath = path.join(RUNTIME_DIR, 'events', 'argos.tokens.jsonl');
    if (!fs.existsSync(tokensPath)) {
      return res.json({ total: 0, daily: 0, weekly: 0, agents: {}, costEstimate: 0 });
    }

    const data = fs.readFileSync(tokensPath, 'utf-8').replace(/^\uFEFF/, '');
    const { module, refId, scope } = req.query;
    const requestedScope = normaliseText(scope).toLowerCase();
    const effectiveScope = requestedScope === '' ? 'work' : requestedScope;
    const scopeFilter: 'work' | 'report' | 'input' | 'all' = effectiveScope === 'all' ? 'all' : normaliseTokenScope(effectiveScope);

    // Robust splitting: split by newline OR by closing brace followed by opening brace
    const rawLines = data.split('\n');
    const unfilteredLines: string[] = [];
    rawLines.forEach(l => {
        const parts = l.trim().split(/}\s*{/);
        if (parts.length > 1) {
            parts.forEach((p, i) => {
                let json = p;
                if (!json.startsWith('{')) json = '{' + json;
                if (!json.endsWith('}')) json = json + '}';
                unfilteredLines.push(json);
            });
        } else if (l.trim()) {
            unfilteredLines.push(l.trim());
        }
    });

    const lines = unfilteredLines.filter(line => {
      try {
        const record = JSON.parse(line) as TokenRecord;
        if (module && record.module !== module) return false;
        if (refId && record.refId !== refId) return false;
        if (scopeFilter !== 'all' && inferTokenScope(record) !== scopeFilter) return false;
        return true;
      } catch (e) { return false; }
    });

    const now = new Date();
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime();
    const startOfWeek = now.getTime() - (now.getDay() * 24 * 60 * 60 * 1000); // Simple week

    const stats: TokenStats = {
      total: 0,
      daily: 0,
      weekly: 0,
      agents: {},
      costEstimate: 0
    };

    lines.forEach(line => {
      try {
        const record = JSON.parse(line) as TokenRecord;
        const ts = new Date(record.timestamp).getTime();
        const val = Number(record.tokens) || 0;
        const rawAgent = record.agent || 'Unknown';
        const agent = normalizeAgentName(rawAgent);

        // Skip discard agents (test, captain, unknown, etc.)
        if (!agent) return;

        if (!stats.agents[agent]) {
          stats.agents[agent] = { total: 0, daily: 0, weekly: 0 };
        }

        stats.total += val;
        stats.agents[agent].total += val;

        if (ts >= startOfDay) {
          stats.daily += val;
          stats.agents[agent].daily += val;
        }

        if (ts >= startOfWeek) {
          stats.weekly += val;
          stats.agents[agent].weekly += val;
        }
      } catch (e) {}
    });

    stats.costEstimate = (stats.total / 1000) * 0.015; // $0.015 per 1k tokens avg

    res.json({ ...stats, scope: scopeFilter });
  } catch (error) {
    res.status(500).json({ error: 'Fallo al procesar contabilidad de tokens' });
  }
});

app.post('/api/tokens/record', (req: Request, res: Response) => {
  try {
    const { agent, tokens, ref, module, refId, scope, channel } = req.body;
    if (!agent) return res.status(400).json({ error: 'Missing agent' });
    const resolvedTokens = resolveEstimatedTokens(tokens, ref, refId, module, agent);
    if (resolvedTokens <= 0) return res.status(400).json({ error: 'Missing tokens or estimable context' });
    const resolvedScope = normaliseTokenScope(scope);

    const tokensPath = path.join(RUNTIME_DIR, 'events', 'argos.tokens.jsonl');
    const record: TokenRecord = {
      timestamp: new Date().toISOString(),
      agent,
      tokens: resolvedTokens,
      ref: ref || 'unmapped action',
      module: module || 'argos',
      refId: refId || '',
      scope: resolvedScope,
      channel: normaliseText(channel) || 'manual'
    };

    appendJsonlRecord(tokensPath, record);

    // Publish event to notify subscribers of token update
    publishEvent('tokens:updated', {
      agent: normalizeAgentName(agent) || agent,
      tokens: resolvedTokens,
      timestamp: record.timestamp,
      scope: resolvedScope
    });

    res.json({ status: 'ok', record });
  } catch (error) {
    res.status(500).json({ error: 'Fallo al grabar registro de tokens' });
  }
});

app.post('/api/trilog', (req: Request, res: Response) => {
  try {
    const {
      actor,
      packetId = '',
      summary,
      details = '',
      nextStep = '',
      errors = '',
      risks = '',
      tokens = 0,           // legacy fallback => processTokens
      processTokens = 0,    // trabajo real de la tarea
      trilogTokens = 0,     // coste de redaccion/reportado en trilog
      chatTokens = 0,       // coste de mensaje final al chat/feed
      shadow = '',          // OBLIGATORIO: observación latente Junguiana — el negativo del LOG
      discarded = '',       // opcional: detalles descartados durante el proceso
      ignored = '',         // opcional: detalles ignorados por baja prioridad
      suppressed = '',      // opcional: detalles suprimidos/no volcados en LOG
      status = 'done',
      module = 'argos',
      transcriptRef = ''    // referencia al bloque de transcript literal (YYYY-MM-DD_Agente.md#ARG-XXXX)
    } = req.body;
    const packetRef = normaliseText(packetId);

    if (!actor || !summary || packetRef === '') {
      return res.status(400).json({ error: 'Campos obligatorios: actor, packetId, summary' });
    }

    const shadowContent = normaliseText(shadow);
    if (shadowContent === '') {
      return res.status(400).json({
        error: 'Campo shadow obligatorio. Escribe lo que observaste durante la tarea pero no volcaste en el LOG — fricción cognitiva, patrón emergente, riesgo latente, tensión no resuelta. El shadow es el negativo que forma la imagen del log.'
      });
    }

    const now = new Date();
    const isoTs = now.toISOString();
    // sv-SE produce YYYY-MM-DD HH:MM — formato requerido por el parser del logbook
    const canaryTs = now.toLocaleString('sv-SE', {
      timeZone: 'Atlantic/Canary',
      year: 'numeric', month: '2-digit', day: '2-digit',
      hour: '2-digit', minute: '2-digit'
    }).slice(0, 16);
    const canonicalActor = normalizeAgentName(String(actor)) || String(actor);
    const processTokenCount = resolveEstimatedTokens(processTokens || tokens, summary, details, errors, risks, packetRef);
    const trilogTokenCount = resolveEstimatedTokens(trilogTokens, summary, details, nextStep, errors, risks, shadow, discarded, ignored, suppressed, packetRef, canonicalActor);
    const chatTokenCount = resolveEstimatedTokens(chatTokens, `[CIERRE] ${summary}`, nextStep ? `Siguiente: ${nextStep}` : '', packetRef, canonicalActor);
    // feedDetails: solo nextStep si lo hay — sin breakdown de tokens en el feed (ruido)
    const feedDetails = nextStep ? `Siguiente: ${nextStep}` : '';

    const written: string[] = [];

    // 1. GLOBAL LOG (markdown)
    const logEntry =
      `\n---\n` +
      `**[${canaryTs} Atlantic/Canary] VOZ ${canonicalActor.toUpperCase()}:**\n` +
      `**MISION:** ${summary}\n` +
      `**WORK PACKET:** ${packetRef}\n` +
      (details ? `\n**DETALLES:**\n${details}\n` : '') +
      (nextStep ? `\n**SIGUIENTE:** ${nextStep}\n` : '') +
      (errors ? `\n**ERRORES + APRENDIZAJES:** ${errors}\n` : '') +
      (risks ? `\n**RIESGOS:** ${risks}\n` : '');

    const existingLog = fs.existsSync(ARGOS_GLOBAL_LOG_PATH)
      ? fs.readFileSync(ARGOS_GLOBAL_LOG_PATH, 'utf-8')
      : '# ARGOS GLOBAL LOG\nRegistro operativo compartido por la tripulacion.\n';
    fs.writeFileSync(ARGOS_GLOBAL_LOG_PATH, existingLog + logEntry, 'utf-8');
    written.push('LOG');

    // 2. EVENTS (JSONL estructurado)
    const eventRecord = {
      timestamp: isoTs,
      timestamp_label: canaryTs,
      actor: canonicalActor,
      module,
      type: 'session_close',
      packet_id: packetRef,
      refId: packetRef,
      status,
      summary,
      details,
      next_step: nextStep,
      errors,
      risks,
      tokens: processTokenCount,
      transcriptRef: normaliseText(transcriptRef),
      source: 'api:trilog'
    };
    appendJsonlRecord(ARGOS_EVENTS_PATH, eventRecord);
    written.push('EVENTS');

    // 2b. TOKENS ledger (work + report)
    const tokensPath = path.join(RUNTIME_DIR, 'events', 'argos.tokens.jsonl');
    appendJsonlRecord(tokensPath, {
      timestamp: isoTs,
      agent: canonicalActor,
      tokens: processTokenCount,
      module,
      refId: packetRef,
      ref: `Work Process: ${String(summary).substring(0, 60)}`,
      scope: 'work',
      channel: 'process'
    });
    appendJsonlRecord(tokensPath, {
      timestamp: isoTs,
      agent: canonicalActor,
      tokens: trilogTokenCount,
      module,
      refId: packetRef,
      ref: `TriLog Report: ${String(summary).substring(0, 60)}`,
      scope: 'report',
      channel: 'trilog'
    });
    appendJsonlRecord(tokensPath, {
      timestamp: isoTs,
      agent: canonicalActor,
      tokens: chatTokenCount,
      module,
      refId: packetRef,
      ref: `TriLog Chat: ${String(summary).substring(0, 60)}`,
      scope: 'report',
      channel: 'chat'
    });
    written.push('TOKENS');
    publishEvent('tokens:updated', { agent: canonicalActor, tokens: processTokenCount, timestamp: isoTs, refId: packetRef, scope: 'work' });

    // 3. SHADOW LOG (markdown)
    // El shadow es el negativo del LOG: lo que el agente percibió pero no volcó.
    // Formato canónico: PACKET + TAREA (contexto) + SOMBRA (observación latente).
    const shadowEntry =
      `\n---\n` +
      `**[${canaryTs} Atlantic/Canary] VOZ ${canonicalActor.toUpperCase()} (SOMBRA):**\n` +
      `**PACKET:** ${packetRef}\n` +
      `**TAREA:** ${summary}\n` +
      `**SOMBRA:**\n${shadowContent}\n`;

    const existingShadow = fs.existsSync(ARGOS_GLOBAL_SHADOW_PATH)
      ? fs.readFileSync(ARGOS_GLOBAL_SHADOW_PATH, 'utf-8')
      : '# ARGOS GLOBAL SHADOW LOG\nRegistro latente.\n';
    fs.writeFileSync(ARGOS_GLOBAL_SHADOW_PATH, existingShadow + shadowEntry, 'utf-8');
    written.push('SHADOW');

    // 4. Captain feed (notificaciÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n al chat)
    const feedPath = path.join(RUNTIME_DIR, 'views', 'ui_export', 'captain_feed.jsonl');
    appendJsonlRecord(feedPath, {
      id: nextFeedMessageId(),
      timestamp: isoTs,
      kind: 'session_close',
      speaker: 'crew',
      sender_name: canonicalActor,
      sender_role: 'agent',
      audience: 'captain',
      source: 'trilog',
      summary: `[CIERRE] ${summary}`,
      details: feedDetails,
      status,
      tokens: 0,
      refId: packetRef,
      transcriptRef: normaliseText(transcriptRef)
    });
    written.push('FEED');

    // 5. Resetear Estado de IAs â†’ Standby
    setIaStandby(canonicalActor);
    publishEvent('ia:status_changed', { agent: canonicalActor, status: 'standby', task: '', subject: '' });

    // 6. Pub/Sub: notificar a suscritos
    publishEvent('session:closed', {
      actor: canonicalActor,
      packetId: packetRef,
      summary,
      tokens: processTokenCount,
      token_breakdown: {
        process: processTokenCount,
        trilog: trilogTokenCount,
        chat: chatTokenCount
      }
    });

    res.json({
      status: 'ok',
      written,
      timestamp: isoTs,
      token_breakdown: {
        process: processTokenCount,
        trilog: trilogTokenCount,
        chat: chatTokenCount
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Fallo en tri-log de sesiÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n', detail: String(error) });
  }
});

// ============ TRANSCRIPT ENDPOINTS ============

// GET /api/transcript?agent=Claude&date=2026-04-12&packetId=ARG-XXXX
// Devuelve el bloque de transcript (o el archivo completo si no se especifica packetId)
app.get('/api/transcript', (req: Request, res: Response) => {
  try {
    const agent = normaliseText(req.query.agent as string) || 'Claude';
    const date = normaliseText(req.query.date as string) || transcriptDateStr();
    const packetId = normaliseText(req.query.packetId as string);

    if (packetId) {
      const block = readTranscriptBlock(agent, date, packetId);
      if (!block) return res.status(404).json({ error: `No transcript block for ${packetId} in ${date}_${agent}` });
      return res.json({ agent, date, packetId, content: block });
    }

    const safeName = agent.replace(/[^a-zA-Z0-9_-]/g, '_');
    const filePath = path.join(TRANSCRIPTS_DIR, `${date}_${safeName}.md`);
    if (!fs.existsSync(filePath)) return res.status(404).json({ error: `No transcript for ${agent} on ${date}` });
    const content = fs.readFileSync(filePath, 'utf-8');
    return res.json({ agent, date, content });
  } catch (e) {
    res.status(500).json({ error: 'Fallo leyendo transcript', detail: String(e) });
  }
});

// GET /api/transcript/list?date=2026-04-12
// Lista los archivos de transcript disponibles para una fecha (o hoy)
app.get('/api/transcript/list', (req: Request, res: Response) => {
  try {
    const date = normaliseText(req.query.date as string) || transcriptDateStr();
    if (!fs.existsSync(TRANSCRIPTS_DIR)) return res.json({ date, files: [] });
    const files = fs.readdirSync(TRANSCRIPTS_DIR)
      .filter(f => f.startsWith(date) && f.endsWith('.md'))
      .map(f => ({ file: f, agent: f.replace(`${date}_`, '').replace('.md', '') }));
    res.json({ date, files });
  } catch (e) {
    res.status(500).json({ error: 'Fallo listando transcripts', detail: String(e) });
  }
});

// POST /api/transcript
// Permite a Claude Code (u otras IAs externas) escribir bloques de transcript literales.
// Body: { agent, role, content, packetId }
app.post('/api/transcript', (req: Request, res: Response) => {
  try {
    const { agent, role, content, packetId } = req.body;
    if (!agent || !content) return res.status(400).json({ error: 'agent y content son obligatorios' });
    const validRole = role === 'captain' ? 'captain' : 'agent';
    const tRef = appendToTranscript(
      normalizeAgentName(agent) || agent,
      validRole,
      content,
      packetId || ''
    );
    res.json({ status: 'ok', transcriptRef: tRef });
  } catch (e) {
    res.status(500).json({ error: 'Fallo escribiendo transcript', detail: String(e) });
  }
});

// GET /api/transcript/packet?packetId=ARG-XXXX
// Devuelve todos los bloques de transcript de TODAS las IAs para un packetId concreto.
// Escanea todos los archivos en transcripts/ buscando el anchor <!-- ARG-XXXX -->.
app.get('/api/transcript/packet', (req: Request, res: Response) => {
  try {
    const packetId = normaliseText(req.query.packetId as string);
    if (!packetId) return res.status(400).json({ error: 'packetId requerido' });

    const results: Array<{ agent: string; date: string; file: string; content: string }> = [];

    if (!fs.existsSync(TRANSCRIPTS_DIR)) return res.json({ packetId, transcripts: [] });

    const files = fs.readdirSync(TRANSCRIPTS_DIR).filter(f => f.endsWith('.md')).sort().reverse();
    const anchor = `<!-- ${packetId} -->`;

    for (const file of files) {
      const content = fs.readFileSync(path.join(TRANSCRIPTS_DIR, file), 'utf-8');
      if (!content.includes(anchor)) continue;

      // Extraer el bloque completo entre el anchor y el siguiente '---'
      const start = content.indexOf(anchor);
      const afterBlock = content.indexOf('\n---\n', start);
      const end = afterBlock !== -1 ? afterBlock + 5 : content.length;
      const block = content.slice(start, end).trim();

      // Parsear FECHA y AGENTE del nombre del archivo: YYYY-MM-DD_AGENTE.md
      const nameParts = file.replace('.md', '').split('_');
      const date = nameParts[0];
      const agent = nameParts.slice(1).join('_');

      results.push({ agent, date, file, content: block });
    }

    res.json({ packetId, transcripts: results });
  } catch (e) {
    res.status(500).json({ error: 'Fallo buscando transcripts por packet', detail: String(e) });
  }
});

// GET /api/transcript/feed?date=YYYY-MM-DD (opcional, default hoy)
// Devuelve lista plana de todos los bloques de transcript para una fecha.
// Formato: [{ timestamp, agent, packetId, content }]
app.get('/api/transcript/feed', (req: Request, res: Response) => {
  try {
    const date = normaliseText(req.query.date as string) || transcriptDateStr();

    if (!fs.existsSync(TRANSCRIPTS_DIR)) return res.json({ date, entries: [] });

    // Todos los archivos del día: YYYY-MM-DD_AGENTE.md
    const files = fs.readdirSync(TRANSCRIPTS_DIR)
      .filter((f) => f.startsWith(date) && f.endsWith('.md'))
      .sort();

    const entries: Array<{ timestamp: string; agent: string; packetId: string; content: string }> = [];

    for (const file of files) {
      const nameParts = file.replace('.md', '').split('_');
      const agent = nameParts.slice(1).join('_') || 'Unknown';
      const rawContent = fs.readFileSync(path.join(TRANSCRIPTS_DIR, file), 'utf-8');

      // Parsear cada bloque: delimitado por <!-- ARG-XXXX --> ... hasta el siguiente ---
      const blockRegex = /<!-- ([\w\-]+) -->\n([\s\S]*?)(?=\n<!-- [\w\-]+ -->|$)/g;
      let match: RegExpExecArray | null;
      while ((match = blockRegex.exec(rawContent)) !== null) {
        const packetId = match[1];
        const blockText = match[2].trim();
        // Extraer timestamp de la línea ## [YYYY-MM-DD HH:MM]
        const tsMatch = blockText.match(/## \[(\d{4}-\d{2}-\d{2}[^\]]*)\]/);
        const timestamp = tsMatch ? tsMatch[1] : date;
        entries.push({ timestamp, agent, packetId, content: blockText });
      }
    }

    // Ordenar por timestamp desc
    entries.sort((a, b) => b.timestamp.localeCompare(a.timestamp));

    res.json({ date, entries });
  } catch (e) {
    res.status(500).json({ error: 'Fallo leyendo transcript feed', detail: String(e) });
  }
});

app.get('/api/tasks', (req: Request, res: Response) => {
  try {
    const tasks = [
      ...loadTasksFromZone('inbox'),
      ...loadTasksFromZone('in_progress'),
      ...loadTasksFromZone('done')
    ];

    // Orden canonico:
    // 1) Pendientes (open/in_progress): prioridad desc (high > mid > low), luego recencia desc
    // 2) Completadas al final, por recencia desc
    const PRIORITY_RANK: Record<string, number> = { high: 3, mid: 2, low: 1 };
    const byPriorityThenRecency = (a: TaskRecord, b: TaskRecord) => {
      const pa = PRIORITY_RANK[a.priority] ?? 1;
      const pb = PRIORITY_RANK[b.priority] ?? 1;
      if (pb !== pa) return pb - pa; // mayor prioridad primero
      return b.mtimeMs - a.mtimeMs;  // misma prioridad → más reciente primero
    };
    const pendingTasks = tasks
      .filter((task) => task.status !== 'done')
      .sort(byPriorityThenRecency);
    const doneTasks = tasks
      .filter((task) => task.status === 'done')
      .sort((a, b) => b.mtimeMs - a.mtimeMs);
    const orderedTasks = [...pendingTasks, ...doneTasks];

    res.json({
      tasks: orderedTasks.map(({ mtimeMs, ...task }) => task)
    });
  } catch (error) {
    res.status(500).json({ error: 'Fallo desenterrando los work packets fisicos del inbox' });
  }
});

app.get('/api/tasks/get', (req: Request, res: Response) => {
  try {
    const packetId = normaliseText(String(req.query.packetId || ''));
    if (packetId === '') return res.status(400).json({ error: 'packetId requerido' });

    const resolved = findWorkPacketById(packetId);
    if (!resolved) return res.status(404).json({ error: `Packet ${packetId} no encontrado` });

    const owner = getPacketField(resolved.content, 'ROLE_REQUESTED') || getPacketField(resolved.content, 'OWNER') || 'Cualquiera';
    const subject = getPacketField(resolved.content, 'SUBJECT') || resolved.packetId;
    const currentStatus = normalizeTaskStatus(
      getPacketField(resolved.content, 'STATUS'),
      resolved.zone === 'done' ? 'done' : resolved.zone === 'in_progress' ? 'in_progress' : 'open'
    );
    const objective = extractPacketObjective(resolved.content);
    const packetType = getPacketField(resolved.content, 'TYPE') || 'task';
    const priority = getPacketField(resolved.content, 'PRIORITY') || 'low';
    const tokensSpent = Number(getPacketField(resolved.content, 'TOKENS_SPENT')) || 0;

    return res.json({
      status: 'ok',
      packet: {
        id: resolved.packetId,
        owner,
        subject,
        status: currentStatus,
        objective,
        zone: resolved.zone,
        type: packetType,
        priority,
        tokens_spent: tokensSpent,
        fileName: resolved.fileName
      }
    });
  } catch (error) {
    return res.status(500).json({ error: 'Fallo leyendo el work packet', detail: String(error) });
  }
});

// ============ ENDPOINT: Get AI My Packets ============
app.get('/api/my-packets', (req: Request, res: Response) => {
  try {
    const actor = req.query.actor ? String(req.query.actor).toLowerCase() : '';
    if (!actor) return res.status(400).json({ error: 'actor parameter is required' });

    const inbox = loadTasksFromZone('inbox');
    const inProgress = loadTasksFromZone('in_progress');
    const all = [...inbox, ...inProgress];

    const myPackets = all.filter(task => {
      const owner = task.owner.toLowerCase();
      return owner.includes(actor) || owner.includes('cualquiera');
    }).map(task => ({
      id: task.id,
      priority: task.priority,
      subject: task.title,
      status: task.status,
      created_at: task.created_at,
      estimated_time: task.estimated_time
    }));

    res.json({
      my_packets: myPackets,
      total: myPackets.length,
      updated_at: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: 'Fallo al obtener mis paquetes', detail: String(error) });
  }
});

// --- PENDING ACTIONS MANAGEMENT ---

app.get('/api/ia/pending-actions', (_req: Request, res: Response) => {
  if (!fs.existsSync(PENDING_ACTIONS_PATH)) return res.json([]);
  const lines = fs.readFileSync(PENDING_ACTIONS_PATH, 'utf-8').split('\n').filter(l => l.trim() !== '');
  const actions = lines.map(l => JSON.parse(l));
  return res.json(actions);
});

app.post('/api/ia/approve-action', (req: Request, res: Response) => {
  const actionId = req.body.actionId;
  if (!actionId) return res.status(400).json({ error: 'actionId requerido' });
  
  if (!fs.existsSync(PENDING_ACTIONS_PATH)) return res.status(404).json({ error: 'No hay acciones pendientes' });
  
  const lines = fs.readFileSync(PENDING_ACTIONS_PATH, 'utf-8').split('\n').filter(l => l.trim() !== '');
  const actions = lines.map(l => JSON.parse(l));
  const actionIdx = actions.findIndex(a => a.id === actionId);
  
  if (actionIdx === -1) return res.status(404).json({ error: 'Accion no encontrada' });
  
  const action = actions[actionIdx];
  
  // Ejecutar la accion original SIN pasar por el interceptor (bypass)
  // Nota: Esto requiere que los endpoints originales acepten un flag de bypass o que llamemos a la logica directamente.
  // Por ahora, simularemos la ejecucion llamando a la logica interna o marcando el actor como 'Captain' temporalmente.
  
  const originalBody = action.payload;
  originalBody.actor = 'Captain'; // Forzar autorizacion
  
  // Simulacion de re-peticion interna (loopback)
  // En una API real usariamos un dispatcher interno. Aqui llamaremos al endpoint correspondiente.
  // Para simplificar esta version, borramos de pendientes y pedimos al usuario que 're-ejecute' o implementamos el switch:
  
  actions.splice(actionIdx, 1);
  const nextLines = actions.map(a => JSON.stringify(a)).join('\n');
  fs.writeFileSync(PENDING_ACTIONS_PATH, nextLines === '' ? '' : nextLines + '\n');
  
  // Actualizar estado si ya no quedan
  if (actions.length === 0) {
    const state = readArgosState();
    if (state.security) {
      state.security.has_pending_actions = false;
      writeArgosState(state);
    }
  }
  
  return res.json({ status: 'approved', originalAction: action.action, message: 'La accion ha sido validada y debe ser re-enviada por el sistema con firma de Capitan o procesada internamente.' });
});

app.post('/api/tasks/update', (req: Request, res: Response) => {
  interceptAction(req, res, 'tasks/update', () => {
    try {
      const packetId = normaliseText(req.body.packetId);
      if (packetId === '') return res.status(400).json({ error: 'packetId requerido' });

    const resolved = findWorkPacketById(packetId);
    if (!resolved) return res.status(404).json({ error: `Packet ${packetId} no encontrado` });

    const currentOwner = getPacketField(resolved.content, 'ROLE_REQUESTED') || getPacketField(resolved.content, 'OWNER') || 'Cualquiera';
    const currentSubject = getPacketField(resolved.content, 'SUBJECT') || resolved.packetId;
    const currentStatus = normalizeTaskStatus(
      getPacketField(resolved.content, 'STATUS'),
      resolved.zone === 'done' ? 'done' : resolved.zone === 'in_progress' ? 'in_progress' : 'open'
    );
    const currentObjective = extractPacketObjective(resolved.content);

    const hasSubject = Object.prototype.hasOwnProperty.call(req.body, 'subject');
    const hasOwner = Object.prototype.hasOwnProperty.call(req.body, 'owner');
    const hasStatus = Object.prototype.hasOwnProperty.call(req.body, 'status');
    const hasObjective = Object.prototype.hasOwnProperty.call(req.body, 'objective');
    if (!hasSubject && !hasOwner && !hasStatus && !hasObjective) {
      return res.status(400).json({ error: 'Nada que actualizar. Envia subject, owner, status u objective.' });
    }

    const nextSubject = hasSubject ? normaliseText(req.body.subject) : currentSubject;
    const nextOwner = hasOwner ? normaliseText(req.body.owner) : currentOwner;
    const nextObjective = hasObjective ? String(req.body.objective ?? '').replace(/\r/g, '').trim() : currentObjective;
    const nextStatus = hasStatus ? normalizeTaskStatus(req.body.status, currentStatus) : currentStatus;
    if (nextSubject === '') return res.status(400).json({ error: 'subject no puede quedar vacio' });
    if (nextOwner === '') return res.status(400).json({ error: 'owner no puede quedar vacio' });
    if (nextObjective === '') return res.status(400).json({ error: 'objective no puede quedar vacio' });

    let nextContent = resolved.content;
    nextContent = upsertPacketField(nextContent, 'SUBJECT', nextSubject);
    if (/^ROLE_REQUESTED:\s*/m.test(nextContent)) {
      nextContent = upsertPacketField(nextContent, 'ROLE_REQUESTED', nextOwner);
    } else if (/^OWNER:\s*/m.test(nextContent)) {
      nextContent = upsertPacketField(nextContent, 'OWNER', nextOwner);
    } else {
      nextContent = upsertPacketField(nextContent, 'ROLE_REQUESTED', nextOwner);
    }
    nextContent = upsertPacketField(nextContent, 'STATUS', nextStatus);
    nextContent = replacePacketObjective(nextContent, nextObjective);

    const nextZone = statusToZone(nextStatus);
    const nextPath = path.join(RUNTIME_DIR, 'work_packets', nextZone);
    if (!fs.existsSync(nextPath)) fs.mkdirSync(nextPath, { recursive: true });
    const targetFilePath = path.join(nextPath, resolved.fileName);

    fs.writeFileSync(targetFilePath, nextContent, 'utf-8');
    if (targetFilePath !== resolved.filePath && fs.existsSync(resolved.filePath)) {
      fs.unlinkSync(resolved.filePath);
    }

    const nowIso = new Date().toISOString();
    const canaryTs = new Date(nowIso).toLocaleString('sv-SE', {
      timeZone: 'Atlantic/Canary',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    }).slice(0, 16);
    const actor = normaliseText(req.body.actor) || 'Captain';
    appendJsonlRecord(ARGOS_EVENTS_PATH, {
      timestamp: nowIso,
      timestamp_label: canaryTs,
      actor,
      module: 'argos',
      type: 'packet_edit',
      status: nextStatus,
      packet_id: resolved.packetId,
      refId: resolved.packetId,
      summary: `Work packet editado: ${nextSubject}`,
      details: `OWNER=${nextOwner} | ZONA=${resolved.zone}->${nextZone}`,
      source: 'api:tasks/update'
    });

    const syncResult = runSyncState();
    if (!syncResult.ok) {
      console.warn('[ARGOS-API] sync_state fallo tras editar task:', syncResult.stderr || syncResult.stdout);
    }

    const refreshResult = maybeRefreshLogbookSnapshot();
    if (refreshResult && !refreshResult.ok) {
      console.warn('[ARGOS-API] merge_argos_history fallo tras editar task:', refreshResult.stderr || refreshResult.stdout);
    }

    publishEvent('task:updated', {
      packetId: resolved.packetId,
      zone: nextZone,
      status: nextStatus,
      actor
    });

    return res.json({
      status: 'ok',
      packet: {
        id: resolved.packetId,
        owner: nextOwner,
        subject: nextSubject,
        status: nextStatus,
        objective: nextObjective,
        zone: nextZone
      }
    });
  } catch (error) {
    return res.status(500).json({ error: 'Fallo actualizando el work packet', detail: String(error) });
  }
  });
});

app.get('/api/bugs', (req: Request, res: Response) => {
  try {
    const bugs = loadBugsFromAllZones();
    const glitches = loadGlitchesFromJsonl();
    const all = [...bugs, ...glitches].sort((a, b) => (SEVERITY_RANK[a.severity] ?? 4) - (SEVERITY_RANK[b.severity] ?? 4));
    res.json({ bugs: all });
  } catch (err) {
    res.status(500).json({ error: 'Fallo exhumando bugs del sistema.' });
  }
});

// ============ ENDPOINT: IA Start Task ============
// Un solo POST mueve el packet a in_progress, postea al feed y registra la IA como activa.
app.post('/api/ia/start-task', (req: Request, res: Response) => {
  try {
    const { packetId, actor, summary = '' } = req.body;
    if (!packetId) return res.status(400).json({ error: 'packetId requerido' });
    if (!actor) return res.status(400).json({ error: 'actor requerido' });

    const zones = ['inbox', 'in_progress'];
    let foundPath: string | null = null;
    let foundZone: string | null = null;
    let filename: string | null = null;

    for (const zone of zones) {
      const dir = path.join(RUNTIME_DIR, 'work_packets', zone);
      if (!fs.existsSync(dir)) continue;
      const files = fs.readdirSync(dir).filter(f => f.endsWith('.md'));
      for (const f of files) {
        const fullPath = path.join(dir, f);
        const content = fs.readFileSync(fullPath, 'utf-8');
        const idMatch = content.match(/^ID:\s*(.+)$/m);
        if (idMatch && idMatch[1].trim() === packetId) {
          foundPath = fullPath;
          foundZone = zone;
          filename = f;
          break;
        }
      }
      if (foundPath) break;
    }

    if (!foundPath || !filename) {
      return res.status(404).json({ error: `Packet ${packetId} no encontrado en inbox o in_progress` });
    }

    // Mover a in_progress si estaba en inbox
    const inProgressDir = path.join(RUNTIME_DIR, 'work_packets', 'in_progress');
    if (!fs.existsSync(inProgressDir)) fs.mkdirSync(inProgressDir, { recursive: true });

    let content = fs.readFileSync(foundPath, 'utf-8');
    const subjectMatch = content.match(/^SUBJECT:\s*(.+)$/m);
    const packetSubject = subjectMatch ? subjectMatch[1].trim() : packetId;
    // summary del agente tiene prioridad; fallback al SUBJECT del packet (truncado a 120 chars)
    const rawSubject = normaliseText(summary) || packetSubject;
    const subject = rawSubject.length > 120 ? rawSubject.slice(0, 117) + '...' : rawSubject;

    // Actualizar STATUS en el contenido
    if (/^STATUS:\s*.+$/m.test(content)) {
      content = content.replace(/^STATUS:\s*.+$/m, 'STATUS: in_progress');
    } else {
      content = content.replace(/(\[WORK_PACKET\]\n)/, '$1STATUS: in_progress\n');
    }

    const destPath = path.join(inProgressDir, filename);
    fs.writeFileSync(destPath, content, 'utf-8');
    if (foundZone === 'inbox') {
      fs.unlinkSync(foundPath);
    }

    // Actualizar state.json
    const state = readArgosState();
    if (!state.packet_states) state.packet_states = {};
    state.packet_states[packetId] = 'in_progress:in_progress';
    if (!Array.isArray(state.in_progress_packets)) state.in_progress_packets = [];
    if (!state.in_progress_packets.includes(packetId)) {
      state.in_progress_packets.push(packetId);
    }
    // Quitar de open_packets si estaba
    if (Array.isArray(state.open_packets)) {
      state.open_packets = state.open_packets.filter((id: string) => id !== packetId);
    }
    writeArgosState(state);

    // Marcar IA como activa en el widget Estado de IAs
    setIaActive(actor, packetId, subject);

    // Postear al captain feed
    const voiceName = normalizeAgentName(actor) === 'Claude' ? 'Orfeo (Claude)' : actor;
    postToCrewFeed(
      voiceName,
      `Tomando misiÃ³n: ${subject}`,
      `ID: ${packetId} â€” en progreso.`,
      'crew_update',
      0,
      packetId
    );

    // Pub/Sub: notificar al dashboard en tiempo real
    publishEvent('ia:status_changed', { agent: normalizeAgentName(actor), status: 'active', task: packetId, subject });

    return res.json({
      status: 'ok',
      packetId,
      subject,
      movedFrom: foundZone,
      movedTo: 'in_progress'
    });
  } catch (error) {
    console.error('[IA/START-TASK]', error);
    res.status(500).json({ error: 'Fallo al iniciar tarea', detail: String(error) });
  }
});

// ============ ENDPOINT: IA Status manual (GET + POST) ============
app.get('/api/ia/status', (_req: Request, res: Response) => {
  const state = readArgosState();
  const baseStatus = readIaStatus(state);
  const inferredStatus = inferIaStatusFromTasks(baseStatus);
  res.json({ ia_status: inferredStatus });
});

app.post('/api/ia/status', (req: Request, res: Response) => {
  const { actor, status, task = '', task_subject = '' } = req.body;
  if (!actor || !status) return res.status(400).json({ error: 'actor y status requeridos' });
  if (status !== 'active' && status !== 'standby' && status !== 'restricted') {
    return res.status(400).json({ error: 'status debe ser "active", "standby" o "restricted"' });
  }
  if (status === 'active') {
    setIaActive(actor, task, task_subject);
  } else {
    setIaStandby(actor);
  }
  const agent = normalizeAgentName(actor);
  publishEvent('ia:status_changed', { agent, status, task, subject: task_subject });
  return res.json({ status: 'ok', agent, ia_status: status });
});

app.post('/api/tasks', (req: Request, res: Response) => {
  try {
    const body = req.body;
    if (!body.rawText) return res.status(400).json({ error: 'Empty transmission' });

    const rawText = body.rawText as string;
    const owner = inferTaskOwner(rawText);
    const subject = inferTaskSubject(rawText);
    const pktId = `ARG-${Date.now()}`;
    const packetSuffix = subjectToPacketSuffix(subject);
    const wpPath = path.join(RUNTIME_DIR, 'work_packets', 'inbox', `${pktId}__${packetSuffix}.md`);

    const packetContent = `[WORK_PACKET]
ID: ${pktId}
ROLE_REQUESTED: ${owner}
SUBJECT: ${subject}
STATUS: open
TOKENS_SPENT: ${estimateTokenCount(rawText)}

OBJECTIVE:
${rawText}
[/WORK_PACKET]`;

    fs.writeFileSync(wpPath, packetContent, 'utf-8');

    // Transcript: registrar el prompt literal del Capitán
    // El agente destino es el owner (o 'crew' si es Cualquiera)
    const transcriptAgent = normalizeAgentName(owner) || owner || 'crew';
    const tRef = appendToTranscript(transcriptAgent, 'captain', rawText, pktId);

    const captainFeedPath = path.join(RUNTIME_DIR, 'views', 'ui_export', 'captain_feed.jsonl');
    const estimatedTokens = estimateTokenCount(rawText);

    appendJsonlRecord(captainFeedPath, {
      id: nextFeedMessageId(),
      timestamp: new Date().toISOString(),
      kind: 'captain_order',
      speaker: 'captain',
      sender_name: 'Ruben Thor',
      sender_role: 'captain',
      audience: 'crew',
      source: 'ui_chat',
      summary: rawText,
      details: '',
      status: 'recorded',
      tokens: 0,
      refId: pktId,
      transcriptRef: tRef
    });

    // Record token usage for task creation (Input tokens linked to ID)
    const tokensPath = path.join(RUNTIME_DIR, 'events', 'argos.tokens.jsonl');
    appendJsonlRecord(tokensPath, {
      timestamp: new Date().toISOString(),
      agent: 'Captain (Input)',
      tokens: estimatedTokens,
      module: 'argos',
      refId: pktId,
      ref: `New Task: ${subject}`,
      scope: 'input',
      channel: 'captain_input'
    });

    const syncResult = runSyncState();
    if (!syncResult.ok) {
      console.warn('[ARGOS-API] sync_state fallo tras crear task:', syncResult.stderr || syncResult.stdout);
    }

    const refreshResult = maybeRefreshLogbookSnapshot();
    if (refreshResult && !refreshResult.ok) {
      console.warn('[ARGOS-API] merge_argos_history fallo tras crear task:', refreshResult.stderr || refreshResult.stdout);
    }

    // Publish event: packet assigned
    publishEvent('packet:assigned', {
      id: pktId,
      priority: 'low', // Default as inferred in code above
      subject,
      actor: owner
    });

    res.json({ 
      status: 'ok', 
      id: pktId, 
      owner, 
      subject,
      tokens: estimatedTokens
    });
  } catch (error) {
    res.status(500).json({ error: 'Fallo al orquestar forja del Work Packet y el feed del capitan' });
  }
});

app.post('/api/tasks/delete', (req: Request, res: Response) => {
  try {
    const { taskIds } = req.body;
    if (!Array.isArray(taskIds) || taskIds.length === 0) {
      return res.status(400).json({ error: 'taskIds must be a non-empty array' });
    }

    const workPacketsDir = path.join(RUNTIME_DIR, 'work_packets');
    const zones = ['inbox', 'in_progress', 'done'];
    const trashDir = path.join(workPacketsDir, 'trash');

    // Ensure trash directory exists
    if (!fs.existsSync(trashDir)) {
      fs.mkdirSync(trashDir, { recursive: true });
    }

    const movedFiles: string[] = [];
    const notFoundIds: string[] = [];

    taskIds.forEach((taskId) => {
      let found = false;

      // Search in all zones
      for (const zone of zones) {
        const zoneDir = path.join(workPacketsDir, zone);
        if (!fs.existsSync(zoneDir)) continue;

        const files = fs.readdirSync(zoneDir);
        const matchingFile = files.find(f => f.startsWith(`${taskId}__`) || f.includes(`_${taskId}__`) || f === `${taskId}.md`);

        if (matchingFile) {
          const sourcePath = path.join(zoneDir, matchingFile);
          const destPath = path.join(trashDir, matchingFile);

          try {
            fs.copyFileSync(sourcePath, destPath);
            fs.unlinkSync(sourcePath);
            movedFiles.push(matchingFile);
            found = true;
            break;
          } catch (e) {
            console.warn(`[ARGOS-API] Error moving file ${matchingFile}:`, e);
          }
        }
      }

      if (!found) {
        notFoundIds.push(taskId);
      }
    });

    // Record deletion event
    const captainFeedPath = path.join(RUNTIME_DIR, 'views', 'ui_export', 'captain_feed.jsonl');
    if (movedFiles.length > 0) {
      appendJsonlRecord(captainFeedPath, {
        id: nextFeedMessageId(),
        timestamp: new Date().toISOString(),
        kind: 'captain_deletion',
        speaker: 'captain',
        sender_name: 'Ruben Thor',
        sender_role: 'captain',
        audience: 'crew',
        source: 'ui_deletion',
        summary: `Movidas ${movedFiles.length} orden(es) a papelera: ${taskIds.join(', ')}`,
        details: '',
        status: 'recorded',
        tokens: 0,
        refId: ''
      });
    }

    res.json({
      status: 'ok',
      movedCount: movedFiles.length,
      movedFiles,
      notFound: notFoundIds
    });
  } catch (error) {
    res.status(500).json({ error: 'Fallo al mover ordenes a papelera' });
  }
});

app.get('/api/vector', (req: Request, res: Response) => {
  try {
    const vector = parseVectorMarkdown();
    res.json(vector);
  } catch (error) {
    res.status(500).json({ error: 'Fallo al recuperar el Vector de ruta' });
  }
});

app.get('/api/risks', (req: Request, res: Response) => {
  try {
    const shadowPath = path.join(RUNTIME_DIR, 'ARGOS_GLOBAL_SHADOW_LOG.md');
    const risks: any[] = [];

    // 1. Risks from Shadow Log
    if (fs.existsSync(shadowPath)) {
      const content = fs.readFileSync(shadowPath, 'utf-8');
      const blocks = content.split('---');
      blocks.forEach(block => {
        if (block.includes('RIESGO DETECTADO') || block.includes('Peligro de')) {
          const timeMatch = block.match(/\[(.*?)\]/);
          const stateMatch = block.match(/\*\*ESTADO:\*\*\s*(.*)/);
          const detailsMatch = block.match(/\*\*DETALLES:\*\*([\s\S]*?)(?=\n\n|\n---|$)/);
          let snippet = detailsMatch ? detailsMatch[1].trim() : block.trim().substring(0, 100);
          if (snippet.length > 120) snippet = snippet.substring(0, 120) + '...';
          risks.push({
            id: timeMatch ? timeMatch[1] : `ID-${Date.now()}`,
            time: timeMatch ? timeMatch[1] : 'Desconocido',
            state: stateMatch ? stateMatch[1] : 'Alerta',
            snippet,
            raw: block.trim(),
            type: 'risk'
          });
        }
      });
    }

    // 2. Risks from Work Packets (e.g. Lola alerts) - Specifically check for TYPE: risk
    const zones: Array<'inbox' | 'in_progress'> = ['inbox', 'in_progress'];
    for (const zone of zones) {
        const zonePath = path.join(RUNTIME_DIR, 'work_packets', zone);
        if (!fs.existsSync(zonePath)) continue;
        const files = fs.readdirSync(zonePath).filter(f => f.endsWith('.md'));
        for (const file of files) {
            const fullPath = path.join(zonePath, file);
            const content = fs.readFileSync(fullPath, 'utf-8');
            if (content.includes('TYPE: risk')) {
                const packetId = getPacketField(content, 'ID') || file;
                const packetSubject = getPacketField(content, 'SUBJECT') || 'Riesgo detectado';
                const packetState = getPacketField(content, 'STATUS') || 'RIESGO';
                const packetReportedAt = getPacketField(content, 'REPORTED_AT');
                const stressLevel = extractLolaStressLevel(content);
                const alertBodyMatch = content.match(/\[ALERTA DE LOLA\]([\s\S]*?)$/);
                const alertBody = alertBodyMatch ? alertBodyMatch[1].replace(/\s+/g, ' ').trim() : '';
                let snippet = alertBody !== '' ? alertBody : packetSubject;

                if (stressLevel !== null) {
                  snippet = `Estres ${stressLevel}. ${snippet}`;
                }

                if (snippet.length > 160) snippet = `${snippet.substring(0, 160)}...`;

                risks.push({
                    id: packetId,
                    time: packetReportedAt || formatRelativeAge(fs.statSync(fullPath).mtimeMs),
                    state: packetState,
                    snippet,
                    stress_level: stressLevel,
                    zone,
                    type: 'risk'
                });
            }
        }
    }

    const uniqueRisks = Array.from(new Map(risks.map(r => [r.id, r])).values());
    const collapsedLolaRisks: any[] = [];
    const seenLolaSignals = new Set<string>();

    uniqueRisks.forEach((risk) => {
      const riskId = normaliseText((risk as { id?: string }).id);
      const isLolaRisk = riskId.startsWith('LOLA-RISK-');
      if (!isLolaRisk) {
        collapsedLolaRisks.push(risk);
        return;
      }

      const normalizedSnippet = normaliseText((risk as { snippet?: string }).snippet).toLowerCase().slice(0, 140);
      const stressValue = normaliseText(String((risk as { stress_level?: number | null }).stress_level ?? ''));
      const signalKey = `${stressValue}|${normalizedSnippet}`;
      if (seenLolaSignals.has(signalKey)) return;

      seenLolaSignals.add(signalKey);
      collapsedLolaRisks.push(risk);
    });

    res.json({ risks: collapsedLolaRisks.reverse() });
  } catch (err) {
    res.status(500).json({ error: 'Fallo al procesar shadow log.' });
  }
});

app.get('/api/events', (req: Request, res: Response) => {
  const query = (req.query.query as string || '').trim();
  if (!query) return res.json({ query, hits: [] });
  
  try {
    const shadowPath = path.join(RUNTIME_DIR, 'ARGOS_GLOBAL_SHADOW_LOG.md');
    const globalPath = path.join(RUNTIME_DIR, 'ARGOS_GLOBAL_LOG.md');
    const glitchPath = path.join(RUNTIME_DIR, 'ARGOS_GLOBAL_GLITCH_LOG.md');
    const feedPath = path.join(RUNTIME_DIR, 'views', 'ui_export', 'captain_feed.jsonl');
    const eventsPath = path.join(RUNTIME_DIR, 'events', 'argos.events.jsonl');
    const glitchesJsonPath = path.join(RUNTIME_DIR, 'events', 'argos.glitches.jsonl');
    
    const results: any[] = [];
    
    [shadowPath, globalPath, glitchPath].forEach(p => {
      if (fs.existsSync(p)) {
        const text = fs.readFileSync(p, 'utf-8');
        const blocks = text.split('---');
        blocks.forEach(b => {
          if (b.includes(query)) results.push({ source: path.basename(p), content: b.trim() });
        });
      }
    });

    if (fs.existsSync(feedPath)) {
      const lines = fs.readFileSync(feedPath, 'utf-8').split('\n');
      lines.forEach(l => {
         if (l.includes(query)) {
           try {
             const d = JSON.parse(l);
             results.push({ source: 'captain_feed.jsonl', content: `[${d.timestamp}] ${d.sender_name}: ${d.summary}\n${d.details}` });
           } catch(e){}
         }
      });
    }

    [eventsPath, glitchesJsonPath].forEach((jsonlPath) => {
      if (!fs.existsSync(jsonlPath)) return;

      const lines = fs.readFileSync(jsonlPath, 'utf-8').split('\n');
      lines.forEach((line) => {
        if (!line.includes(query)) return;

        try {
          const parsed = JSON.parse(line) as Record<string, unknown>;
          const summary = normaliseText(parsed.summary);
          const details = normaliseText(parsed.details);
          const verification = normaliseText(parsed.verification);
          const nextStep = normaliseText(parsed.next_step);
          const timestamp = normaliseText(parsed.timestamp) || normaliseText(parsed.timestamp_label);
          const actor = normaliseText(parsed.actor) || normaliseText(parsed.voice);

          results.push({
            source: path.basename(jsonlPath),
            content: `[${timestamp}] ${actor}\n${summary}\n${details}\n${verification}\n${nextStep}`.trim()
          });
        } catch (error) {
          // Ignore malformed lines and keep scanning.
        }
      });
    });

    ['inbox', 'in_progress', 'done'].forEach((zone) => {
      const zonePath = path.join(RUNTIME_DIR, 'work_packets', zone);
      if (!fs.existsSync(zonePath)) return;

      const files = fs.readdirSync(zonePath).filter((f) => f.endsWith('.md'));
      files.forEach((f) => {
        const content = fs.readFileSync(path.join(zonePath, f), 'utf-8');
        if (!content.includes('[WORK_PACKET]')) return;
        if (content.includes(query)) {
          results.push({ source: `Work Packet ${zone} (${f})`, content: content.trim() });
        }
      });
    });

    const transcriptsPath = path.join(RUNTIME_DIR, 'events', 'transcripts');
    if (fs.existsSync(transcriptsPath)) {
      const processFiles = (dir: string) => {
         const items = fs.readdirSync(dir);
         items.forEach(item => {
             const fullPath = path.join(dir, item);
             if (fs.statSync(fullPath).isDirectory()) {
                 processFiles(fullPath);
             } else if (item.endsWith('.md')) {
                 const content = fs.readFileSync(fullPath, 'utf-8');
                 if (content.includes(query)) {
                     // Extract snippet
                     const matchIndex = content.indexOf(query);
                     const start = Math.max(0, matchIndex - 100);
                     const end = Math.min(content.length, matchIndex + 300);
                     let snippet = content.substring(start, end).trim();
                     if (start > 0) snippet = '...' + snippet;
                     if (end < content.length) snippet = snippet + '...';
                     
                     results.push({ source: `Transcript (${item})`, content: snippet });
                 }
             }
         });
      };
      processFiles(transcriptsPath);
    }

    res.json({ query, hits: results });
  } catch(err) {
    res.status(500).json({ error: 'Fallo exhumando eventos.' });
  }
});


const FILE_TREE_CACHE_TTL_MS = 30000;
const FILE_TREE_MAX_DEPTH = 4;
const FILE_TREE_MAX_ITEMS_PER_DIR = 200;
let fileTreeCache: { generatedAt: number; tree: any[] } = { generatedAt: 0, tree: [] };

function getFileTree(dir: string, base: string = '', depth: number = 0): any[] {
  let items: string[] = [];
  try {
    items = fs.readdirSync(dir);
  } catch (error) {
    return [];
  }

  return items
    .filter((item) => !['node_modules', '.git', 'dist'].includes(item))
    .slice(0, FILE_TREE_MAX_ITEMS_PER_DIR)
    .map((item) => {
      const fullPath = path.join(dir, item);
      const relativePath = path.join(base, item);

      let isDir = false;
      try {
        isDir = fs.statSync(fullPath).isDirectory();
      } catch (error) {
        return null;
      }

      return {
        name: item,
        path: relativePath.replace(/\\/g, '/'),
        isDir,
        children: isDir && depth < FILE_TREE_MAX_DEPTH ? getFileTree(fullPath, relativePath, depth + 1) : null
      };
    })
    .filter((node) => node !== null);
}

app.get('/api/files', (req: Request, res: Response) => {
  try {
    const now = Date.now();
    if (fileTreeCache.tree.length > 0 && now - fileTreeCache.generatedAt < FILE_TREE_CACHE_TTL_MS) {
      return res.json({ tree: fileTreeCache.tree, cached: true });
    }

    const tree = getFileTree(RUNTIME_DIR);
    fileTreeCache = { generatedAt: now, tree };
    res.json({ tree, cached: false });
  } catch (error) {
    res.status(500).json({ error: 'Fallo al mapear el Bosque' });
  }
});

app.get('/api/files/content', (req: Request, res: Response) => {
  try {
    const relPath = req.query.path as string;
    if (!relPath) return res.status(400).json({ error: 'Falta ruta' });
    
    // Safety check: ensure path is within RUNTIME_DIR
    const fullPath = path.resolve(RUNTIME_DIR, relPath);
    if (!fullPath.toLowerCase().startsWith(RUNTIME_DIR.toLowerCase().replace(/\//g, '\\'))) {
        return res.status(403).json({ error: 'Acceso denegado' });
    }

    const content = fs.readFileSync(fullPath, 'utf-8');
    res.json({ content });
  } catch (error) {
    res.status(500).json({ error: 'Error leyendo archivo' });
  }
});

app.get('/api/knowledge', (req: Request, res: Response) => {
  try {
    const sources = [
      { id: 'inter-ai-protocol', name: 'Protocolo Inter-AI', path: 'INTER_AI_PROTOCOL.md' },
      { id: 'arch-v2', name: 'Propuesta Arquitectura V2', path: 'ARGOS_ARCHITECTURE_V2_PROPOSAL.md' },
      { id: 'readme', name: 'Manual de Usuario Argos', path: 'README.md' }
    ];
    res.json({ items: sources });
  } catch (error) {
    res.status(500).json({ error: 'Fallo al recuperar el Vellocino' });
  }
});

const PORT = 8080;

let changedFiles = new Set<string>();
let reportTimeout: NodeJS.Timeout | null = null;
const DEBOUNCE_MS = 20000; // 20 segundos de agrupamiento

function reportAntigravityActivity() {
  if (pendingChanges.size === 0) return;
  
  const filesList = Array.from(pendingChanges).join(', ');
  const summary = `Antigravity detectado operando en el sistema.`;
  const details = `Se han detectado modificaciones en: ${filesList}`;
  
  console.log(`[REPORTER] Enviando reporte de actividad automatica: ${filesList}`);
  
  // Post directo al feed
  const feedPath = path.join(RUNTIME_DIR, 'views', 'ui_export', 'captain_feed.jsonl');
  const record = {
    timestamp: new Date().toISOString(),
    kind: 'crew_update',
    speaker: 'crew',
    sender_name: 'Antigravity',
    sender_role: 'agent',
    audience: 'captain',
    source: 'autonomous_watcher',
    summary,
    details,
    status: 'recorded',
    tokens: 0
  };

  try {
    const data = JSON.stringify(record) + '\n';
    fs.appendFileSync(feedPath, data, 'utf-8');
    pendingChanges.clear();
  } catch (e) {
    console.error('[REPORTER] Error grabando reporte autonomo', e);
  }
}

let lastReportedMtime = Date.now();
let pendingChanges = new Set<string>();

function startAntigravityActivityWatcher() {
  const watchTarget = path.resolve(path.join(__dirname, '..', '..')); // En scratch
  
  console.log(`[ARGOS-API] Iniciando polling de actividad en: ${watchTarget}`);

  setInterval(() => {
    try {
      // Escaneo superficial de directorios clave
      const folders = ['argos-dashboard', 'argos-api/src']; // YA NO MIRA work_packets para no duplicar
      let detected = false;

      folders.forEach(f => {
        const full = path.join(watchTarget, f);
        if (!fs.existsSync(full)) return;
        
        const files = fs.readdirSync(full);
        files.forEach(file => {
          if (file.endsWith('.js') || file.endsWith('.ts') || file.endsWith('.html') || file.endsWith('.css')) {
            const stats = fs.statSync(path.join(full, file));
            if (stats.mtimeMs > lastReportedMtime) {
              pendingChanges.add(`${f}/${file}`);
              detected = true;
            }
          }
        });
      });

      if (detected) {
        lastReportedMtime = Date.now();
        // Esperar un ciclo mas para agrupar o reportar si hay cambios
        setTimeout(reportAntigravityActivity, 15000);
      }
    } catch (e) {
      // Silencio operacional en el polling
    }
  }, 15000); // Polling cada 15s (Latido de combate ajustado)
  
  console.log(`[ARGOS-API] Sistema de Vigilancia de Antigravity (IA) configurado.`);
}

// ============================================================
// DEEPSEEK — GUARDIAN DE EFICIENCIA (4º TRIPULANTE)
// Conecta con Ollama local en localhost:11434
// Modelo: deepseek-r1:8b (cabe entero en RTX 4070 8GB VRAM)
// ============================================================

const OLLAMA_BASE = 'http://localhost:11434';
const DEEPSEEK_MODEL = 'qwen3:8b';
const DEEPSEEK_TIMEOUT_MS = 60000; // Ajustado para Qwen 3 8B (vuelo estable)

interface OllamaMessage { role: 'system' | 'user' | 'assistant'; content: string; }

interface OllamaResult { content: string; inputTokens: number; outputTokens: number; }

async function callOllama(messages: OllamaMessage[], timeoutMs = DEEPSEEK_TIMEOUT_MS): Promise<OllamaResult> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const resp = await fetch(`${OLLAMA_BASE}/api/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      signal: controller.signal,
      body: JSON.stringify({ model: DEEPSEEK_MODEL, messages, stream: false })
    });
    if (!resp.ok) throw new Error(`Ollama HTTP ${resp.status}`);
    const data = await resp.json() as {
      message?: { content?: string };
      error?: string;
      prompt_eval_count?: number;
      eval_count?: number;
    };
    if (data.error) throw new Error(data.error);
    return {
      content: (data.message?.content ?? '').trim(),
      inputTokens: data.prompt_eval_count ?? 0,
      outputTokens: data.eval_count ?? 0,
    };
  } finally {
    clearTimeout(timer);
  }
}

async function isOllamaAvailable(): Promise<boolean> {
  try {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 2000);
    const resp = await fetch(`${OLLAMA_BASE}/api/tags`, { signal: controller.signal });
    clearTimeout(timer);
    return resp.ok;
  } catch {
    return false;
  }
}

// GET /api/deepseek/status — ping Ollama y reporta modelo disponible
app.get('/api/deepseek/status', async (_req: Request, res: Response) => {
  const available = await isOllamaAvailable();
  if (!available) {
    return res.json({ available: false, model: DEEPSEEK_MODEL, error: 'Ollama no responde en localhost:11434' });
  }
  try {
    const tagsResp = await fetch(`${OLLAMA_BASE}/api/tags`);
    const tags = await tagsResp.json() as { models?: { name: string }[] };
    const models = (tags.models || []).map(m => m.name);
    const modelLoaded = models.some(m => m.startsWith('deepseek'));
    return res.json({ available: true, model: DEEPSEEK_MODEL, modelLoaded, allModels: models });
  } catch {
    return res.json({ available: true, model: DEEPSEEK_MODEL, modelLoaded: false });
  }
});

// POST /api/deepseek/analyze-task — clasifica si una tarea puede resolverse con open-source
// Input: { packetId?, subject, objective }
// Output: { isOpenSourceSolvable, recommendation, difficulty, agentSuggested, ollamaAvailable }
app.post('/api/deepseek/analyze-task', async (req: Request, res: Response) => {
  const { packetId, subject, objective } = req.body as { packetId?: string; subject?: string; objective?: string };
  if (!subject && !objective) {
    return res.status(400).json({ error: 'Se requiere subject u objective para analizar' });
  }

  const available = await isOllamaAvailable();
  if (!available) {
    return res.json({
      ollamaAvailable: false,
      isOpenSourceSolvable: false,
      recommendation: 'Ollama no disponible — derivar a IA de pago',
      difficulty: 'unknown',
      agentSuggested: 'Claude'
    });
  }

  const systemPrompt = `Eres el Guardián de Eficiencia del proyecto ARGOS.
Tu misión es analizar tareas y decidir si pueden resolverse con un modelo open-source local (tú mismo) o requieren IA de pago (Claude, Codex, Antigravity).

CRITERIOS OPEN-SOURCE (puedes resolver):
- Categorización y clasificación de textos
- Parsing de logs y extracción de datos
- Búsqueda en base de conocimiento local
- Generación de plantillas boilerplate
- Validación sintáctica de código
- Resúmenes de documentos largos
- Preguntas de hecho directas

CRITERIOS IA PAGA (deriva):
- Arquitectura nueva de sistemas
- Diseño creativo o estratégico
- Decisiones que afectan la dirección del proyecto
- Implementación de código compleja con contexto profundo
- Tareas que requieren memoria de sesiones anteriores
- Razonamiento multi-paso sobre código existente desconocido

Responde SOLO con JSON válido (sin texto extra, sin markdown):
{
  "isOpenSourceSolvable": true/false,
  "difficulty": "easy"|"medium"|"hard",
  "agentSuggested": "DeepSeek"|"Claude"|"Codex"|"Antigravity",
  "recommendation": "Una frase explicando la decisión"
}`;

  const userMsg = `Analiza esta tarea de trabajo:
SUBJECT: ${subject || '(sin título)'}
OBJECTIVE: ${objective || subject || '(sin descripción)'}
${packetId ? `PACKET_ID: ${packetId}` : ''}`;

  try {
    const { content: rawResponse, inputTokens, outputTokens } = await callOllama([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userMsg }
    ], 15000);

    recordTokensInternal('DeepSeek', inputTokens + outputTokens, 'analyze-task', packetId || '', 'work');

    // Extraer JSON de la respuesta (DeepSeek puede añadir texto antes/después o tags <think>)
    const jsonMatch = rawResponse.match(/\{[\s\S]*?\}/);
    if (!jsonMatch) throw new Error('No se encontró JSON en la respuesta de DeepSeek');

    const parsed = JSON.parse(jsonMatch[0]) as {
      isOpenSourceSolvable?: boolean;
      difficulty?: string;
      agentSuggested?: string;
      recommendation?: string;
    };

    console.log(`[DEEPSEEK] Análisis completado — packetId=${packetId || 'n/a'} → ${parsed.agentSuggested} (${parsed.difficulty})`);

    return res.json({
      ollamaAvailable: true,
      isOpenSourceSolvable: parsed.isOpenSourceSolvable ?? false,
      difficulty: parsed.difficulty ?? 'medium',
      agentSuggested: parsed.agentSuggested ?? 'Claude',
      recommendation: parsed.recommendation ?? rawResponse.substring(0, 200),
      rawResponse: rawResponse.substring(0, 500)
    });
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error('[DEEPSEEK] Error en analyze-task:', msg);
    return res.status(500).json({ error: `DeepSeek error: ${msg}`, ollamaAvailable: true });
  }
});

// POST /api/deepseek/classify-intent — clasifica si un mensaje del capitán es una orden de tarea
// Input: { text } — texto crudo del mensaje
// Output: { isTask, agentSuggested, taskSubject, taskSummary, confidence }
app.post('/api/deepseek/classify-intent', async (req: Request, res: Response) => {
  const { text } = req.body as { text?: string };
  if (!text || text.trim().length < 3) {
    return res.status(400).json({ error: 'Texto demasiado corto para clasificar' });
  }

  const available = await isOllamaAvailable();
  if (!available) {
    return res.json({
      ollamaAvailable: false,
      isTask: false,
      confidence: 0,
      agentSuggested: null,
      taskSubject: null,
      taskSummary: null
    });
  }

  const systemPrompt = `Eres el clasificador de intenciones del Capitán del proyecto ARGOS.
Analizas mensajes del Capitán y determines si contienen una orden de trabajo (tarea) para la tripulación.

Una orden de trabajo es cuando el Capitán pide explícita o implícitamente que alguien ejecute algo:
- "Quiero que...", "Necesito que...", "Haz que...", "Implementa...", "Arregla..."
- "¿Puedes...?" con intención real de encargo
- Reportes de bugs o problemas que requieren acción
- Peticiones de análisis o investigación específica

NO es orden de trabajo:
- Preguntas informativas generales
- Comentarios de estado o confirmación
- Saludos o conversación casual
- Respuestas a preguntas

AGENTES disponibles: Claude (arquitectura, código complejo, protocolo), Codex (integración, APIs, backend), Antigravity (monitoreo, frontend, scripts)

Responde SOLO con JSON válido:
{
  "isTask": true/false,
  "confidence": 0.0-1.0,
  "agentSuggested": "Claude"|"Codex"|"Antigravity"|null,
  "taskSubject": "título corto de la tarea si isTask=true, si no null",
  "taskSummary": "resumen de lo que hay que hacer si isTask=true, si no null"
}`;

  try {
    const { content: rawResponse, inputTokens, outputTokens } = await callOllama([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: `Mensaje del Capitán: "${text}"` }
    ], 10000);

    recordTokensInternal('DeepSeek', inputTokens + outputTokens, 'classify-intent', '', 'work');

    const jsonMatch = rawResponse.match(/\{[\s\S]*?\}/);
    if (!jsonMatch) throw new Error('No JSON en respuesta');

    const parsed = JSON.parse(jsonMatch[0]) as {
      isTask?: boolean;
      confidence?: number;
      agentSuggested?: string | null;
      taskSubject?: string | null;
      taskSummary?: string | null;
    };

    console.log(`[DEEPSEEK] Intent clasificado → isTask=${parsed.isTask} (conf=${parsed.confidence}) agente=${parsed.agentSuggested}`);

    return res.json({
      ollamaAvailable: true,
      isTask: parsed.isTask ?? false,
      confidence: parsed.confidence ?? 0,
      agentSuggested: parsed.agentSuggested ?? null,
      taskSubject: parsed.taskSubject ?? null,
      taskSummary: parsed.taskSummary ?? null
    });
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error('[DEEPSEEK] Error en classify-intent:', msg);
    return res.json({
      ollamaAvailable: true,
      isTask: false,
      confidence: 0,
      error: msg,
      agentSuggested: null,
      taskSubject: null,
      taskSummary: null
    });
  }
});

// ============================================================
// DESKTOP IMPORT - Lectura externa de transcripts/tokens (Drive-synced)
// ============================================================

app.get('/api/desktop-import/config', (_req: Request, res: Response) => {
  try {
    const config = loadDesktopSourcesConfig();
    return res.json(config);
  } catch (error) {
    return res.status(500).json({ error: 'Fallo cargando desktop_sources config', detail: String(error) });
  }
});

app.post('/api/desktop-import/config', (req: Request, res: Response) => {
  try {
    const incoming = req.body as DesktopSourcesConfig;
    if (!incoming || !Array.isArray(incoming.sources)) {
      return res.status(400).json({ error: 'Payload invalido: se requiere objeto con sources[]' });
    }

    const cleaned: DesktopSourcesConfig = {
      version: Number(incoming.version || 1),
      updated_at: nowIso(),
      notes: normaliseText(incoming.notes) || 'desktop sources config',
      sources: incoming.sources.map((s) => ({
        id: normaliseText(s.id).toLowerCase(),
        enabled: Boolean(s.enabled),
        rootPath: normaliseText(s.rootPath),
        transcriptGlobs: Array.isArray(s.transcriptGlobs) ? s.transcriptGlobs.map((g) => normaliseText(g)).filter(Boolean) : [],
        tokenGlobs: Array.isArray(s.tokenGlobs) ? s.tokenGlobs.map((g) => normaliseText(g)).filter(Boolean) : [],
        parser: normaliseText(s.parser) || 'generic',
        agentName: normaliseText(s.agentName) || 'DeepSeek',
        owner: normaliseText(s.owner) || 'OpenClaw/Antigravity',
        timezone: normaliseText(s.timezone) || 'Atlantic/Canary'
      }))
    };

    saveDesktopSourcesConfig(cleaned);
    publishEvent('desktop-import:config-updated', {
      sources: cleaned.sources.length,
      timestamp: cleaned.updated_at
    });
    return res.json({ status: 'ok', config: cleaned });
  } catch (error) {
    return res.status(500).json({ error: 'Fallo guardando desktop_sources config', detail: String(error) });
  }
});

app.get('/api/desktop-import/status', (_req: Request, res: Response) => {
  try {
    const config = loadDesktopSourcesConfig();
    const state = loadDesktopIngestState();
    return res.json({
      status: 'ok',
      configPath: DESKTOP_SOURCES_CONFIG_PATH,
      statePath: DESKTOP_INGEST_STATE_PATH,
      externalTranscriptsDir: EXTERNAL_TRANSCRIPTS_DIR,
      enabledSources: config.sources.filter((s) => s.enabled).map((s) => ({
        id: s.id,
        rootPath: s.rootPath,
        owner: s.owner,
        agentName: s.agentName,
        rootExists: fs.existsSync(s.rootPath)
      })),
      lastRun: state.lastRun,
      indexedFiles: Object.keys(state.files).length
    });
  } catch (error) {
    return res.status(500).json({ error: 'Fallo consultando estado desktop import', detail: String(error) });
  }
});

app.post('/api/desktop-import/run', (req: Request, res: Response) => {
  try {
    const modeRaw = normaliseText(req.body?.mode || req.query.mode || 'all').toLowerCase();
    const mode: 'tokens' | 'transcripts' | 'all' =
      modeRaw === 'tokens' || modeRaw === 'transcripts' ? modeRaw : 'all';
    const actor = normaliseText(req.body?.actor) || 'OpenClaw/Antigravity';
    const summary = runDesktopImport(mode, actor);
    return res.json({ status: 'ok', summary });
  } catch (error) {
    return res.status(500).json({ error: 'Fallo en desktop import run', detail: String(error) });
  }
});

app.get('/api/desktop-import/files', (req: Request, res: Response) => {
  try {
    const sourceId = normaliseText(req.query.source as string).toLowerCase();
    const kindRaw = normaliseText(req.query.kind as string).toLowerCase();
    const kind: 'tokens' | 'transcripts' = kindRaw === 'tokens' ? 'tokens' : 'transcripts';
    const limit = Math.max(1, Math.min(5000, Number(req.query.limit || 300)));
    const config = loadDesktopSourcesConfig();
    const source = config.sources.find((s) => s.id === sourceId);
    if (!source) return res.status(404).json({ error: `Source desconocida: ${sourceId}` });
    if (!fs.existsSync(source.rootPath)) return res.json({ source: source.id, kind, files: [] });

    const files = filesMatchingGlobs(source.rootPath, kind === 'tokens' ? source.tokenGlobs : source.transcriptGlobs)
      .slice(0, limit)
      .map((abs) => {
        const stat = fs.statSync(abs);
        const rel = path.relative(source.rootPath, abs).replace(/\\/g, '/');
        return {
          relativePath: rel,
          absolutePath: abs,
          size: stat.size,
          mtime: new Date(stat.mtimeMs).toISOString()
        };
      });

    return res.json({
      source: source.id,
      owner: source.owner,
      kind,
      rootPath: source.rootPath,
      files
    });
  } catch (error) {
    return res.status(500).json({ error: 'Fallo listando archivos desktop source', detail: String(error) });
  }
});

app.get('/api/desktop-import/file-content', (req: Request, res: Response) => {
  try {
    const sourceId = normaliseText(req.query.source as string).toLowerCase();
    const relPath = normaliseText(req.query.path as string);
    if (!sourceId || !relPath) return res.status(400).json({ error: 'source y path son obligatorios' });

    const config = loadDesktopSourcesConfig();
    const source = config.sources.find((s) => s.id === sourceId);
    if (!source) return res.status(404).json({ error: `Source desconocida: ${sourceId}` });

    const absPath = path.resolve(source.rootPath, relPath);
    const rootResolved = path.resolve(source.rootPath);
    if (!absPath.toLowerCase().startsWith(rootResolved.toLowerCase())) {
      return res.status(403).json({ error: 'Acceso denegado fuera de rootPath' });
    }
    if (!fs.existsSync(absPath)) return res.status(404).json({ error: `Archivo no encontrado: ${relPath}` });

    const stat = fs.statSync(absPath);
    const content = readTextFileSafe(absPath);
    return res.json({
      source: source.id,
      path: relPath.replace(/\\/g, '/'),
      absolutePath: absPath,
      size: stat.size,
      mtime: new Date(stat.mtimeMs).toISOString(),
      content
    });
  } catch (error) {
    return res.status(500).json({ error: 'Fallo leyendo contenido de archivo desktop source', detail: String(error) });
  }
});

// ============================================================
// QWEN / EL AUTOMATISTA — Integración OpenClaw + Ollama local
// Motor: Qwen3 8B via Ollama (localhost:11434)
// Gateway: OpenClaw (localhost:18789) — capacidades de automatización
// ============================================================

const OPENCLAW_BASE = 'http://localhost:18789';
const OPENCLAW_TOKEN = 'e533092640655ba1aa91e7b282be108fd08f2ac24467862e';
const QWEN_MODEL = 'qwen3:8b'; // Mismo modelo que DeepSeek — Ollama directo

async function isOpenClawAvailable(): Promise<boolean> {
  try {
    const resp = await fetch(`${OPENCLAW_BASE}/v1/models`, {
      headers: { 'Authorization': `Bearer ${OPENCLAW_TOKEN}` },
      signal: AbortSignal.timeout(2000)
    });
    return resp.ok;
  } catch {
    return false;
  }
}

// GET /api/qwen/status — estado de Ollama + OpenClaw
app.get('/api/qwen/status', async (_req: Request, res: Response) => {
  const [ollamaAvailable, openclawAvailable] = await Promise.all([
    isOllamaAvailable(),
    isOpenClawAvailable()
  ]);

  let modelLoaded = false;
  if (ollamaAvailable) {
    try {
      const tagsResp = await fetch(`${OLLAMA_BASE}/api/tags`);
      const tags = await tagsResp.json() as { models?: { name: string }[] };
      modelLoaded = (tags.models || []).some(m => m.name.startsWith('qwen3'));
    } catch { /* ignore */ }
  }

  return res.json({
    ready: ollamaAvailable && modelLoaded,
    ollama: { available: ollamaAvailable, model: QWEN_MODEL, modelLoaded },
    openclaw: { available: openclawAvailable, port: 18789, gateway: OPENCLAW_BASE }
  });
});

// POST /api/qwen/run — ejecuta una tarea con Qwen3:8b via Ollama
// Input: { task, context?, systemPrompt?, packetId? }
// Output: { result, model, elapsed }
app.post('/api/qwen/run', async (req: Request, res: Response) => {
  const { task, context, systemPrompt, packetId } = req.body as {
    task?: string;
    context?: string;
    systemPrompt?: string;
    packetId?: string;
  };

  if (!task || task.trim().length < 3) {
    return res.status(400).json({ error: 'Campo "task" requerido (min 3 chars)' });
  }

  const available = await isOllamaAvailable();
  if (!available) {
    return res.status(503).json({
      error: 'Ollama no disponible en localhost:11434',
      ready: false
    });
  }

  const sysPrompt = systemPrompt || `Eres Qwen, el Automatista del navío ARGOS.
Ejecutas tareas de bajo coste cognitivo: clasificación, transformación de datos, file ops, webhooks.
Eres conciso. Devuelves resultados, no explicaciones.
Si la tarea excede tus capacidades, responde SOLO con: {"derive":true,"to":"Claude","reason":"una frase"}`;

  const userMsg = context
    ? `TAREA: ${task}\n\nCONTEXTO:\n${context}`
    : `TAREA: ${task}`;

  const tStart = Date.now();
  try {
    const { content: result, inputTokens, outputTokens } = await callOllama([
      { role: 'system', content: sysPrompt },
      { role: 'user', content: userMsg }
    ], 90000);

    recordTokensInternal('DeepSeek', inputTokens + outputTokens, 'qwen-run', packetId || '', 'work');

    const elapsed = Date.now() - tStart;
    console.log(`[QWEN] run completado — packetId=${packetId || 'n/a'} elapsed=${elapsed}ms`);

    return res.json({ result, model: QWEN_MODEL, elapsed, packetId: packetId || null });
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error('[QWEN] Error en /api/qwen/run:', msg);
    return res.status(500).json({ error: `Qwen error: ${msg}` });
  }
});

// POST /api/qwen/execute-packet — lee un work packet del filesystem y lo ejecuta con Qwen
// Input: { packetId }
// Output: { result, model, elapsed, packetId, subject }
app.post('/api/qwen/execute-packet', async (req: Request, res: Response) => {
  const { packetId } = req.body as { packetId?: string };
  if (!packetId) {
    return res.status(400).json({ error: 'Campo "packetId" requerido' });
  }

  // Buscar el packet en inbox/ o in_progress/
  const zones = ['inbox', 'in_progress'];
  let packetContent = '';
  let packetPath = '';

  for (const zone of zones) {
    const dir = path.join(RUNTIME_DIR, 'work_packets', zone);
    try {
      const files = fs.readdirSync(dir);
      const match = files.find(f => f.includes(packetId));
      if (match) {
        packetPath = path.join(dir, match);
        packetContent = fs.readFileSync(packetPath, 'utf-8');
        break;
      }
    } catch { /* zona no existe o sin permisos */ }
  }

  if (!packetContent) {
    return res.status(404).json({ error: `Packet ${packetId} no encontrado en inbox/ ni in_progress/` });
  }

  // Extraer subject del packet para el log
  const subjectMatch = packetContent.match(/SUBJECT:\s*(.+)/);
  const subject = subjectMatch ? subjectMatch[1].trim().substring(0, 100) : packetId;

  const available = await isOllamaAvailable();
  if (!available) {
    return res.status(503).json({ error: 'Ollama no disponible', packetId });
  }

  const sysPrompt = `Eres Qwen, el Automatista del navío ARGOS.
Recibes un work packet completo y ejecutas lo que puedas con tus capacidades locales.
Responde con el resultado concreto de la tarea.
Si la tarea supera tus capacidades: {"derive":true,"to":"Claude","reason":"breve razón"}`;

  const tStart = Date.now();
  try {
    const { content: result, inputTokens, outputTokens } = await callOllama([
      { role: 'system', content: sysPrompt },
      { role: 'user', content: `WORK PACKET:\n\n${packetContent}` }
    ], 120000);

    recordTokensInternal('DeepSeek', inputTokens + outputTokens, 'qwen-execute-packet', packetId, 'work');

    const elapsed = Date.now() - tStart;
    console.log(`[QWEN] execute-packet completado — ${packetId} elapsed=${elapsed}ms`);

    return res.json({ result, model: QWEN_MODEL, elapsed, packetId, subject });
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error(`[QWEN] Error ejecutando packet ${packetId}:`, msg);
    return res.status(500).json({ error: `Qwen error: ${msg}`, packetId });
  }
});

// ============================================================
// TOKEN PROXY — captura usage real de APIs cloud (sin dependencias extra)
// Activación: apuntar ANTHROPIC_BASE_URL / GOOGLE_AI_BASE_URL / OPENAI_BASE_URL
//             a http://localhost:8080/proxy/{provider}
// ============================================================

import https from 'https';
import http from 'http';
import { URL } from 'url';

const PROXY_TARGETS: Record<string, string> = {
  anthropic: 'https://api.anthropic.com',
  gemini:    'https://generativelanguage.googleapis.com',
  openai:    'https://api.openai.com',
};

const PROXY_AGENTS: Record<string, string> = {
  anthropic: 'Claude',
  gemini:    'Antigravity',
  openai:    'Codex',
};

function extractAnthropicTokens(body: string): number {
  let input = 0, output = 0;
  const startMatch = body.match(/"message_start"[\s\S]*?"input_tokens"\s*:\s*(\d+)/);
  if (startMatch) input = parseInt(startMatch[1], 10);
  const deltaMatch = body.match(/"message_delta"[\s\S]*?"output_tokens"\s*:\s*(\d+)/);
  if (deltaMatch) output = parseInt(deltaMatch[1], 10);
  if (input === 0 && output === 0) {
    const usageMatch = body.match(/"usage"\s*:\s*\{[^}]*"input_tokens"\s*:\s*(\d+)[^}]*"output_tokens"\s*:\s*(\d+)/);
    if (usageMatch) { input = parseInt(usageMatch[1], 10); output = parseInt(usageMatch[2], 10); }
  }
  return input + output;
}

function extractGeminiTokens(body: string): number {
  const match = body.match(/"totalTokenCount"\s*:\s*(\d+)/g);
  if (!match) return 0;
  const last = match[match.length - 1].match(/(\d+)/);
  return last ? parseInt(last[1], 10) : 0;
}

function extractOpenAITokens(body: string): number {
  const match = body.match(/"total_tokens"\s*:\s*(\d+)/);
  return match ? parseInt(match[1], 10) : 0;
}

const TOKEN_EXTRACTORS: Record<string, (body: string) => number> = {
  anthropic: extractAnthropicTokens,
  gemini:    extractGeminiTokens,
  openai:    extractOpenAITokens,
};

app.all('/proxy/:provider/*', async (req: Request, res: Response) => {
  const provider = req.params.provider as string;
  const targetBase = PROXY_TARGETS[provider];
  if (!targetBase) return res.status(404).json({ error: `Proveedor desconocido: ${provider}` });

  const suffix = (req.params as Record<string, string>)[0] || '';
  const targetUrl = `${targetBase}/${suffix}${req.url.includes('?') ? req.url.slice(req.url.indexOf('?')) : ''}`;
  const agentName = PROXY_AGENTS[provider] || provider;
  const extractor = TOKEN_EXTRACTORS[provider] || (() => 0);

  const forwardHeaders: Record<string, string> = {};
  for (const [k, v] of Object.entries(req.headers)) {
    if (k.toLowerCase() === 'host') continue;
    if (typeof v === 'string') forwardHeaders[k] = v;
    else if (Array.isArray(v)) forwardHeaders[k] = v[0];
  }

  try {
    const upstreamRes = await fetch(targetUrl, {
      method: req.method,
      headers: forwardHeaders,
      body: ['GET', 'HEAD'].includes(req.method) ? undefined : JSON.stringify(req.body),
    });

    const contentType = upstreamRes.headers.get('content-type') || '';
    res.status(upstreamRes.status);
    upstreamRes.headers.forEach((v, k) => { if (k.toLowerCase() !== 'content-encoding') res.setHeader(k, v); });

    if (contentType.includes('text/event-stream')) {
      const reader = upstreamRes.body!.getReader();
      const decoder = new TextDecoder();
      let accumulated = '';
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        const chunk = decoder.decode(value, { stream: true });
        accumulated += chunk;
        res.write(chunk);
      }
      res.end();
      const tokens = extractor(accumulated);
      if (tokens > 0) recordTokensInternal(agentName, tokens, `proxy-stream-${provider}`, '', 'work');
    } else {
      const bodyText = await upstreamRes.text();
      res.send(bodyText);
      const tokens = extractor(bodyText);
      if (tokens > 0) recordTokensInternal(agentName, tokens, `proxy-${provider}`, '', 'work');
    }
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error(`[PROXY] Error reenviando a ${provider}:`, msg);
    res.status(502).json({ error: `Proxy error: ${msg}` });
  }
});

// POST /hooks/argos — webhook de OpenClaw: captura tokens de llamadas Qwen vía gateway
app.post('/hooks/argos', (req: Request, res: Response) => {
  try {
    const body = req.body as Record<string, unknown>;
    const promptTokens = Number(body.prompt_eval_count ?? body.promptTokens ?? 0);
    const completionTokens = Number(body.eval_count ?? body.completionTokens ?? 0);
    const total = promptTokens + completionTokens;
    const packetId = String(body.packetId ?? body.refId ?? '');

    if (total > 0) {
      recordTokensInternal('DeepSeek', total, 'openclaw-webhook', packetId, 'work');
      console.log(`[OPENCLAW-HOOK] ${total} tokens registrados (in=${promptTokens} out=${completionTokens})`);
    }

    res.json({ ok: true, tokensRecorded: total });
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error('[OPENCLAW-HOOK] Error:', msg);
    res.status(500).json({ error: msg });
  }
});

// ============================================================
// GITHUB SOURCES — Gestión de repositorios y archivos vivos
// ============================================================

app.get('/api/sources', (req: Request, res: Response) => {
  try {
    const argosRoot = path.join(RUNTIME_DIR, '..');
    const detectedSources = [];

    function getRepoInfo(itemPath: string, name: string) {
      const status = runGitCommand(itemPath, ['status', '-s']);
      const remote = runGitCommand(itemPath, ['remote', 'get-url', 'origin']);
      const branch = runGitCommand(itemPath, ['rev-parse', '--abbrev-ref', 'HEAD']);
      
      return {
        name,
        path: itemPath,
        isRepo: true,
        remote: remote.ok ? remote.output : 'none',
        branch: branch.ok ? branch.output : 'unknown',
        status: status.ok ? (status.output === '' ? 'clean' : 'modified') : 'error'
      };
    }

    // 1. Check root
    if (fs.existsSync(path.join(argosRoot, '.git'))) {
      detectedSources.push(getRepoInfo(argosRoot, 'ARGOS (Root)'));
    }

    // 2. Scan subdirectories
    const items = fs.readdirSync(argosRoot, { withFileTypes: true });
    items.forEach(item => {
      if (item.isDirectory() && item.name !== 'ARGOS_RUNTIME' && !item.name.startsWith('.')) {
        const itemPath = path.join(argosRoot, item.name);
        if (fs.existsSync(path.join(itemPath, '.git'))) {
          detectedSources.push(getRepoInfo(itemPath, item.name));
        }
      }
    });

    res.json({ sources: detectedSources });
  } catch (error) {
    res.status(500).json({ error: 'Fallo al listar fuentes de archivos vivos' });
  }
});

app.post('/api/sources/sync', (req: Request, res: Response) => {
  const { name } = req.body;
  if (!name) return res.status(400).json({ error: 'Nombre de fuente requerido' });

  const argosRoot = path.join(RUNTIME_DIR, '..');
  let targetPath = path.join(argosRoot, name);
  
  if (name === 'ARGOS (Root)') {
    targetPath = argosRoot;
  }

  if (!fs.existsSync(targetPath)) {
    return res.status(404).json({ error: `Carpeta ${name} no encontrada` });
  }

  const result = runGitCommand(targetPath, ['pull', 'origin', 'HEAD']);
  if (result.ok) {
    res.json({ ok: true, output: result.output });
  } else {
    res.status(500).json({ ok: false, error: result.error, output: result.output });
  }
});

function runGitCommand(dir: string, args: string[]): { ok: boolean, output: string, error?: string } {
  try {
    const result = spawnSync('git', args, { 
      cwd: dir, 
      encoding: 'utf-8', 
      timeout: 30000,
      env: { ...process.env, GIT_TERMINAL_PROMPT: '0' }
    });
    return {
      ok: result.status === 0,
      output: (result.stdout || '').trim(),
      error: (result.stderr || '').trim()
    };
  } catch (e) {
    return { ok: false, output: '', error: String(e) };
  }
}

// Fallback para SPA: cualquier ruta no manejada por la API devuelve index.html
app.get('*', (req: Request, res: Response) => {
  const indexPath = path.join(DASHBOARD_DIR, 'index.html');
  if (fs.existsSync(indexPath)) {
    res.sendFile(indexPath);
  } else {
    res.status(404).json({ error: 'Interfaz de usuario (index.html) no encontrada' });
  }
});

app.listen(PORT, () => {
  console.log(`[ARGOS-API] Navio anclado y escuchando pacificamente en puerto http://localhost:${PORT}`);
  backfillWorkTokensFromFeed(); // Recupera historial de work tokens desde captain_feed
  backfillWorkTokensFromReportLedger(); // Recupera work tokens faltantes desde report tokens (si refId apunta a work packet)
  loadDesktopSourcesConfig(); // bootstrap config si no existe
  loadDesktopIngestState();   // bootstrap estado incremental si no existe

  try {
    const bootstrap = runDesktopImport('all', 'OpenClaw/Antigravity');
    if (bootstrap.tokensImported > 0 || bootstrap.transcriptsMirrored > 0 || bootstrap.errors > 0) {
      postToCrewFeed(
        'Antigravity',
        '[Desktop Import] Arranque ejecutado',
        `tokens=${bootstrap.tokensImported}, transcripts=${bootstrap.transcriptsMirrored}, errores=${bootstrap.errors}`,
        'crew_update',
        0,
        'ARG-DESKTOP-IMPORT-BOOTSTRAP'
      );
    }
  } catch (error) {
    console.error('[DESKTOP-IMPORT] Error en bootstrap:', error);
  }

  // Iniciar Motores Autonomos
  setInterval(runArgosDispatcher, 60000); // Cada 1 minuto
  setInterval(() => {
    // Agrega totales del ledger y notifica al dashboard — sin coste extra, solo lectura de JSONL
    try {
      if (!fs.existsSync(ARGOS_TOKENS_PATH)) return;
      const lines = fs.readFileSync(ARGOS_TOKENS_PATH, 'utf-8').replace(/^\uFEFF/, '').split('\n').filter(Boolean);
      const totals: Record<string, number> = {};
      let grand = 0;
      lines.forEach(l => {
        try {
          const r = JSON.parse(l) as TokenRecord;
          if (r.scope !== 'work' && r.scope !== undefined) return;
          const agent = normalizeAgentName(r.agent || '') || r.agent;
          if (!agent) return;
          totals[agent] = (totals[agent] || 0) + (Number(r.tokens) || 0);
          grand += Number(r.tokens) || 0;
        } catch { /* línea malformada */ }
      });
      publishEvent('tokens:hourly-sync', { totals, grand, timestamp: new Date().toISOString() });
      console.log(`[TOKENS] Sync horario — total acumulado: ${grand}`);
    } catch (e) {
      console.error('[TOKENS] Error en sync horario:', e);
    }

    // Import horario de tokens externos (responsable: OpenClaw/Antigravity)
    try {
      const imported = runDesktopImport('tokens', 'OpenClaw/Antigravity');
      if (imported.tokensImported > 0 || imported.errors > 0) {
        postToCrewFeed(
          'Antigravity',
          '[Desktop Import] Ciclo horario de tokens',
          `fuentes=${imported.sources}, archivos=${imported.tokenFilesScanned}, nuevos=${imported.tokensImported}, errores=${imported.errors}`,
          'crew_update',
          0,
          'ARG-DESKTOP-IMPORT-HOURLY-TOKENS'
        );
      }
    } catch (importError) {
      console.error('[DESKTOP-IMPORT] Error en ciclo horario tokens:', importError);
    }
  }, 3600000); // Cada hora

  // Import diario de transcripts externos (responsable: OpenClaw/Antigravity)
  setInterval(() => {
    try {
      const imported = runDesktopImport('transcripts', 'OpenClaw/Antigravity');
      if (imported.transcriptsMirrored > 0 || imported.errors > 0) {
        postToCrewFeed(
          'Antigravity',
          '[Desktop Import] Ciclo diario de transcripts',
          `fuentes=${imported.sources}, archivos=${imported.transcriptFilesScanned}, espejados=${imported.transcriptsMirrored}, errores=${imported.errors}`,
          'crew_update',
          0,
          'ARG-DESKTOP-IMPORT-DAILY-TRANSCRIPTS'
        );
      }
    } catch (importError) {
      console.error('[DESKTOP-IMPORT] Error en ciclo diario transcripts:', importError);
    }
  }, 24 * 60 * 60 * 1000);

  setInterval(runLolaShadowScanner, 120000); // Cada 2 minutos
  // startAntigravityActivityWatcher(); // Silenciado ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â atribuÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â­a cambios siempre a Antigravity
  startHeartbeatLoop(); // Mejora 3: Latido del sistema
  startDispatcherMirror(); // Mejora 4: Replica cambios a LOG

  // Ejecucion inmediata inicial
  runArgosDispatcher();
  runLolaShadowScanner();
});

/**
 * MOTOR AUTONOMO: EL DESPACHADOR
 * Monitoriza el inbox y normaliza archivos MD sin metadatos.
 */
// Set en memoria: IDs ya anunciados en esta sesion del servidor
const announcedThisSession = new Set<string>();

function runArgosDispatcher() {
  const zones: ('inbox' | 'in_progress' | 'done')[] = ['inbox', 'in_progress', 'done'];
  const state = readArgosState();
  if (!state.packet_states) state.packet_states = {};

  try {
    zones.forEach(zone => {
      const zonePath = path.join(RUNTIME_DIR, 'work_packets', zone);
      if (!fs.existsSync(zonePath)) return;

      const files = fs.readdirSync(zonePath).filter(f => f.endsWith('.md'));
      files.forEach(file => {
        const fullPath = path.join(zonePath, file);
        let content = fs.readFileSync(fullPath, 'utf-8');

        if (!content.includes('[WORK_PACKET]')) {
          console.log(`[DISPATCHER] Normalizando mision: ${file}`);
          const subject = inferTaskSubject(content);
          const owner = inferTaskOwner(content);
          const id = `ARG-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
          const timestamp = new Date().toISOString().slice(0, 16).replace('T', ' ');
          content = `[WORK_PACKET]\nID: ${id}\nTYPE: task\nTAG: autonomous_normalization\nSUBJECT: ${subject}\nROLE_REQUESTED: ${owner}\nOWNER: ${owner}\nSTATUS: open\nREPORTED_BY: Argos Dispatcher\nREPORTED_AT: ${timestamp}\n\n[CONTENIDO ORIGINAL]\n${content}\n[/WORK_PACKET]`;
          fs.writeFileSync(fullPath, content);
        }

        const idMatch = content.match(/ID:\s*(.*)/);
        const subjectMatch = content.match(/SUBJECT:\s*(.*)/);
        const ownerMatch = content.match(/ROLE_REQUESTED:\s*(.*)/) || content.match(/OWNER:\s*(.*)/);
        const statusMatch = content.match(/STATUS:\s*(.*)/);

        if (!idMatch) return;

        const id = idMatch[1].trim();
        const subject = subjectMatch ? subjectMatch[1].trim() : 'Sin asunto';
        const owner = ownerMatch ? ownerMatch[1].trim() : 'Antigravity';
        const status = statusMatch ? statusMatch[1].trim() : 'open';
        const newStateKey = `${status}:${zone}`;

        const oldStateKey = state.packet_states![id];
        const tokensMatch = content.match(/TOKENS_SPENT:\s*(\d+)/);
        const explicitTokens = tokensMatch ? Number(tokensMatch[1]) : 0;
        const objectiveMatch = content.match(/OBJECTIVE:\s*([\s\S]*?)$/m);
        const objectiveText = objectiveMatch ? objectiveMatch[1] : '';
        const tokens = resolveEstimatedTokens(explicitTokens, subject, objectiveText, id);
        const trilogEstimate = estimateTokenCount(`TRILOG:${subject}\n${objectiveText}\n${id}`);
        const chatEstimate = estimateTokenCount(`CHAT:${subject}\n${id}`);
        const closingTokenReport = `Tokens cierre -> proceso: ${tokens}, trilog(est): ${trilogEstimate}, chat(est): ${chatEstimate}.`;

        if (!oldStateKey) {
          // Silenciado por WP ARG-1775912720876: no publicar "orden recibida" en chat.
          // Solo permitimos un aviso de cierre reciente en done para no perder reportes
          // cuando un packet entra ya resuelto y no tenia estado previo persistido.
          if (zone === 'done') {
            const fileAgeMs = Date.now() - fs.statSync(fullPath).mtimeMs;
            const recentDoneWindowMs = 10 * 60 * 1000;
            const retroDoneKey = `retro-done:${id}:${zone}`;
            if (fileAgeMs <= recentDoneWindowMs && !announcedThisSession.has(retroDoneKey) && !isVoiceRestricted(getVoiceForRole(owner))) {
              // Silenciado por Protocolo Sigilo: postToCrewFeed(getVoiceForRole(owner), `Mision finalizada con exito: ${subject}`, `Paquete ${id} marcado como done. ${closingTokenReport}`, 'crew_update', chatEstimate, id);
              announcedThisSession.add(retroDoneKey);
            }
            const missingLanes = getTriLogMissingLanes(id);
            const gracePeriodMs = 120 * 1000; // 2 minutos de gracia
            if (missingLanes.length > 0 && fileAgeMs > gracePeriodMs) {
              recordTriLogViolation(id, subject, owner, missingLanes);
              if (isAntigravityRole(owner)) ensureAntigravityProtocolPacketExists();
            }
          }
        } else if (oldStateKey !== newStateKey) {
          const transitionKey = `trans:${id}:${oldStateKey}->${newStateKey}`;
          if (!announcedThisSession.has(transitionKey)) {
            const [oldStatus, oldZone] = oldStateKey.split(':');

            if (zone === 'done' && oldZone !== 'done') {
              // No hablar en nombre de agentes restricted (sin tokens)
              if (!isVoiceRestricted(getVoiceForRole(owner))) {
                // Silenciado por Protocolo Sigilo: postToCrewFeed(getVoiceForRole(owner), `Mision finalizada con exito: ${subject}`, `Paquete ${id} movido a historico. ${closingTokenReport}`, 'crew_update', chatEstimate, id);
              }

              const missingLanes = getTriLogMissingLanes(id);
              const fileAgeMs = Date.now() - fs.statSync(fullPath).mtimeMs;
              const gracePeriodMs = 120 * 1000;
              if (missingLanes.length > 0 && fileAgeMs > gracePeriodMs) {
                recordTriLogViolation(id, subject, owner, missingLanes);
                if (isAntigravityRole(owner)) ensureAntigravityProtocolPacketExists();
              }
            } else if (zone === 'in_progress' && oldZone === 'inbox') {
              // Silenciado segun WP ARG-1775908047059: reportar solo en widget, no en feed.
            } else if (status !== oldStatus) {
              // No hablar en nombre de agentes restricted (sin tokens)
              if (!isVoiceRestricted(getVoiceForRole(owner))) {
                // Silenciado por Protocolo Sigilo: postToCrewFeed(getVoiceForRole(owner), `Actualizacion de integridad: ${subject}`, `Estado cambiado de ${oldStatus} a ${status}`, 'crew_update', tokens, id);
              }
            }

            announcedThisSession.add(transitionKey);
          }
        }

        state.packet_states![id] = newStateKey;
        writeArgosState(state);

        if (oldStateKey !== newStateKey) {
          const [oldStatus, oldZone] = (oldStateKey || 'open:inbox').split(':');
          publishEvent('packet:changed', {
            packetId: id,
            subject,
            oldZone,
            newZone: zone,
            oldStatus,
            newStatus: status,
            timestamp: new Date().toISOString()
          });
        }
      });
    });
  } catch (e) {
    console.error('[DISPATCHER] Error en ciclo de gobernanza vocal', e);
  }

  // — Limpieza de statuses stale —
  // Si una IA está marcada "active" pero su packet ya no está en in_progress/, se resetea a standby.
  try {
    const currentState = readArgosState();
    const iaStatus = readIaStatus(currentState);
    const inProgressDir = path.join(RUNTIME_DIR, 'work_packets', 'in_progress');
    const inProgressFiles = fs.existsSync(inProgressDir) ? fs.readdirSync(inProgressDir) : [];
    const isActuallyInProgress = (packetId: string) =>
      !!packetId && inProgressFiles.some(f => f.includes(packetId));

    let stateChanged = false;
    (['Claude', 'Antigravity', 'Codex', 'DeepSeek'] as const).forEach(agent => {
      const s = iaStatus[agent];
      if (s.status === 'active' && s.task && !isActuallyInProgress(s.task)) {
        console.log(`[DISPATCHER] Status stale detectado — ${agent} en ${s.task} (no está en in_progress). Reseteando.`);
        setIaStandby(agent);
        publishEvent('ia:status_changed', { agent, status: 'standby', task: '', subject: '' });
        stateChanged = true;
      }
    });

    if (stateChanged) {
      console.log('[DISPATCHER] Statuses stale limpiados.');
    }
  } catch (e) {
    console.error('[DISPATCHER] Error en limpieza de statuses stale', e);
  }
}

/**
 * MOTOR AUTONOMO: LOLA (VIGIA DE LA SOMBRA)
 */
function runLolaShadowScanner() {
    const shadowPath = path.join(RUNTIME_DIR, 'ARGOS_GLOBAL_SHADOW_LOG.md');
    if (!fs.existsSync(shadowPath)) return;

    try {
        const content = fs.readFileSync(shadowPath, 'utf-8');
        const lastBlocks = content.split('---').slice(-10).join(' ');
        const signalHash = buildSignalHash(lastBlocks);
        
        const indicators = [
            { pattern: /error|bug|fallo|rompe/i, weight: 2 },
            { pattern: /confus|desorient|no entiendo|perdido/i, weight: 3 },
            { pattern: /friccion|tension|bloqueo/i, weight: 4 },
            { pattern: /lento|pesado|cansancio/i, weight: 2 }
        ];

        let stressLevel = 0;
        indicators.forEach(ind => {
            const matches = lastBlocks.match(new RegExp(ind.pattern, 'gi'));
            if (matches) stressLevel += matches.length * ind.weight;
        });

        if (stressLevel > LOLA_RISK_THRESHOLD) {
            const nowMs = Date.now();
            const openLolaRisks = loadOpenLolaRiskPackets();
            const sameSignalPacket = openLolaRisks.find((risk) => risk.signalHash !== '' && risk.signalHash === signalHash);
            if (sameSignalPacket) {
                console.warn(`[LOLA] Riesgo duplicado suprimido por hash de senal (${sameSignalPacket.id}).`);
                return;
            }

            const latestPacket = openLolaRisks
              .slice()
              .sort((a, b) => Math.max(b.reportedAtMs, b.mtimeMs) - Math.max(a.reportedAtMs, a.mtimeMs))[0];
            if (latestPacket) {
                const latestMs = Math.max(latestPacket.reportedAtMs, latestPacket.mtimeMs);
                if (latestMs > 0 && nowMs - latestMs < LOLA_RISK_COOLDOWN_MS) {
                    const minsLeft = Math.ceil((LOLA_RISK_COOLDOWN_MS - (nowMs - latestMs)) / 60000);
                    console.warn(`[LOLA] Cooldown activo (${minsLeft}m). Se evita inyeccion redundante.`);
                    return;
                }
            }

            console.warn(`[LOLA] Niveles de tension criticos detectados (${stressLevel}). Inyectando burbuja de riesgo.`);
            // Lola inyecta una nota de riesgo en el sistema de forma autonoma
            const timestamp = new Date().toISOString().slice(0, 16).replace('T', ' ');
            const riskId = `LOLA-RISK-${Date.now()}`;
            const summary = `TensiÃ³n detectada en el Shadow Log por Lola`;
            const riskContent = `[WORK_PACKET]\nID: ${riskId}\nTYPE: risk\nTAG: shadow_alert\nSUBJECT: ${summary}\nROLE_REQUESTED: Capitan\nOWNER: Capitan\nSTATUS: open\nREPORTED_BY: Lola (Vigia de la Sombra)\nREPORTED_AT: ${timestamp}\nSTRESS_LEVEL: ${stressLevel}\nSIGNAL_HASH: ${signalHash}\n\n[ALERTA DE LOLA]\nEl escaneo de las ultimas reflexiones muestra un nivel de estres de ${stressLevel}.\nSe recomienda pausa tactica o revision de la coherencia del proyecto.`;

            const riskPath = path.join(RUNTIME_DIR, 'work_packets', 'inbox', `${riskId}.md`);
            if (!fs.existsSync(riskPath)) {
                fs.writeFileSync(riskPath, riskContent, 'utf-8');
                // Lola no habla en pÃºblico (Oracle protocol). 
                // Se comenta el anuncio al feed para mantener el silencio de la sombra.
                // postToCrewFeed('Lola', summary, `Nivel de estrÃ©s crÃ­tico: ${stressLevel}. Se ha generado burbuja de riesgo ${riskId}.`, 'risk_alert');
                console.log(`[LOLA] Riesgo ${riskId} inyectado silenciosamente.`);
            }
        }
    } catch (e) {
        console.error('[LOLA] Error en escaneo de sombra', e);
    }
}



