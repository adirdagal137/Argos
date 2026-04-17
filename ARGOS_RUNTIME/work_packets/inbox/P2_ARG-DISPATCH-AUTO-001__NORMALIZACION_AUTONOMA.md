[WORK_PACKET]
ID: ARG-DISPATCH-AUTO-001
TYPE: task
TAG: future_dev
SUBJECT: ImplementaciÃ³n de Sistema de Cuarentena y ReparaciÃ³n en el Despachador
OWNER: Antigravity
STATUS: open
REPORTED_BY: Antigravity (a peticion del Capitan)
REPORTED_AT: 2026-04-10 16:48

[OBJETIVO]
Dotar al Motor AutÃ³nomo (Despachador) de la capacidad de gestionar archivos que no solo carecen de metadatos, sino que son ilegibles o "basura" sistÃ©mica.

[ESPECIFICACIONES]
1. Crear carpeta `c:\Users\Widox\Desktop\ARGOS\ARGOS_RUNTIME\work_packets\quarantine\`.
2. Si el despachador encuentra un archivo `.md` en el inbox que estÃ¡ vacÃ­o o malformado tras intentar repararlo, debe moverlo a la carpeta de cuarentena.
3. Notificar al CapitÃ¡n mediante una burbuja de riesgo exclusiva: "Archivos en cuarentena detectados".

[COMENTARIOS]
Postergado por orden directa del CapitÃ¡n para priorizar la estabilidad de las alertas de Lola.
