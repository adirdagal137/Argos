---
doc_id: ARGOS-VERSIONING-0001
title: Estandar de Versionado Documental para ARGOS
status: open:inbox
created: 2026-04-21
owner: Codex
priority: medium
type: architecture
---

# WORK PACKET: ARGOS-VERSIONING-0001
## Estandar de Versionado Documental para ARGOS

---

## CONTEXTO

ARGOS ha alcanzado un punto de madurez en el que la coherencia entre documentos operativos, skills y codigo deployed no se puede mantener por convencion o memoria del Capitan. Existen historias de skills que apuntan a flujos ya modificados, documentos syn referencia cruzada, y GitHub sin estructura de metadatos que permita auditoria.

Este packet define e implementa el sistema de versionado documental para ARGOS.

---

## OBJETIVO

Que todo archivo operativo del sistema lleve metadatos de version legibles, de forma que:

- Cualquier agente pueda detectar si un documento esta anticuado
- Las dependencias rotas entre documentos sean visibles
- GitHub tenga estructura auditable por PR
- El state del sistema tenga una fuente de verdad unica para versiones

---

## DECISIONES DE DISENO (APROBADAS POR CAPRTAN)

### 1. Formato de Front Matter YAML

Todo archivo Markdown operativo debe incluir al inicio:

```yaml
---
doc_id: <identificador-unico-y-permanente>
title: <titulo canonico>
version: <semver: 1.0.0>
status: draft | active | deprecated | archived
last_updated: <YYYY-MM-DD>
owner: <agente o persona>
change_type: patch | minor | major
summary_of_changes: <resumen breve>
depends_on:            # opcional: lista de doc_id@version
  - <doc_id>@<cualiquiera|version>
changelog_ref: <ruta al changelog global o nota breve>
---
```

### 2. Regla Patch / Minor / Major

- **PATCH**: correcciones, redaccion, formato. No cambia comportamiento.
- **MINOR**: nuevas secciones o funcionalidad, sin romper compatibilidad.
- **MAJOR**: cambia el contrato del documento, rompe compatibilidad, requiere revision de dependientes.

### 3. Jerarquia de Documentos (delimita donde el front matter es obligatorio)

- **Nivel 1 - Criticos**: INTER_AI_PROTOCOL, ARGOS_GLOBAL_LOG, README, argos.state.json, indice maestro de versiones. Front matter OBLIGATORIO.
- **Nivel 2 - Operativos**: skills, work packets, guias, plantillas. Front matter OBLIGATORIO.
- **Nivel 3 - Auxiliares**: notas, borradores, ideas. Front matter OPCIONAL (basta status:draft).

### 4. Indice Maestro de Versiones

Un unico archivo `versions.json` en raiz del repositorio actua como fuente de verdad:

```json
{
  "argos-inter-ai-protocol": {
    "version": "1.4.0",
    "status": "active",
    "last_updated": "2026-04-18",
    "dependents": ["argos-skill-*"]
  }
}
```

Este archivo es lo que cualquier agente consulta primero. Se actualiza cada vez que un documento sube de version.

### 5. Separacion de Planos (solo en Indice Maestro)

En documentos individuales basta `version` y `status`. El indice maestro puede registrar los tres planos cuando sea relevante:

- `version_doc`: la version del archivo
- version_repo`: lo que esta en GitHub
- `version_runtime`: lo que el servidor esta corriendo

---

## TAREAS

### Tarea 1: Crear `versions.json` en la raiz del repo

Estructura inicial con los documentos criticos actuales:
- INTER_AI_PROTOCOL.md
- ARGOS_GLOBAL_LOG.md
- ARGOS_CREW_VOIAES,md
- ARGOS_VECTOR.md
- ARGOS_GLOBAL_SHADOW_LOG.md
- argos.state.json
- cada SKILL.md existente

### Tarea 2: Anadir front matter YAML a documentos Nivel 1 y 2

Retrofit de front matter en todos los archivos operativos existentes.
Version inicial de todos: 1.0.0 (si no tienen historia clara) o la que corresponda segun logs.

### Tarea 3: Plantilla de Work Packet actualizada

Anadir front matter YAML a la plantilla de work packets para que todos los packets futuros lleven version desde el origen.

### Tarea 4: Regla de agente ante documento sin version

Todo agente que lea un archivo operativo sin front matter debe:
1. Senalarlo en su log como glitch menor.
2. Continuar normalmente (no bloquear).
3. Proponer al Capitan anadir front matter si es Nivel 1 o 2.

### Tarea 5 (OPCIONAL B2): Script `check_versions.sh `

Script liviano que escanea los archivos md del repo y produce:
- Listado de documentos sin front matter
- Listado de documentos con status:deprecated
- Listado de dependencias que apuntan a versiones no existentes en versions.json

Esta tarea es baja prioridad. Las tareas 1-3 son el nicleo minimo.

---

## LO QUE NO HACE ESTE PACKET

- No define architectura de runtime ni codigo (solo documentacion)
- No obliga a rescribir skills o protocolos (solo anadir front matter)
- No es bloqueante para otros packets en curso

---

## CRITERIOS DE CIERRE

- [ ] `versions.json` existe en raiz del repo
- [ ] Documentos Nivel 1 tienen front matter YAML
- [ ] Documentos Nivel 2 (skills y plantillas) tienen front matter YAML
- [ ] Plantilla de work packet actualizada
- [ ] Regla de agente documentada en INTER_AI_PROTOCOL (patch minor)
