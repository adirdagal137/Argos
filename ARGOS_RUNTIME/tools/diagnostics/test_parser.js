const fs = require('fs');
const path = require('path');

function normaliseText(value) {
  return typeof value === 'string' ? value.replace(/\uFEFF/g, '').trim() : '';
}

function mojibakeScore(value) {
  return (value.match(/[ÃÂâð\uFFFD]/g) || []).length;
}

function repairMojibake(value) {
  let out = value;
  for (let i = 0; i < 2; i += 1) {
    const currentScore = mojibakeScore(out);
    if (currentScore === 0) break;
    try {
      const decoded = Buffer.from(out, 'latin1').toString('utf8');
      if (!decoded || decoded === out) break;
      const decodedScore = mojibakeScore(decoded);
      if (decodedScore >= currentScore) break;
      out = decoded;
    } catch {
      break;
    }
  }
  return out;
}

function cleanupReplacementArtifacts(value) {
  let out = value;
  out = out
    .replace(/â€”/g, '-')
    .replace(/â€“/g, '-')
    .replace(/Â·/g, '·')
    .replace(/Â¿/g, '¿')
    .replace(/Â¡/g, '¡');
  return out;
}

function normaliseHumanText(value) {
  const normalized = normaliseText(value);
  if (normalized === '') return '';
  return cleanupReplacementArtifacts(repairMojibake(normalized));
}

function parseVectorMarkdown(content) {
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
        .filter((line) => /^([-*]\s*\[[ x~X]\]|\d+\.\s+)/.test(line))
        .map((line) => {
          const isChecklist = /^([-*]\s*\[[ x~X]\])/.test(line);
          const isDone = isChecklist && /\[[xX]\]/.test(line);
          const isInProgress = isChecklist && /\[~\]/.test(line);
          
          let text = line;
          if (isChecklist) {
            text = line.replace(/^[-*]\s*\[[ x~X]\]\s*/, '').trim();
          } else {
            text = line.replace(/^\d+\.\s+/, '').trim();
          }
          
          let status = 'todo';
          if (isDone) status = 'done';
          else if (isInProgress) status = 'in_progress';
          
          return { text, status };
        });

      return { title, goals };
    })
    .filter((category) => category.title !== '' && !category.title.startsWith('#') && category.goals.length > 0);

  return { categories };
}

const content = fs.readFileSync('C:/Users/Widox/Desktop/argos/ARGOS_RUNTIME/ARGOS_VECTOR.md', 'utf-8');
const result = parseVectorMarkdown(normaliseHumanText(content));
console.log(JSON.stringify(result, null, 2));
