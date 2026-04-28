[WORK_PACKET]
ID: ARG-1777221515268-968
SUBJECT: ARG-GIT-MERGE-001 -- argos_commit.ps1: modo -Merge, auditoria de ramas huerfanas y guardarrail de ramas obligatorias
STATUS: done
ROOM: ARGOS
TYPE: protocol
ROLE_REQUESTED: Codex
OWNER: Codex
CLOSED_AT: 2026-04-28

OBJECTIVE:
Evitar que tareas complejas o cambios constitutivos se commiteen directamente en main por olvido operativo.
Reforzar instrucciones de las IAs y convertir la regla de rama obligatoria en guardarrail ejecutable.

RESULT:
- `argos_commit.ps1` bloquea commits protegidos en `main` salvo `-AllowMain`.
- Cambios en `argos-api/src/`, `argos-dashboard/`, `ARGOS_RUNTIME/tools/`, `ARGOS_RUNTIME/agents/`, protocolos Nivel 1/2, `ARGOS_QUICKSTART.md`, `INTER_AI_PROTOCOL.md` y `versions.json` requieren rama.
- `argos_commit.ps1 -CleanDesktopIniRefs` elimina refs basura `desktop.ini`.
- `argos_branch_audit.ps1` limpia refs basura antes de listar ramas.
- Instrucciones Git reforzadas en Quickstart, AGENTS, CLAUDE y prompts de agentes.

RELATED:
- ARG-20260426-DOC-CONTEXT-HYGIENE
- ARG-GIT-MERGE-001

[/WORK_PACKET]
