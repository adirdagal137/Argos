#!/usr/bin/env node
// check_versions.js -- escanea docs operativos y reporta estado de front matter
// Uso: node ARGOS_RUNTIME/tools/check_versions.js [--json]

const fs = require('fs');
const path = require('path');

const REPO_ROOT = path.resolve(__dirname, '..', '..');
const VERSIONS_FILE = path.join(REPO_ROOT, 'versions.json');

const NIVEL_1 = [
  'ARGOS_RUNTIME/ARGOS_QUICKSTART.md',
  'ARGOS_RUNTIME/INTER_AI_PROTOCOL.md',
  'ARGOS_RUNTIME/ARGOS_CREW_VOICES.md',
  'ARGOS_RUNTIME/ARGOS_VECTOR.md',
  'ARGOS_RUNTIME/REGISTRY.md',
  'CLAUDE.md',
  'AGENTS.md',
  'README.md',
];

const NIVEL_2 = [
  'ARGOS_RUNTIME/docs/protocols/REMOTE_CLOSURE_SETUP.md',
  'ARGOS_RUNTIME/tools/work_packet_template.md',
];

function extractFrontMatter(content) {
  if (!content.startsWith('---')) return null;
  const end = content.indexOf('\n---', 3);
  if (end === -1) return null;
  const yaml = content.slice(4, end).trim();
  const result = {};
  for (const line of yaml.split('\n')) {
    const m = line.replace(/\r$/, '').match(/^(\w[\w_-]*):\s*(.*)$/);
    if (m) result[m[1]] = m[2].trim();
  }
  return result;
}

function checkDoc(relPath, nivel) {
  const absPath = path.join(REPO_ROOT, relPath);
  if (!fs.existsSync(absPath)) return { path: relPath, nivel, status: 'NOT_FOUND' };
  const content = fs.readFileSync(absPath, 'utf8');
  const fm = extractFrontMatter(content);
  if (!fm) return { path: relPath, nivel, status: 'NO_FRONT_MATTER' };
  return {
    path: relPath,
    nivel,
    status: fm.status || '?',
    doc_id: fm.doc_id || '?',
    version: fm.version || '?',
    last_updated: fm.last_updated || '?',
    owner: fm.owner || '?',
  };
}

function loadVersionsJson() {
  if (!fs.existsSync(VERSIONS_FILE)) return null;
  return JSON.parse(fs.readFileSync(VERSIONS_FILE, 'utf8'));
}

function run() {
  const asJson = process.argv.includes('--json');
  const results = [
    ...NIVEL_1.map(p => checkDoc(p, 1)),
    ...NIVEL_2.map(p => checkDoc(p, 2)),
  ];

  const versionsData = loadVersionsJson();
  const issues = {
    no_front_matter: results.filter(r => r.status === 'NO_FRONT_MATTER'),
    not_found: results.filter(r => r.status === 'NOT_FOUND'),
    deprecated: results.filter(r => r.status === 'deprecated'),
  };

  // Docs en versions.json no encontrados en filesystem
  const broken_refs = [];
  if (versionsData) {
    for (const [key, doc] of Object.entries(versionsData.documents || {})) {
      const abs = path.join(REPO_ROOT, doc.path);
      if (!fs.existsSync(abs)) broken_refs.push({ key, path: doc.path });
    }
  }

  if (asJson) {
    console.log(JSON.stringify({ results, issues, broken_refs }, null, 2));
    return;
  }

  console.log('\n=== ARGOS check_versions ===\n');
  console.log(`Escaneando ${results.length} documentos (Nivel 1: ${NIVEL_1.length}, Nivel 2: ${NIVEL_2.length})\n`);

  if (issues.no_front_matter.length) {
    console.log(`[!] SIN FRONT MATTER (${issues.no_front_matter.length}):`);
    issues.no_front_matter.forEach(r => console.log(`    - ${r.path}`));
  }
  if (issues.not_found.length) {
    console.log(`[!] NO ENCONTRADOS (${issues.not_found.length}):`);
    issues.not_found.forEach(r => console.log(`    - ${r.path}`));
  }
  if (issues.deprecated.length) {
    console.log(`[!] DEPRECATED (${issues.deprecated.length}):`);
    issues.deprecated.forEach(r => console.log(`    - ${r.path} (${r.doc_id} v${r.version})`));
  }
  if (broken_refs.length) {
    console.log(`[!] REFS ROTAS EN versions.json (${broken_refs.length}):`);
    broken_refs.forEach(r => console.log(`    - ${r.key} -> ${r.path}`));
  }

  const ok = results.filter(r => r.status !== 'NO_FRONT_MATTER' && r.status !== 'NOT_FOUND');
  console.log(`\n[OK] Con front matter: ${ok.length}/${results.length}`);
  ok.forEach(r => console.log(`    - [N${r.nivel}] ${r.path} (${r.doc_id} v${r.version} ${r.status})`));

  if (!issues.no_front_matter.length && !issues.not_found.length && !broken_refs.length) {
    console.log('\n[OK] Todos los documentos operativos tienen front matter valido.\n');
  } else {
    console.log('\n[!] Hay documentos que requieren atencion. Ver arriba.\n');
  }
}

run();
