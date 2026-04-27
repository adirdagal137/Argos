# ARGOS API — Endpoints Canónicos para Agentes Remotos

> Versión: 2.0 | Autor: Orfeo (Claude) | Work packet: ARG-1777293327727 | 2026-04-27

---

## Autenticación

Todos los endpoints marcados 🔒 requieren:

```
Authorization: Bearer <token_del_agente>
```

Los tokens son por agente y se rotan via `POST /api/admin/rotate-token` (solo Capitán).

---

## Endpoints Canónicos (v2)

### 🔒 POST /api/ia/state — *Actualizar estado operacional*

Endpoint principal para que cada IA declare su memoria operacional completa. Reemplaza a `POST /api/ia/status` (legacy).

**Body:**
```json
{
  "actor": "Claude",
  "availability": "available | busy | offline | restricted",
  "current_packet": "ARG-XXXXXXXXX",
  "current_theme": "Descripción breve de lo que se está haciendo",
  "last_interaction_summary": "Resumen de la última acción completada",
  "next_step": "Qué sigue: quién, qué",
  "source": "cowork | chat | api | claude_code",
  "last_seen": "2026-04-27T15:00:00.000Z"
}
```

**Campos:**
| Campo | Requerido | Descripción |
|-------|-----------|-------------|
| `actor` | ✅ | Nombre canónico del agente (`Claude`, `Codex`, `Gemini`, `ChatGPT`, `OpenClaw`, `Qwen`) |
| `availability` | ✅ | Estado semántico. `busy` → activo en tarea; `available` → libre; `offline` → sin sesión; `restricted` → bloqueado |
| `current_packet` | ✗ | ID del work packet en curso |
| `current_theme` | ✗ | Tema o asunto del trabajo actual (≤80 chars recomendado) |
| `last_interaction_summary` | ✗ | Resumen de la última acción o cierre realizado |
| `next_step` | ✗ | Siguiente acción esperada |
| `source` | ✗ | Interfaz desde la que opera el agente |
| `last_seen` | ✗ | ISO timestamp del último contacto (si no se envía, se usa `now`) |

**Respuesta 200:**
```json
{
  "status": "ok",
  "agent": "Claude",
  "ia_status": { ... }
}
```

---

### GET /api/ia/state — *Leer estado de toda la tripulación*

Equivalente a `GET /api/ia/status`. Devuelve el mapa completo con campos v2.

**Respuesta 200:**
```json
{
  "ia_status": {
    "Claude": {
      "status": "standby",
      "availability": "available",
      "current_packet": "",
      "current_theme": "",
      "last_interaction_summary": "Implementé endpoint /api/ia/state canónico",
      "next_step": "Capitán reinicia argos-api",
      "source": "cowork",
      "last_seen": "2026-04-27T15:00:00.000Z",
      ...
    },
    ...
  }
}
```

---

### GET /api/ia/state/:actor — *Leer estado de un agente concreto*

**Parámetro URL:** `actor` — nombre del agente (insensible a mayúsculas)

**Ejemplo:** `GET /api/ia/state/Claude`

**Respuesta 200:**
```json
{
  "agent": "Claude",
  "ia_status": { ... }
}
```

**Respuesta 404:** actor no reconocido por el sistema.

---

## Endpoints Canónicos (establecidos)

### 🔒 GET /api/ia/bootstrap — *Bootstrap completo por agente*

Devuelve: estado de la tripulación, inbox, vector de ruta, tunnel URL.

### 🔒 POST /api/remote/closure — *Cierre de sesión/tarea*

Endpoint principal de cierre. Ver `REMOTE_CLOSURE_SETUP.md`.

### 🔒 POST /api/remote/packet — *Crear work packet desde agente externo*

### 🔒 POST /api/ia/start-task — *Mover packet a in_progress y marcar IA como activa*

### GET /api/state — *Estado global de ARGOS (state.json)*

### GET /api/bootstrap — *Bootstrap público (sin token, info reducida)*

---

## Endpoints Legacy (mantener compatibilidad, no extender)

| Ruta | Reemplazado por | Notas |
|------|-----------------|-------|
| `GET /api/ia/status` | `GET /api/ia/state` | Alias funcional |
| `POST /api/ia/status` | `POST /api/ia/state` | Campos limitados: solo `status`, `task`, `task_subject` |

---

## Mapeo de campos legacy → canónico

| Campo legacy | Campo canónico v2 |
|---|---|
| `status: 'active'` | `availability: 'busy'` |
| `status: 'standby'` | `availability: 'available'` |
| `task` | `current_packet` |
| `task_subject` | `current_theme` |
| `last_output` | `last_interaction_summary` |

Los campos canónicos y legacy conviven en `ia_status` — los nuevos clientes usan los canónicos, los legacy siguen funcionando.

---

## Ejemplo de cierre con state update integrado

Al cerrar una sesión, la IA debe hacer dos llamadas:

```bash
# 1. Actualizar estado operacional
POST /api/ia/state
{
  "actor": "Claude",
  "availability": "available",
  "current_packet": "",
  "last_interaction_summary": "Implementé endpoint canonical /api/ia/state — ARG-1777293327727",
  "next_step": "Capitán reinicia argos-api para aplicar cambios",
  "source": "cowork"
}

# 2. Registrar el cierre
POST /api/remote/closure
{ ... payload de cierre ... }
```

O usar el closure directamente — actualiza `ia_status` automáticamente via `sections.log` y el estado se infiere del payload.

---

*Mantenido por: Orfeo (Claude). Actualizar al añadir o deprecar endpoints.*
