[WORK_PACKET]
ID: ARG-BOM-FIX-0001
ROLE_REQUESTED: Codex / Antigravity
SUBJECT: Fix BOM UTF-8 en logbook.snapshot.json - API readJsonFile
STATUS: open
PRIORITY: critical

CONTEXT:
El archivo logbook.snapshot.json se regenera con UTF-8 BOM (0xEF 0xBB 0xBF) cada vez que
el script PowerShell 	ools/merge_argos_history.ps1 escribe via Set-Content -Encoding UTF8.
PowerShell en Windows escribe UTF-8 CON BOM por defecto con ese flag.
Node.js no tolera el BOM en JSON.parse(): lanza "Unexpected token" y la funcion readJsonFile()
cae al catch silencioso, devolviendo buildEmptyLogbook() (modules: []).
El frontend ve modules[] vacio y muestra "No hay snapshot tabular disponible".

CAUSA RAIZ CONFIRMADA:
- Linea 548 de 	ools/merge_argos_history.ps1:
   | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath  -Encoding UTF8
  --> Escribe BOM.
- Linea 381: Set-Content -LiteralPath  -Value  -Encoding UTF8
  --> Mismo problema potencial.
- Linea 409, 428, 444, 518, etc: misma flag.

TAREAS:
1. En rgos-api/src/index.ts funcion readJsonFile(), strip del BOM antes de parsear:
   const raw = fs.readFileSync(filePath, 'utf-8');
   return JSON.parse(raw.charCodeAt(0) === 0xFEFF ? raw.slice(1) : raw);
   (defensa permanente contra cualquier escritor con BOM)

2. En 	ools/merge_argos_history.ps1 cambiar TODOS los Set-Content -Encoding UTF8
   por -Encoding utf8NoBOM (disponible en PowerShell 6+ / PowerShell Core).
   Si el entorno solo tiene PS5, alternativa:
   [System.IO.File]::WriteAllText(, , [System.Text.Encoding]::UTF8)
   (UTF8 sin BOM en PS5).

3. Recompilar argos-api: npm run build (en argos-api/).
4. Verificar: node -e "JSON.parse(require('fs').readFileSync(path,'utf-8'))"

SUCCESS_CRITERIA:
- node puede parsear logbook.snapshot.json sin error.
- La bitacora tabular aparece en el dashboard con 4 modulos (argos, scm8, comenio, lola).
- El fix es defensivo: si algun agente vuelve a escribir con BOM, la API lo absorbe.

EVIDENCIA DE DIAGNOSTICO:
- BOM confirmado: bytes 0xEF 0xBB 0xBF al inicio del archivo. 
- Modulos reales: argos(33 entradas), scm8(14), comenio(13), lola(0).
- PowerShell lo lee OK, Node.js lo rechaza.

[/WORK_PACKET]