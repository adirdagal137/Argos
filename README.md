# ARGOS — El Navío

Sistema de coordinación multi-IA operado por Rubén ("el Capitán").

Argos es el navío. Las IAs son la tripulación. Este repositorio es la constitución del navío — las reglas, los roles, los protocolos y la arquitectura que definen cómo funciona todo. No es un archivo de logs ni un estado operativo: es lo que hace que el navío sea el navío.

---

## La tripulación

| IA | Nombre | Rol | Mandato principal |
|---|---|---|---|
| **Claude** | Orfeo | Navegadora | Estrategia de sesión, arquitectura, decisiones de diseño |
| **Codex / ChatGPT** | Mecánico | Implementación | Código, reparación técnica, refactorización |
| **Gemini / Antigravity** | Primer Oficial | Integración | Continuidad operativa, UI, cohesión entre capas |
| **Lola** | Analista de la Sombra | Memoria | Contexto relacional entre sesiones (en desarrollo) |
| **Qwen / DeepSeek** | Recadero Local | Tareas rutinarias | Clasificación, file ops, búsquedas en logs |

---

## Estructura del repositorio

```
Argos/
├── README.md                          ← este archivo
├── CLAUDE.md                          ← instrucciones de inicio para Claude Code (Orfeo)
├── AGENTS.md                          ← instrucciones para otros agentes
│
├── ARGOS_RUNTIME/
│   ├── README.md                      ← qué es ARGOS_RUNTIME
│   ├── INTER_AI_PROTOCOL.md           ← reglas operativas entre IAs
│   ├── ARGOS_CREW_VOICES.md           ← carácter y tono de cada tripulante
│   ├── ARGOS_VECTOR.md                ← timón vivo: foco, prioridades, blockers
│   ├── ARGOS_QUICKSTART.md            ← cómo unirse al navío en frío
│   ├── schemas/                       ← esquemas canónicos (work_packet, event, state)
│   └── work_packets/
│       ├── inbox/                     ← packets pendientes de ejecución
│       └── in_progress/               ← packets en ejecución activa
│
├── Comenio/                           ← proyecto educación (docs vivos)
├── LOLA/                              ← proyecto Lola (docs vivos)
├── SciClass-M8/                       ← proyecto SCM8 (docs vivos)
└── XuanShu/                           ← proyecto XuanShu (docs vivos)
```

Lo que **no** está aquí (vive en local/Drive):
- Logs operativos (`ARGOS_GLOBAL_LOG.md`, `*.jsonl`)
- Estado en tiempo real (`argos.state.json`)
- Work packets cerrados (`done/`, `archived/`)
- Archivos pesados, snapshots, legacy histórico
- Diarios personales de IAs (`.claude/`, `.gemini/`)

---

## Cómo leer el navío (para IAs entrando en frío)

1. **Este README** — qué es Argos y quién hace qué
2. **`ARGOS_RUNTIME/ARGOS_VECTOR.md`** — qué está pasando ahora mismo
3. **`ARGOS_RUNTIME/INTER_AI_PROTOCOL.md`** — las reglas del juego
4. **`CLAUDE.md` o `AGENTS.md`** — tu mandato específico
5. **`ARGOS_RUNTIME/work_packets/inbox/`** — qué hay pendiente para ti
6. Estado en tiempo real → `ARGOS_RUNTIME/state/argos.state.json` (local/Drive)

No leas el historial de logs hasta que lo necesites. El estado actual está en `ARGOS_VECTOR.md`.

---

## Arquitectura de fuentes de verdad

| Capa | Dónde | Qué contiene |
|---|---|---|
| **GitHub** (este repo) | Nube | Constitución del navío: protocolos, instrucciones, esquemas, docs vivos |
| **Local** (`C:\Users\Widox\Desktop\ARGOS\`) | Máquina Widox | Estado operativo, logs, events, work packets activos |
| **Drive** | Nube | Espejo del local — backup y acceso remoto desde IAs sin filesystem |

---

*Argos opera bajo el principio de que el contexto vive en el navío, no en los tripulantes.*
