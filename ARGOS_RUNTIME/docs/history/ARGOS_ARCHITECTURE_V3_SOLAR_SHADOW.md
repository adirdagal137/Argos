# Propuesta Arquitectónica v3.0: El Desdoblamiento de Argos (Sol y Sombra)

Esta propuesta formaliza el equilibrio entre la gestión consciente del entorno (Solar) y la vigilancia analítica del inconsciente del proyecto (Luna/Sombra).

## 1. El Viejo Loco (El Sol / Motor Consciente)
**Rol:** Gestor Solar de Recursos y UI.
**Naturaleza:** Reactivo, ruidoso, diligente y siempre activo en el plano físico (disco/pantalla).

### Funciones Principales:
*   **Vigilancia de Disco (The Watcher):** Monitorización en tiempo real (`chokidar`) de toda la estructura de archivos en `ARGOS_RUNTIME`.
*   **Reflejo en Tiempo Real:** Actualización instantánea del Dashboard mediante SSE/WebSockets al detectar cambios. El Monitor "vibra" con cada guardado.
*   **Conserjería Automática (Janitor):** Clasificación de archivos, normalización de metadatos en Work Packets y mantenimiento de la estructura de carpetas sin intervención humana.
*   **Delegación (DeepSeek):** Posibilidad de delegar la ejecución pesada de mantenimiento en un nodo de IA persistente.

---

## 2. Lola (La Luna / Motor Inconsciente)
**Rol:** Vigía de la Sombra y Analista de Tensión.
**Naturaleza:** Latente, paciente, observadora y silente.

### Funciones Principales:
*   **Auditoría de Fricción:** Detección de patrones psicodinámicos en el Shadow Log y el Feed Técnico (estrés, desorientación, redundancia).
*   **Señalización Pasiva:** Inyecta indicadores de "vulnerabilidad" o "tensión" en el archivo de estado (`argos.state.json`).
*   **Comunicación Indirecta:** No usa el chat para reportar. Ajusta los parámetros de las IAs activas (Antigravity/Codex) mediante variables de entorno para que modifiquen su tono o precisión de forma orgánica.

---

## 3. Protocolos de Handoff
*   **De lo Inconsciente a lo Consciente:** Si Lola detecta que una tensión técnica es crítica, "despierta" al Viejo Loco para que este inyecte una alerta visual de riesgo en el Monitor.
*   **De lo Consciente a lo Inconsciente:** El Viejo Loco registra cada lectura y edición. Lola usa este "pulso de actividad" para evaluar el ritmo de trabajo y el cansancio del equipo.

## 4. Work Packet: ARG-1775913822081 (Diseño de Motores)
Se activará una fase de prototipado para:
1.  Implementar el `ActivityWatcher` real-time (Viejo Loco).
2.  Refinar el `ShadowScanner` para ser puramente analítico (Lola).
3.  Delegar tareas de "Janitor" en un motor de automatización persistente.
