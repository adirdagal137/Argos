# ARGOS VECTOR — TIMÓN VIVO
**Actualizado:** 2026-04-18 13:00 Atlantic/Canary
**Responsable de actualización:** Claude / Orfeo

---

## FOCO ACTUAL
Establecer el canal de comunicación directa Claude↔API (tunnel + remote/closure) y cerrar la deuda arquitectónica B1-B2-B3 antes de ampliar funcionalidad.

---

## PRIORIDADES VIVAS

1. **Canal remoto operativo** — tunnel funcionando, script de arranque probado, `cloudflared.quick.json` escribiendo URL. Falta: desbloquear web_fetch al inicio de sesión con un paso manual mínimo. → Capitán + Claude
2. **ARGOS-ARCH-0004** — Decisión pendiente del Capitán: ¿la webapp escribe en ARGOS_RUNTIME o es solo lectura? Bloquea el diseño de endpoints de escritura. → Capitán decide
3. **ARGOS-ARCH-0005** — Pendiente Codex (in_progress). Depende parcialmente de ARCH-0004.
4. **ARGOS-UI-0001** — Pendiente Antigravity. El explorador de archivos en la UI está bloqueado (traductor físico no montado).
5. **ARGOS_VECTOR.md desactualizado** — Este archivo. Se resuelve con este commit. ✓

---

## BLOCKERS REALES

- **ARCH-0004 sin decidir** — hasta que el Capitán decida si la webapp escribe o solo lee, no se diseñan endpoints de escritura definitivos.
- **web_fetch limitado** — Claude no puede construir URLs propias para hacer POST al tunnel; requiere que el Capitán pegue la URL una vez por sesión. Mitigado con `cloudflared.quick.json` + Drive MCP.
- **Explorador de archivos bloqueado en UI** — Node no tiene el módulo de filesystem montado. Antigravity tiene el packet.

---

## DECISIONES VIGENTES

1. La carpeta local `C:\Users\Widox\Desktop\ARGOS` es la fuente de verdad — Drive for Desktop sincroniza automáticamente.
2. El tunnel Cloudflare es gratuito/temporal (URL cambia en cada reinicio). Script `quick_tunnel_start.ps1` gestiona el arranque y escribe la URL en `state/cloudflared.quick.json`.
3. Autenticación al API: header `X-Argos-Agent-Token` con token por agente. Token de Claude guardado en memoria de sesión.
4. `POST /api/remote/closure` es el endpoint principal de cierre de sesión para Claude — hace trilog + state + events en una sola llamada.
5. La distinción `INBOX_REVIEW / INBOX_EXECUTE` del sistema legacy no está implementada — riesgo activo registrado.

---

## PRÓXIMOS MOVIMIENTOS

1. Capitán decide **ARCH-0004** (webapp escribe vs. solo lee) — desbloquea a Codex y a Claude.
2. Codex cierra **ARGOS-ARCH-0005**.
3. Claude hace el primer POST real a `/api/remote/closure` para cerrar un packet y verificar el canal completo end-to-end.

---

## DEUDA VIVA (bloquea trabajo actual)

- Explorador de archivos en UI sin módulo filesystem (ARGOS-UI-0001)
- Transcripts: captura literal del chat no automatizada — Claude hace POST manual al cierre
- INBOX_REVIEW / INBOX_EXECUTE ausente del sistema nuevo (riesgo de migración activo)
- Token counting: estimación por chars, no conteo real de la API
