---
doc_id: trilog-ARGOS-VEQSIONING-0001
packet_id: ARGOS-VEQSIONING-0001
actor: Claude
date: 2026-04-21
---

# TRILOG - ARGOS-VEQSIONING-0001

---

## SUMMARY

Packet define e implementa el estandar de versionado documental para ARGOS. Origin en propuesta externa (ChatGPT) revisada y refinada por Claude y Capitan. El objetivo es que todo archivo operativo lleve metadatos de version legibles, cualquier agente pueda detectar documentos anticuados, y GitHub tenga estructura auditable.

---

## DETAILS

### Decisiones de diseno

1. **Front matter YAML** en cada archivo Markdown operativo. Campos minimos: `doc_id`, `version`, `status`, `last_updated`, `owner`, `change_type`, `summary_of_changes`. Campos opcionales: `depends_on`, `changelog_ref`.

2. **Jeraquia de niveles**: Los documentos Nivel 1 (criticos) y Nivel 2 (operativos) tienen front matter obligatorio. Los Nivel 3 (auxiliares), opcional.

3. **Indice maestro**: Un unico `versions.json` en raiz del repo es la fuente de verdad rapida para agentes. Contiene doc_id → version → status → dependents.

4. **Separacion de planos**: `document_version / repo_version / runtime_version` solo en el indice maestro, no en cada archivo. Esto reduce overhead individual sin perder la distincion critica.

5. **Regla de agente**: Archivo sin front matter = glitch menor. Continuar, senalar, proponer retrofit. No bloquea.

### Lo que se refino respecto a la propuesta original

- El `changelog_ref` se anadio como campo adicional que la propuesta omitia: sin el, la trazabilidad queda rota.
- `check_versions` se redefinio: no es una "skill" ARGOS sino un script auditor, optando por que es la categoria adecuada.
- La separacion de planos se confino al indice maestro para evitar overhead de mantenimiento.
- La regla de agente ante desajo de versiones se concreto con arbol de decision minimo: senalar, no bloquear, proponer.

### Impacto sobre el estado actual

\ Actualmente la coherencia entre archivos depende de memoria del Capitan y convencion. Con este sistema pasa a ser verificable por cualquier agente. El cambio mas concreto en el flujo de trabajo: cualquier modificacion a un archivo operativo requiere actualizar su version y el indice. Friccion pequena, trazabilidad alta.

---

## NEXT_STEP

Codex ejecuta ARGOS-VERSIONING-0001 tras recibir validacion multi-agente (Gemini y ChatGPT) por parte del Capitan.

---

## ERRORS

Ningunon.

---

## RISKS

- El retrofit de front matter en archivos existentes puede generar diffs grandes en GitHub sin cambios funcionales. Recomendado: hacerlo en una PR separada con label `docs-retrofit`.
- versions.json puede desincronizarse si no se mantiene como parte del ritual de cierre. Propuesta: anadir al PROTOCOL la norma de actualizar versions.json al cerrar packets que tocquen documentos Nivel 1 o 2.
