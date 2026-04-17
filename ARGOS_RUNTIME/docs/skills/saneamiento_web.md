# SKILL: SANEAMIENTO WEB (Argos Webapp Sanitization)

Esta skill define el protocolo para mantener la salud operativa y visual del Navío Argos Dashboard.

## Objetivos
1.  **Sincronización Total**: Asegurar que todos los repositorios "vivos" (GitHub) estén actualizados.
2.  **Integridad de Datos**: Refrescar el estado de la API para reflejar cambios en el sistema de archivos local.

## Protocolo de Ejecución

### 1. Sincronización de Fuentes (GitHub)
- Acceder a la pestaña **Fuentes (@)** en el dashboard.
- Ejecutar el comando de sincronización para cada repositorio detectado.
- Si se detectan conflictos, priorizar siempre el estado remoto o notificar al Capitán.

### 2. Saneamiento de Logs y Bitácora
- Ejecutar `merge_argos_history.ps1` (o su equivalente en Node) para compactar los logs del día.
- Verificar que no existan errores de encoding (mojibake) en las entradas recientes.
- Si existen "Glitches" registrados, marcarlos como revisados si ya no son relevantes.

### 3. Refresco de Vector y Work Packets
- Asegurar que el `argos.state.json` refleje exactamente el contenido de `work_packets/`.
- Limpiar la carpeta `trash/` si excede los 50 elementos para mantener la higiene del disco.

## Automatización
Para ejecutar esta skill de forma rápida, el agente puede invocar los endpoints de la API:
- `GET /api/sources` seguido de `POST /api/sources/sync` para cada fuente.
- Invocación de `sync_state` vía API para refrescar el estado global.
