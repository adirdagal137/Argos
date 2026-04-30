#!/usr/bin/env node
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const thisFile = fileURLToPath(import.meta.url);
const runtimeDir = path.resolve(path.dirname(thisFile), '..');
const feedDir = path.join(runtimeDir, 'cubierta');
const logsDir = path.join(runtimeDir, 'events', 'logs');
const activeFeed = path.join(feedDir, 'feed.jsonl');

const CANDIDATE_ORDER = [
  path.join('legacy', 'captain_feed.jsonl'),
  path.join('legacy', 'captain_feed.preclean_2026-04-25.jsonl'),
  path.join('legacy', 'captain_feed.pre_heartbeat_cleanup_2026-04-24T23-06.jsonl'),
  path.join('legacy', 'captain_feed.jsonl.bak_saneamiento')
];

const MOJI_RE = /Ã|Â|�/g;
const MAX_ACCEPTABLE_MOJI_RATIO = 8.0;

function nowStamp() {
  const d = new Date();
  const iso = d.toISOString();
  return iso.replace(/[:.]/g, '-');
}

function ensureDir(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

function countMojibake(text) {
  return (text.match(MOJI_RE) || []).length;
}

function readJsonl(filePath) {
  if (!fs.existsSync(filePath)) {
    return { filePath, exists: false, lines: 0, invalid: 0, mojibake: 0, ratio: 0, records: [], text: '' };
  }

  const text = fs.readFileSync(filePath, 'utf8').replace(/^\uFEFF/, '');
  const lines = text.split(/\r?\n/).filter((line) => line.trim() !== '');
  const records = [];
  let invalid = 0;

  lines.forEach((line, idx) => {
    try {
      const parsed = JSON.parse(line);
      records.push({ raw: line, data: parsed, idx });
    } catch {
      invalid += 1;
    }
  });

  const mojibake = countMojibake(text);
  const ratio = lines.length > 0 ? Number((mojibake / lines.length).toFixed(2)) : 0;

  return {
    filePath,
    exists: true,
    lines: lines.length,
    invalid,
    mojibake,
    ratio,
    records,
    text
  };
}

function parseTs(value) {
  const raw = String(value || '').trim();
  if (!raw) return 0;
  const parsed = Date.parse(raw);
  return Number.isNaN(parsed) ? 0 : parsed;
}

function dedupe(records) {
  const seen = new Set();
  const out = [];

  for (const rec of records) {
    const data = rec.data || {};
    const id = String(data.id || '').trim();
    const key = id || [
      String(data.timestamp || '').trim(),
      String(data.sender_name || '').trim(),
      String(data.summary || '').trim(),
      String(data.refId || '').trim(),
      String(data.source || '').trim()
    ].join('|');

    if (seen.has(key)) continue;
    seen.add(key);
    out.push(rec);
  }

  out.sort((a, b) => {
    const ta = parseTs(a.data?.timestamp);
    const tb = parseTs(b.data?.timestamp);
    if (ta !== tb) return ta - tb;
    return a.idx - b.idx;
  });

  return out;
}

function chooseBase(candidates) {
  const valid = candidates.filter((c) => c.exists && c.invalid === 0 && c.lines > 0);
  if (valid.length === 0) throw new Error('No hay candidatos validos para restauracion.');

  for (const preferred of CANDIDATE_ORDER) {
    const candidate = valid.find((c) => path.basename(c.filePath) === preferred);
    if (candidate && candidate.ratio <= MAX_ACCEPTABLE_MOJI_RATIO) {
      return { chosen: candidate, reason: `preferencia+calidad (${preferred})` };
    }
  }

  const sorted = [...valid].sort((a, b) => {
    if (a.ratio !== b.ratio) return a.ratio - b.ratio;
    return b.lines - a.lines;
  });

  return { chosen: sorted[0], reason: 'mejor ratio de mojibake disponible' };
}

function writeForensicReport(reportPath, payload) {
  const lines = [];
  lines.push(`# CAPTAIN FEED FORENSIC REPORT`);
  lines.push(``);
  lines.push(`- Generated at: ${new Date().toISOString()}`);
  lines.push(`- Active feed: ${payload.activeFeed}`);
  lines.push(`- Selected base: ${payload.base.filePath}`);
  lines.push(`- Selection reason: ${payload.baseReason}`);
  lines.push(`- Replay records appended: ${payload.replayed}`);
  lines.push(`- Output records: ${payload.outputLines}`);
  lines.push(`- Output mojibake ratio: ${payload.outputRatio}`);
  lines.push(``);
  lines.push(`## Candidates`);
  payload.candidates.forEach((c) => {
    lines.push(`- ${path.basename(c.filePath)} => lines=${c.lines}, invalid=${c.invalid}, mojibake=${c.mojibake}, ratio=${c.ratio}`);
  });
  lines.push(``);
  lines.push(`## Notes`);
  lines.push(`- No se aplico reparacion heuristica de texto; restauracion por fuente + replay seguro.`);
  lines.push(`- Dedupe aplicado por id o firma estructurada.`);

  fs.writeFileSync(reportPath, `${lines.join('\n')}\n`, 'utf8');
}

function main() {
  ensureDir(logsDir);

  const current = readJsonl(activeFeed);
  if (!current.exists) throw new Error(`No existe feed activo: ${activeFeed}`);

  const candidateStats = CANDIDATE_ORDER
    .map((name) => readJsonl(path.join(feedDir, name)));

  const { chosen: base, reason } = chooseBase(candidateStats);

  const backupPath = path.join(feedDir, `captain_feed.backup_before_recovery_${nowStamp()}.jsonl`);
  fs.copyFileSync(activeFeed, backupPath);

  const baseMaxTs = base.records.reduce((max, rec) => Math.max(max, parseTs(rec.data?.timestamp)), 0);
  const replay = current.records.filter((rec) => parseTs(rec.data?.timestamp) > baseMaxTs);

  const merged = dedupe([...base.records, ...replay]);
  const output = merged.map((rec) => JSON.stringify(rec.data)).join('\n') + '\n';

  fs.writeFileSync(activeFeed, output, 'utf8');

  const post = readJsonl(activeFeed);
  if (post.invalid > 0) {
    fs.copyFileSync(backupPath, activeFeed);
    throw new Error(`Restore invalido: ${post.invalid} lineas corruptas. Revertido desde backup.`);
  }

  const reportPath = path.join(logsDir, `CAPTAIN_FEED_FORENSIC_${nowStamp()}.md`);
  writeForensicReport(reportPath, {
    activeFeed,
    base,
    baseReason: reason,
    candidates: candidateStats,
    replayed: replay.length,
    outputLines: post.lines,
    outputRatio: post.ratio
  });

  console.log(JSON.stringify({
    status: 'ok',
    activeFeed,
    backupPath,
    reportPath,
    selectedBase: path.basename(base.filePath),
    selectedReason: reason,
    replayed: replay.length,
    outputLines: post.lines,
    outputMojibake: post.mojibake,
    outputRatio: post.ratio
  }, null, 2));
}

main();
