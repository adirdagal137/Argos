# ARGOS VECTOR - HOJA DE RUTA
**Actualizado:** 2026-04-11 22:35 Atlantic/Canary

## OBJETIVOS DIARIOS (2026-04-11)
- [x] ORDEN EJECUTIVA TOKENS — Panel solo WORK_TOKENS + cierre obligatorio con process/trilog/chat tokens (2026-04-11)
- [~] Estabilizar ciclo log-shadow-realidad â€” Sincronizado estado 'restricted' en API/UI (2026-04-11)
- [x] Contador de tokens actualiza en tiempo real â€” ARG-1775828525682 / ARG-TOKEN-AUTO-001 (Verificado via SSE)
- [ ] ARG-SHADOW-SYNTHESIS-001 â€” SÃ­ntesis del shadow log para que Lola opere bien

## OBJETIVOS SEMANALES (EN CURSO)
- [ ] Integrar MÃ³dulos SciClass-M8 (Comenio) â€” NO INICIADO
- [~] Refinar sistema de "MÃ¡scaras" (Handoff entre IAs) â€” observar emergencias (SISTEMA-ARGOS, Argos-Dispatcher)
- [ ] ARG-COMMS-005 â€” Inbox observado en tiempo real
- [ ] Antigravity encoding espaÃ±ol â€” mojibake en tildes persiste

## OBJETIVOS GENERALES (LARGO PLAZO)
- [~] Consolidar Argos como Orquestador Multi-Agente agnÃ³stico â€” EN CURSO
- [x] Implementar Analista de la Sombra (Lola) asincrÃ³nico â€” HECHO
- [ ] Dashboard Modular con selecciÃ³n de Dominio CWD â€” NO INICIADO
- [~] Deepseek como 4Âº tripulante (GuardiÃ¡n de Eficiencia) â€” GGUF Descarga ~72% (ETR ~8m)

## BLOCKERS IDENTIFICADOS (2026-04-11)
1. **Enforcer Tri-Log demasiado estricto** â€” dispara blocker por packet individual, no por sesiÃ³n. Genera ruido en SISTEMA-ARGOS.
2. [x] **Tokens no actualizan en tiempo real** â€” RESUELTO via SSE 'tokens:updated'
3. **Exports stale** â€” snapshots de logbook no se regeneran automÃ¡ticamente (ARGOS-NOTE-0001)

## DEUDA TÃ‰CNICA
- Tokens: solo estimaciÃ³n por chars, no conteo real de la API (ARG-TOKEN-AUTO-001)
- Transcripts: captura literal del chat no automatizada (ARG-1775791234000)
- Legibilidad: columnas legacy estrechas (ARGOS-NOTE-0002)
- Cuarentena: sin sistema para paquetes malformados (ARG-DISPATCH-AUTO-001)
