# Arquitectura v1 del taller IA para problemas resueltos de ciencias

## 0. Propósito

Este documento define la arquitectura inicial de un sistema pedagógico-editorial asistido por IA orientado a:

- resolver y explicar problemas clásicos de **física, química y matemáticas**;
- adaptar el desarrollo al **nivel del alumno**;
- enlazar cada problema con **conceptos clave** y explicaciones específicas;
- producir **material docente reutilizable** en formato digital y PDF;
- generar **variaciones, extensiones y ejercicios creativos**;
- incorporar **gráficos, diagramas, scripts y simulaciones** cuando aporten comprensión real;
- sostener una colaboración ordenada entre varias IAs (ChatGPT, Claude, Gemini u otras);
- mantener un **banco de materiales vivo**, con estructura, revisión y continuidad.

La ambición no es crear un simple solucionador de ejercicios. La ambición es construir un **taller de enseñanza, edición, archivo y expansión conceptual**.

---

## 1. Principio rector

El sistema no debe entrenar al alumno únicamente para reproducir un algoritmo de examen. Debe enseñarle a:

1. **leer un problema**;
2. **reconocer la ley o estructura subyacente**;
3. **traducir el enunciado a un modelo**;
4. **desarrollar una resolución rigurosa**;
5. **verificar la coherencia del resultado**;
6. **interpretar el significado físico/químico/matemático**;
7. **transferir la idea a otros contextos**.

El problema resuelto es la puerta. No es el templo entero.

---

## 2. Alcance inicial

### 2.1 Rango general del proyecto

El sistema abarcará desde:

- **ESO**
- **Bachillerato**
- **primer año de carreras universitarias**

### 2.2 Punto de inicio recomendado

Se propone comenzar por **segundo de Bachillerato** como nivel medio de complejidad, porque:

- exige suficiente precisión conceptual;
- conecta bien con examen y acceso universitario;
- sirve de puente hacia primero de carrera;
- aún permite adaptar hacia abajo sin desfigurar el contenido.

### 2.3 Orden sugerido de despliegue

1. Física (2º de Bachillerato)
2. Matemáticas (2º de Bachillerato)
3. Química (2º de Bachillerato)
4. Extensión hacia ESO y 1º de carrera

No conviene empezar con las tres disciplinas a la vez. Conviene empezar donde la arquitectura pueda probarse sin dispersión.

---

## 3. Ley pedagógica del sistema

### 3.1 Qué es una buena resolución

Una buena resolución no es la más larga, sino la que ordena el pensamiento sin mutilar la profundidad.

Debe contener, cuando proceda:

1. **Lectura del enunciado**
2. **Datos explícitos e implícitos**
3. **Qué se pide realmente**
4. **Marco teórico aplicable**
5. **Supuestos y simplificaciones**
6. **Representación del problema**
7. **Desarrollo paso a paso**
8. **Control de unidades, signos, dominio, magnitud o coherencia**
9. **Resultado final claro**
10. **Interpretación conceptual**
11. **Utilidad real o contexto de aplicación**
12. **Variaciones y generalizaciones**
13. **Ejercicio creativo o transferencia final**

### 3.2 Resolución en capas

Toda resolución debería poder expresarse en capas. Esto permite adaptar sin falsear.

#### Capa 1 — Núcleo intuitivo
- Qué está ocurriendo
- Qué ley manda
- Por qué ese enfoque y no otro

#### Capa 2 — Resolución estándar
- Procedimiento completo
- Desarrollo limpio
- Resultado justificado

#### Capa 3 — Profundización conceptual
- Derivaciones más finas
- Discusión de supuestos
- Errores frecuentes
- Conexiones con otros temas

#### Capa 4 — Apertura
- Variantes
- Aplicaciones reales
- Extensión geométrica, experimental o creativa

### 3.3 Modos de explicación

El sistema debe poder responder en distintos registros. Se propone fijar estos modos:

- **Modo intuición**: explicación visual y verbal, mínima carga simbólica
- **Modo estándar**: nivel académico regular del curso
- **Modo formal**: mayor precisión simbólica y justificativa
- **Modo examen**: síntesis orientada a rendimiento y claridad operativa
- **Modo profesor**: incluye observaciones didácticas, fallos típicos y alternativas de enfoque

### 3.4 Niveles de profundidad

Cada salida puede etiquetarse además por profundidad:

- **breve**
- **normal**
- **exhaustiva**

La combinación de modo + profundidad evita respuestas erráticas.

---

## 4. Arquitectura funcional general

El sistema se organiza en **cuatro planos**.

### 4.1 Plano A — Motor de autoría

Uso principal: creación de materiales.

Funciones:
- redactar problemas resueltos;
- convertir enunciados de libros o apuntes a formato de trabajo;
- generar versiones adaptadas;
- producir variantes;
- diseñar diagramas, esquemas y scripts;
- redactar fichas docentes;
- preparar PDFs y materiales exportables.

Usuario principal: profesor / editor.

### 4.2 Plano B — Tutor de alumno

Uso principal: interacción pedagógica con estudiantes.

Funciones:
- guiar paso a paso;
- detectar lagunas previas;
- explicar conceptos enlazados;
- ofrecer pistas graduales;
- proponer práctica progresiva;
- evitar la dependencia pasiva de la solución completa.

Usuario principal: alumno.

### 4.3 Plano C — Banco de conocimiento

Uso principal: conservación, indexación y reutilización.

Contendrá:
- problemas;
- conceptos;
- scripts;
- imágenes;
- simulaciones;
- errores típicos;
- rúbricas;
- plantillas;
- fichas de alumno;
- metadatos de revisión.

### 4.4 Plano D — Gobierno y producción

Uso principal: coherencia del sistema.

Funciones:
- taxonomía de carpetas y nombres;
- control de versiones;
- criterios de revisión;
- trazabilidad de fuentes;
- protocolo entre IAs;
- estado de cada material;
- derechos de uso y notas editoriales.

---

## 5. Roles de las IAs

No conviene pedir a una sola IA que sea simultáneamente tutor, archivista, editor, ilustrador, revisor y coordinador. Es preferible distribuir roles.

### 5.1 Rol 1 — IA autora principal

Misión:
- redactar y expandir materiales;
- construir problemas resueltos;
- proponer variantes y ejercicios creativos;
- generar primeras versiones de recursos visuales.

Salida típica:
- borradores extensos y estructurados.

### 5.2 Rol 2 — IA revisora conceptual

Misión:
- detectar ambigüedades;
- encontrar errores lógicos, físicos, químicos o matemáticos;
- cuestionar supuestos;
- señalar lagunas o pasos opacos.

Salida típica:
- informe crítico y lista de correcciones.

### 5.3 Rol 3 — IA pedagógica

Misión:
- adaptar el material al nivel;
- simplificar sin traicionar;
- señalar prerequisitos;
- diseñar andamiaje para alumno.

Salida típica:
- versión por niveles y sugerencias didácticas.

### 5.4 Rol 4 — IA técnica/visual

Misión:
- generar scripts;
- producir gráficas, simulaciones y esquemas;
- preparar recursos para PDF o soporte digital.

Salida típica:
- código documentado, imagen exportable, notas de uso.

### 5.5 Rol 5 — IA archivista/normalizadora

Misión:
- convertir borradores a formato interno;
- verificar metadatos;
- nombrar archivos;
- ubicar materiales en la carpeta correcta;
- mantener consistencia documental.

Salida típica:
- material normalizado según plantilla.

### 5.6 Regla de oro

Cada IA debe saber **qué rol ocupa** en cada tarea. Si no, contaminará el proceso con mezclas innecesarias.

---

## 6. Protocolo de comunicación cruzada entre IAs

Para que Claude, Gemini, ChatGPT u otras colaboren sin disolver el rigor, necesitan un **lenguaje común**, sobrio y explícito.

La comunicación entre IAs no debe parecer una conversación libre, sino un **intercambio de paquetes de trabajo normalizados**.

### 6.1 Principios del lenguaje cruzado

1. **Explicitar objetivo**
2. **Declarar rol de la IA receptora**
3. **Delimitar entrada y salida esperadas**
4. **Separar hechos, inferencias, hipótesis y dudas**
5. **No mezclar revisión con reescritura salvo que se pida**
6. **Indicar nivel académico objetivo**
7. **Indicar restricciones de estilo**
8. **Exigir formato de salida estable**

### 6.2 Estructura recomendada de un paquete de trabajo

```text
[WORK_PACKET]
ID: PHY-2B-MEC-0007
ROLE_REQUESTED: Revisor conceptual
SUBJECT: Física
LEVEL_TARGET: 2º Bachillerato
TASK_TYPE: revisión
OBJECTIVE: detectar errores y pasos insuficientemente justificados
INPUT_SUMMARY: resolución de problema de plano inclinado con rozamiento
REQUIRED_OUTPUT:
- lista de errores
- pasos oscuros
- supuestos omitidos
- mejoras sugeridas
CONSTRAINTS:
- no reescribir todo
- mantener nivel 2º Bachillerato
- distinguir error grave / mejora opcional
OUTPUT_FORMAT:
1. Errores graves
2. Ambigüedades
3. Mejoras opcionales
4. Veredicto final
[/WORK_PACKET]
```

### 6.3 Etiquetas estándar sugeridas

Para normalizar el intercambio, usar siempre campos como estos:

- `ID`
- `ROLE_REQUESTED`
- `SUBJECT`
- `TOPIC`
- `LEVEL_TARGET`
- `TASK_TYPE`
- `OBJECTIVE`
- `INPUT_SUMMARY`
- `REQUIRED_OUTPUT`
- `CONSTRAINTS`
- `OUTPUT_FORMAT`
- `STATUS`
- `REVIEW_STAGE`
- `SOURCE_REFERENCES`

### 6.4 Tipos de tarea normalizados

- `authoring`
- `review`
- `didactic_adaptation`
- `concept_extraction`
- `visual_design`
- `script_generation`
- `metadata_normalization`
- `variant_generation`
- `assessment_design`
- `student_profile_synthesis`

### 6.5 Niveles de estado del material

- `draft`
- `review_pending`
- `reviewed`
- `didactic_pending`
- `final_candidate`
- `published`
- `archived`

### 6.6 Regla de honestidad cruzada

Toda IA debe marcar explícitamente:

- qué sabe con certeza;
- qué está infiriendo;
- qué no puede verificar;
- qué parte requeriría revisión humana.

### 6.7 Tono del lenguaje cruzado

Debe ser:
- seco;
- técnico;
- no ornamental;
- sin autoelogio;
- sin conversación innecesaria.

El lenguaje entre IAs no debe ser humanoide. Debe ser **operativo**.

---

## 7. Taxonomía central del banco de materiales

Todo material debe pertenecer a una estructura común.

### 7.1 Entidades principales

1. **Problema**
2. **Concepto**
3. **Recurso visual**
4. **Script**
5. **Actividad / variación**
6. **Ficha docente**
7. **Ficha de alumno**
8. **Plantilla**
9. **Rúbrica**
10. **Fuente**

### 7.2 Unidad mínima: el problema estructurado

Cada problema debe poder describirse mediante estos campos:

- ID único
- título corto
- disciplina
- bloque temático
- subtema
- nivel objetivo
- prerequisitos
- ley o idea nuclear
- tipo de problema
- dificultad
- enunciado original
- fuente
- derechos / observaciones de uso
- resolución breve
- resolución extensa
- errores frecuentes
- conceptos enlazables
- recursos visuales asociados
- scripts asociados
- variantes
- ejercicio creativo final
- estado editorial
- fecha de revisión
- responsable humano

### 7.3 Unidad mínima: el concepto enlazable

Cada concepto debe tener su propia ficha.

Campos propuestos:

- ID de concepto
- nombre canónico
- sinónimos
- disciplina
- nivel mínimo sugerido
- definición breve
- explicación extendida
- intuición geométrica/física/química
- prerequisitos
- error típico
- ejemplo mínimo
- aplicación real
- problemas relacionados
- recursos visuales relacionados

---

## 8. Estructura de carpetas en Drive

La idea no es solo almacenar, sino permitir búsqueda, revisión y trabajo colaborativo.

### 8.1 Carpeta raíz

```text
00_TALLER_IA_CIENCIAS/
```

### 8.2 Árbol principal sugerido

```text
00_TALLER_IA_CIENCIAS/
│
├── 00_GOBIERNO_Y_SISTEMA/
├── 01_PLANTILLAS_Y_PROTOCOLOS/
├── 02_CONCEPTOS/
├── 03_PROBLEMAS/
├── 04_RECURSOS_VISUALES/
├── 05_SCRIPTS_Y_SIMULACIONES/
├── 06_MATERIALES_DOCENTES/
├── 07_MATERIALES_ALUMNADO/
├── 08_PERFILES_Y_FICHAS_ALUMNOS/
├── 09_FUENTES_Y_ENUNCIADOS/
├── 10_REVISION_Y_CONTROL_DE_CALIDAD/
├── 11_PUBLICADOS_PDF/
├── 12_ARCHIVO_HISTORICO/
└── 99_ENTRADA_RAPIDA/
```

### 8.3 Contenido de cada carpeta

#### `00_GOBIERNO_Y_SISTEMA/`
Contendrá:
- visión general del proyecto;
- arquitectura v1;
- normas de nomenclatura;
- criterios de calidad;
- políticas de revisión;
- mapa de roles humanos e IA;
- decisiones estratégicas.

#### `01_PLANTILLAS_Y_PROTOCOLOS/`
Contendrá:
- plantilla de problema;
- plantilla de concepto;
- plantilla de revisión;
- plantilla de ficha docente;
- plantilla de ficha de alumno;
- formato de paquete de trabajo entre IAs;
- glosario de etiquetas.

#### `02_CONCEPTOS/`
Subdividida por disciplina y luego por bloque.

Ejemplo:
```text
02_CONCEPTOS/
├── FISICA/
├── QUIMICA/
└── MATEMATICAS/
```

#### `03_PROBLEMAS/`
Subdividida por disciplina, nivel y tema.

Ejemplo:
```text
03_PROBLEMAS/
├── FISICA/
│   ├── ESO/
│   ├── BACH_1/
│   ├── BACH_2/
│   └── UNI_1/
├── QUIMICA/
└── MATEMATICAS/
```

#### `04_RECURSOS_VISUALES/`
Contendrá:
- diagramas;
- esquemas;
- imágenes definicionales;
- figuras para problemas;
- gráficos exportados.

#### `05_SCRIPTS_Y_SIMULACIONES/`
Contendrá:
- scripts Python;
- notebooks;
- datos de entrada;
- versiones exportadas;
- notas de uso;
- capturas o salidas estáticas.

#### `06_MATERIALES_DOCENTES/`
Contendrá:
- fichas de clase;
- guías de discusión;
- soluciones completas;
- notas pedagógicas;
- secuencias didácticas.

#### `07_MATERIALES_ALUMNADO/`
Contendrá:
- hojas de práctica;
- versiones simplificadas;
- problemas graduados;
- tareas;
- actividades creativas.

#### `08_PERFILES_Y_FICHAS_ALUMNOS/`
Solo si se decide gestionar seguimiento individual.

Subcarpetas sugeridas:
- plantillas vacías;
- grupos;
- alumnos;
- observaciones de progreso;
- planes personalizados.

**Advertencia:** esta carpeta requiere tratamiento responsable y criterios claros de privacidad.

#### `09_FUENTES_Y_ENUNCIADOS/`
Contendrá:
- capturas o transcripciones de enunciados;
- libros de referencia;
- fuentes propias;
- notas de origen;
- permisos o estado de uso.

#### `10_REVISION_Y_CONTROL_DE_CALIDAD/`
Contendrá:
- informes de revisión;
- listas de errores detectados;
- pendientes;
- materiales bloqueados;
- validaciones finales.

#### `11_PUBLICADOS_PDF/`
Contendrá los productos finales listos para distribuir.

Subestructura sugerida:
```text
11_PUBLICADOS_PDF/
├── DOCENTE/
├── ALUMNO/
└── COLECCIONES/
```

#### `12_ARCHIVO_HISTORICO/`
Contendrá:
- versiones antiguas;
- materiales descontinuados;
- experimentos fallidos que convenga conservar.

#### `99_ENTRADA_RAPIDA/`
Buzón temporal para:
- material recién subido;
- textos pendientes de clasificar;
- enunciados capturados rápidamente.

Todo lo que entra aquí debe ser procesado y reubicado.

---

## 9. Niveles internos dentro de una carpeta de problemas

Ejemplo concreto:

```text
03_PROBLEMAS/FISICA/BACH_2/MECANICA/DINAMICA/
│
├── PHY-B2-DIN-0001_plano_inclinado_rozamiento/
│   ├── 00_METADATA/
│   ├── 01_ENUNCIADO/
│   ├── 02_RESOLUCION_BREVE/
│   ├── 03_RESOLUCION_EXTENSA/
│   ├── 04_VARIANTES/
│   ├── 05_EJERCICIO_CREATIVO/
│   ├── 06_CONCEPTOS_ENLAZADOS/
│   ├── 07_RECURSOS_VISUALES/
│   ├── 08_SCRIPTS/
│   ├── 09_REVISION/
│   └── 10_EXPORTS/
```

Esta estructura por problema evita que el material quede disperso entre carpetas generales sin continuidad.

---

## 10. Convención de nombres

Los nombres deben servir para encontrar el material sin abrirlo.

### 10.1 Formato de ID sugerido

```text
[DISCIPLINA]-[NIVEL]-[TEMA]-[NUMERO]
```

Ejemplos:
- `PHY-B2-DIN-0001`
- `MAT-B2-INT-0004`
- `CHE-B2-EQB-0007`
- `PHY-U1-CAL-0012`

### 10.2 Abreviaturas sugeridas

#### Disciplinas
- `PHY` Física
- `CHE` Química
- `MAT` Matemáticas

#### Niveles
- `E1`, `E2`, `E3`, `E4` según curso de ESO si se desea granularidad
- `B1`, `B2`
- `U1`

#### Estados
- `_draft`
- `_reviewed`
- `_final`
- `_published`

### 10.3 Nombres de archivo recomendados

```text
PHY-B2-DIN-0001_resolucion_extensa_v01.md
PHY-B2-DIN-0001_resolucion_alumno_v01.pdf
PHY-B2-DIN-0001_script_grafica_v02.py
PHY-B2-DIN-0001_revision_claude_v01.md
PHY-B2-DIN-0001_conceptos_enlazados_v01.json
```

---

## 11. Plantilla maestra de problema resuelto

### 11.1 Encabezado

- ID
- título
- disciplina
- nivel
- tema
- subtema
- dificultad
- tiempo estimado
- prerequisitos
- idea nuclear

### 11.2 Sección A — Enunciado

- enunciado limpio;
- aclaraciones de notación si hace falta;
- fuente o procedencia;
- observaciones de uso.

### 11.3 Sección B — Lectura inteligente del problema

- qué se sabe;
- qué se pide;
- qué tipo de estructura tiene;
- qué pista decisiva contiene el enunciado.

### 11.4 Sección C — Representación

- dibujo o esquema;
- sistema de ejes, magnitudes o especies químicas si procede;
- tabla inicial de datos.

### 11.5 Sección D — Conceptos clave enlazados

Lista breve de conceptos con identificador.

Ejemplo:
- Segunda ley de Newton (`CON-PHY-FOR-0002`)
- Rozamiento cinético (`CON-PHY-DIN-0011`)
- Descomposición vectorial (`CON-MAT-VEC-0003`)

### 11.6 Sección E — Resolución paso a paso

Cada paso debe incluir:
- objetivo del paso;
- operación realizada;
- justificación;
- resultado parcial.

### 11.7 Sección F — Verificación

Según disciplina:
- unidades;
- signo;
- orden de magnitud;
- límite físico;
- dominio matemático;
- coherencia química;
- interpretación geométrica.

### 11.8 Sección G — Interpretación profunda

Responder:
- qué significa el resultado;
- qué relación revela entre magnitudes;
- qué cambia si varían los supuestos;
- qué idea general conviene retener.

### 11.9 Sección H — Utilidad real

Conectar la ley o herramienta con:
- ingeniería;
- naturaleza;
- laboratorio;
- tecnología;
- modelización;
- vida cotidiana bien elegida.

### 11.10 Sección I — Errores frecuentes

Ejemplos:
- confundir fuerza neta con componente de peso;
- omitir signo;
- usar fórmula sin verificar régimen;
- suponer proporcionalidad lineal donde no la hay.

### 11.11 Sección J — Variaciones

Al menos tres tipos:
- variación paramétrica;
- variación geométrica;
- variación conceptual.

### 11.12 Sección K — Ejercicio creativo final

Debe obligar al alumno a transferir la idea a:
- un contexto realista;
- una geometría distinta;
- una situación experimental o de diseño;
- una interpretación abierta pero controlada.

### 11.13 Sección L — Recursos asociados

- imagen;
- script;
- simulación;
- ficha conceptual;
- material docente.

---

## 12. Plantilla maestra de concepto enlazable

### Encabezado
- ID
- nombre
- disciplina
- bloque
- nivel mínimo

### Cuerpo
1. Definición breve
2. Explicación extendida
3. Qué lo distingue de conceptos cercanos
4. Intuición central
5. Representación visual o simbólica
6. Ejemplo mínimo
7. Error frecuente
8. Aplicación real
9. Problemas relacionados
10. Recursos asociados

---

## 13. Tipos de producto final

El sistema debe producir varios tipos de salida, no una sola.

### 13.1 Ficha maestra interna
Versión completa para edición y archivo.

### 13.2 PDF docente
Incluye:
- desarrollo integral;
- notas pedagógicas;
- observaciones de clase;
- alternativas de enfoque.

### 13.3 PDF alumno
Incluye:
- versión más limpia;
- conceptos enlazados;
- extensión controlada;
- práctica derivada.

### 13.4 Banco de variaciones
Colección de ejercicios hermanos del problema matriz.

### 13.5 Actividad creativa o de transferencia
Pensada para ir más allá del formato examen.

### 13.6 Recurso visual independiente
Un diagrama o gráfico reutilizable fuera del problema concreto.

---

## 14. Uso de gráficos, scripts y simulaciones

### 14.1 Cuándo merece la pena un recurso visual

Solo debe generarse cuando ayude a:
- ver una dependencia funcional;
- entender una geometría;
- distinguir regímenes;
- interpretar parámetros;
- conectar símbolo y fenómeno.

### 14.2 Cuándo NO merece la pena

No debe generarse solo para embellecer.

Hay que evitar:
- interactividad vacía;
- figuras redundantes;
- gráficos que repiten una tabla sin revelar nada;
- simulaciones complejas para ideas elementales.

### 14.3 Paquete mínimo de cada script

Todo script debería ir acompañado de:
- propósito;
- inputs;
- outputs;
- versión del problema al que sirve;
- comentarios básicos;
- imagen exportada o captura de la salida esperada.

### 14.4 Doble salida recomendada

Para cada recurso técnico:
- una versión **editable** (`.py`, notebook, datos)
- una versión **estable** (PNG, PDF, SVG, captura, tabla exportada)

---

## 15. Flujo editorial completo

### Fase 1 — Captura
Entrada de material desde:
- libro;
- foto o escaneo;
- enunciado propio;
- conversación previa;
- idea nueva;
- ejercicio de examen.

Destino inicial:
- `99_ENTRADA_RAPIDA/`

### Fase 2 — Normalización
Se convierte el enunciado a formato legible y se registra:
- ID provisional;
- disciplina;
- nivel;
- fuente;
- estado.

### Fase 3 — Autoría base
La IA autora genera:
- resolución;
- conceptos;
- errores típicos;
- variantes;
- ejercicio creativo.

### Fase 4 — Revisión conceptual
Otra IA o revisión humana detecta:
- errores;
- lagunas;
- pasos dudosos;
- sobreexplicaciones inútiles;
- simplificaciones ilegítimas.

### Fase 5 — Adaptación didáctica
Se generan versiones por nivel o modo.

### Fase 6 — Recursos visuales y scripts
Solo si añaden valor real.

### Fase 7 — Maquetación y exportación
Se producen versiones PDF y/o materiales de aula.

### Fase 8 — Publicación y archivo
Se mueven los materiales finales a:
- `11_PUBLICADOS_PDF/`

Las versiones previas o descartadas se mueven a:
- `12_ARCHIVO_HISTORICO/`

---

## 16. Control de calidad

### 16.1 Criterios mínimos antes de publicar

Un material no debe publicarse si falla alguno de estos puntos:

- corrección conceptual;
- notación coherente;
- nivel adecuado;
- lectura clara;
- pasos justificables;
- resultado verificable;
- ausencia de contradicciones internas;
- metadatos completos;
- conceptos enlazados correctos.

### 16.2 Lista de revisión recomendada

1. ¿La ley principal está bien identificada?
2. ¿Hay supuestos ocultos sin declarar?
3. ¿El nivel real coincide con el nivel declarado?
4. ¿Se explica demasiado o demasiado poco?
5. ¿Los símbolos son consistentes?
6. ¿La verificación es real o decorativa?
7. ¿La aplicación real es pertinente o forzada?
8. ¿Las variantes amplían de verdad la idea?
9. ¿El ejercicio creativo exige transferencia genuina?
10. ¿El material podría confundir a un alumno atento?

### 16.3 Clasificación de incidencias

- **grave**: error que invalida la comprensión o el resultado
- **media**: defecto que enturbia la enseñanza
- **leve**: mejora editorial o de estilo

---

## 17. Interacción con alumnos

### 17.1 Regla fundamental

El tutor no debe regalar siempre la solución completa al primer intento.

Debe ser capaz de elegir entre:
- pregunta guía;
- pista leve;
- pista fuerte;
- subproblema auxiliar;
- resolución parcial;
- resolución completa.

### 17.2 Tipos de ayuda al alumno

- detectar concepto faltante;
- recordar herramienta previa;
- corregir un paso concreto;
- traducir lenguaje verbal a simbólico;
- interpretar un resultado extraño;
- sugerir práctica análoga.

### 17.3 Registro ideal de la dificultad del alumno

Si se trabaja con fichas de alumno, conviene registrar:
- nivel actual estimado;
- errores recurrentes;
- temas dominados;
- temas inseguros;
- tipo de ayuda que mejor le sirve.

---

## 18. Fichas de alumno

Solo si el proyecto realmente quiere sostener personalización.

### 18.1 Campos sugeridos

- nombre o identificador
- curso
- grupo
- objetivos
- nivel estimado por disciplina
- fortalezas
- errores recurrentes
- hábitos de trabajo observados
- materiales recomendados
- seguimiento de progreso

### 18.2 Precaución

Estas fichas deben ser sobrias. No deben convertirse en perfiles psicológicos inflados ni en depósitos de juicios vagos.

---

## 19. Política de fuentes y derechos

Toda fuente debe registrarse. Nunca asumir que por estar en internet puede reutilizarse sin más.

Para cada enunciado o material externo, guardar:
- procedencia;
- autor/editorial si se conoce;
- fecha si se conoce;
- uso interno o uso distribuible;
- observaciones.

Cuando un ejercicio provenga de un libro, conviene decidir si:
- se conserva el enunciado tal cual solo para trabajo interno;
- se reformula;
- se usa como inspiración para crear una variante propia.

---

## 20. Arquitectura v1 de los GPTs o asistentes

### 20.1 Asistente A — Autor de problemas

**Función:** crear borradores completos.

Debe saber:
- usar la plantilla maestra;
- enlazar conceptos;
- proponer variantes;
- añadir utilidad real;
- sugerir recursos visuales útiles.

No debe:
- mezclar demasiadas opciones a la vez;
- hablar como si se dirigiera directamente al alumno salvo que se indique.

### 20.2 Asistente B — Revisor riguroso

**Función:** desmontar errores y opacidades.

Debe:
- buscar inconsistencias;
- marcar pasos débiles;
- diferenciar error grave de mejora opcional;
- no reescribir entero salvo orden explícita.

### 20.3 Asistente C — Adaptador pedagógico

**Función:** traducir el material a niveles y modos.

Debe:
- preservar la ley conceptual;
- graduar el lenguaje;
- señalar prerequisitos faltantes;
- decidir cuándo usar analogías.

### 20.4 Asistente D — Visualizador / técnico

**Función:** producir y documentar scripts y figuras.

Debe:
- justificar por qué el recurso visual ayuda;
- documentar inputs y outputs;
- ofrecer exportables claros;
- evitar pirotecnia inútil.

### 20.5 Asistente E — Archivista

**Función:** ordenar y normalizar.

Debe:
- nombrar bien;
- completar metadatos;
- ubicar en carpeta correcta;
- dejar trazabilidad de cambios.

---

## 21. Mapa mínimo de metadatos

Conviene mantener un archivo maestro por problema, por ejemplo en formato JSON o YAML.

### Ejemplo conceptual

```yaml
id: PHY-B2-DIN-0001
status: reviewed
subject: fisica
level: B2
topic: mecanica
subtopic: dinamica
core_idea: segunda_ley_de_newton
difficulty: media
prerequisites:
  - vectores
  - descomposicion_de_fuerzas
  - rozamiento
linked_concepts:
  - CON-PHY-FOR-0002
  - CON-PHY-DIN-0011
  - CON-MAT-VEC-0003
assets:
  - figura_01.png
  - script_grafica.py
exports:
  - resolucion_docente.pdf
  - resolucion_alumno.pdf
review:
  reviewer: claude
  date: 2026-__-__
  verdict: apto_con_correcciones_menores
```

---

## 22. Primer lote semilla recomendado

No comenzar con una masa enorme de materiales. Comenzar con un conjunto pequeño, fuerte y bien revisado.

### 22.1 Meta inicial

Crear **10 problemas semilla** de gran calidad en 2º de Bachillerato.

### 22.2 Reparto sugerido

#### Física
- dinámica en plano inclinado
- conservación de la energía
- movimiento circular
- campo eléctrico o potencial

#### Matemáticas
- optimización con derivadas
- interpretación geométrica de integrales
- sistemas o matrices

#### Química
- equilibrio químico
- estequiometría con rendimiento
- ácido-base o redox básico

### 22.3 Propósito del lote semilla

Sirve para:
- probar la plantilla;
- ajustar el tono;
- detectar carencias estructurales;
- crear los primeros nodos de conceptos;
- validar el flujo entre IAs.

---

## 23. Secuencia de implementación recomendada

### Etapa 1 — Cimiento
- fijar estructura de carpetas;
- fijar nomenclatura;
- fijar plantilla maestra;
- fijar lenguaje cruzado entre IAs.

### Etapa 2 — Banco base
- crear 10 problemas semilla;
- crear 20–30 conceptos enlazables básicos;
- crear 5–10 recursos visuales útiles.

### Etapa 3 — Revisión
- someter el lote a revisión conceptual;
- corregir la plantilla según los fallos detectados.

### Etapa 4 — Productos finales
- generar PDF docente y PDF alumno;
- ordenar publicaciones.

### Etapa 5 — Tutoría
- definir comportamiento del tutor para alumno;
- diseñar reglas de ayuda gradual.

### Etapa 6 — Escalado
- extender a otras disciplinas y niveles;
- incorporar fichas de alumno si de verdad se van a usar;
- afinar automatizaciones.

---

## 24. Lo que debe evitarse desde el inicio

1. Crear cientos de archivos sin metadatos
2. Mezclar niveles en el mismo material
3. Confundir exhaustividad con claridad
4. Generar gráficos ornamentales
5. Acumular enunciados sin revisión de origen
6. Pedir a una sola IA que haga todos los papeles a la vez
7. No distinguir borrador de material publicable
8. Usar enlaces conceptuales sin fichas conceptuales reales detrás
9. Crear fichas de alumno vagas o invasivas
10. Escalar antes de validar el lote semilla

---

## 25. Visión de madurez futura

Si esta arquitectura se sostiene, el sistema podría llegar a convertirse en:

- una biblioteca de problemas resueltos de alta calidad;
- un entorno de tutoría adaptativa;
- un taller de material docente reutilizable;
- un archivo conceptual enlazado;
- una red de colaboración entre humano e IAs bien diferenciadas.

Pero para llegar ahí, la ley inicial debe ser firme:

**orden antes que abundancia, criterio antes que automatización, profundidad antes que espectáculo.**

---

## 26. Próximos pasos inmediatos

1. Crear la carpeta raíz y el árbol de carpetas
2. Crear las plantillas maestras
3. Elegir la primera disciplina
4. Definir los 10 problemas semilla
5. Crear el protocolo de trabajo entre IAs
6. Redactar el primer problema modelo completo
7. Someterlo a revisión cruzada
8. Ajustar la arquitectura antes de escalar

---

## 27. Fórmula operativa final

**Un buen sistema no produce solo respuestas. Produce materiales fiables, legibles, enlazables, revisables y fértiles.**

Ése es el umbral que esta arquitectura v1 busca establecer.

---

## 28. Repriorización estratégica: primero práctica docente, después plataforma

A la luz del objetivo principal —asistir cuanto antes a la práctica ([help.openai.com](https://help.openai.com/es-419/articles/10169521-proyectos-en-chatgpt))la secuencia correcta no es empezar por la web ni por el chatbot público, sino por un **taller editorial operativo** que ya sirva en clase.

### 28.1 Orden revisado de prioridades

#### Paso 1 — Proyecto maestro `SciClass-M8`
Debe convertirse en el centro de trabajo.

Funciones:
- agrupar chats útiles del asistente didáctico;
- conservar el contexto de producción;
- almacenar archivos subidos al proyecto;
- servir como punto de entrada a materiales y conversaciones en curso;
- actuar como memoria práctica del trabajo docente.

Justificación técnica:
- los proyectos permiten agrupar chats, archivos e instrucciones;
- se pueden mover chats existentes al proyecto;
- los proyectos tienen memoria integrada del contenido del propio proyecto.

#### Paso 2 — GPT custom autor/editor
Debe ser el instrumento de fabricación de materiales, no todavía el producto final.

Funciones:
- redactar problemas resueltos;
- generar variantes;
- adaptar por nivel;
- enlazar conceptos;
- preparar borradores exportables;
- ayudar a producir fichas para alumno y docente.

Debe trabajar en continuidad con el proyecto `SciClass-M8`, aunque la lógica de archivo y gobierno siga viviendo en Drive y en la estructura documental del sistema.

#### Paso 3 — Banco de contenido para 1º y 2º de Bachillerato
Una vez que el editor ya funcione de forma estable, el foco debe ser construir una base de datos documental suficiente de las tres materias.

Ámbito inicial:
- Física
- Química
- Matemáticas
- niveles B1 y B2

#### Paso 4 — Interfaz de visualización funcional y exportable
Antes de una web completa, conviene producir una interfaz o formato de visualización que ya permita:
- consultar materiales con orden;
- imprimir o exportar fácilmente;
- mostrar teoría enlazada;
- mostrar recursos gráficos;
- dejar preparada la transición posterior a website.

#### Paso 5 — Website, APIs e integración de chatbot
Esto debe venir al final, cuando ya existan:
- estructura madura;
- corpus suficiente;
- estilo didáctico asentado;
- criterio de revisión estable;
- materiales exportables y reutilizables.

### 28.2 Traducción operativa de esta prioridad

La meta inmediata no es "lanzar una plataforma".

La meta inmediata es esta:

**tener, cuanto antes, un sistema interno que ayude a preparar clases, resolver dudas, fabricar materiales y reutilizar lo producido con orden.**

### 28.3 Nueva secuencia por metas

#### Meta 1 — Asistencia inmediata a la práctica docente
Entregables mínimos:
- proyecto `SciClass-M8` creado y ordenado;
- GPT autor/editor funcional;
- plantillas operativas;
- 10–20 materiales semilla utilizables con alumnos;
- estructura de Drive funcionando;
- flujo de exportación sencillo.

#### Meta 2 — Base documental útil para Bachillerato
Entregables:
- teoría enlazada básica de B1 y B2;
- repertorio creciente de problemas resueltos;
- variantes y ejercicios creativos;
- primeros scripts y recursos visuales reutilizables.

#### Meta 3 — Sistema editorial consolidado
Entregables:
- revisión más estable;
- metadatos consistentes;
- mejor visualización;
- organización apta para escalar a web.

#### Meta 4 — Plataforma web y API
Entregables:
- interfaz pública o semipública;
- base de datos integrada;
- chatbot externo;
- APIs y automatizaciones.

### 28.4 Distinción crucial sobre Google Drive

Conviene distinguir tres cosas:

1. **Drive como almacenamiento humano**
   - carpetas, versiones, archivos fuente, PDFs, scripts.

2. **Drive como app conectada en ChatGPT**
   - permite buscar y abrir archivos relevantes;
   - puede usarse en chats y proyectos;
   - dentro de proyectos, la app de Drive no aporta sincronización previa para recuperación.

3. **Drive con sync a nivel de cuenta/app**
   - puede sincronizar archivos de Google Drive a la cuenta de ChatGPT cuando se configura con la opción correspondiente;
   - esto no equivale a que un proyecto concreto sincronice automáticamente sus fuentes de Drive.

### 28.5 Conclusión estratégica revisada

La arquitectura correcta ya no debe imaginarse como:

`web -> chatbot -> contenido`

sino como:

`proyecto + editor + banco documental + visualización exportable -> luego web`

Ése es el orden más fértil y el que mejor sirve a la práctica docente inmediata.

