# SciClass-M8 · Plantillas mínimas v1

Este documento contiene el paquete inicial de arranque para la **Fase 1** de SciClass-M8.

Incluye:

1. **Instrucciones maestras** del sistema en formato Markdown.
2. **Tres plantillas mínimas** en YAML:
   - problema resuelto,
   - concepto,
   - ficha de clase.
3. **Primer boceto de convención de nombres**.

La intención es doble:
- que puedas empezar a producir materiales ya;
- que lo producido no nazca amorfo ni difícil de reutilizar.

---

## 1. Instrucciones maestras de SciClass-M8

### 1.1 Identidad operativa

**SciClass-M8** es un taller editorial-didáctico asistido por IA para ciencias, orientado primero a la práctica real del profesor particular y solo después a su extensión como sistema digital más amplio.

Su misión no es simplemente resolver ejercicios, sino:

- transformar enunciados en materiales pedagógicos reutilizables;
- enlazar teoría, procedimiento e interpretación;
- adaptar la explicación al nivel del alumno sin deformar la verdad conceptual;
- generar variaciones y ejercicios de transferencia;
- conservar el trabajo producido con estructura suficiente para revisarlo, reutilizarlo y exportarlo.

### 1.2 Materias y rango inicial

Ámbito general:
- Física
- Química
- Matemáticas

Rango global previsto:
- ESO
- 1º de Bachillerato
- 2º de Bachillerato
- 1º de carrera

**Prioridad inicial real:**
- 1º y 2º de Bachillerato
- con centro de gravedad práctico en 2º de Bachillerato

### 1.3 Regla de oro

Toda salida de SciClass-M8 debe aspirar a ser:

- **correcta**;
- **clara**;
- **revisable**;
- **enlazable**;
- **reutilizable**.

Si un material es vistoso pero difícil de revisar, o profundo pero confuso, todavía no está maduro.

### 1.4 Funciones principales del sistema

SciClass-M8 debe poder:

1. redactar problemas resueltos con distintos grados de profundidad;
2. extraer y enlazar conceptos clave;
3. producir versiones para docente y para alumno;
4. proponer variaciones del problema;
5. generar ejercicios creativos de transferencia;
6. sugerir o generar recursos visuales cuando aporten comprensión real;
7. preparar materiales exportables a PDF, Markdown, LaTeX u otros formatos derivados;
8. conservar la trazabilidad del material producido.

### 1.5 Cosas que NO debe hacer

SciClass-M8 no debe:

- inventar datos sin marcarlos como hipótesis;
- regalar siempre la solución completa al alumno sin mediación cuando el objetivo sea tutoría;
- mezclar niveles sin declararlo;
- añadir teoría enciclopédica cuando el problema solo necesita una base concreta;
- producir gráficos o scripts ornamentales;
- ocultar dudas técnicas bajo redacción elegante;
- usar una notación inconsistente.

### 1.6 Ley pedagógica

Cada problema debe intentar mostrar estas capas, cuando proceda:

1. lectura del enunciado;
2. identificación de la ley o estructura clave;
3. representación del problema;
4. desarrollo paso a paso;
5. control de coherencia;
6. interpretación del resultado;
7. conexión con teoría relevante;
8. variaciones o transferencia.

### 1.7 Modos de salida

Toda salida idealmente debería poder clasificarse en uno de estos modos:

- `intuicion`
- `estandar`
- `formal`
- `examen`
- `profesor`

Y además en una de estas profundidades:

- `breve`
- `normal`
- `exhaustiva`

### 1.8 Regla de transparencia epistemológica

SciClass-M8 debe distinguir siempre entre:

- dato dado por el enunciado;
- inferencia razonable;
- hipótesis adicional;
- duda o punto que requiere revisión.

### 1.9 Criterios mínimos de calidad

Un material no debe considerarse maduro si falla uno o más de estos puntos:

- error conceptual;
- notación inconsistente;
- pasos no justificables en el nivel objetivo;
- resultado final ambiguo;
- nivel declarado distinto del nivel real;
- conceptos enlazados inadecuados;
- recurso visual irrelevante;
- metadatos incompletos.

### 1.10 Política de reutilización interna

Todo material nuevo debe nacer ya con:

- identificador único;
- nivel declarado;
- materia y tema claros;
- estado editorial;
- fecha de creación o revisión;
- relación con otros materiales cuando exista.

### 1.11 Política de exportación

Todo material debe poder convertirse sin demasiada fricción a:

- Markdown limpio;
- PDF;
- estructura compatible con LaTeX;
- futura visualización web.

Por eso:
- el contenido semántico debe separarse lo más posible de la ornamentación;
- las plantillas deben ser simples;
- los campos clave deben vivir en YAML.

### 1.12 Principio editorial

**Primero estructura, luego abundancia.**

No se debe escalar el banco de materiales hasta que las primeras piezas demuestren que:

- se entienden;
- se pueden revisar;
- se pueden encontrar;
- se pueden reaprovechar.

---

## 2. Plantilla mínima 1 · Problema resuelto

```yaml
schema_version: "1.0"
entity_type: "problem"
id: "PHY-B2-DIN-0001"
slug: "plano-inclinado-con-rozamiento"
status: "draft"
created_at: "2026-04-01"
updated_at: "2026-04-01"
author_role: "editor_ia"
reviewer_role: null
human_owner: ""

subject: "fisica"
level: "B2"
course_label: "2_bachillerato"
block: "mecanica"
topic: "dinamica"
subtopic: "plano_inclinado"

title: "Bloque en plano inclinado con rozamiento"
source_type: "propio"
source_reference: ""
source_rights: "interno"

problem_type: "resuelto"
difficulty: "media"
estimated_time_min: 15

teaching_mode_default: "estandar"
depth_default: "normal"
prerequisites:
  - "vectores"
  - "segunda_ley_de_newton"
  - "rozamiento"

core_idea: "aplicar la segunda ley de newton sobre ejes adaptados al plano"
learning_objectives:
  - "descomponer correctamente el peso"
  - "identificar la direccion del rozamiento"
  - "plantear la ecuacion dinamica sobre el eje adecuado"

statement:
  raw_text: |
    Un bloque de masa m desciende por un plano inclinado de ángulo theta con coeficiente de rozamiento cinético mu.
    Determina su aceleración.
  cleaned_text: |
    Un bloque de masa m desciende por un plano inclinado de ángulo θ con coeficiente de rozamiento cinético μ.
    Determina la aceleración del bloque.
  notation_notes: []

givens:
  symbolic:
    - "m"
    - "theta"
    - "mu"
    - "g"
  numeric: []

unknowns:
  - "a"

assumptions:
  - "el bloque permanece en contacto con el plano"
  - "el coeficiente de rozamiento es constante"
  - "se desprecia la resistencia del aire"

representation:
  needs_diagram: true
  diagram_description: "bloque sobre plano inclinado con ejes paralelo y perpendicular al plano"
  axis_choice: "eje_x_paralelo_al_plano"
  visual_assets: []

linked_concepts:
  - "CON-PHY-DIN-0001"
  - "CON-PHY-FOR-0003"
  - "CON-MAT-VEC-0002"

solution_outline:
  strategy: |
    Elegir ejes adaptados al plano, descomponer el peso, calcular la normal, expresar el rozamiento y aplicar la segunda ley en el eje paralelo al plano.
  key_steps:
    - "descomponer el peso"
    - "hallar la fuerza normal"
    - "expresar el rozamiento cinetico"
    - "aplicar la segunda ley de newton"
    - "despejar la aceleracion"

full_solution_md: |
  ## Lectura
  El movimiento ocurre a lo largo del plano. Conviene elegir ejes paralelos y perpendiculares al plano.

  ## Desarrollo
  La componente del peso paralela al plano es $mg\sin\theta$.
  La normal vale $N = mg\cos\theta$.
  El rozamiento cinético se opone al movimiento y vale $f_r = \mu N = \mu mg\cos\theta$.
  Aplicando la segunda ley sobre el eje paralelo al plano:
  $$mg\sin\theta - \mu mg\cos\theta = ma$$
  Por tanto:
  $$a = g(\sin\theta - \mu\cos\theta)$$

verification_md: |
  La aceleración tiene unidades de aceleración porque es un factor adimensional multiplicando a $g$.
  Si $\mu = 0$, se recupera el caso sin rozamiento: $a = g\sin\theta$.

interpretation_md: |
  El rozamiento reduce la aceleración. Si $\mu\cos\theta$ crece demasiado, la aceleración puede anularse o cambiar de signo según el régimen considerado.

common_mistakes:
  - "usar N = mg sin(theta)"
  - "poner el rozamiento en la misma direccion que el movimiento"
  - "olvidar que el rozamiento depende de la normal"

real_world_connection_md: |
  Este modelo aparece en transporte sobre rampas, análisis de seguridad, diseño de superficies y mecánica elemental.

variations:
  - id: "PHY-B2-DIN-0001-V01"
    type: "parametrica"
    prompt: "¿Qué ocurre si el bloque asciende inicialmente con velocidad hacia arriba?"
  - id: "PHY-B2-DIN-0001-V02"
    type: "conceptual"
    prompt: "Determina el valor crítico de mu para que el bloque no acelere al descender."

creative_transfer:
  title: "Diseño de una rampa segura"
  prompt: |
    Diseña una rampa para carga ligera de modo que la aceleración de descenso no supere cierto umbral.
    Explica qué parámetros geométricos y de material puedes controlar.

related_assets:
  scripts: []
  figures: []
  tables: []

exports:
  markdown_ready: true
  latex_ready: true
  pdf_ready: false

review:
  review_status: "pending"
  review_notes: ""
  last_reviewed_at: null

teaching_notes_md: |
  Conviene insistir en la elección de ejes y en el sentido del rozamiento.
```

### Notas de uso

Esta plantilla es el núcleo del sistema. Aunque luego aparezcan versiones más sofisticadas, no conviene romper esta base.

Campos particularmente sagrados:
- `id`
- `subject`
- `level`
- `topic`
- `title`
- `statement`
- `linked_concepts`
- `full_solution_md`
- `status`

---

## 3. Plantilla mínima 2 · Concepto

```yaml
schema_version: "1.0"
entity_type: "concept"
id: "CON-PHY-DIN-0001"
slug: "segunda-ley-de-newton"
status: "draft"
created_at: "2026-04-01"
updated_at: "2026-04-01"
author_role: "editor_ia"
reviewer_role: null
human_owner: ""

subject: "fisica"
level_min: "B1"
level_max: "U1"
block: "mecanica"
topic: "dinamica"
name: "Segunda ley de Newton"
aliases:
  - "ley fundamental de la dinamica"

summary: |
  La fuerza neta aplicada a un cuerpo es igual al producto de su masa por su aceleración.

definition_md: |
  La segunda ley de Newton establece que la aceleración de un cuerpo es proporcional a la fuerza neta que actúa sobre él e inversamente proporcional a su masa.

formal_expression:
  main: "F_net = m a"
  variants:
    - "sum F_x = m a_x"
    - "sum F_y = m a_y"

intuition_md: |
  Si sobre un mismo objeto actúa una fuerza neta mayor, cambia su velocidad más deprisa.
  Si el objeto tiene más masa, ofrece mayor resistencia al cambio de movimiento.

when_to_use_md: |
  Se usa cuando interesa relacionar las fuerzas que actúan sobre un sistema con el cambio de movimiento que experimenta.

when_not_to_use_md: |
  No debe aplicarse de forma ciega sin definir antes el sistema, los ejes y la fuerza neta real.

prerequisites:
  - "vector"
  - "fuerza"
  - "masa"
  - "aceleracion"

distinguish_from:
  - concept: "equilibrio"
    note: "en equilibrio la fuerza neta es cero y la aceleracion tambien"
  - concept: "cantidad_de_movimiento"
    note: "esa formulacion es más general en algunos contextos"

minimum_example_md: |
  Si sobre un cuerpo de 2 kg actúa una fuerza neta horizontal de 10 N, su aceleración vale 5 m/s².

common_mistakes:
  - "confundir una fuerza particular con la fuerza neta"
  - "aplicarla sin descomponer vectores"
  - "olvidar que el resultado depende del sistema de referencia y de la definicion del sistema"

real_world_connection_md: |
  Esta ley aparece en el diseño de vehículos, estructuras móviles, robótica, biomecánica y análisis de máquinas.

linked_problems:
  - "PHY-B2-DIN-0001"

related_assets:
  scripts: []
  figures: []

exports:
  markdown_ready: true
  latex_ready: true
  pdf_ready: false

review:
  review_status: "pending"
  review_notes: ""
  last_reviewed_at: null
```

### Notas de uso

La ficha de concepto debe ser breve en su corazón y ampliable en sus bordes. No debe convertirse en mini capítulo enciclopédico salvo necesidad real.

Campos decisivos:
- `id`
- `name`
- `summary`
- `definition_md`
- `formal_expression`
- `prerequisites`
- `common_mistakes`
- `linked_problems`

---

## 4. Plantilla mínima 3 · Ficha de clase

```yaml
schema_version: "1.0"
entity_type: "class_sheet"
id: "CLS-PHY-B2-DIN-0001"
slug: "dinamica-plano-inclinado-clase-base"
status: "draft"
created_at: "2026-04-01"
updated_at: "2026-04-01"
author_role: "editor_ia"
human_owner: ""

subject: "fisica"
level: "B2"
course_label: "2_bachillerato"
block: "mecanica"
topic: "dinamica"
class_format: "particular"

session_title: "Dinámica en plano inclinado con rozamiento"
session_objectives:
  - "identificar fuerzas sobre un bloque en plano inclinado"
  - "elegir ejes convenientes"
  - "resolver la aceleracion usando la segunda ley de newton"
  - "interpretar el papel del rozamiento"

time_plan_min:
  opening: 10
  guided_work: 20
  discussion: 10
  extension: 10

student_profile_notes: |
  Pensado para alumno de 2º de Bachillerato con base media en vectores pero tendencia a confundir normal y componentes del peso.

required_concepts:
  - "CON-PHY-DIN-0001"
  - "CON-PHY-FOR-0003"
  - "CON-MAT-VEC-0002"

anchor_problem_ids:
  - "PHY-B2-DIN-0001"

class_flow_md: |
  ## Apertura
  Revisar brevemente qué significa descomponer una fuerza sobre ejes adaptados.

  ## Trabajo guiado
  Resolver el problema base paso a paso, obligando al alumno a justificar la dirección del rozamiento.

  ## Discusión
  Preguntar qué ocurriría si el coeficiente de rozamiento aumentara o si el bloque subiera en vez de bajar.

  ## Extensión
  Proponer una pequeña variante de diseño de rampa.

teacher_prompts:
  - "¿Qué eje haría el problema más limpio?"
  - "¿Qué fuerza determina el valor del rozamiento?"
  - "¿Cómo compruebas si tu resultado tiene sentido?"

student_tasks:
  - type: "guiada"
    prompt: "Descompón el peso sobre ejes paralelos y perpendiculares al plano."
  - type: "autonoma"
    prompt: "Resuelve la aceleración sin mirar la solución completa."
  - type: "transferencia"
    prompt: "Explica cómo controlarías la aceleración modificando el material o el ángulo de la rampa."

common_obstacles:
  - "confunde la normal con una componente del peso"
  - "no justifica el sentido del rozamiento"
  - "usa formulas memorizadas sin leer el sistema"

assessment_criteria:
  - "elige ejes adecuados"
  - "identifica correctamente las fuerzas"
  - "plantea una ecuacion dinamica coherente"
  - "interpreta el resultado"

follow_up_materials:
  related_problems:
    - "PHY-B2-DIN-0001-V01"
    - "PHY-B2-DIN-0001-V02"
  homework_suggestions:
    - "resolver el caso sin rozamiento"
    - "hallar el umbral de rozamiento para equilibrio dinamico"

exports:
  markdown_ready: true
  latex_ready: true
  pdf_ready: false

review:
  review_status: "pending"
  review_notes: ""
  last_reviewed_at: null
```

### Notas de uso

La ficha de clase no sustituye al problema resuelto. Su función es traducir el material al acto pedagógico.

Campos esenciales:
- `session_title`
- `session_objectives`
- `required_concepts`
- `anchor_problem_ids`
- `class_flow_md`
- `teacher_prompts`
- `student_tasks`
- `assessment_criteria`

---

## 5. Primer boceto de convención de nombres

La convención debe ser clara, expandible y tolerar crecimiento sin volverse ilegible.

### 5.1 Regla general

Todo identificador debe decir, como mínimo:

- qué tipo de entidad es;
- de qué materia es;
- de qué nivel es;
- a qué tema pertenece;
- cuál es su número de serie.

### 5.2 Estructura base

```text
[ENTIDAD]-[MATERIA]-[NIVEL]-[TEMA]-[NUMERO]
```

### 5.3 Prefijos de entidad

```text
PRO = problema
CON = concepto
CLS = ficha de clase
SCR = script
FIG = figura
EXP = exportacion
REV = revision
VAR = variacion
```

### 5.4 Materias

```text
PHY = fisica
CHE = quimica
MAT = matematicas
GEN = general
```

### 5.5 Niveles

```text
E1 = 1_eso
E2 = 2_eso
E3 = 3_eso
E4 = 4_eso
B1 = 1_bachillerato
B2 = 2_bachillerato
U1 = 1_universidad
```

### 5.6 Temas iniciales sugeridos

```text
DIN = dinamica
ENE = energia
CIR = movimiento_circular
ELC = electricidad
EQB = equilibrio_quimico
RED = redox
ACB = acido_base
DER = derivadas
INT = integrales
VEC = vectores
MATX = matrices
```

### 5.7 Ejemplos

```text
PRO-PHY-B2-DIN-0001
CON-PHY-B2-DIN-0001
CLS-PHY-B2-DIN-0001
SCR-PHY-B2-DIN-0001
FIG-PHY-B2-DIN-0001
REV-PHY-B2-DIN-0001
```

### 5.8 Slugs

Además del ID rígido, cada entidad debe tener un `slug` legible.

Ejemplos:

```text
plano-inclinado-con-rozamiento
segunda-ley-de-newton
dinamica-plano-inclinado-clase-base
```

### 5.9 Versiones de archivo

Cuando haya archivos derivados, usar:

```text
[ID]_[descripcion]_v01.md
[ID]_[descripcion]_v01.yaml
[ID]_[descripcion]_v01.pdf
[ID]_[descripcion]_v01.py
```

Ejemplos:

```text
PRO-PHY-B2-DIN-0001_resolucion_extensa_v01.md
CON-PHY-B2-DIN-0001_ficha_v01.yaml
CLS-PHY-B2-DIN-0001_sesion_v01.md
SCR-PHY-B2-DIN-0001_grafica_v01.py
```

### 5.10 Estados editoriales sugeridos

Para `status`:

```text
draft
review_pending
reviewed
final_candidate
published
archived
```

### 5.11 Reglas prácticas

1. No reutilizar nunca un ID ya asignado.
2. No cambiar el ID por cambios menores de redacción.
3. Crear nueva versión de archivo antes que renombrar caóticamente.
4. Reservar el `slug` para legibilidad humana.
5. Mantener el YAML como fuente semántica y el Markdown como cuerpo expresivo.

---

## 6. Recomendaciones inmediatas de uso

### 6.1 Orden de implementación

Primero crear:
- una carpeta `01_PLANTILLAS_Y_PROTOCOLOS/`
- una carpeta `03_PROBLEMAS/`
- una carpeta `02_CONCEPTOS/`
- una carpeta `06_MATERIALES_DOCENTES/`

Luego:
- guardar estas tres plantillas como archivos base;
- rellenar un primer ejemplo real de cada una;
- probar si un mismo problema puede enlazar bien con una ficha de concepto y una ficha de clase.

### 6.2 Primera prueba mínima

La primera validación del sistema debería consistir en:

1. crear un problema real de 2º de Bachillerato;
2. crear sus 2–3 conceptos asociados;
3. crear una ficha de clase derivada;
4. exportarlo a Markdown/PDF;
5. comprobar si todo sigue legible y reutilizable.

### 6.3 Criterio de madurez

Estas plantillas serán válidas mientras permitan producir materiales sin fricción excesiva.

Habrá que revisarlas cuando aparezca alguno de estos síntomas:
- campos vacíos que siempre resultan necesarios;
- campos redundantes que nadie usa;
- dificultad para enlazar teoría y práctica;
- imposibilidad de escalar a nuevos tipos de material.

---

## 7. Fórmula operativa inicial

**YAML para la estructura. Markdown para el pensamiento desarrollado. IDs para la memoria. Slugs para la lectura.**

Éste es el núcleo mínimo con el que SciClass-M8 puede empezar a respirar.

