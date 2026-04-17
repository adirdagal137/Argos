Sí, es viable, y además encaja bastante bien con vuestra arquitectura actual, con una condición: no tratar el transcript bruto como memoria permanente, sino como materia prima efímera para extraer señales compactas. Vuestra configuración ya va en esa dirección: prioriza “memoria ligera”, olvida transcripts largos en bruto y favorece reconstruir señales, logs y colas de revisión en lugar de conservar texto verbatim.  

La idea buena no es “LLM barato analiza todo y LLM caro relee todo”, sino una tubería en 3 capas:

1. **ASR / limpieza**
   Audio → transcript con diarización simple si la tenéis.
2. **Destilación barata**
   Modelo barato extrae estructura: errores frecuentes, chunks útiles, CEFR estimado por skill, ratio teacher/student talk, grammar hits, review flags, evidencias breves.
3. **Síntesis potente**
   Un modelo mejor recibe solo el resumen estructurado + 3–8 citas cortas del transcript y saca conclusiones pedagógicas, actualización del perfil y propuesta de siguiente clase.

Eso es coherente con vuestro sistema dict+log: cada clase debería terminar en algo parecido a `g/k/e/f + evidencias mínimas`, no en guardar páginas y páginas de conversación.  

En costes, hoy hay opciones muy razonables para esa capa barata. OpenAI publica GPT-5.4 nano a $0.20 por millón de tokens de entrada y $1.25 por millón de salida; GPT-5.4 mini sube a $0.75 / $4.50; GPT-5.4 completo a $2.50 / $15.00. Además, el Batch API reduce un 50% input y output. ([OpenAI][1])
Google ofrece modelos muy baratos y además con free tier en algunos casos: Gemini 2.5 Flash-Lite Preview figura con entrada gratis en free tier y, en pago, $0.10 por millón de tokens de entrada y $0.40 de salida; su Batch baja a $0.05 / $0.20. ([Google AI for Developers][2])
Groq tiene opciones abiertas muy baratas y rápidas: Llama 3.1 8B a $0.05 input / $0.08 output por millón, GPT-OSS 20B a $0.075 / $0.30, y Whisper Large V3 Turbo a $0.04 por hora de audio para transcripción. ([GroqCloud][3])
Anthropic Claude Haiku 4.5 también entra como capa intermedia solvente: $1 input / $5 output por millón. ([Anthropic][4])

Traducido a una sesión típica, un transcript de unas 8k–15k tokens es barato de destilar. Por ejemplo, con un pase barato que consuma 10k tokens de entrada y devuelva 800 de salida, estarías alrededor de una fracción de céntimo a pocos milésimos de dólar con Groq open models, unos milésimos con GPT-5.4 nano, y todavía bajo con Flash-Lite. El coste empieza a subir no por “analizar una clase”, sino por rehacer análisis completos muchas veces o por mandar transcripts enteros al modelo potente en cada turno. Los precios publicados hacen que el cuello de botella sea más de diseño que de presupuesto. ([OpenAI][1])

Donde sí hay riesgo es en la **calidad pedagógica del primer pase**. Un modelo muy barato puede:

* confundir error puntual con patrón estable,
* sobreinferir nivel CEFR,
* mezclar corrección del profe con producción real del alumno,
* perder matices de pronunciación si partes solo de transcript,
* generar etiquetas inconsistentes.

Por eso el primer pase no debería decidir solo; debería **normalizar y candidatear**. Ejemplo de salida ideal del modelo barato:

* top_errors_candidate: `["QWO","ART","3S"]`
* grammar_hits_candidate: `["grammar_paths.questions","grammar_paths.determiners.articles"]`
* evidence_spans: 4–6 citas cortas con speaker labels
* talk_ratio: `{teacher: 62, student: 38}`
* task_types_seen
* confidence flags
* unresolved ambiguities

Y luego el modelo potente valida, descarta falsos positivos y actualiza `signals`, `review_queue`, `diagnostics` o la propuesta de próxima sesión. Eso además encaja con vuestra política de no recalcular todo el historial en cada turno salvo cuando se pida recopilar todo.  

Mi recomendación práctica sería esta:

**Fase A: barato / siempre**

* Transcribir.
* Limpiar marcas triviales.
* Segmentar por speaker y por actividad.
* Extraer JSON corto.
* Guardar solo:

  * resumen estructurado,
  * 3–8 evidencias textuales cortas,
  * métricas,
  * propuesta de log-entry.

**Fase B: potente / selectivo**

* Solo cuando haya una de estas condiciones:

  * cambio de nivel sospechado,
  * error persistente,
  * revisión cada 5–10 clases,
  * preparación de informe,
  * generación de próxima clase importante.

**Fase C: persistencia**

* Persistir únicamente profile/log/signals/milestones.
* No persistir transcript completo salvo necesidad legal, QA o auditoría.

Eso es exactamente el tipo de economía de tokens que ya reflejan vuestros documentos: historial comprimido, señales, hits y review queue, no texto libre por clase.  

Mi veredicto: **sí, viable y recomendable**, pero como sistema de “destilación + verificación”, no como “memoria conversacional masiva”.
La combinación más sensata hoy sería algo así:

* **muy barato**: Groq + open model para extracción mecánica y Whisper Turbo para ASR ([GroqCloud][3])
* **barato con free tier**: Gemini 2.5 Flash-Lite para resúmenes estructurados y clasificación inicial ([Google AI for Developers][2])
* **más sólido para la capa final**: GPT-5.4 mini o GPT-5.4, según la importancia del informe ([OpenAI][1])

La decisión clave no es el modelo, sino el contrato de salida del primer pase. Si lo definís bien, el sistema escala y sale barato. Si no, el modelo potente gastará tokens arreglando ruido.

Puedo proponerte ahora un esquema concreto de pipeline y un JSON de salida para ese “primer pase sobre transcript” listo para implementar.

[1]: https://openai.com/api/pricing/ "OpenAI API Pricing | OpenAI"
[2]: https://ai.google.dev/gemini-api/docs/pricing "Gemini Developer API pricing  |  Gemini API  |  Google AI for Developers"
[3]: https://console.groq.com/docs/models "Supported Models - GroqDocs"
[4]: https://www.anthropic.com/pricing "Plans & Pricing | Claude by Anthropic"
