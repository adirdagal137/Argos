#!/usr/bin/env node
/*
 * Gemini Append Bridge V1
 * Fallback local writer for Gemini when HTTP/tunnel access is unavailable.
 *
 * V1 accepts only LOG deposits in ARGOS_RUNTIME/Gemini and appends them to
 * ARGOS_RUNTIME/ARGOS_GLOBAL_LOG.md. Invalid or unsupported deposits are moved
 * to ARGOS_RUNTIME/Gemini/_quarantine without deleting their contents.
 */

const fs = require('fs');
const path = require('path');

const SCRIPT_DIR = __dirname;
const RUNTIME_DIR = path.resolve(SCRIPT_DIR, '..');
const GEMINI_DIR = path.join(RUNTIME_DIR, 'Gemini');
const QUARANTINE_DIR = path.join(GEMINI_DIR, '_quarantine');
const PROCESSED_DIR = path.join(GEMINI_DIR, '_processed');
const GLOBAL_LOG_PATH = path.join(RUNTIME_DIR, 'ARGOS_GLOBAL_LOG.md');
const EVENTS_PATH = path.join(RUNTIME_DIR, 'events', 'argos.events.jsonl');
const DEFAULT_SETTLE_MS = 2000;

const args = parseArgs(process.argv.slice(2));
const once = Boolean(args.once);
const watch = Boolean(args.watch) || !once;
const dryRun = Boolean(args['dry-run']);
const keepProcessed = Boolean(args['keep-processed']);
const settleMs = Number.isFinite(Number(args['settle-ms']))
  ? Math.max(0, Number(args['settle-ms']))
  : DEFAULT_SETTLE_MS;

const processing = new Set();

main();

function main() {
  ensureDir(GEMINI_DIR);
  ensureDir(QUARANTINE_DIR);
  if (keepProcessed) ensureDir(PROCESSED_DIR);

  if (args.help) {
    printHelp();
    return;
  }

  scanOnce();

  if (!watch) return;

  console.log(`[gemini-append-bridge] watching ${GEMINI_DIR}`);
  fs.watch(GEMINI_DIR, { persistent: true }, () => {
    setTimeout(scanOnce, Math.min(settleMs, 500));
  });
  setInterval(scanOnce, Math.max(settleMs, 5000));
}

function scanOnce() {
  const entries = fs.readdirSync(GEMINI_DIR, { withFileTypes: true });
  for (const entry of entries) {
    if (!entry.isFile()) continue;
    if (!entry.name.toLowerCase().endsWith('.md')) continue;
    const filePath = path.join(GEMINI_DIR, entry.name);
    if (processing.has(filePath)) continue;
    processing.add(filePath);
    try {
      processDeposit(filePath);
    } finally {
      processing.delete(filePath);
    }
  }
}

function processDeposit(filePath) {
  const fileName = path.basename(filePath);
  const target = parseTarget(fileName);
  if (!target) {
    quarantine(filePath, 'bad_name');
    return;
  }

  if (target !== 'LOG') {
    quarantine(filePath, `unsupported_target_${target.toLowerCase()}`);
    return;
  }

  const stat = fs.statSync(filePath);
  if (Date.now() - stat.mtimeMs < settleMs) return;

  const raw = fs.readFileSync(filePath, 'utf8').replace(/^\uFEFF/, '');
  if (!/^\s*agent\s*:\s*Gemini\s*$/im.test(raw)) {
    quarantine(filePath, 'missing_agent_gemini');
    return;
  }

  const timestamp = new Date();
  const timestampIso = timestamp.toISOString();
  const canaryLabel = canaryTimestampLabel(timestamp);
  const packetId = extractField(raw, 'packet_id') || extractField(raw, 'packet') || 'N/A';
  const summary = summarize(raw);
  const entry =
    `\n---\n` +
    `**[${canaryLabel}] VOZ GEMINI:**\n` +
    `**MISION:** Gemini Append Bridge: ${summary}\n` +
    `**WORK PACKET:** ${packetId}\n\n` +
    `**DETALLES:**\n${raw.trim()}\n\n` +
    `**ORIGEN:** ARGOS_RUNTIME/Gemini/${fileName}\n`;

  if (dryRun) {
    console.log(`[dry-run] would append ${fileName} to ${GLOBAL_LOG_PATH}`);
    return;
  }

  appendMarkdown(GLOBAL_LOG_PATH, '# ARGOS GLOBAL LOG\nRegistro operativo compartido por la tripulacion.\n', entry);
  appendJsonl(EVENTS_PATH, {
    timestamp: timestampIso,
    timestamp_label: canaryLabel.replace(' Atlantic/Canary', ''),
    actor: 'Gemini',
    module: 'argos',
    type: 'gemini_append_bridge_log',
    packet_id: packetId === 'N/A' ? '' : packetId,
    refId: packetId === 'N/A' ? '' : packetId,
    status: 'received',
    mission: summary,
    summary,
    details: raw.trim(),
    source: 'gemini_append_bridge'
  });

  if (keepProcessed) {
    moveTo(filePath, PROCESSED_DIR, 'processed');
  } else {
    fs.unlinkSync(filePath);
  }

  console.log(`[gemini-append-bridge] appended ${fileName}`);
}

function parseTarget(fileName) {
  const canonical = /^gemini_([a-z]+)_[^.]+\.md$/i.exec(fileName);
  if (canonical) return canonical[1].toUpperCase();

  // Compatibility with the first hand-written probe:
  // LOG_gemini-code-1777226564485.md
  const legacy = /^([a-z]+)_gemini[-_][^.]+\.md$/i.exec(fileName);
  if (legacy) return legacy[1].toUpperCase();

  return null;
}

function extractField(text, name) {
  const escaped = name.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const re = new RegExp(`^\\s*${escaped}\\s*:\\s*(.+?)\\s*$`, 'im');
  const match = re.exec(text);
  return match ? match[1].trim() : '';
}

function summarize(text) {
  const lines = text
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean)
    .filter((line) => !/^\s*agent\s*:/i.test(line))
    .filter((line) => !/^\s*packet(_id)?\s*:/i.test(line));

  const heading = lines.find((line) => /^#{1,6}\s+/.test(line));
  const candidate = (heading || lines[0] || 'Entrada LOG de Gemini').replace(/^#{1,6}\s+/, '');
  return candidate.length > 120 ? `${candidate.slice(0, 117)}...` : candidate;
}

function appendMarkdown(filePath, fallbackHeader, entry) {
  const existing = fs.existsSync(filePath) ? fs.readFileSync(filePath, 'utf8') : fallbackHeader;
  const base = existing.endsWith('\n') ? existing : `${existing}\n`;
  fs.writeFileSync(filePath, `${base}${entry}`, 'utf8');
}

function appendJsonl(filePath, record) {
  ensureDir(path.dirname(filePath));
  const line = JSON.stringify(record);
  const separator = fs.existsSync(filePath) && fs.statSync(filePath).size > 0 ? '' : '';
  fs.appendFileSync(filePath, `${separator}${line}\n`, 'utf8');
}

function quarantine(filePath, reason) {
  if (dryRun) {
    console.log(`[dry-run] would quarantine ${path.basename(filePath)} (${reason})`);
    return;
  }
  ensureDir(QUARANTINE_DIR);
  const destination = moveTo(filePath, QUARANTINE_DIR, reason);
  console.warn(`[gemini-append-bridge] quarantined ${path.basename(filePath)} -> ${path.basename(destination)} (${reason})`);
}

function moveTo(filePath, dir, suffix) {
  ensureDir(dir);
  const parsed = path.parse(filePath);
  const destination = uniquePath(path.join(dir, `${parsed.name}.${suffix}${parsed.ext}`));
  fs.renameSync(filePath, destination);
  return destination;
}

function uniquePath(candidate) {
  if (!fs.existsSync(candidate)) return candidate;
  const parsed = path.parse(candidate);
  let n = 1;
  while (true) {
    const next = path.join(parsed.dir, `${parsed.name}.${n}${parsed.ext}`);
    if (!fs.existsSync(next)) return next;
    n += 1;
  }
}

function canaryTimestampLabel(date) {
  const canaryTs = date.toLocaleString('sv-SE', {
    timeZone: 'Atlantic/Canary',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  }).slice(0, 16);
  return `${canaryTs} Atlantic/Canary`;
}

function ensureDir(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
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
  node ARGOS_RUNTIME/tools/gemini_append_bridge.js --once
  node ARGOS_RUNTIME/tools/gemini_append_bridge.js --watch

Options:
  --once             Process current deposits and exit.
  --watch            Keep watching ARGOS_RUNTIME/Gemini (default).
  --dry-run          Validate without writing, moving, or deleting files.
  --keep-processed   Move processed files to _processed instead of deleting.
  --settle-ms <n>    Minimum file age before processing. Default: ${DEFAULT_SETTLE_MS}.

Accepted V1 deposit:
  ARGOS_RUNTIME/Gemini/gemini_LOG_20260426T174245Z.md
  The file must include a line: agent: Gemini
`);
}
