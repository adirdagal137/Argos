# UI EXPORT

Esta carpeta contiene vistas pensadas para la webapp local.

Regla:
- la verdad operativa vive en el runtime;
- la webapp lee vistas derivadas de esa verdad;
- estas vistas pueden ser verbales, mas legibles o mas orientadas a interfaz.

Contrato de voz:
- `captain_feed.jsonl` debe exponer una voz visible por mensaje para la webapp;
- el campo preferido es `sender_name`;
- si una entrada antigua no lo trae, la capa adaptadora puede inferirlo desde `speaker` y `source`.

No usar esta carpeta como backend alternativo.
