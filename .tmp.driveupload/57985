[WORK_PACKET]
ID: ARG-UI-DELETE-TASKS
TYPE: task
TAG: ui, ordenes, deletion
ROLE_REQUESTED: Claude / Orfeo
SUBJECT: Agregar funcionalidad de borrado a Ã“rdenes Pendientes con selector y confirmaciÃ³n
PRIORITY: P2
STATUS: done
CREATED_AT: 2026-04-11T00:50 Atlantic/Canary
CREATED_BY: Claude (Orfeo)
TOKENS_SPENT: 1850
COMPLETED_AT: 2026-04-11T00:55 Atlantic/Canary

---

## OBJETIVO

Implementar UI de borrado para Ã“rdenes Pendientes:
- Checkbox selector individual por tarea
- Checkbox "Seleccionar Todo"
- Contador de seleccionados
- BotÃ³n "Borrar Seleccionadas"
- Modal de confirmaciÃ³n con vista previa
- Traslado de tareas a carpeta `/trash` en el filesystem

---

## IMPLEMENTACIÃ“N

### 1. Backend â€” Nuevo Endpoint (index.ts:1829-1907)

`POST /api/tasks/delete`

```typescript
{
  "taskIds": ["ARG-123456", "ARG-789012"]
}
```

Funcionalidad:
- Busca tareas en: inbox, in_progress, done
- Copia archivo a `work_packets/trash/`
- Elimina archivo original
- Registra evento en captain_feed.jsonl
- Respuesta: `{ status: "ok", movedCount: N, movedFiles: [...], notFound: [...] }`

Manejo de errores:
- Carpeta trash creada automÃ¡ticamente si no existe
- ContinÃºa si algÃºn archivo no se encuentra
- Registra intentos fallidos en logs

### 2. Frontend â€” HTML (index.html)

**Toolbar de selecciÃ³n** (lÃ­nea 135-147):
```html
<div class="task-toolbar" id="task-toolbar">
  <div class="toolbar-left">
    <label class="checkbox-container">
      <input type="checkbox" id="select-all-tasks" />
      <span>Seleccionar Todo</span>
    </label>
    <span class="selection-counter" id="selection-counter" style="display:none;">
      <span id="selected-count">0</span> seleccionadas
    </span>
  </div>
  <div class="toolbar-right">
    <button class="btn btn-danger" id="btn-delete-tasks" style="display:none;">
      <span class="btn-icon">X</span> Borrar Seleccionadas
    </button>
  </div>
</div>
```

**Modal de confirmaciÃ³n** (lÃ­nea 1290-1310):
- Muestra lista de tareas a borrar
- Cuenta dinÃ¡micamente
- Botones: Cancelar, Borrar
- Cierre con X

### 3. Frontend â€” CSS (styles.css)

**Toolbar:**
- `.task-toolbar` â€” flex layout, border-bottom
- `.checkbox-container` â€” estilo limpio, user-select: none
- `.selection-counter` â€” contador visual con separador
- `.btn-danger` â€” rojo 20% opacidad, rojo 30% en hover

**Task Items:**
- `.task-checkbox` â€” elemento flotante antes de task-info
- `.task-item.selected` â€” fondo azul 15%, borde azul
- `.task-item` â€” transiciÃ³n smooth en estado selected

**Modal de confirmaciÃ³n:**
- `.delete-modal` â€” ancho 500px max
- `.task-delete-list` â€” lista scrolleable con fondo oscuro
- `.task-delete-item` â€” rojo 10% opacidad, rojo border-left
- `.modal-footer` â€” flex right-aligned con botones

### 4. Frontend â€” JavaScript (app.js)

**Variables de estado** (lÃ­nea 37-38):
```javascript
let selectedTasks = new Set();  // IDs de tareas seleccionadas
let pendingTasks = [];           // Cache de tareas visibles
```

**FunciÃ³n updateTaskSelection()** (lÃ­nea 350-379):
- Actualiza contador visual
- Muestra/oculta botones segÃºn selecciÃ³n
- Sincroniza checkbox "Seleccionar Todo" (checked/indeterminate)
- Aplica clase `.selected` a items

**FunciÃ³n renderTasks() modificada** (lÃ­nea 381-468):
- Agrega `<input type="checkbox" class="task-checkbox">` a cada item
- Event listener: agrega/quita de selectedTasks
- Click en task abre hermenÃ©utica (si no es el checkbox)
- Almacena pendingTasks en variable global

**Modal de confirmaciÃ³n** (lÃ­nea 1271-1344):
- `openDeleteConfirmation()` â€” renderiza lista de tareas
- `closeDeleteConfirmation()` â€” cierra modal
- `confirmDelete()` â€” POST /api/tasks/delete, reload, toast
- Event listeners para botones y "Seleccionar Todo"

### 5. Carpeta Trash

Nueva carpeta creada:
- `c:/Users/Widox/Desktop/ARGOS/ARGOS_RUNTIME/work_packets/trash/`
- AlojarÃ¡ archivos eliminados (no borrados permanentemente)
- Permite recuperaciÃ³n futura
- OrganizaciÃ³n separada de `archived/`

---

## FLUJO DE UX

1. Usuario abre "Ã“rdenes Pendientes"
2. Ver checkbox individual por orden
3. Clic en checkbox â†’ selecciona orden
4. Clic en "Seleccionar Todo" â†’ selecciona todas (o deselecciona)
5. Contador muestra cantidad seleccionada
6. BotÃ³n "Borrar Seleccionadas" aparece cuando hay selecciÃ³n
7. Clic en botÃ³n â†’ abre modal de confirmaciÃ³n
8. Modal muestra lista de IDs y tÃ­tulos a borrar
9. Clic "Cancelar" â†’ cierra modal (nada ocurre)
10. Clic "Borrar" â†’ POST /api/tasks/delete
11. Toast confirma: "âœ“ N orden(es) movida(s) a papelera"
12. Lista se refresca automÃ¡ticamente (hydrate)
13. Tareas desaparecen de la vista

---

## COMPILACIÃ“N & VERIFICACIÃ“N

âœ… TypeScript compila sin errores
```bash
npm run build  # exitoso
```

âœ… JavaScript sintaxis correcta
```bash
node -c app.js  # âœ“ Sintaxis correcta
```

âœ… HTML vÃ¡lido (sin errores de cierre)
âœ… CSS vÃ¡lido (sin errores de sintaxis)

---

## NOTAS TÃ‰CNICAS

**Seguridad:**
- taskIds validadas como array no-vacÃ­o
- BÃºsqueda de archivos en directorios especÃ­ficos
- Sin ejecuciÃ³n de comandos shell
- Sin acceso directo a filesystem desde cliente

**Performance:**
- selectedTasks es Set (O(1) lookup)
- updateTaskSelection() solo recalcula UI cuando cambia
- Modal renderizado on-demand
- Evento POST tiene timeout implÃ­cito vÃ­a fetch

**Compatibilidad:**
- EventSource para SSE (nativo en todos los navegadores modernos)
- Fetch API (no soporta IE11, OK para dashboard moderno)
- CSS Grid/Flex ampliamente soportado

**UX:**
- Toast confirma acciÃ³n completada
- Modal muestra vista previa
- Contador en tiempo real
- Desaparece de lista inmediatamente post-borrado
- Archivos recuperables en carpeta /trash

---

## PRÃ“XIMOS PASOS (FUTURO)

1. **UI de papelera:**
   - PestaÃ±a "Papelera" en navbar
   - Mostrar tareas eliminadas
   - Botones: Restaurar, Borrar permanentemente

2. **Limpieza automÃ¡tica:**
   - Script que borre tareas en /trash mÃ¡s antiguas de 30 dÃ­as
   - Implementar como cron job

3. **Batch operations:**
   - Seleccionar mÃºltiples en bugs, bitÃ¡cora, etc.
   - Aplicar patrÃ³n a otras secciones

4. **Undo:**
   - Implementar undo de Ãºltimas N operaciones
   - Usar SSE para anunciar deshacer a todos los agentes

---

## TESTING MANUAL

Una vez servidor reiniciado:

1. **Abrir Ã“rdenes Pendientes** â†’ debe mostrar toolbar
2. **Marcar checkbox** â†’ contador aparece, botÃ³n se muestra
3. **"Seleccionar Todo"** â†’ todos marked, botÃ³n activo
4. **Clic en "Borrar Seleccionadas"** â†’ modal abre
5. **Verificar lista en modal** â†’ IDs y tÃ­tulos correctos
6. **Clic "Cancelar"** â†’ modal cierra, tareas siguen visibles
7. **Abrir modal nuevamente, clic "Borrar"** â†’ toast aparece
8. **Verificar papelera** â†’ archivos en `work_packets/trash/`
9. **Actualizar pÃ¡gina** â†’ tareas desaparecidas de lista
10. **Verificar captain_feed.jsonl** â†’ evento de borrado registrado

---

## ARCHIVOS MODIFICADOS

1. âœ… `C:\Users\Widox\.gemini\antigravity\scratch\argos-dashboard\index.html`
   - Toolbar y modal agregados

2. âœ… `C:\Users\Widox\.gemini\antigravity\scratch\argos-dashboard\styles.css`
   - Estilos toolbar, checkbox, modal, delete-item (146 lÃ­neas nuevas)

3. âœ… `C:\Users\Widox\.gemini\antigravity\scratch\argos-dashboard\app.js`
   - Variables de estado, updateTaskSelection(), renderTasks() modificado, manejadores de modal (157 lÃ­neas nuevas)

4. âœ… `C:\Users\Widox\.gemini\antigravity\scratch\argos-api\src\index.ts`
   - Nuevo endpoint POST /api/tasks/delete (79 lÃ­neas nuevas)

5. âœ… `c:/Users/Widox/Desktop/ARGOS/ARGOS_RUNTIME/work_packets/trash/`
   - Nueva carpeta de papelera creada

---

## ESTADO FINAL

**Listo para:** Reinicio del servidor y prueba en el dashboard

**CÃ³digo:** Compilado, sin errores de sintaxis, sin breaking changes

**UI:** Integrado con estilos existentes, responsive (mobile-friendly)

**Backend:** Endpoint robusto con manejo de errores
