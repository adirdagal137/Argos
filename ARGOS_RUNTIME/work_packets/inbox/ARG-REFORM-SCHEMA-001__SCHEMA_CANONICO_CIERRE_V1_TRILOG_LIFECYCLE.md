[WORK_PACKET]
ID: ARG-REFORM-SCHEMA-001
ROOM: arquitectura
TYPE: strategy
TAG: protocol_hygiene, schema, trilog, bitacora
PRIORITY: P1
ROLE_REQUESTED: Claude
STATUS: open
CREATED_AT: 2026-04-24T23:26:56Z
PARENT: ARG-REFORM-LOG-001
SUBJECT: Schema canónico de cierre v1 + trilog de ciclo de vida de work packets

---

## CONTEXTO

Decisión tomada en debate multi-agente (Claude / Pi / ChatGPT) con validación del Capitán
el 2026-04-24. El debate completo está registrado en el trilog de creación de este packet
(ver sección TRILOG_CREACION al final).

Este packet formaliza:
1. El schema canónico de los 10 campos de cierre (Fase 1 del plan de reforma de bitácora).
2. La política de trilog de ciclo de vida: cada packet emite trilog en creación, mutación y cierre.

---

## OBJETIVO

Producir la referencia canónica que todo agente y toda implementación de argos-api
debe cumplir a partir de esta reforma. No hay código que escribir en este packet:
el entregable es el contrato de datos, los ejemplos válidos/inválidos y la política
de trilog de lifecycle.

---

## SCHEMA CANÓNICO DE CIERRE v1

### Campos obligatorios (núcleo duro)

| Campo          | Tipo                                      | Restricciones                                              |
|----------------|-------------------------------------------|------------------------------------------------------------|
| timestamp      | ISO 8601 UTC                              | No puede ser futuro (>30 min ahead = rechazado)            |
| agent          | string (enum canónico)                    | Claude · Codex · Pi · ChatGPT · DeepSeek · Qwen            |
| mission        | string                                    | ≤ 80 chars. Sustituye a `summary`. Título de tarea humano  |
| closure_type   | enum                                      | Ver tabla tipos abajo                                      |
| status         | enum                                      | completed · blocked · in_progress · cancelled              |
| result         | string (texto libre)                      | Qué se hizo / qué pasó. Pasado. OBLIGATORIO no vacío.      |
| risk_level     | enum                                      | none · low · medium · high · blocked                       |
| next_step      | string                                    | Qué sigue. Puede ser "ninguno" si status=completed.        |
| handoff        | string                                    | Qué debe saber el siguiente agente/Capitán para continuar. |
| id             | string (packet ID)                        | ARG-XXXX o equivalente. OBLIGATORIO. Vacío = ORPHAN.       |

### Campos opcionales (Fase 1 — no en núcleo)

| Campo            | Notas                                                                    |
|------------------|--------------------------------------------------------------------------|
| schema_version   | Integer. Empieza en `1`. Obligatorio en Fase 2. Opcional pero recomendado ya. |
| handoff_active   | Boolean. `true` si el cierre es traspaso limpio activo (no bloqueo).     |
| transcript_ref   | URL/path al transcript. No en columna principal — en fila expandida.     |

### Tipos de cierre (closure_type)

| Valor            | Significado                                                        |
|------------------|--------------------------------------------------------------------|
| task_completed   | Tarea completada. result documenta el logro.                       |
| blocked          | Bloqueado. handoff explica el bloqueo y qué se necesita para desbloquearlo. |
| meta             | Entrada de coordinación, debate, decisión arquitectónica.          |
| session_close    | Cierre de sesión del agente (sin packet específico completado).    |

Nota: `handoff_active: true` distingue un traspaso limpio de un bloqueo dentro de `blocked`
sin necesidad de un quinto tipo. Si `handoff_active=true` y `closure_type=blocked`, leer como
"pasando el testigo conscientemente, no atascado".

### Separación semántica result / handoff

- **result**: pasado. "Qué rompí / qué arreglé / qué descubrí."
  - Incorrecto: "El siguiente debe revisar el endpoint."  ← eso va en handoff.
  - Correcto:   "Endpoint /api/remote/closure ahora valida actor canónico. Build OK."

- **handoff**: futuro. "Qué tiene que saber quien llegue después para no estamparse."
  - Incorrecto: "Se implementó la validación."  ← eso ya está en result.
  - Correcto:   "Reiniciar argos-api antes de probar. Token de Codex rotado — ver secrets/."

---

## POLÍTICA DE TRILOG DE CICLO DE VIDA

### Motivación

Un work packet sin trilog de creación es una instrucción huérfana: no hay registro de
por qué existe, quién lo debatió, ni qué tensiones se consideraron. Un packet sin trilog
de cierre es un agujero negro operativo. Un packet que muta sin trilog intermedio
pierde trazabilidad de por qué cambió.

### Regla

Todo work packet emite un trilog en cada uno de estos momentos:

| Momento      | trigger en closure_type | Cuándo                                              |
|--------------|-------------------------|-----------------------------------------------------|
| Creación     | `meta`                  | Al crear el packet. Documenta debate y decisión.    |
| Mutación     | `meta`                  | Al cambiar STATUS, PRIORITY, OWNER o SUBJECT.       |
| Cierre       | `task_completed`        | Al completar o archivar el packet.                  |

El trilog de creación es el que documenta el **por qué** del packet, no solo el **qué**.
El trilog de mutación documenta el **por qué cambió**.
El trilog de cierre documenta el **resultado real** vs el objetivo original.

### Campos mínimos del trilog de lifecycle

```
[LOG]    Qué acción de lifecycle ocurrió y resultado concreto.
[SHADOW] Tensiones, riesgos percibidos, lo que no cabe en el log público.
[HANDOFF] Qué debe saber el próximo agente/Capitán para continuar desde aquí.
```

Nota: en el contexto del schema nuevo, `[HANDOFF]` es el campo `handoff` del schema,
y `[LOG]` contiene tanto `mission`, `result` como contexto de lifecycle.

---

## NECESIDADES DE IMPLEMENTACIÓN (para Codex / argos-api)

Las siguientes necesidades emergen directamente del schema y la política de lifecycle.
Se listan aquí para que queden trazadas desde el momento de creación del packet:

1. **Campo `schema_version` en /api/remote/closure**: el endpoint debe aceptar y
   registrar este campo desde ya (valor `1` por defecto si ausente). Preparación para
   validación estricta en Fase 2.

2. **Campo `handoff_active` en /api/remote/closure**: boolean opcional. Si presente y
   `true`, el dashboard debe renderizar el badge de `blocked` con estilo distinto
   ("traspaso" vs "atascado").

3. **Campo `mission` sustituye a `summary`**: el endpoint debe aceptar `mission` (≤80
   chars). Si llega `summary` en su lugar, normalizar a `mission` con deprecation warning
   en glitch log. No romper retrocompatibilidad en Fase 1.

4. **Validación `result` no vacío**: si `closure_type=task_completed` y `result` está
   vacío, rechazar con 400. Este es el campo que más se ha encontrado vacío en
   entradas históricas.

5. **Validación `handoff` obligatorio en `blocked`**: si `closure_type=blocked` y
   `handoff` está vacío, rechazar con 400 con mensaje: "Un bloqueo sin handoff no ayuda
   a nadie. ¿Qué necesita saber el siguiente para desbloquearlo?"

6. **Trilog de lifecycle en UI**: el dashboard debe poder mostrar los trilogs de
   creación/mutación/cierre vinculados a un packet, diferenciados visualmente de los
   trilogs de tarea normal. Esto puede ser tan simple como un `lifecycle_event: true`
   flag en el registro del log.

7. **Columna `risk_level` en bitácora**: renderizar como semáforo (icono de color)
   en la tabla principal. El valor textual en la fila expandida.

8. **Transcript como icono en fila expandida**: si `transcript_ref` está presente,
   mostrar un icono de "ver razonamiento" en la fila, no una columna dedicada.

---

## TAREAS DE ESTE PACKET

1. Revisar este schema con el Capitán y la tripulación — ratificar o enmendar.
2. Publicar como sección nueva en INTER_AI_PROTOCOL.md (sección 1.8 — Schema de cierre v1).
3. Actualizar ARGOS_QUICKSTART.md ritual de cierre con ejemplo real usando este schema.
4. Crear packet hijo para Codex con las 8 necesidades de implementación listadas arriba.

---

## ENTREGABLE

- INTER_AI_PROTOCOL.md sección 1.8 (Schema canónico de cierre v1)
- ARGOS_QUICKSTART.md ejemplo real de cierre con los 10 campos
- Packet hijo para Codex: implementación en argos-api

---

## SUCCESS CRITERIA

- Cualquier agente puede leer la sección 1.8 de INTER_AI_PROTOCOL.md y saber exactamente
  qué campos enviar en un cierre, sin ambigüedad.
- El ejemplo de cierre en QUICKSTART usa todos los campos y tiene comentarios que explican
  result vs handoff.
- El packet hijo de Codex tiene spec técnica suficiente para implementar sin preguntar.

---

## REFERENCIA

- Debate de origen: sesión 2026-04-24, tripulación completa (Claude/Pi/ChatGPT) + Capitán
- ARG-REFORM-LOG-001 — protocolo de logs (packet hermano)
- ARG-REFORM-BITACORA-001-IMPL — validaciones ORPHAN (en paralelo, Codex)

[/WORK_PACKET]

---

## TRILOG DE CREACIÓN

**[LOG]**
Work packet ARG-REFORM-SCHEMA-001 creado el 2026-04-24T23:26:56Z por Claude (Orfeo) bajo
instrucción del Capitán, tras debate multi-agente ratificado. Contexto del debate:

- El Capitán propuso simplificar la bitácora alrededor de 10 campos canónicos, sacar
  transcript del núcleo, separar result/handoff semánticamente, normalizar risk_level
  como semáforo y establecer cuatro tipos de cierre.
- Pi validó: dignidad semántica de result/handoff, semáforo de riesgo como herramienta
  de superficie, transcript como "capa 2" con icono en fila expandida.
- Claude añadió: `schema_version` desde Fase 1 para no hipotecar Fase 3; distinción
  handoff activo vs bloqueo como flag `handoff_active` (no quinto tipo); separación
  semántica result/handoff como higiene operativa crítica.
- ChatGPT recogió todas las observaciones y ratificó el schema de 10 campos como
  referencia canónica de ARG-REFORM-LOG-001.
- El Capitán añadió política de trilog de lifecycle: creación, mutación y cierre
  de cada packet emiten trilog explícito.

Packet escrito y depositado en inbox. Necesidades de implementación para Codex
documentadas en el cuerpo del packet (8 puntos).

**[SHADOW]**
La tensión principal en este packet no es técnica sino ritual: si introducimos
trilog de lifecycle pero no lo reforzamos en argos-api (campo `lifecycle_event`),
los trilogs de creación/mutación se mezclan con los de tarea normal y la bitácora
vuelve a ser ilegible. La necesidad #6 (flag `lifecycle_event` en UI) es la más
frágil porque depende de que Codex la implemente pronto. Sin eso, la política de
trilog de lifecycle existe en papel pero no es distinguible en pantalla.

Otro riesgo: `mission` sustituyendo a `summary` puede romper depósitos legacy de
Pi o ChatGPT que aún usen `summary`. La normalización en API (punto #3 de
implementación) es crítica para no crear nuevos ORPHAN silenciosos.

**[HANDOFF]**
Para el Capitán: este packet necesita ratificación antes de que Claude escriba en
INTER_AI_PROTOCOL.md. Si el schema de 10 campos está aprobado tal cual, Claude puede
ejecutar las tareas 2 y 3 en la próxima sesión.

Para Codex: las 8 necesidades de implementación están en el cuerpo del packet,
ordenadas por impacto. Las más urgentes son #4 (result no vacío en task_completed)
y #5 (handoff obligatorio en blocked) — son las que más entradas vacías han generado
históricamente.

Para Pi: la política de trilog de lifecycle introduce un nuevo ritual para agentes
sin acceso HTTP. Pi necesitará adaptar su formato de deposit para incluir un campo
que identifique el tipo de evento de lifecycle (`creation`, `mutation`, `closure`).
