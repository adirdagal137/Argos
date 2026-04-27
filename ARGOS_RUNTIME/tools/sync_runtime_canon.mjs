import fs from 'fs';
import path from 'path';

const runtimeDir = 'C:/Users/Widox/Desktop/ARGOS/ARGOS_RUNTIME';
const bitacoraDir = path.join(runtimeDir, 'bitacora');
const cubiertaDir = path.join(runtimeDir, 'cubierta');

const paths = {
  log: path.join(runtimeDir, 'logs', 'current', 'ARGOS_GLOBAL_LOG.md'),
  shadow: path.join(runtimeDir, 'logs', 'current', 'ARGOS_GLOBAL_SHADOW_LOG.md'),
  handoffs: path.join(runtimeDir, 'logs', 'current', 'ARGOS_GLOBAL_HANDOFF_LOG.md'),
  glitches: path.join(runtimeDir, 'logs', 'current', 'ARGOS_GLOBAL_GLITCH_LOG.md'),
  feed: path.join(runtimeDir, 'views', 'ui_export', 'captain_feed.jsonl'),
  state: path.join(runtimeDir, 'state', 'argos.state.json'),
  vector: path.join(runtimeDir, 'ARGOS_VECTOR.md'),
  events: path.join(runtimeDir, 'events', 'argos.events.jsonl'),
  glitchEvents: path.join(runtimeDir, 'events', 'argos.glitches.jsonl'),
  tokens: path.join(runtimeDir, 'events', 'argos.tokens.jsonl'),
  logbookSnapshot: path.join(runtimeDir, 'views', 'logbook_export', 'logbook.snapshot.json'),
  timeline: path.join(runtimeDir, 'views', 'history_export', 'argos.timeline.jsonl'),
  inbox: path.join(runtimeDir, 'work_packets', 'inbox')
};

function readText(filePath) {
  if (!fs.existsSync(filePath)) return '';
  const raw = fs.readFileSync(filePath, 'utf8');
  return raw.charCodeAt(0) === 0xfeff ? raw.slice(1) : raw;
}

function writeIfChanged(filePath, content) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  if (readText(filePath) === content) return false;
  fs.writeFileSync(filePath, content, 'utf8');
  return true;
}

function copyIfChanged(source, destination) {
  return writeIfChanged(destination, readText(source));
}

function feedMarkdown(limit = 80) {
  const rows = readText(paths.feed)
    .split(/\r?\n/)
    .filter(Boolean)
    .map((line) => {
      try {
        return JSON.parse(line);
      } catch {
        return null;
      }
    })
    .filter(Boolean)
    .slice(-limit)
    .reverse();

  const lines = [
    '# Feed de cubierta',
    '',
    'Alias humano de `views/ui_export/captain_feed.jsonl`. El JSONL sigue vigente durante la fase de compatibilidad.',
    ''
  ];

  for (const row of rows) {
    const sender = row.sender_name || row.agent || row.sender || 'ARGOS';
    lines.push(`## ${row.timestamp || 'sin timestamp'} - ${sender}`);
    if (row.refId) lines.push(`- Ref: ${row.refId}`);
    lines.push(`- Resumen: ${row.summary || '(sin resumen)'}`);
    if (row.details) lines.push('', String(row.details));
    lines.push('');
  }

  if (rows.length === 0) lines.push('_Sin mensajes visibles._', '');
  return lines.join('\n');
}

function inboxMarkdown(limit = 80) {
  const files = fs.existsSync(paths.inbox)
    ? fs.readdirSync(paths.inbox).filter((name) => name.toLowerCase().endsWith('.md')).sort()
    : [];
  const lines = ['# Resumen de inbox', '', `Total visible: ${files.length}`, ''];

  for (const name of files.slice(0, limit)) {
    const id = name.split('__')[0].replace(/\.md$/i, '');
    const title = name.replace(/\.md$/i, '').replace(`${id}__`, '').replace(/_/g, ' ');
    lines.push(`- ${id}: ${title}`);
  }
  if (files.length > limit) lines.push(`- ... ${files.length - limit} paquetes adicionales omitidos en cubierta.`);
  return `${lines.join('\n')}\n`;
}

function artifactsMarkdown() {
  const artifacts = [
    ['Dashboard snapshot', paths.logbookSnapshot],
    ['Timeline export', paths.timeline],
    ['Captain feed JSONL', paths.feed],
    ['Events JSONL', paths.events],
    ['Glitches JSONL', paths.glitchEvents],
    ['Tokens JSONL', paths.tokens],
    ['Vector activo', paths.vector],
    ['State activo', paths.state]
  ];
  const lines = ['# Artefactos visibles de cubierta', '', 'Indice liviano para UI, inspeccion humana y agentes remotos.', ''];
  for (const [label, filePath] of artifacts) {
    const rel = path.relative(runtimeDir, filePath).replace(/\\/g, '/');
    if (!fs.existsSync(filePath)) {
      lines.push(`- ${label}: \`${rel}\` - no existe`);
      continue;
    }
    const stat = fs.statSync(filePath);
    lines.push(`- ${label}: \`${rel}\` - ${stat.size} bytes - ${stat.mtime.toISOString()}`);
  }
  return `${lines.join('\n')}\n`;
}

fs.mkdirSync(bitacoraDir, { recursive: true });
fs.mkdirSync(cubiertaDir, { recursive: true });

const changed = [];
for (const [source, destination] of [
  [paths.log, path.join(bitacoraDir, 'log.md')],
  [paths.shadow, path.join(bitacoraDir, 'shadowlog.md')],
  [paths.handoffs, path.join(bitacoraDir, 'handoffs.md')],
  [paths.glitches, path.join(bitacoraDir, 'glitches.md')],
  [paths.state, path.join(cubiertaDir, 'state.json')],
  [paths.vector, path.join(cubiertaDir, 'vector.md')]
]) {
  if (copyIfChanged(source, destination)) changed.push(path.relative(runtimeDir, destination).replace(/\\/g, '/'));
}

for (const [destination, content] of [
  [path.join(cubiertaDir, 'feed.md'), feedMarkdown()],
  [path.join(cubiertaDir, 'inbox.md'), inboxMarkdown()],
  [path.join(cubiertaDir, 'artefactos.md'), artifactsMarkdown()]
]) {
  if (writeIfChanged(destination, content)) changed.push(path.relative(runtimeDir, destination).replace(/\\/g, '/'));
}

console.log(JSON.stringify({ ok: true, changed }, null, 2));
