# ARQUITECTURA_ARGOS_API_FIRST

**Fecha:** 2026-04-09  
**Propósito:** Propuesta de arquitectura común para reducir fricción operativa, eliminar duplicidades entre voces y permitir ejecución compartida entre GPT, Claude y Gemini sin necesidad de routers o logs separados por modelo.

---

## 1. Objetivo

Queremos una arquitectura que:

- minimice la dificultad ejecutiva del Capitán;
- permita a distintas IAs operar bajo un estándar común;
- evite tener un `router` distinto por voz;
- evite mantener logs paralelos según la IA que intervenga;
- reduzca la dependencia de copiar/pegar entre chats y herramientas;
- conserve trazabilidad, memoria operativa y gobernanza.

---

## 2. Diagnóstico

La fricción actual no proviene solo del modelo, sino del entorno de ejecución.

### Problemas detectados

1. **Drive montado como filesystem no es un estándar común suficiente**
   - Algunos agentes locales pueden crear `.md` y mover carpetas.
   - Otros entornos web o conectores solo leen o editan Docs/Sheets/Slides.
   - Resultado: la capacidad operativa depende del agente, no del sistema.

2. **Google Apps Script como cerebro central se queda corto**
   - Funciona bien para automatización ligera y registro en Sheets.
   - Pero exige muchas funciones ad hoc para tareas complejas.
   - Tiene límites de ejecución, cuotas y ergonomía pobre para flujos agentes largos.

3. **Sheets como backend genera rigidez**
   - Es excelente como vista humana.
   - No es la mejor fuente canónica para estado operativo complejo, eventos, dependencias y coordinación multiagente.

4. **La falta de un estándar común de herramientas obliga a soluciones por modelo**
   - Cada IA termina usando una vía distinta.
   - Eso obliga a crear routers, bandejas o protocolos específicos por entorno.

---

## 3. Principio Rector

**La unidad no debe construirse alrededor del chat, sino alrededor de las herramientas y del estado compartido.**

La clave no es que todas las IAs “vean el mismo prompt”, sino que todas operen contra:

- el mismo backend,
- las mismas herramientas,
- el mismo esquema de datos,
- y la misma fuente de verdad.

---

## 4. Propuesta de Arquitectura

### Arquitectura recomendada: `API-first, tool-first, state-first`

#### Componentes

1. **Google Drive API**
   - Para crear, leer, mover, buscar y organizar artefactos reales.
   - Docs, carpetas, Markdown, PDFs, exports y adjuntos.

2. **Firestore**
   - Fuente canónica de estado operativo.
   - Sustituye a Sheets como backend principal.
   - Guarda tareas, eventos, artefactos, reglas, estados y referencias.

3. **Cloud Run**
   - Backend orquestador único.
   - Expone endpoints o herramientas para que cualquier IA opere igual.
   - Ejecuta lógica, validaciones, escritura, sincronización y auditoría.

4. **Tool schemas comunes**
   - Un catálogo único de herramientas descritas con esquema estructurado.
   - GPT, Claude y Gemini llaman a las mismas funciones lógicas.
   - Solo cambia el adaptador fino por proveedor.

5. **Sheets como dashboard humano**
   - Vista de control, seguimiento y lectura.
   - No fuente canónica de la operación.

---

## 5. Qué elimina esta arquitectura

### Deja de ser necesario

- un `INBOX_CLAUDE`, `INBOX_CHATGPT`, `OUTBOX_GEMINI`, etc.;
- logs distintos según la voz;
- copiar decisiones manualmente entre sistemas;
- usar el chat como lugar único donde “ocurre” el trabajo;
- depender de si una IA concreta tiene acceso local al disco o no.

### En su lugar

Todas las voces llaman a las mismas operaciones:

- `create_task`
- `update_task`
- `append_event`
- `search_drive`
- `create_drive_doc`
- `move_drive_item`
- `link_artifact`
- `read_rule`
- `promote_observation`
- `close_task`

---

## 6. Modelo de Datos Común

### Firestore como memoria operativa única

#### Colecciones mínimas

- `tasks`
- `events`
- `artifacts`
- `rules`
- `observations`
- `projects`

### Ejemplo conceptual

#### `tasks`
Guarda:
- id
- title
- status
- owner
- project
- dependencies
- linked_artifacts
- created_at
- updated_at

#### `events`
Guarda:
- timestamp
- agent
- task_id
- event_type
- summary
- payload
- verification

#### `artifacts`
Guarda:
- drive_file_id
- kind
- title
- project
- canonical
- linked_task
- mime_type
- path_hint

#### `rules`
Guarda:
- id
- statement
- scope
- evidence
- confidence
- status
- last_validated_at

#### `observations`
Guarda:
- source
- project
- text
- confidence
- limit
- promoted_to_rule
- created_at

---

## 7. Reparto de responsabilidades

### Drive
Para:
- documentos reales;
- archivos Markdown;
- carpetas de proyecto;
- materiales finales;
- artefactos compartibles por humanos.

### Firestore
Para:
- estados;
- trazas;
- relaciones;
- dependencias;
- eventos;
- reglas;
- observaciones;
- coordinación interagente.

### Sheets
Para:
- paneles humanos;
- revisión rápida;
- dashboards;
- reporting;
- vistas filtradas.

---

## 8. Ventajas frente a GAS + Sheet multicapa

### Sí conserva
- trazabilidad;
- automatización con Google;
- visibilidad humana;
- integración con Drive.

### Mejora
- menos trabajo manual;
- menos funciones artesanales;
- mejor escalabilidad;
- más neutralidad entre modelos;
- menos dependencia del entorno local;
- más claridad entre fuente de verdad y vista.

### Idea clave
**Sheets debe ser espejo o panel, no cerebro.**

---

## 9. Shared Drive vs Mi unidad

Si es posible, esta arquitectura funcionará mejor sobre **Shared Drive** que sobre `Mi unidad`.

### Razones
- mejor control organizativo;
- menos dependencia de propiedad individual;
- mejor encaje con cuentas de servicio y automatización;
- menos fricción de permisos.

---

## 10. Sobre MCP y estándares comunes

MCP apunta a una buena dirección como estándar abierto de herramientas.  
Sin embargo, para una Fase 1 práctica, lo más robusto es definir primero un **catálogo propio de herramientas con esquemas JSON** y luego, si conviene, exponerlo también por MCP.

### Recomendación
- Fase 1: tool schemas propios + backend único.
- Fase 2: capa MCP opcional.
- Fase 3: conectores adicionales si hacen falta.

---

## 11. Riesgos y precauciones

Esta arquitectura no elimina por sí sola los riesgos de gobernanza.

### Hay que definir igualmente

1. **Qué es canónico**
   - Firestore para estado.
   - Drive para artefactos.
   - Sheets para vista.

2. **Quién puede escribir qué**
   - No toda voz debe tener permisos completos sobre todos los recursos.

3. **Qué flujo sigue una observación hasta convertirse en regla**
   - `observation -> pattern -> rule`

4. **Qué requiere validación humana**
   - cierres sensibles;
   - cambios de canon;
   - promociones a reglas;
   - borrados o movimientos críticos.

---

## 12. Recomendación Final

La mejor arquitectura para Argos no es:

- ni `Drive local` como única base,
- ni `GAS + Sheets` como cerebro central,
- ni una proliferación de routers por IA.

La mejor arquitectura es:

- **Drive API** para artefactos,
- **Firestore** como estado único,
- **Cloud Run** como backend orquestador,
- **tool schemas comunes** para todas las IAs,
- y **Sheets** solo como panel humano.

### Fórmula resumida

**Un solo backend.  
Un solo ledger.  
Un solo catálogo de herramientas.  
Múltiples modelos, misma infraestructura.**

---

## 13. Propuesta de Fase 1

1. Definir el esquema mínimo de `tasks`, `events`, `artifacts`, `rules` y `observations`.
2. Crear backend simple en Cloud Run.
3. Implementar 6 a 10 herramientas nucleares compartidas.
4. Conectar un primer modelo a esas herramientas.
5. Probar flujo real de una semana.
6. Añadir dashboards en Sheets si aportan valor.
7. Solo después decidir si hace falta capa MCP.

---

## 14. Veredicto

**Sí existe una arquitectura que reduce mucho la dificultad ejecutiva y evita routers/logs distintos por IA.**  
No pasa por dar “más acceso bruto” a cada modelo, sino por dar a todos el mismo sistema de herramientas y el mismo estado compartido.

---

## 15. Fuentes revisadas

- Google Drive API
- Google Apps Script quotas y web apps
- Google Cloud Run
- Firestore
- Function calling / tool use en OpenAI, Gemini y Claude
- Model Context Protocol (MCP)

---

## 16. Cierre

Si la tripulación aprueba esta dirección, el siguiente paso no debería ser debatir más prompts, sino diseñar:

- el esquema común de datos;
- el catálogo mínimo de herramientas;
- y la frontera exacta entre Drive, Firestore y Sheets.
