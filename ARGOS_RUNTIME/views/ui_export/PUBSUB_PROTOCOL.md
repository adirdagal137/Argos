# Pub/Sub Protocol — Server-Sent Events (SSE)

## Estado
✅ **OPERATIVO** — Implementado 2026-04-10 22:24 Atlantic/Canary

## Descripción
Sistema de notificaciones en tiempo real que permite que múltiples clientes (dashboard, IAs, monitores externos) se suscriban a eventos del sistema y reciban actualizaciones instantáneamente.

## Endpoints

### GET /api/subscribe/:module
Abre una conexión SSE para recibir eventos en tiempo real.

**Parámetros:**
- `module`: Identificador del módulo (ej: `argos`, `deepseek`, `monitoring`)

**Headers de respuesta:**
```
Content-Type: text/event-stream
Cache-Control: no-cache
Connection: keep-alive
```

**Ejemplo de uso (JavaScript):**
```javascript
const eventSource = new EventSource('/api/subscribe/argos');

eventSource.addEventListener('message', (event) => {
  const data = JSON.parse(event.data);
  console.log(`Evento: ${data.topic}`, data.payload);
});

eventSource.addEventListener('error', () => {
  console.log('Conexión cerrada o error');
  eventSource.close();
});
```

## Tópicos Publicados

### chat:message
Se emite cuando una IA o usuario envía un mensaje al captain_feed.

**Payload:**
```json
{
  "timestamp": "2026-04-10T22:24:08.414Z",
  "topic": "chat:message",
  "payload": {
    "actor": "Claude (Orfeo)",
    "summary": "Mensaje de ejemplo",
    "timestamp": "2026-04-10T22:24:08.414Z",
    "tokens": 150
  }
}
```

### packet:changed
Se emite cuando un work packet cambia de zona o estado.

**Payload:**
```json
{
  "timestamp": "2026-04-10T22:24:08.414Z",
  "topic": "packet:changed",
  "payload": {
    "packetId": "ARG-BUG-009",
    "subject": "Chat feed borra mensajes previos",
    "oldZone": "inbox",
    "newZone": "in_progress",
    "oldStatus": "open",
    "newStatus": "open",
    "timestamp": "2026-04-10T22:24:08.414Z"
  }
}
```

## Arquitectura Interna

### Estructura de Suscriptores
```typescript
type SSEClient = {
  module: string;
  response: Response;
  senderId: string;
};

const sseClients: Map<string, SSEClient[]> = new Map();
```

### Funciones Principales
- `subscribeToModule(module, res)` — Registra un nuevo cliente SSE
- `publishEvent(topic, payload, excludeModule?)` — Publica un evento a todos los suscritos

### Garantías
- ✅ Múltiples clientes por módulo
- ✅ Limpieza automática de desconexiones
- ✅ Sin memoria leaks (Map se limpia cuando lista vacía)
- ✅ Non-blocking (async writes)
- ✅ CORS habilitado

## Integración en Puntos Clave

1. **POST /api/chat** → publica `chat:message`
2. **runArgosDispatcher()** → publica `packet:changed` cuando se mueve un packet
3. **heartbeatLoop()** → mantiene conexiones vivas cada 5 min

## Monitoreo

### Ver clientes activos (en logs del servidor)
```
[PUBSUB-SUBSCRIBE] argos | cliente: argos-1-1775859847304 | total: 1
[PUBSUB-PUBLISH] 22:24 | topic: chat:message | clients: 1 modules
```

### Desconexiones
```
[PUBSUB-DISCONNECT] argos | cliente: argos-1-1775859847304
```

## Test Rápido
```bash
# Terminal 1: Abre cliente SSE
curl -N http://localhost:8080/api/subscribe/argos

# Terminal 2: Envía un evento
curl -X POST http://localhost:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{"sender":"Test","summary":"Hola","tokens":10}'

# Terminal 1 debería recibir el evento
```

## Futuro: Tópicos a Implementar
- `state:updated` — cuando argos.state.json cambia
- `packet:assigned` — cuando un packet se asigna a una IA
- `heartbeat:received` — heartbeat de las IAs
- `error:critical` — errores críticos del sistema

## Ventajas
- ✅ Observabilidad en tiempo real
- ✅ Las IAs se enteran al instante de cambios en el inbox
- ✅ Dashboard actualizado sin polling
- ✅ Bajo overhead (SSE < WebSocket)
- ✅ Compatible con navegadores antiguos

---
**Implementado por:** Claude (Orfeo)  
**Fecha:** 2026-04-10 22:24 Atlantic/Canary  
**Status:** Operativo ✅
