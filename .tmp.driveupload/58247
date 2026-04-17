[WORK_PACKET]
ID: ARG-1776613005000
ROLE_REQUESTED: Claude
SUBJECT: Crear CONTEXT_INDEX.md â€” mapa del Drive para que las IAs sepan quÃ© leer y cuÃ¡ndo
STATUS: open
PRIORITY: P2
ROOM: ARGOS
TYPE: strategy
TOKENS_SPENT: 0

OBJECTIVE:
Las IAs arrancan cada sesiÃ³n leyendo demasiado porque no hay un mapa que diga quÃ© hay en
Drive, quÃ© peso tiene cada carpeta y cuÃ¡ndo consultarla. Esto alarga el arranque frÃ­o y
genera lecturas innecesarias que consumen tokens y contexto.

CONTEXT_INDEX.md es el Ã­ndice activo que resuelve esto: no es documentaciÃ³n exhaustiva,
es un mapa de navegaciÃ³n.

TAREAS:
1. Explorar la estructura de c:/Users/Widox/Desktop/ARGOS/ARGOS_RUNTIME/ y c:/Users/Widox/Desktop/ARGOS/ completa.
2. Crear c:/Users/Widox/Desktop/ARGOS/ARGOS_RUNTIME/CONTEXT_INDEX.md con estas secciones:

   ## QuÃ© es quÃ© (mapa de carpetas)
   Para cada carpeta relevante:
   - DescripciÃ³n en una frase
   - Tipo de contenido (protocolo / estado / histÃ³rico / output / archivo)
   - Prioridad de lectura en arranque: ALTA / MEDIA / BAJA / NUNCA-EN-FRÃO
   - CuÃ¡ndo consultarla (siempre / solo bajo condiciÃ³n especÃ­fica)

   ## JerarquÃ­a de lectura en arranque frÃ­o
   El orden exacto y mÃ­nimo para que una IA entienda el estado del navÃ­o sin sobrecargar contexto.
   (Debe ser mÃ¡s corto que el protocolo actual â€” mÃ¡ximo 6 pasos.)

   ## Archivos constitutivos (lo que no cambia)
   Lista de los ficheros que definen el sistema: protocolos, instrucciones de agentes, VECTOR.
   Candidatos para migraciÃ³n a GitHub.

   ## Archivos operativos (lo que cambia a diario)
   state.json, logs, packets, transcripts. Viven en Drive. No van a GitHub.

   ## Archivos que NO hay que leer nunca en frÃ­o
   Transcripts completos, logs histÃ³ricos, archivos legacy. Solo bajo peticiÃ³n explÃ­cita o
   debugging especÃ­fico.

3. El documento debe caber en menos de 200 lÃ­neas. Es un mapa, no un manual.
4. AÃ±adir referencia a CONTEXT_INDEX.md en ARGOS_QUICKSTART.md como recurso de orientaciÃ³n.

ENTREGABLE:
- CONTEXT_INDEX.md creado y Ãºtil para una IA que arranca sin contexto previo.
- Referencia aÃ±adida en ARGOS_QUICKSTART.md.
[/WORK_PACKET]
