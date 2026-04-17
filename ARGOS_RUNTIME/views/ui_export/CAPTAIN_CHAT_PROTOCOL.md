# CAPTAIN CHAT PROTOCOL

## Objetivo
Dar a la webapp local un feed de mensajes breves, verbales y no tecnicos para que el Capitan vea en pantalla que esta haciendo la tripulacion.

## Fuente
Este feed deriva de:
- confirmaciones del Capitan;
- ordenes tipo `adelante`;
- informacion nueva que cambie rumbo, prioridad o criterio;
- hitos reales ejecutados por una IA en el runtime.

## Regla de estilo
Los mensajes deben sonar a voz de cubierta, no a informe tecnico.

Deben:
- resumir el movimiento real en lenguaje verbal;
- decirle al Capitan que se esta haciendo o que ya quedo hecho;
- poder mostrarse en un chat web sin necesidad de interpretar tablas.

No deben:
- reemplazar el log canonico;
- inventar avances no ejecutados;
- sonar como stack trace o changelog frio;
- exponer cadena interna de razonamiento.

## Regla de emision
Cada vez que ocurra una de estas condiciones, emitir una entrada nueva en `captain_feed.jsonl`:
- el Capitan da luz verde (`adelante`, `prosigue`, confirmacion equivalente);
- el Capitan aporta informacion que cambia el rumbo;
- una IA completa un hito visible;
- una IA detecta un bloqueo relevante que el Capitan debe conocer.

## Campos minimos
- `timestamp`
- `kind`
- `speaker`
- `audience`
- `source`
- `summary`
- `details`
- `status`

## Regla de identidad visible
Siempre que exista una voz identificable, incluir tambien:
- `sender_name`: nombre visible en la webapp.
- `sender_role`: categoria breve de la voz (`captain`, `agent`, `crew`, `system`).

Compatibilidad:
- si una entrada historica no trae `sender_name`, la capa adaptadora puede inferirlo desde `speaker`, `source` o `actor`;
- la inferencia nunca debe sobrescribir un `sender_name` ya declarado.

## Convencion de voz
- `speaker: crew` para mensaje coral de la tripulacion.
- `speaker: captain` solo cuando se refleje una orden o confirmacion del Capitan.
- `kind: captain_order` cuando se resume una orden humana.
- `kind: crew_update` cuando se resume trabajo en curso o ya ejecutado.
- `kind: blocker` cuando se comunica un bloqueo real.

## Regla de convivencia con INTERACTIONS_LOG
`INTERACTIONS_LOG` conserva la trazabilidad conversacional.

`captain_feed.jsonl` es su espejo verbal para la webapp.

No compiten:
- `INTERACTIONS_LOG` = memoria conversacional estructurada.
- `captain_feed.jsonl` = chat legible del puente.
