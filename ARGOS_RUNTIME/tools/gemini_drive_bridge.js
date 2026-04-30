#!/usr/bin/env node
/*
 * Gemini Drive Bridge V2
 *
 * Reads Google Docs created by Gemini web in the ARGOS Drive root, exports them
 * as Markdown, parses the ARGOS closure/concilio contract, and appends to local
 * canonical runtime files. The old ARGOS_RUNTIME/Gemini deposit folder is legacy.
 */

const fs = require('fs');
const path = require('path');

const SCRIPT_DIR = __dirname;
const RUNTIME_DIR = path.resolve(SCRIPT_DIR, '..');
const ARGOS_ROOT = path.resolve(RUNTIME_DIR, '..');
const API_DIR = path.join(ARGOS_ROOT, 'argos-api');

const LOG_PATH = path.join(RUNTIME_DIR, 'bitacora', 'log.md');
const SHADOW_PATH = path.join(RUNTIME_DIR, 'bitacora', 'shadowlog.md');
const GLITCH_PATH = path.join(RUNTIME_DIR, 'bitacora', 'glitches.md');
const EVENTS_PATH = path.join(RUNTIME_DIR, 'events', 'argos.events.jsonl');
const GLITCHES_JSONL_PATH = path.join(RUNTIME_DIR, 'events', 'argos.glitches.jsonl');
const REMOTE_CLOSURES_PATH = path.join(RUNTIME_DIR, 'events', 'argos.remote_closures.jsonl');
const FEED_PATH = path.join(RUNTIME_DIR, 'cubierta', 'feed.jsonl');
const STATE_PATH = path.join(RUNTIME_DIR, 'state', 'argos.state.json');
const CONCILIO_DIR = path.join(RUNTIME_DIR, 'events', 'concilio');
const CONCILIO_SESSIONS_DIR = path.join(CONCILIO_DIR, 'sessions');
const CONCILIO_JSONL_PATH = path.join(CONCILIO_DIR, 'argos.concilio.jsonl');
const BRIDGE_STATE_PATH = path.join(RUNTIME_DIR, 'state', 'gemini_drive_bridge.state.json');
const ERROR_DIR = path.join(RUNTIME_DIR, 'events', 'gemini_drive_bridge_errors');

const DOC_MIME = 'application/vnd.google-apps.document';
const DEFAULT_POLL_MS = 30000;
const DEFAULT_SETTLE_MS = 10000;
const VALID_TARGETS = new Set(['closure', 'log', 'concilio']);
const VALID_STATUSES = new Set(['idle', 'working', 'blocked', 'waiting_captain']);
const CANONICAL_HANDOFFS = new Set(['Codex', 'Claude', 'Gemini', 'ChatGPT', 'OpenClaw', 'Qwen']);

const args = parseArgs(process.argv.slice(2));
const once = Boolean(args.once) || Boolean(args['from-file']);
const watch = Boolean(args.watch) || !once;
const dryRun = Boolean(args['dry-run']);
const pollMs = positiveNumber(args['poll-ms'], DEFAULT_POLL_MS);
const settleMs = positiveNumber(args['settle-ms'], DEFAULT_SETTLE_MS);

main().catch((error) => {
  console.error(`[gemini-drive-bridge] fatal: ${error.stack || error.message || String(error)}`);
  process.exitCode = 1;
});

async function main() {
  if (args.help) {
    printHelp();
    return;
  }

  ensureDir(ERROR_DIR);

  if (args['from-file']) {
    const filePath = path.resolve(String(args['from-file']));
    const raw = fs.readFileSync(filePath, 'utf8').replace(/^\uFEFF/, '');
    const source = { id: `local:${filePath}`, name: path.basename(filePath), markdown: raw, localFilePath: filePath };
    const result = processMarkdownSource(source);
    console.log(`[gemini-drive-bridge] local fixture ${result.ok ? 'processed' : 'rejected'}: ${result.reason}`);
    if (!result.ok) process.exitCode = 2;
    return;
  }

  const state = readBridgeState();
  const drive = await buildDriveClientOrNull();
  if (drive) {
    await scanDriveOnce(drive, state);
  } else if (!watch) {
    process.exitCode = 2;
    return;
  }
  writeBridgeState(state);

  if (!watch) return;

  console.log(`[gemini-drive-bridge] polling Drive every ${pollMs}ms`);
  setInterval(async () => {
    try {
      const retryDrive = await buildDriveClientOrNull();
      if (!retryDrive) return;
      const fresh = readBridgeState();
      await scanDriveOnce(retryDrive, fresh);
      writeBridgeState(fresh);
    } catch (error) {
      console.error(`[gemini-drive-bridge] scan failed: ${error.message || String(error)}`);
    }
  }, pollMs);
}

let missingCredentialsLogged = false;

async function buildDriveClientOrNull() {
  try {
    return await buildDriveClient();
  } catch (error) {
    const message = error.message || String(error);
    if (!missingCredentialsLogged) {
      console.warn(`[gemini-drive-bridge] Drive unavailable: ${message}`);
      console.warn('[gemini-drive-bridge] Configure ARGOS_DRIVE_ROOT_FOLDER_ID and ARGOS_GOOGLE_SERVICE_ACCOUNT_JSON, or set ARGOS_GOOGLE_USE_ADC=1 for Application Default Credentials.');
      missingCredentialsLogged = true;
    }
    return null;
  }
}

async function buildDriveClient() {
  const googleapis = loadGoogleApis();
  const { google } = googleapis;
  const keyFile = findServiceAccountPath();
  const useAdc = normalise(process.env.ARGOS_GOOGLE_USE_ADC) === '1';
  if (!keyFile && !useAdc) {
    throw new Error('missing Google Drive credentials');
  }
  const authOptions = {
    scopes: ['https://www.googleapis.com/auth/drive']
  };
  if (keyFile) authOptions.keyFile = keyFile;
  const auth = new google.auth.GoogleAuth(authOptions);
  const client = await auth.getClient();
  return google.drive({ version: 'v3', auth: client });
}

function loadGoogleApis() {
  try {
    return require('googleapis');
  } catch {
    const fallback = path.join(API_DIR, 'node_modules', 'googleapis');
    return require(fallback);
  }
}

function findServiceAccountPath() {
  const candidates = [
    process.env.ARGOS_GOOGLE_SERVICE_ACCOUNT_JSON,
    process.env.GOOGLE_APPLICATION_CREDENTIALS,
    path.join(API_DIR, 'credentials', 'service_account.json'),
    path.join(RUNTIME_DIR, 'secrets', 'google_service_account.json')
  ].filter(Boolean);
  return candidates.find((candidate) => fs.existsSync(candidate)) || '';
}

async function scanDriveOnce(drive, state) {
  const rootFolderId = await resolveArgosRootFolderId(drive);
  const docs = await listGeminiDocs(drive, rootFolderId);
  for (const doc of docs) {
    if (!doc.id || state.processed[doc.id]) continue;
    if (doc.modifiedTime && Date.now() - Date.parse(doc.modifiedTime) < settleMs) continue;

    try {
      const markdown = await exportDocMarkdown(drive, doc.id);
      const result = processMarkdownSource({ id: doc.id, name: doc.name || doc.id, markdown, driveFile: doc });
      if (!result.ok) {
        recordBridgeError(doc, result.reason, markdown);
        state.errors[doc.id] = { name: doc.name, reason: result.reason, at: nowIso() };
        continue;
      }

      state.processed[doc.id] = { name: doc.name, processed_at: nowIso(), target: result.target, packet_id: result.packetId };
      if (!dryRun && !args['keep-drive-docs']) {
        await drive.files.update({ fileId: doc.id, requestBody: { trashed: true } });
      }
      console.log(`[gemini-drive-bridge] processed ${doc.name} (${result.target})`);
    } catch (error) {
      const reason = error.message || String(error);
      recordBridgeError(doc, reason, '');
      state.errors[doc.id] = { name: doc.name, reason, at: nowIso() };
    }
  }
}

async function resolveArgosRootFolderId(drive) {
  if (normalise(process.env.ARGOS_DRIVE_ROOT_FOLDER_ID)) return normalise(process.env.ARGOS_DRIVE_ROOT_FOLDER_ID);
  const escaped = escapeDriveQueryValue(process.env.ARGOS_DRIVE_ROOT_FOLDER_NAME || 'ARGOS');
  const res = await drive.files.list({
    q: `name = '${escaped}' and mimeType = 'application/vnd.google-apps.folder' and trashed = false`,
    fields: 'files(id,name,modifiedTime)',
    pageSize: 10,
    supportsAllDrives: true,
    includeItemsFromAllDrives: true
  });
  const folders = res.data.files || [];
  if (folders.length < 1) throw new Error('No Drive folder named ARGOS found. Set ARGOS_DRIVE_ROOT_FOLDER_ID.');
  if (folders.length > 1) throw new Error('Multiple Drive folders named ARGOS found. Set ARGOS_DRIVE_ROOT_FOLDER_ID.');
  return folders[0].id;
}

async function listGeminiDocs(drive, rootFolderId) {
  const docs = [];
  let pageToken = undefined;
  do {
    const res = await drive.files.list({
      q: `'${escapeDriveQueryValue(rootFolderId)}' in parents and name contains 'gemini_ARGOS_' and mimeType = '${DOC_MIME}' and trashed = false`,
      fields: 'nextPageToken, files(id,name,mimeType,createdTime,modifiedTime,owners(displayName,emailAddress))',
      orderBy: 'createdTime',
      pageSize: 100,
      pageToken,
      supportsAllDrives: true,
      includeItemsFromAllDrives: true
    });
    for (const file of res.data.files || []) {
      if (/^gemini_ARGOS_\d{8}T\d{6}Z$/i.test(file.name || '')) docs.push(file);
    }
    pageToken = res.data.nextPageToken;
  } while (pageToken);
  return docs;
}

async function exportDocMarkdown(drive, fileId) {
  try {
    const res = await drive.files.export(
      { fileId, mimeType: 'text/markdown' },
      { responseType: 'text' }
    );
    return typeof res.data === 'string' ? res.data : String(res.data || '');
  } catch (error) {
    const res = await drive.files.export(
      { fileId, mimeType: 'text/plain' },
      { responseType: 'text' }
    );
    return typeof res.data === 'string' ? res.data : String(res.data || '');
  }
}

function processMarkdownSource(source) {
  const parsed = parseGeminiMarkdown(source.markdown);
  const validation = validateParsed(parsed);
  if (!validation.ok) return { ok: false, reason: validation.reason };

  if (dryRun) {
    return { ok: true, reason: 'dry-run', target: parsed.meta.target, packetId: parsed.meta.packet_id };
  }

  if (parsed.legacyCaptainDuplicate) {
    appendBridgeEvent('gemini_drive_bridge_legacy_captain_duplicate', {
      packet_id: parsed.meta.packet_id,
      details: `[FEED] and legacy [CAPTAIN] both present in ${source.name}; [FEED] used.`
    });
  } else if (parsed.legacyCaptainUsed) {
    appendBridgeEvent('gemini_drive_bridge_legacy_captain_alias', {
      packet_id: parsed.meta.packet_id,
      details: `Legacy [CAPTAIN] normalized to [FEED] in ${source.name}.`
    });
  }

  if (parsed.meta.target === 'log') integrateLog(parsed, source);
  if (parsed.meta.target === 'closure') integrateClosure(parsed, source);
  if (parsed.meta.target === 'concilio') integrateConcilio(parsed, source);

  appendBridgeEvent('gemini_drive_bridge_processed', {
    packet_id: parsed.meta.packet_id,
    summary: `${source.name} -> ${parsed.meta.target}`,
    details: source.id
  });
  return { ok: true, reason: 'processed', target: parsed.meta.target, packetId: parsed.meta.packet_id };
}

function parseGeminiMarkdown(raw) {
  const text = raw.replace(/^\uFEFF/, '').replace(/\r\n/g, '\n');
  const meta = {};
  const lines = text.split('\n');
  let firstSectionLine = lines.findIndex((line) => /^\s*(?:#{1,6}\s*)?\[(LOG|SHADOW|GLITCH|STATE|FEED|CAPTAIN)\]\s*$/i.test(line));
  if (firstSectionLine < 0) firstSectionLine = lines.length;
  for (const line of lines.slice(0, firstSectionLine)) {
    const match = line.match(/^\s*([a-zA-Z0-9_]+)\s*:\s*(.*?)\s*$/);
    if (match) meta[match[1].toLowerCase()] = match[2];
  }

  const body = lines.slice(firstSectionLine).join('\n');
  const sectionMatches = Array.from(body.matchAll(/^\s*(?:#{1,6}\s*)?\[(LOG|SHADOW|GLITCH|STATE|FEED|CAPTAIN)\]\s*$/gim));
  const sections = {};
  sectionMatches.forEach((match, index) => {
    const key = match[1].toUpperCase();
    const start = (match.index || 0) + match[0].length;
    const end = index + 1 < sectionMatches.length ? (sectionMatches[index + 1].index || body.length) : body.length;
    sections[key] = body.slice(start, end).trim();
  });

  let legacyCaptainUsed = false;
  let legacyCaptainDuplicate = false;
  if (normalise(sections.FEED) === '' && normalise(sections.CAPTAIN) !== '') {
    sections.FEED = sections.CAPTAIN;
    legacyCaptainUsed = true;
  } else if (normalise(sections.FEED) !== '' && normalise(sections.CAPTAIN) !== '') {
    legacyCaptainDuplicate = true;
  }

  const state = parseKeyValues(sections.STATE || '');
  const target = normalise(meta.target).toLowerCase();
  const packetId = normalise(meta.packet_id || meta.packet);
  return {
    meta: {
      agent: normalise(meta.agent),
      packet_id: packetId,
      session_id: normalise(meta.session_id),
      target,
      type: normalise(meta.type),
      timestamp: parseTimestamp(meta.timestamp)
    },
    sections,
    state,
    legacyCaptainUsed,
    legacyCaptainDuplicate
  };
}

function validateParsed(parsed) {
  if (parsed.meta.agent !== 'Gemini') return { ok: false, reason: 'agent must be Gemini' };
  if (!VALID_TARGETS.has(parsed.meta.target)) return { ok: false, reason: 'target must be closure, log, or concilio' };
  if ((parsed.meta.target === 'closure' || parsed.meta.target === 'log') && !parsed.meta.packet_id) {
    return { ok: false, reason: 'packet_id is required for closure/log' };
  }
  if (parsed.meta.target === 'closure') {
    if (!normalise(parsed.sections.LOG)) return { ok: false, reason: '[LOG] is required for closure' };
    if (!normalise(parsed.sections.SHADOW)) return { ok: false, reason: '[SHADOW] is required for closure' };
    if (!normalise(parsed.sections.FEED)) return { ok: false, reason: '[FEED] is required for closure' };
  }
  if (parsed.meta.target === 'log' && !normalise(parsed.sections.LOG)) {
    return { ok: false, reason: '[LOG] is required for log target' };
  }
  if (parsed.meta.target === 'concilio') {
    if (!parsed.meta.session_id) return { ok: false, reason: 'session_id is required for concilio' };
    if (!isSafeSessionId(parsed.meta.session_id)) return { ok: false, reason: 'session_id contains unsafe characters' };
    if (!normalise(parsed.sections.LOG)) return { ok: false, reason: '[LOG] body is required for concilio' };
  }
  return { ok: true };
}

function integrateLog(parsed, source) {
  const tsLabel = canaryLabel(parsed.meta.timestamp);
  const logText = normalise(parsed.sections.LOG);
  const entry =
    `\n---\n` +
    `**[${tsLabel}] VOZ GEMINI:**\n` +
    `**MISION:** Gemini Drive Bridge: ${firstLine(logText) || 'Entrada LOG'}\n` +
    `**WORK PACKET:** ${parsed.meta.packet_id}\n\n` +
    `**DETALLES:**\n${logText}\n\n` +
    `**ORIGEN:** ${source.id}\n`;
  appendMarkdown(LOG_PATH, '# ARGOS GLOBAL LOG\nRegistro operativo compartido por la tripulacion.\n', entry);
  appendJsonl(EVENTS_PATH, {
    timestamp: parsed.meta.timestamp,
    timestamp_label: tsLabel.replace(' Atlantic/Canary', ''),
    actor: 'Gemini',
    module: 'argos',
    type: 'gemini_drive_bridge_log',
    packet_id: parsed.meta.packet_id,
    refId: parsed.meta.packet_id,
    status: 'received',
    summary: firstLine(logText) || 'Entrada LOG de Gemini',
    details: logText,
    source: 'gemini_drive_bridge'
  });
}

function integrateClosure(parsed, source) {
  integrateLog(parsed, source);
  const ts = parsed.meta.timestamp;
  const tsLabel = canaryLabel(ts);
  const packetId = parsed.meta.packet_id;
  const mission = normalise(parsed.state.summary) || firstLine(parsed.sections.LOG) || 'Cierre Gemini Drive';
  const status = VALID_STATUSES.has(normalise(parsed.state.status)) ? normalise(parsed.state.status) : 'idle';

  const shadow = normalise(parsed.sections.SHADOW);
  appendMarkdown(
    SHADOW_PATH,
    '# ARGOS GLOBAL SHADOW LOG\nMaterial observado sin destino operativo inmediato.\n',
    `\n---\n**[${tsLabel}] VOZ GEMINI (SOMBRA):**\n**PACKET:** ${packetId}\n**TAREA:** ${mission}\n**SOMBRA:**\n${shadow}\n`
  );

  const glitch = normalise(parsed.sections.GLITCH);
  if (!isEmptyGlitch(glitch)) {
    appendMarkdown(
      GLITCH_PATH,
      '# ARGOS GLOBAL GLITCH LOG\nRegistro estructural de fallas sistemicas y fricciones tecnicas.\n',
      `\n---\n**[${tsLabel}] VOZ GEMINI (GLITCH):**\n**PACKET:** ${packetId}\n${glitch}\n`
    );
    appendJsonl(GLITCHES_JSONL_PATH, {
      id: `GEMINI-DRIVE-${Date.now()}`,
      timestamp: ts,
      timestamp_label: tsLabel,
      actor: 'Gemini',
      module: 'gemini_drive_bridge',
      type: 'glitch',
      status: 'open',
      packet_id: packetId,
      summary: firstLine(glitch) || 'Glitch via Gemini Drive Bridge',
      details: glitch,
      source: 'gemini_drive_bridge'
    });
  }

  const feedId = `gemini_drive_${Date.now()}`;
  appendJsonl(FEED_PATH, {
    id: feedId,
    timestamp: ts,
    kind: 'crew_update',
    speaker: 'crew',
    sender_name: 'Gemini',
    sender_role: 'agent',
    audience: 'feed',
    source: 'gemini_drive_bridge',
    summary: `[CIERRE-GEMINI-DRIVE] ${mission}`,
    details: normalise(parsed.sections.FEED),
    status,
    tokens: 0,
    refId: packetId,
    transcriptRef: `gemini_drive_bridge:${source.id}`
  });

  appendJsonl(REMOTE_CLOSURES_PATH, {
    key: `gemini|${packetId}|${ts}`,
    closure_id: feedId,
    timestamp: ts,
    agent: 'Gemini',
    packet_id: packetId,
    trigger: 'gemini_drive_bridge',
    source: 'gemini_drive_bridge'
  });

  updateIaStatus(packetId, status, mission, normalise(parsed.state.next_step), normalise(parsed.state.handoff_to), ts);
}

function integrateConcilio(parsed, source) {
  ensureDir(CONCILIO_SESSIONS_DIR);
  ensureDir(CONCILIO_DIR);
  const sessionId = parsed.meta.session_id;
  const packetId = parsed.meta.packet_id;
  const body = normalise(parsed.sections.LOG);
  const ts = parsed.meta.timestamp;
  const type = normalise(parsed.meta.type) || 'mensaje';
  const sessionPath = path.join(CONCILIO_SESSIONS_DIR, `${sessionId}.md`);
  const entryLines = [
    '',
    '---',
    `**[${canaryLabel(ts)}] VOZ GEMINI | CONCILIO**`,
    `SESSION_ID: ${sessionId}`,
    `SOURCE: ${source.id}`
  ];
  if (packetId) entryLines.push(`PACKET_ID: ${packetId}`);
  if (type) entryLines.push(`TYPE: ${type}`);
  entryLines.push('', body, '');
  appendMarkdown(sessionPath, `# CONCILIO SESSION ${sessionId}\n`, entryLines.join('\n'));
  appendJsonl(CONCILIO_JSONL_PATH, {
    message_id: `gemini_drive_${Date.now()}`,
    agent: 'Gemini',
    timestamp: ts,
    room: 'concilio',
    type,
    body,
    packet_id: packetId,
    session_ref: sessionId,
    source: 'gemini_drive_bridge'
  });
  appendJsonl(EVENTS_PATH, {
    timestamp: ts,
    actor: 'Gemini',
    module: 'concilio',
    type: 'concilio_message',
    packet_id: packetId,
    refId: packetId,
    summary: firstLine(body) || `Concilio ${sessionId}`,
    details: body,
    source: 'gemini_drive_bridge',
    session_ref: sessionId
  });
}

function updateIaStatus(packetId, status, summary, nextStep, handoffTo, timestamp) {
  const state = readJson(STATE_PATH, {});
  const ia = state.ia_status && typeof state.ia_status === 'object' ? state.ia_status : {};
  const handoffCanonical = CANONICAL_HANDOFFS.has(handoffTo) ? handoffTo : '';
  ia.Gemini = {
    ...(ia.Gemini || {}),
    status: status === 'idle' ? 'standby' : 'active',
    task: status === 'idle' ? '' : packetId,
    task_subject: summary,
    since: timestamp,
    last_seen: timestamp,
    stale: false,
    stale_since: '',
    handoff_to: handoffCanonical,
    next_step: nextStep,
    last_output: summary
  };
  state.ia_status = ia;
  if (nextStep) state.next_step = nextStep;
  writeJson(STATE_PATH, state);
}

function recordBridgeError(doc, reason, markdown) {
  const safeName = safeFileName(`${doc.name || doc.id}.${Date.now()}.error.md`);
  const errorPath = path.join(ERROR_DIR, safeName);
  const body = [
    `source_id: ${doc.id || ''}`,
    `source_name: ${doc.name || ''}`,
    `reason: ${reason}`,
    '',
    markdown || ''
  ].join('\n');
  if (!dryRun) fs.writeFileSync(errorPath, body, 'utf8');
  appendBridgeEvent('gemini_drive_bridge_rejected', {
    summary: `Rejected ${doc.name || doc.id}`,
    details: reason,
    source_doc_id: doc.id || ''
  });
  console.warn(`[gemini-drive-bridge] rejected ${doc.name || doc.id}: ${reason}`);
}

function appendBridgeEvent(type, extra) {
  appendJsonl(EVENTS_PATH, {
    timestamp: nowIso(),
    actor: 'Codex',
    module: 'gemini_drive_bridge',
    type,
    status: 'processed',
    source: 'gemini_drive_bridge',
    ...(extra || {})
  });
}

function parseKeyValues(raw) {
  const out = {};
  String(raw || '').split(/\n/).forEach((line) => {
    const match = line.match(/^\s*([a-zA-Z0-9_]+)\s*:\s*(.*?)\s*$/);
    if (match) out[match[1].toLowerCase()] = match[2];
  });
  return out;
}

function parseTimestamp(raw) {
  const parsed = Date.parse(normalise(raw));
  return Number.isNaN(parsed) ? nowIso() : new Date(parsed).toISOString();
}

function canaryLabel(iso) {
  const date = new Date(iso);
  const label = date.toLocaleString('sv-SE', {
    timeZone: 'Atlantic/Canary',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  }).slice(0, 16);
  return `${label} Atlantic/Canary`;
}

function appendMarkdown(filePath, fallbackHeader, entry) {
  ensureDir(path.dirname(filePath));
  const existing = fs.existsSync(filePath) ? fs.readFileSync(filePath, 'utf8') : fallbackHeader;
  fs.writeFileSync(filePath, `${existing.endsWith('\n') ? existing : `${existing}\n`}${entry}`, 'utf8');
}

function appendJsonl(filePath, record) {
  ensureDir(path.dirname(filePath));
  let separator = '';
  if (fs.existsSync(filePath) && fs.statSync(filePath).size > 0) {
    const fd = fs.openSync(filePath, 'r');
    try {
      const buffer = Buffer.alloc(1);
      fs.readSync(fd, buffer, 0, 1, fs.statSync(filePath).size - 1);
      separator = buffer.toString() === '\n' ? '' : '\n';
    } finally {
      fs.closeSync(fd);
    }
  }
  fs.appendFileSync(filePath, `${separator}${JSON.stringify(record)}\n`, 'utf8');
}

function readBridgeState() {
  const state = readJson(BRIDGE_STATE_PATH, { version: 2, processed: {}, errors: {} });
  state.version = 2;
  state.processed = state.processed || {};
  state.errors = state.errors || {};
  state.updated_at = nowIso();
  return state;
}

function writeBridgeState(state) {
  if (dryRun) return;
  state.updated_at = nowIso();
  writeJson(BRIDGE_STATE_PATH, state);
}

function readJson(filePath, fallback) {
  try {
    if (!fs.existsSync(filePath)) return fallback;
    return JSON.parse(fs.readFileSync(filePath, 'utf8').replace(/^\uFEFF/, ''));
  } catch {
    return fallback;
  }
}

function writeJson(filePath, value) {
  ensureDir(path.dirname(filePath));
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`, 'utf8');
}

function ensureDir(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

function normalise(value) {
  return String(value || '').trim();
}

function firstLine(value) {
  return normalise(value).split(/\n/).map((line) => line.trim()).find(Boolean) || '';
}

function isEmptyGlitch(value) {
  const cleaned = normalise(value).toLowerCase().replace(/[().\s]/g, '');
  return cleaned === '' || cleaned === 'none' || cleaned === 'no' || cleaned === 'vacio';
}

function isSafeSessionId(value) {
  return /^[A-Za-z0-9][A-Za-z0-9_.-]{1,120}$/.test(value);
}

function safeFileName(value) {
  return value.replace(/[^A-Za-z0-9_.-]+/g, '_').slice(0, 180);
}

function escapeDriveQueryValue(value) {
  return String(value || '').replace(/\\/g, '\\\\').replace(/'/g, "\\'");
}

function positiveNumber(value, fallback) {
  const n = Number(value);
  return Number.isFinite(n) && n > 0 ? Math.trunc(n) : fallback;
}

function nowIso() {
  return new Date().toISOString();
}

function parseArgs(argv) {
  const out = {};
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (!arg.startsWith('--')) continue;
    const key = arg.slice(2);
    const next = argv[i + 1];
    if (next && !next.startsWith('--')) {
      out[key] = next;
      i += 1;
    } else {
      out[key] = true;
    }
  }
  return out;
}

function printHelp() {
  console.log(`Usage:
  node ARGOS_RUNTIME/tools/gemini_drive_bridge.js --once
  node ARGOS_RUNTIME/tools/gemini_drive_bridge.js --watch
  node ARGOS_RUNTIME/tools/gemini_drive_bridge.js --from-file fixture.md

Environment:
  ARGOS_DRIVE_ROOT_FOLDER_ID         Preferred Drive folder id for ARGOS root.
  ARGOS_DRIVE_ROOT_FOLDER_NAME       Folder name fallback. Default: ARGOS.
  ARGOS_GOOGLE_SERVICE_ACCOUNT_JSON  Service account JSON path.
  GOOGLE_APPLICATION_CREDENTIALS     ADC/service account JSON path.

Options:
  --once              Scan Drive once and exit.
  --watch             Poll Drive continuously (default).
  --from-file <path>  Process a local Markdown fixture through the same parser/writer.
  --dry-run           Validate without writing local files or trashing Docs.
  --keep-drive-docs   Do not move processed Google Docs to trash.
  --poll-ms <n>       Watch polling interval. Default: ${DEFAULT_POLL_MS}.
  --settle-ms <n>     Minimum modified-age before processing. Default: ${DEFAULT_SETTLE_MS}.
`);
}
