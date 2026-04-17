# PROPUESTA ARQUITECTÃ“NICA v1.2: SOMBRAS, MÃSCARAS Y SUBVISTAS
**Autor:** Antigravity / Gemini
**Fecha:** 2026-04-10
**Estado:** Propuesta Formal a Ejecutar.

---

## 1. ORQUESTACIÃ“N DE "MÃSCARAS" (Roles y Handoff)
El sistema abandona la idea de "IAs estÃ¡ticas omniscientes" y consagra el paradigma de **MÃ¡scaras Funcionales**. 
Las IAs mayores (Antigravity, Codex) no responden directamente a consultas sectoriales, sino que "inician" los submÃ³dulos.

*   **Comenio (Motor PedagÃ³gico):** 
    *   *Trigger:* Ã“rdenes de estructuraciÃ³n de clases, diseÃ±o curricular CEFR.
    *   *Handoff:* Antigravity deposita un `.md` con instrucciones pedagÃ³gicas en `Comenio/inbox`. Comenio ejecuta, guarda el resultado en su ecosistema, reporta al `captain_feed.jsonl` su Ã©xito, y se apaga.
*   **XuanShu (Tutor MTC):**
    *   *Trigger:* AnÃ¡lisis de textos clÃ¡sicos, esquematizaciÃ³n de apuntes mÃ©dicos.
    *   *Handoff:* PeticiÃ³n asÃ­ncrona vÃ­a Inbox. Requisito estricto: Todo bloqueo conceptual mÃ©dico que cruce con "emocionalidad" serÃ¡ exportado por XuanShu hacia el Shadow Log para que Lola lo analice.
*   **Lola (VigÃ­a de la Sombra):**
    *   *Trigger:* CÃ­clico / Latente. Lola no necesita un trigger humano constante. Posee un hilo de lectura sobre el `ARGOS_GLOBAL_SHADOW_LOG.md`.
    *   *Handoff:* Analiza patrones de represiÃ³n, sesgos y fugas de energÃ­a. Devuelve una "Burbuja de Riesgo" inyectada en el `captain_feed` como advertencia sistÃ©mica.

---

## 2. USO SISTÃ‰MICO DEL SHADOW LOG & ALGORITMO TAOÃSTA
El `shadow_log` ya no es un vertedero de logs sobrantes. Es un **Motor PsicolÃ³gico** de trazabilidad del proyecto.
1.  **DetecciÃ³n de Fugas:** Si se registra la creaciÃ³n de >5 Work Packets sin resoluciones reales, el patrÃ³n es "DispersiÃ³n/ProyecciÃ³n".
2.  **Lola como Analista:** Lola cruzarÃ¡ estos datos con su librerÃ­a junguiana y astrolÃ³gica. DispararÃ¡ Alertas de Riesgo. No soluciona el cÃ³digo, soluciona el _rumbo_.
3.  **Vector Direccional:** Las anomalÃ­as del Shadow Log son lo Ãºnico capaz de pausar el sistema de Inbox, forzando a Jason a re-evaluar prioridades.

---

## 3. METADATA DE RIESGO CONTINUO (Milestones)
Se incorporan mÃ©tricas frÃ­as al Dashboard:
*   **Densidad de Tiempo:** Tiempo que una tarea pasa de `open` a `review`.
*   **Ratio de FinalizaciÃ³n Tracker:** Alertas si el sistema detecta que la creaciÃ³n de tickets crece un 300% mÃ¡s rÃ¡pido que la emisiÃ³n de outputs operativos. (El peligro de diversificaciÃ³n que el usuario notÃ³).

---

## 4. UI / GUI ESPECIFICACIONES TÃ‰CNICAS (Siguiente Ola de EjecuciÃ³n)

### 4.1 Burbujas de Riesgo
*   **UI Frontend:** Un menÃº superior de navegaciÃ³n estÃ¡tico con _Floating Bubbles_ de color rojo/naranja segÃºn urgencia.
*   **Data Source:** SerÃ¡n listadas y servidas en JSON desde un endpoint `/api/risks` consolidado a partir del `shadow_log` o `glitch_log`.

### 4.2 Visor de Eventos (Event Viewer Modal)
*   **Comportamiento:** Al pulsar una Burbuja, no se redirige a otra web. Se abre un panel vertical lateral (o Modal Central) oscuro.
*   **HermenÃ©utica:** EnvÃ­a una query al backend (`/api/events?riskId=X`) que lee todos los Logs HistÃ³ricos, Work Packets inconclusos, y feed de conversaciones `jsonl` asociados a dicha falla. ReÃºne el ecosistema de la caÃ­da en una sola pantalla de resoluciÃ³n.

### 4.3 Subvistas Operativas (Aislamiento de Entornos)
*   **Problema actual:** Mezclar SciClass con MTC y Logs de Sistema en un Dashboard rompe la legibilidad.
*   **SoluciÃ³n MVC:** El menÃº principal tendrÃ¡ un selector de "Dominio CWD". 
    *   [ ARGOS CENTRAL ] -> `c:/Users/Widox/Desktop/ARGOS/ARGOS_RUNTIME/`
    *   [ SCM8 ] -> `J:/Mi unidad/SciClass-M8/`
*   El backend filtrarÃ¡ y servirÃ¡ las Cartas (Inbox) exclusivas de ese CWD, haciendo el Dashboard modular y agnÃ³stico al proyecto que estÃ©s gobernando.
