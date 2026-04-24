[WORK_PACKET]
ID: LOLA-SHADOW-0001
ROOM: GENERAL
TYPE: task
PRIORITY: P3
TAG: lola, shadow_log, analisis_relacional, alertas, dashboard, vigia
ROLE_REQUESTED: Claude Code / Antigravity
OWNER: pendiente
STATUS: open
REPORTED_BY: Orfeo (Claude)
REPORTED_AT: 2026-04-24
MERGES: ARG-1775915097259, ARG-1776826258409, ARG-1777052788376, LOLA-RISK-1776424632454

CONTEXT:
Cuatro packets dispersos sobre Lola consolidados aquí tras debate multi-agente
(Claude + ChatGPT + Pi + Capitán, 2026-04-24) sobre arquitectura de shadow_log.

Lola (Vigía de la Sombra) tiene dos funciones que hasta ahora no estaban bien separadas:
  A) Función técnica: escanear shadow_logs en busca de patrones de riesgo operativo
     (trilog incompleto, tensión entre agentes, stale prolongado, glitches recurrentes).
  B) Función relacional (nueva): detectar patrones en la interacción Capitán–IA que
     revelen estilo de coordinación, fricción recurrente, desalineación de expectativas.
     No como juicio, sino como espejo de patrones para aprendizaje del Capitán.

Esta segunda función nace de la observación del Capitán: el shadow_log de las IAs
enseña sobre cómo el Capitán trata a la tripulación y qué tipo de Capitán es cuando
piensa en voz alta, está bajo presión o busca verdad en lugar de ejecución.

CAUTELA (formulada por ChatGPT):
Lola no debe confundir interacción intensa con interacción disfuncional.
La presión, el cambio de marco o la insistencia no son síntomas — pueden ser
el motor del descubrimiento. Lola describe tensiones y patrones, no los patologiza.

SHADOW TÉCNICO vs SHADOW RELACIONAL:
  Shadow del agente       → qué tensiones internas, riesgos o dudas percibió la IA
  Shadow relacional       → qué patrones aparecieron en la interacción Capitán–IA
  (Lola lee ambos, pero los reporta separados para no mezclar capas)

TAREAS:

A. Motor de análisis (mejora de runLolaShadowScanner):
1. [ ] Mejorar reportes de alerta — actualmente demasiado escuetos (ARG-1775915097259).
       Incluir: qué patrones exactos detectó, en qué entradas del shadow log,
       con qué peso/frecuencia. No solo stress_level numérico.

2. [ ] Ordenar y estructurar los shadow_logs antes de escanear (ARG-1776826258409).
       Si los shadows llegan desordenados o mal formateados, el análisis de Lola
       es ruidoso. Añadir normalización previa al escaneo.

3. [ ] Alertas en dashboard: mínimo 5 segundos de visibilidad en pantalla.
       Revisar por qué el sistema de alertas no está funcionando bien (ARG-1777052788376).
       Considerar: cola de alertas, no solo toast efímero. Las alertas de riesgo
       deben ser visibles hasta que el Capitán las acuse (dismiss manual).

B. Función relacional (nueva — no implementar hasta que A esté estable):
4. [ ] Diseñar schema de "shadow relacional" — cómo Lola reporta patrones
       de interacción sin patologizarlos. Propuesta inicial de ChatGPT:
         - el Capitán elevó exigencia de fidelidad literal
         - el agente percibió riesgo de malentendido
         - apareció tensión entre concisión y exhaustividad
         - la instrucción implícita parecía ser continuidad, no exactitud formal
       Estos patrones van a un log separado ARGOS_LOLA_RELACIONAL_LOG.md,
       no al shadow log técnico.

5. [ ] Vista en dashboard para shadow relacional — separada del panel de riesgo técnico.
       Lectura orientada al Capitán, no a la tripulación.

SUCCESS_CRITERIA (fase A):
- Alertas de Lola incluyen patrones concretos, entradas afectadas y frecuencia
- Alertas persisten mínimo 5 segundos, con dismiss manual para alertas de riesgo
- Shadow_logs normalizados antes del escaneo

SUCCESS_CRITERIA (fase B):
- Lola puede emitir un reporte relacional semanal legible por el Capitán
- El reporte describe patrones de interacción sin juicios de valor
- El Capitán puede responder: "¿qué tipo de Capitán soy cuando estoy bajo presión?"

OUT_OF_SCOPE:
- Psicologización o juicio moral de las interacciones
- Análisis de shadow_log de sesiones anteriores al 2026-04-24 (arranque limpio)
- Automatización de ingesta de shadows externos (OpenClaw, packet separado)

NOTA:
LOLA-RISK-1776424632454 era una alerta activa de estrés nivel 20 emitida el 2026-04-17.
Se absorbe en este packet. El Capitán puede revisarla como dato histórico pero no
requiere acción separada — el motor de Lola la generó y está registrada.

TOKENS_SPENT: 0
[/WORK_PACKET]
