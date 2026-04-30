---
doc_id: argos-readme-root
title: ARGOS - El Navio
version: 1.2.0
status: active
last_updated: 2026-04-29
owner: Claude
change_type: minor
summary_of_changes: Estructura bitacora/cubierta reflejada como filesystem runtime final.
---

# ARGOS — El Navío

Sistema de coordinación multi-IA operado por Rubén ("el Capitán").

Argos es el navío. Las IAs son la tripulación. Este repositorio es la constitución del navío — las reglas, los roles, los protocolos y la arquitectura que definen cómo funciona todo. No es un archivo de logs ni un estado operativo: es lo que hace que el navío sea el navío.

version: ver ARGOS_RUNTIME/argos.version

---

## La tripulación

| IA | Nombre | Rol | Mandato principal |
|---|---|---|---|
| **Claude** | Orfeo | Navegadora | Estrategia de sesión, arquitectura, decisiones de diseño |
| **Codex** | Mecánico | Implementación | Código, reparación técnica, refactorización |
| **Gemini** | Primer Oficial | Integración | Continuidad operativa, UI, cohesión entre capas |
| **ChatGPT** | Consultor | Análisis y estrategia | Soporte contextual y segunda opinión |
| **OpenClaw** | Gateway local | Ejecución local | Qwen vía Ollama, clasificación, file ops |
| **Lola** | Analista de la Sombra | Memoria | Contexto relacional entre sesiones (en desarrollo) |

---

## Estructura del repositorio

```
Argos/
├── README.md                          ← este archivo
├── CLAUDE.md                          ← instrucciones de inicio para Claude Code (Orfeo)
├── AGENTS.md                          ← instrucciones para otros agentes
│
├── versions.json                      ← indice de documentos con version y estado
│
├── ARGOS_RUNTIME/
│   ├── README.md                      ← que es ARGOS_RUNTIME
│   ├── ARGOS_QUICKSTART.md            ← tarjeta operativa diaria (LECTURA OBLIGATORIA)
│   ├── INTER_AI_PROTOCOL.md           ← protocolo completo (referencia on-demand)
│   ├── ARGOS_CREW_VOICES.md           ← caracter y tono de cada tripulante
│   ├── ARGOS_VECTOR.md                ← timon vivo: foco, prioridades, blockers
│   ├── bitacora/                      ← LOG, shadow, handoff y glitches activos
│   ├── cubierta/                      ← feed, state, vector e informacion viva visible
│   ├── REGISTRY.md                    ← indice documental del runtime
│   ├── argos.version                  ← version global del sistema
│   ├── docs/
│   │   ├── protocols/                 ← protocolos de referencia (REMOTE_CLOSURE_SETUP.md)
│   │   ├── reference/                 ← docs tecnicos de referencia
│   │   └── legacy/                    ← documentos historicos
│   ├── tools/
│   │   ├── argos_commit.ps1           ← commits y ramas por protocolo
│   │   └── diagnostics/               ← utilidades temporales de diagnostico
│   └── work_packets/
│       ├── inbox/                     ← packets pendientes de ejecucion
│       └── in_progress/               ← packets en ejecucion activa
│
├── Comenio/                           ← proyecto educación (docs vivos)
├── LOLA/                              ← proyecto Lola (docs vivos)
├── SciClass-M8/                       ← proyecto SCM8 (docs vivos)
└── XuanShu/                           ← proyecto XuanShu (docs vivos)
```

Lo que **no** está aquí (vive en local/Drive):
- Logs operativos (`bitacora/log.md`, `bitacora/shadowlog.md`, `bitacora/handoffs.md`, `bitacora/glitches.md`, `*.jsonl`)
- Estado en tiempo real (`argos.state.json`)
- Work packets cerrados (`done/`, `archived/`)
- Archivos pesados, snapshots, legacy histórico
- Diarios personales de IAs (`.claude/`, `.gemini/`)

---

## Cómo leer el navío (para IAs entrando en frío)

1. **`CLAUDE.md` o `AGENTS.md`** — tu mandato específico por interfaz
2. **`ARGOS_RUNTIME/ARGOS_QUICKSTART.md`** — tarjeta operativa: inicio, cierre, actores, git
3. **`ARGOS_RUNTIME/work_packets/inbox/`** — qué hay pendiente
4. **`ARGOS_RUNTIME/state/argos.state.json`** — foco y riesgos activos
5. **`ARGOS_RUNTIME/bitacora/log.md`** (tail) — qué se hizo recientemente

Solo bajo ambigüedad o conflicto:
- `ARGOS_RUNTIME/INTER_AI_PROTOCOL.md` — protocolo completo
- `ARGOS_RUNTIME/ARGOS_CREW_VOICES.md` — voz y carácter
- `ARGOS_RUNTIME/docs/protocols/REMOTE_CLOSURE_SETUP.md` — setup remoto

---

## Arquitectura de fuentes de verdad

| Capa | Dónde | Qué contiene |
|---|---|---|
| **GitHub** (este repo) | Nube | Constitución del navío: protocolos, instrucciones, esquemas, docs vivos |
| **Local** (`C:\Users\Widox\Desktop\ARGOS\`) | Máquina Widox | Estado operativo, logs, events, work packets activos |
| **Drive** | Nube | Espejo del local — backup y acceso remoto desde IAs sin filesystem |

---


## Versionado global

- version: ver ARGOS_RUNTIME/argos.version
- Hook de tag por commit: .githooks/post-commit
- Activacion local del hook: git config core.hooksPath .githooks

*Argos opera bajo el principio de que el contexto vive en el navío, no en los tripulantes.*
