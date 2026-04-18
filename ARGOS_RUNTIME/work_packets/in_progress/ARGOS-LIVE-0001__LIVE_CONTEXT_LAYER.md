[WORK_PACKET]
ID: ARG-1776467399391-231
TYPE: task
TAG: autonomous_normalization
SUBJECT: # WORK PACKET — ARGOS-LIVE-0001 **ID:** ARGOS-LIVE-0001 **Título:** Capa de contexto en...
ROLE_REQUESTED: Cualquiera
OWNER: Cualquiera
STATUS: in_progress
REPORTED_BY: Argos Dispatcher
REPORTED_AT: 2026-04-17 23:09

[CONTENIDO ORIGINAL]
# WORK PACKET — ARGOS-LIVE-0001

**ID:** ARGOS-LIVE-0001
**Título:** Capa de contexto en vivo entre agentes (live/ layer)
**Fecha:** 2026-04-17
**Creado por:** Claude
**Target:** Codex (implementación) + todas las IAs (adopción de protocolo)
**Estado:** inbox / pendiente
**Prioridad:** Alta — desbloquea coordinación multi-agente en vivo

---

## Problema

Actualmente no existe ningún mecanismo de comunicación en vivo entre agentes.
Cuando el Capitán cambia de ventana (Claude → Codex → Gemini), cada IA
empieza desde cero. El único puente son los transcripts completos — pesados,
lentos, procesados una vez al día.

El Capitán necesita poder decirle a Codex "escucha lo que dijo Claude"
sin copy-paste, sin aumentar el contexto, sin esperar al batch diario.

---

## Solución propuesta: capa `live/`

Una carpeta `ARGOS_RUNTIME/live/` con un JSON pequeño por agente.
Cada IA lo actualiza al terminar su turno. La siguiente lo lee al arrancar.
Son 5-10 líneas. Coste de tokens: mínimo.

---

## Estructura de archivos a crear

### 1. `ARGOS_RUNTIME/live/` (nueva carpeta)

Un archivo por agente activo:

```
ARGOS_RUNTIME/live/
  claude.live.json
  codex.live.json
  gemini.live.json
  openclaw.live.json     ← si se incorpora
  _schema.json           ← schema del formato
```

### 2. Schema: `ARGOS_RUNTIME/live/_schema.json`

```json
{
  "$schema": "argos-live-v1",
  "fields": {
    "agent":         "string — nombre canónico del agente (Claude, Codex, Gemini, OpenClaw)",
    "updated_at":    "ISO 8601 timestamp",
    "packet_id":     "string | null — work packet activo en este momento",
    "status":        "idle | working | blocked | waiting_captain",
    "last_output":   "string — resumen de 1-3 líneas de lo último que hizo/dijo",
    "open_question": "string | null — pregunta abierta para el Capitán o para otra IA",
    "next_step":     "string | null — qué planea hacer a continuación",
    "handoff_to":    "string | null — si deja algo pendiente para otro agente, cuál"
  }
}
```

### 3. Estado inicial: `ARGOS_RUNTIME/live/claude.live.json`

```json
{
  "agent": "Claude",
  "updated_at": "2026-04-17T23:55:00Z",
  "packet_id": "ARGOS-LIVE-0001",
  "status": "waiting_captain",
  "last_output": "Propuesta de capa live/ diseñada y documentada. Work packet ARGOS-LIVE-0001 creado. Documento AGENT_DATA_PATHS.md generado. Recomendación: Gemini CLI sobre Antigravity para Argos por eficiencia de tokens.",
  "open_question": null,
  "next_step": "Esperar que Codex implemente el endpoint /api/live y la lógica de lectura/escritura",
  "handoff_to": "Codex"
}
```

---

## Cambios de protocolo requeridos — ediciones para Codex

### A. `INTER_AI_PROTOCOL.md` — añadir sección 1.6

Añadir después de la sección de transcripts (1.2) o al final de la taxonomía:

```markdown
### 1.6 LIVE — Estado en tiempo real entre agentes

**Qué va aquí:** El estado mínimo de cada agente al terminar su turno,
para que la siguiente IA (o el mismo agente en nueva sesión) sepa
dónde estamos sin leer transcripts completos.

**Archivo:** `ARGOS_RUNTIME/live/<agente>.live.json` — sobrescrito en cada cierre.

**Cuándo escribir:** Al final de cada intervención sustantiva (no en cada
mensaje, sino al cerrar una sesión o entregar un work packet).

**Cuándo leer:** Al arrancar cualquier sesión, ANTES de responder al Capitán.
Leer solo el archivo del agente más relevante para el contexto actual
(o todos si la tarea implica coordinación multi-agente).

**Coste:** Mínimo. Un JSON de ~10 líneas por agente.

**Regla de no-duplicación:** El live/ NO reemplaza el trilog ni el transcript.
Captura solo el estado operativo inmediato — lo que otra IA necesita
saber para arrancar sin preguntar.
```

### B. `ARGOS_RUNTIME/README.md` — añadir entrada en la estructura de carpetas

En la sección que describe la estructura de ARGOS_RUNTIME, añadir:

```markdown
- `live/` — Estado en tiempo real por agente. Un JSON pequeño por IA,
  sobrescrito al cerrar cada turno. Permite coordinación sin transcripts
  completos. Ver INTER_AI_PROTOCOL.md §1.6.
```

### C. Servidor Argos (webapp) — endpoint nuevo

Codex debe implementar en el servidor local:

```
GET  /api/live               → devuelve todos los live JSONs como array
GET  /api/live/<agente>      → devuelve el live JSON de un agente concreto
POST /api/live/<agente>      → escribe/sobrescribe el live JSON de un agente
```

**Cuerpo del POST:** el objeto JSON completo según `_schema.json`.

**Validación mínima:** campos `agent` y `updated_at` obligatorios.

**Notas de implementación:**
- Los archivos viven en `ARGOS_RUNTIME/live/` en el filesystem local.
- Drive for Desktop los sincroniza automáticamente → disponibles para todas las IAs.
- No hay locking necesario: cada agente solo escribe su propio archivo.
- Si un archivo tiene más de 24h sin actualizar, el servidor puede marcarlo
  como `stale` en la respuesta del GET.

### D. Quickstart / onboarding de nuevas IAs

Añadir al documento de onboarding (o al INTER_AI_PROTOCOL si no existe doc
separado) el paso explícito:

```markdown
## Al arrancar una sesión

1. Lee `ARGOS_RUNTIME/live/` para ver el estado actual de los otros agentes.
   Endpoint: GET /api/live
   O directamente en filesystem: `ARGOS_RUNTIME/live/*.live.json`

2. Lee tu work packet activo (si lo hay).

3. Solo si hay ambigüedad de diseño: lee transcripts específicos.

## Al cerrar una sesión

1. Escribe tu estado en `ARGOS_RUNTIME/live/<tu_agente>.live.json`.
   Endpoint: POST /api/live/<tu_agente>
   O directamente en filesystem (Drive sincroniza).
```

---

## Criterio de éxito

- [ ] Carpeta `live/` existe en `ARGOS_RUNTIME/`
- [ ] `_schema.json` creado y documentado
- [ ] Endpoints GET/POST `/api/live` funcionales en el servidor
- [ ] INTER_AI_PROTOCOL.md actualizado con §1.6
- [ ] README.md de ARGOS_RUNTIME actualizado
- [ ] Claude puede escribir su live.json al cerrar sesión (vía POST o filesystem)
- [ ] Codex puede leer el live.json de Claude al arrancar sin copy-paste

---

## Reparto de trabajo

| Tarea | Responsable |
|---|---|
| Crear carpeta `live/` + `_schema.json` | Codex |
| Implementar endpoints `/api/live` | Codex |
| Editar `INTER_AI_PROTOCOL.md` §1.6 | Codex |
| Editar `README.md` ARGOS_RUNTIME | Codex |
| Actualizar quickstart/onboarding | Codex |
| Escribir `claude.live.json` inicial | Claude (este archivo ya lo deja aquí) |
| Validar que el flujo funciona end-to-end | Capitán + Claude |

---

## Nota de diseño

Esta capa NO resuelve comunicación asíncrona profunda entre agentes —
para eso están los handoffs y los work packets. Resuelve el problema
concreto del Capitán: cambiar de ventana sin perder el hilo,
sin copy-paste, sin gastar tokens en transcripts completos.

Es intencionalmente pequeña. Si crece, algo está mal.

---

*Generado por Claude — sesión Argos 2026-04-17*

[/WORK_PACKET]