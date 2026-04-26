[WORK_PACKET]
ID: ARG-1777221515268-968
TYPE: task
TAG: autonomous_normalization
SUBJECT: # ARG-GIT-MERGE-001 — argos_commit.ps1: modo -Merge y auditoría de ramas huérfanas...
ROLE_REQUESTED: Cualquiera
OWNER: Cualquiera
STATUS: in_progress
REPORTED_BY: Argos Dispatcher
REPORTED_AT: 2026-04-26 16:38

[CONTENIDO ORIGINAL]
# ARG-GIT-MERGE-001 — argos_commit.ps1: modo -Merge y auditoría de ramas huérfanas

**TYPE:** maintenance  
**PRIORITY:** high  
**ASSIGNED_TO:** Codex  
**ROOM:** argos_core  
**CREATED:** 2026-04-26  
**CREATED_BY:** Orfeo (Claude) — sesión Cowork  

---

## Problema

Los agentes crean ramas con `-Branch` en `argos_commit.ps1` pero el merge a `main` está documentado como un paso manual que sistemáticamente se omite. Las ramas quedan abiertas indefinidamente sin visibilidad en el dashboard ni en `argos.state.json`. No hay ownership del merge ni ritual automatizado que lo fuerce.

**Raíz:** el merge es el único paso del protocolo de commits que no tiene un comando del navio que lo ejecute.

---

## Objetivo

### Paso 1 — Añadir `-Merge` a `argos_commit.ps1`

Nuevo parámetro que ejecuta el ritual de cierre de rama:

```powershell
.\ARGOS_RUNTIME\tools\argos_commit.ps1 -Agent Codex -PacketId ARG-XXXX -Merge
```

Internamente debe hacer:
1. Detectar la rama actual (`git rev-parse --abbrev-ref HEAD`)
2. Si ya está en `main` → avisar y salir sin error
3. Si está en otra rama:
   - `git checkout main`
   - `git merge <rama> --no-ff -m "[<Agent>] merge <PacketId>: <rama>"`
   - `git push origin main` (si hay remote configurado)
   - Opcionalmente: `git branch -d <rama>` (con flag `-DeleteBranch` opcional)
4. Imprimir confirmación: `[ARGOS-COMMIT] Merge completado: <rama> → main`

### Paso 2 — Añadir `-ListBranches` para auditoría

```powershell
.\ARGOS_RUNTIME\tools\argos_commit.ps1 -ListBranches
```

Debe mostrar:
- Todas las ramas locales distintas de `main`
- Si el nombre sigue el formato `agente/packet-id`, extraer el packet-id y mostrar si ese packet está done o in_progress
- Marcar como `[HUÉRFANA]` las ramas cuyo packet ya está en `done/` o `archived/`

Ejemplo de salida:
```
[ARGOS-BRANCHES] Ramas abiertas:
  codex/arg-1776816000001  →  packet: ARG-1776816000001  [DONE — MERGE PENDIENTE]
  codex/arg-1776354464819  →  packet: ARG-1776354464819  [IN_PROGRESS]
  claude/work-20260420-1430  →  packet: desconocido  [HUÉRFANA]
```

### Paso 3 — Documentar en QUICKSTART

Actualizar `ARGOS_QUICKSTART.md`, sección "Protocolo de commits y ramas", añadiendo:

```powershell
# Cierre de rama — merge a main
.\ARGOS_RUNTIME\tools\argos_commit.ps1 -Agent Codex -PacketId ARG-XXXX -Merge

# Auditoría de ramas abiertas
.\ARGOS_RUNTIME\tools\argos_commit.ps1 -ListBranches
```

Y añadir como regla explícita:
> Todo packet que usó `-Branch` **NO puede cerrarse con trilog** sin antes ejecutar `-Merge`. Si el merge falla, documentarlo en `glitch`.

### Paso 4 (Bonus) — Script de auditoría one-shot

Crear `ARGOS_RUNTIME/tools/argos_branch_audit.ps1` que:
- Liste todas las ramas abiertas
- Cruce con `state/argos.state.json` para detectar packets done con rama viva
- Imprima un resumen limpio para el Capitán

---

## Criterio de aceptación

- [ ] `argos_commit.ps1 -Merge` ejecuta checkout+merge+push sin errores en repo limpio
- [ ] `-ListBranches` cruza correctamente con `argos.state.json`
- [ ] QUICKSTART actualizado con los nuevos comandos y la regla de cierre
- [ ] Probado con al menos una rama real del repo

---

## Contexto adicional

Script actual en: `ARGOS_RUNTIME/tools/argos_commit.ps1`  
El script ya tiene `-Branch` y `-BranchName` implementados — extender desde ahí.  
El merge manual documentado actualmente en QUICKSTART:
```powershell
git checkout main
git merge <rama> --no-ff -m "[<Agente>] merge <packet-id>: <descripcion>"
```
Esto es lo que `-Merge` debe automatizar.

[/WORK_PACKET]