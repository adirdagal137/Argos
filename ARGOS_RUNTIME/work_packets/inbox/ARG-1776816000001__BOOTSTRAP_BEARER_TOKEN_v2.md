[WORK_PACKET]
ID: ARG-1776816000001
ROLE_REQUESTED: Codex
SUBJECT: Bootstrap — aceptar Bearer token además de X-Argos-Agent-Token
STATUS: open
PRIORITY: P1
ROOM: ARGOS
TYPE: build
CREATED_AT: 2026-04-22 Atlantic/Canary
AUTHORED_BY: Claude + ChatGPT (diagnóstico conjunto)

## Contexto

ChatGPT accede a /api/bootstrap via GPT Actions, que envía el token como:
  Authorization: Bearer <token>

El endpoint actual solo lee X-Argos-Agent-Token. Resultado: 401 para ChatGPT
aunque el token sea válido. Claude accede con curl y puede pasar headers
arbitrarios — por eso funciona. ChatGPT no tiene esa flexibilidad.

Adicionalmente: herramientas web (incluyendo la de ChatGPT) no pueden inyectar
headers personalizados ni ngrok-skip-browser-warning. Por tanto, ?token= como
fallback de query param es también necesario para diagnóstico y acceso desde
navegador.

## Implementación

Añadir esta función al inicio del handler (o como helper compartido si otros
endpoints necesitan el mismo patrón en el futuro):

```typescript
function extractAgentToken(req: Request): string | null {
  const auth = req.get("authorization");
  const bearer =
    auth && auth.startsWith("Bearer ")
      ? auth.slice("Bearer ".length).trim()
      : null;

  const xArgos = req.get("x-argos-agent-token")?.trim() || null;
  const xBootstrap = req.get("x-bootstrap-token")?.trim() || null;
  const queryToken =
    typeof req.query.token === "string" ? req.query.token.trim() : null;

  return bearer || xArgos || xBootstrap || queryToken;
}
```

Aplicar al handler de /api/bootstrap:

```typescript
app.get("/api/bootstrap", async (req, res) => {
  const auth = req.get("authorization");
  const hasBearer = Boolean(auth?.startsWith("Bearer "));
  const hasXArgos = Boolean(req.get("x-argos-agent-token"));
  const hasXBootstrap = Boolean(req.get("x-bootstrap-token"));
  const hasQuery = typeof req.query.token === "string";

  const token = extractAgentToken(req);

  if (!token || !isValidAgentToken(token)) {
    console.log("[BOOTSTRAP AUTH FAIL]", { hasBearer, hasXArgos, hasXBootstrap, hasQuery });
    return res.status(401).json({
      ok: false,
      error: "Unauthorized",
      accepted_auth: [
        "Authorization: Bearer <token>",
        "X-Argos-Agent-Token: <token>",
        "X-Bootstrap-Token: <token>",
        "?token=<token>"
      ]
    });
  }

  return res.json({ /* payload existente */ });
});
```

Donde isValidAgentToken() es la función de validación actual — solo cambia
cómo se extrae el token, no cómo se valida.

## Prioridad de formatos (para documentar en INTER_AI_PROTOCOL)

1. Authorization: Bearer <token>  — agentes cloud (ChatGPT Actions, futuras integraciones OAuth)
2. X-Argos-Agent-Token: <token>  — agentes locales y Claude con curl (compatibilidad actual)
3. X-Bootstrap-Token: <token>    — alternativa explícita para bootstrap
4. ?token=<token>                — fallback para diagnóstico y navegador

## Alcance

- Aplicar a /api/bootstrap mínimo.
- Evaluar si extractAgentToken() se aplica como middleware global — si el cambio
  es trivial y no hay riesgo de regresión, hacerlo de una vez.
- NO cambiar los tokens existentes ni la lógica de validación posterior.

## Verificación post-deploy

Una vez desplegado, el Capitán pega esta URL en el chat de ChatGPT para
confirmar acceso:

  https://aids-prevail-unguarded.ngrok-free.dev/api/bootstrap?token=<token-chatgpt>

Si devuelve JSON con ok: true, el canal ChatGPT↔API queda establecido.

## Criterio de DONE

- ChatGPT puede llamar a /api/bootstrap con Authorization: Bearer y recibe bootstrap.
- ChatGPT puede llamar con ?token= y recibe bootstrap.
- Claude y Codex siguen funcionando con X-Argos-Agent-Token (sin regresión).
- 401 devuelve lista de formatos aceptados (útil para debugging futuro).
- npm run build + node --check OK.
[/WORK_PACKET]
