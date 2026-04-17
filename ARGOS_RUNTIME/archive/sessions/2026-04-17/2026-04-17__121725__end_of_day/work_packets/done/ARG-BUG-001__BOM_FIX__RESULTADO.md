[WORK_PACKET]
ID: ARG-BUG-001
TYPE: bug
TAG: bug
SEVERITY: critical
ROLE_REQUESTED: Claude
SUBJECT: BOM UTF-8 en logbook.snapshot.json - RESUELTO
STATUS: done
REPORTED_BY: Antigravity
REPORTED_AT: 2026-04-10T11:28 Atlantic/Canary
RESOLVED_AT: 2026-04-10 Atlantic/Canary
RESOLVED_BY: Claude (Orfeo)

ABSORBE: ARG-BOM-FIX-0001 (duplicado consolidado)

CAUSA RAIZ:
PowerShell 5 en Windows escribe UTF-8 CON BOM cuando se usa Set-Content -Encoding UTF8.
El archivo logbook.snapshot.json se regeneraba con BOM (0xEF 0xBB 0xBF), Node.js lanzaba
"Unexpected token" en JSON.parse() y la funcion readJsonFile() caia al catch silencioso,
devolviendo buildEmptyLogbook(). El frontend mostraba "No hay snapshot tabular disponible".

SOLUCION APLICADA:
1. tools/merge_argos_history.ps1: definido $utf8NoBom = New-Object System.Text.UTF8Encoding $false
   y sustituidos los 7 Set-Content -Encoding UTF8 por WriteAllLines/WriteAllText con esa instancia.
2. views/logbook_export/logbook.snapshot.json: BOM eliminado del archivo existente en disco (node).
3. argos-api/src/index.ts: ya tenia strip defensivo en readJsonFile() (linea 95) - conservado.

VERIFICACION:
- logbook.snapshot.json: BOM presente: false (verificado con node -e hexdump)
- No quedan Set-Content.*UTF8 en el script (grep limpio)
- La API absorbe BOM residual si alguna otra herramienta lo genera

SUCCESS_CRITERIA CUMPLIDOS:
- Dashboard puede cargar bitacora tabular sin "No hay snapshot tabular disponible"
- Fix es defensivo: si algun agente escribe con BOM, la API lo absorbe en readJsonFile()

[/WORK_PACKET]
