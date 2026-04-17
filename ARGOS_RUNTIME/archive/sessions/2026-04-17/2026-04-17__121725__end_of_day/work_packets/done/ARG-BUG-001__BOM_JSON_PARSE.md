[WORK_PACKET]
ID: ARG-BUG-001
TYPE: bug
TAG: bug
SEVERITY: critical
ROLE_REQUESTED: Codex
SUBJECT: BOM UTF-8 en logbook.snapshot.json - JSON.parse() falla silenciosamente
STATUS: done
REPORTED_BY: Antigravity
REPORTED_AT: 2026-04-10T11:28 Atlantic/Canary

CONTEXT:
El archivo logbook.snapshot.json se regenera con UTF-8 BOM (0xEF 0xBB 0xBF) cada vez que
merge_argos_history.ps1 escribe via Set-Content -Encoding UTF8. PowerShell 5 en Windows
escribe UTF-8 CON BOM con ese flag. Node.js rechaza el BOM en JSON.parse() con
"Unexpected token", la funcion readJsonFile() cae al catch silencioso y devuelve
buildEmptyLogbook() (modules: []). El frontend muestra "No hay snapshot tabular disponible".

ARCHIVOS AFECTADOS:
- views/logbook_export/logbook.snapshot.json (confirmado con hexdump: 0xEF 0xBB 0xBF)
- tools/merge_argos_history.ps1 (fuente del BOM, lineas 381, 409, 428, 444, 518, 548)
- argos-api/src/index.ts (funcion readJsonFile sin strip de BOM)
- argos-api/dist/index.js (compilado, misma funcion)

TAREAS:
1. En argos-api/src/index.ts funcion readJsonFile(), strip del BOM antes de parsear:
   const raw = fs.readFileSync(filePath, 'utf-8');
   return JSON.parse(raw.charCodeAt(0) === 0xFEFF ? raw.slice(1) : raw);
2. En tools/merge_argos_history.ps1 sustituir TODOS los Set-Content -Encoding UTF8
   por [System.IO.File]::WriteAllText(, , [System.Text.Encoding]::UTF8)
3. Recompilar argos-api con npm run build.
4. Verificar: node -e "JSON.parse(require('fs').readFileSync(path,'utf-8'))" no lanza excepcion.

SUCCESS_CRITERIA:
- Dashboard muestra 4 modulos en la Bitacora Tabular (argos, scm8, comenio, lola).
- El fix es defensivo: si algun agente vuelve a escribir con BOM, la API lo absorbe.

GLITCH_REFS: G-004 (antecedente de encoding), recurrencia documentada 10-ABR
[/WORK_PACKET]
