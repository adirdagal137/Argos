const API_URL = 'http://localhost:8080/api';

document.addEventListener('DOMContentLoaded', async () => {
    const statusSpan = document.getElementById('backend-status');
    const vectorContainer = document.getElementById('vector-container');
    const monitorInboxList = document.getElementById('monitor-inbox-list');
    const expandedTaskList = document.getElementById('expanded-task-list');
    const chatContainer = document.getElementById('chat-container');
    const tokenDisplay = document.getElementById('token-counter');
    const moduleTabs = document.getElementById('logbook-module-tabs');
    const streamTabs = document.getElementById('logbook-stream-tabs');
    const logbookMeta = document.getElementById('logbook-meta');
    const logbookHead = document.getElementById('logbook-head');
    const logbookBody = document.getElementById('logbook-body');
    const logbookTable = logbookHead ? logbookHead.closest('table') : null;
    const riskBar = document.getElementById('risk-bubbles-container');
    const activeMissionsCount = document.getElementById('active-missions-count');
    const activeAlertsCount = document.getElementById('active-alerts-count');
    const forestContainer = document.getElementById('view-bosque');
    const vellocinoContainer = document.getElementById('view-vellocino');
    const sourcesBody = document.getElementById('sources-body');

    const defaultTasks = [
        { id: 'ARG-M8-002', title: 'Mocks cargados por fallo de red', owner: 'Claude', status: 'open', time: 'Sin enlace' }
    ];

    const viewState = {
        moduleId: null,
        streamId: null,
        logbook: null
    };

    let expandedLogbookRow = null;
    let expandedEventRow = null;
    let forestLoaded = false;
    let vellocinoLoaded = false;
    let sourcesLoaded = false;

    // Task selection and deletion state
    let selectedTasks = new Set();
    let pendingTasks = [];
    let latestVisibleTasks = [];

    let currentProject = 'argos';
    let currentSubTarget = 'subview-ordenes';

    // Global raw data for filtering
    let allRawTasks = [];
    let allRawBugs = [];

    const navItems = document.querySelectorAll('.nav-item');
    const viewSections = document.querySelectorAll('.view-section');

    function activateView(targetId, clickedNav = null) {
        // Desactivar todas las secciones y navs
        viewSections.forEach((section) => section.classList.remove('active'));
        navItems.forEach((item) => item.classList.remove('active'));

        // Activar la secciÃƒÂ³n objetivo
        const target = document.getElementById(targetId);
        if (target) target.classList.add('active');

        // Activar el nav item correspondiente
        if (clickedNav) {
            clickedNav.classList.add('active');
        } else {
            // Intenta encontrar el nav item por targetId (usado en el arranque)
            // Para proyectos, esto siempre pillarÃƒÂ¡ el primero, pero es aceptable para el estado inicial
            const nav = document.querySelector(`.nav-item[data-target="${targetId}"]`);
            if (nav) nav.classList.add('active');
        }

        // Visibilidad de la barra de riesgos
        if (riskBar) {
            riskBar.style.display = (targetId === 'view-monitorizacion' || targetId === 'view-bugs') ? 'flex' : 'none';
        }
    }

    navItems.forEach((nav) => {
        nav.addEventListener('click', (event) => {
            event.preventDefault();
            const targetId = nav.getAttribute('data-target');
            
            if (nav.classList.contains('nav-project')) {
                currentProject = nav.getAttribute('data-project') || 'argos';
                viewState.moduleId = currentProject; // Sincronizar logbook tab
                
                const titleNode = document.getElementById('current-project-title');
                if (titleNode) {
                    titleNode.textContent = nav.textContent.trim().replace(/^#\s*/, '');
                }
                // Refilter things now that project changed
                renderTasks(allRawTasks);
                if (allRawBugs.length > 0) renderBugs(allRawBugs);
            }

            activateView(targetId, nav);
            
            if (targetId === 'view-project-container') {
                if (currentSubTarget === 'subview-bitacora' || targetId === 'view-bitacora') {
                    loadLogbookSnapshot();
                }
            } else if (targetId === 'view-bitacora') {
                loadLogbookSnapshot();
            }

            if (targetId === 'view-bosque' && !forestLoaded) {
                loadForest();
            }
            if (targetId === 'view-vellocino' && !vellocinoLoaded) {
                loadVellocino();
            }
            if (targetId === 'view-fuentes' && !sourcesLoaded) {
                loadSources();
            }
        });
    });

    // Subnav functionality
    const subnavItems = document.querySelectorAll('.subnav-item');
    const subviewSections = document.querySelectorAll('.subview-section');

    subnavItems.forEach((subnav) => {
        subnav.addEventListener('click', (event) => {
            event.preventDefault();
            subnavItems.forEach(n => n.classList.remove('active'));
            subviewSections.forEach(s => s.classList.remove('active'));
            
            subnav.classList.add('active');
            currentSubTarget = subnav.getAttribute('data-subtarget');
            const tgt = document.getElementById(currentSubTarget);
            if (tgt) tgt.classList.add('active');

            if (currentSubTarget === 'subview-bitacora') {
                loadLogbookSnapshot();
            }
        });
    });

    // Estado inicial: ocultar alertas fuera de Bugs del Sistema.
    const initialTarget = document.querySelector('.nav-item.active')?.getAttribute('data-target') || 'view-monitorizacion';
    activateView(initialTarget);
    let lastTokenTotal = 0;
    const masters = { 'Antigravity': 'val-antigravity', 'Claude': 'val-claude', 'Codex': 'val-codex', 'OpenClaw': 'val-openclaw' };
    const bars = { 'Antigravity': 'bar-antigravity', 'Claude': 'bar-claude', 'Codex': 'bar-codex', 'OpenClaw': 'bar-openclaw' };

    function animateValue(id, start, end, duration) {
        const obj = document.getElementById(id);
        if (!obj) return;
        if (start === end) {
            obj.innerText = end.toLocaleString();
            return;
        }
        const range = end - start;
        const startTime = performance.now();
        const endTime = startTime + duration;

        function step(now) {
            const remaining = Math.max((endTime - now) / duration, 0);
            const value = Math.round(end - (remaining * range));
            obj.innerText = value.toLocaleString();
            if (now < endTime) {
                requestAnimationFrame(step);
            } else {
                obj.innerText = end.toLocaleString();
            }
        }
        requestAnimationFrame(step);
    }

    async function loadTokens() {
        try {
            const res = await fetch(`${API_URL}/tokens?scope=work`);
            if (!res.ok) return;
            const stats = await res.json();
            
            const counterEl = document.getElementById('token-counter');
            if (counterEl && stats.total !== lastTokenTotal) {
                animateValue('token-counter', lastTokenTotal, stats.total, 800);
                counterEl.classList.add('pulse-animation');
                setTimeout(() => counterEl.classList.remove('pulse-animation'), 500);
                lastTokenTotal = stats.total;
            } else if (counterEl) {
                counterEl.innerText = stats.total.toLocaleString();
            }
            
            const totalForBars = Math.max(stats.total, 1);
            Object.keys(masters).forEach(agent => {
                const valId = masters[agent];
                const barId = bars[agent];
                const data = stats.agents[agent] || { total: 0 };
                
                const valEl = document.getElementById(valId);
                if (valEl) valEl.innerText = data.total.toLocaleString();

                const barEl = document.getElementById(barId);
                if (barEl) {
                    const pct = (data.total / totalForBars) * 100;
                    barEl.style.width = `${pct}%`;
                }
            });
        } catch (e) {
            console.warn('Error en la matricula de tokens', e);
        }
    }

    function normalizeUiText(value) {
        let out = String(value ?? '');
        for (let i = 0; i < 2; i += 1) {
            if (!/[ÃƒÃ‚Ã¢Ã°]/.test(out)) break;
            try {
                // Repair mojibake from UTF-8 bytes interpreted as latin1/cp1252.
                out = decodeURIComponent(escape(out));
            } catch {
                break;
            }
        }
        return out;
    }

    function normalizeUiTextStable(value) {
        let out = String(value ?? '');
        const looksMojibake = (s) => {
            for (const ch of s) {
                const code = ch.charCodeAt(0);
                if (code === 0x00C3 || code === 0x00C2 || code === 0x00E2 || code === 0x00F0) return true;
            }
            return false;
        };
        for (let i = 0; i < 2; i += 1) {
            if (!looksMojibake(out)) break;
            try {
                const bytes = Uint8Array.from([...out].map((ch) => ch.charCodeAt(0) & 0xFF));
                const decoded = new TextDecoder('utf-8', { fatal: false }).decode(bytes);
                if (!decoded || decoded === out) break;
                out = decoded;
            } catch {
                break;
            }
        }
        return out;
    }

    function safeHtml(value) {
        return normalizeUiTextStable(normalizeUiText(value))
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function renderMultiline(value) {
        let text = safeHtml(value || '--');
        // Inject Listeners Regex
        // Match ARG-12312312 or ID-12312312
        text = text.replace(/\b(ARG-\d+|ID-\d+|DISPATCH-\d+)\b/g, '<span class="event-link" onclick="window.openEventInPanel(\'$1\')">$1</span>');
        // Match ACCION XX
        text = text.replace(/\b(ACCION \d+)\b/gi, '<span class="event-link" onclick="window.openEventInPanel(\'$1\')">$1</span>');
        // Match Date [YYYY-MM-DD HH:MM]
        text = text.replace(/(\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}\])/g, '<span class="event-link" onclick="window.openEventInPanel(\'$1\')">$1</span>');
        
        return text.replace(/\n/g, '<br>');
    }

    function formatMaritimeDate(isoOrStr, precision) {
        if (!isoOrStr || isoOrStr === '--') return '--';
        const isDayPrecision = precision === 'day' || isoOrStr.length <= 10;
        
        let dateObj;
        if (isoOrStr.includes('T')) dateObj = new Date(isoOrStr);
        else dateObj = new Date(isoOrStr.replace(' ', 'T') + ':00');
        
        if (isNaN(dateObj.getTime())) {
            const m = isoOrStr.match(/(\d{4})-(\d{2})-(\d{2})(?: (\d{2}):(\d{2}))?/);
            if (m) {
                const mesArr = ['ENE','FEB','MAR','ABR','MAY','JUN','JUL','AGO','SEP','OCT','NOV','DIC'];
                let mesStr = mesArr[parseInt(m[2], 10)-1];
                if (isDayPrecision || !m[4]) return `${m[3]}-${mesStr}`;
                return `${m[4]}:${m[5]} ${m[3]}-${mesStr}`;
            }
            return isoOrStr; 
        }

        const months = ['ENE','FEB','MAR','ABR','MAY','JUN','JUL','AGO','SEP','OCT','NOV','DIC'];
        const day = String(dateObj.getDate()).padStart(2, '0');
        const month = months[dateObj.getMonth()];
        const HH = String(dateObj.getHours()).padStart(2, '0');
        const MM = String(dateObj.getMinutes()).padStart(2, '0');

        if (isDayPrecision) return `${day}-${month}`;
        return `${HH}:${MM} ${day}-${month}`;
    }

    function buildBubbleCell(text, extraClass = '') {
        const div = document.createElement('div');
        div.className = `cell-bubble ${extraClass}`.trim();
        div.innerHTML = renderMultiline(text || '--');
        return div;
    }

    function compactTaskTitle(title) {
        const text = String(title || '').trim();
        if (!text) return 'Sin orden activa';
        return text.length > 36 ? `${text.slice(0, 35)}...` : text;
    }

    function isGenericOwner(ownerText) {
        const owner = String(ownerText || '').toLowerCase();
        return owner.includes('cualquiera') || owner.includes('codex / antigravity') || owner.includes('antigravity / codex');
    }

    function isTaskAssignedTo(task, agentName) {
        const owner = String(task.owner || '').toLowerCase();
        return owner.includes(agentName.toLowerCase());
    }

    function formatIaTask(task) {
        if (!task) return 'Sin orden activa';
        const prefix = task.status === 'in_progress' ? 'En curso' : 'Pendiente';
        return compactTaskTitle(`${prefix}: ${task.title || ''}`);
    }

    function isLolaPacket(task) {
        const id = String(task?.id || '').toUpperCase();
        const title = String(task?.title || '').toLowerCase();
        const type = String(task?.type || '').toLowerCase();
        return id.startsWith('LOLA-RISK-') || (type === 'risk' && title.includes('lola'));
    }

    function isLolaRiskRecord(risk) {
        const riskId = String(risk?.id || '').toUpperCase();
        return riskId.startsWith('LOLA-RISK-');
    }

    function isRiskActive(risk) {
        const state = String(risk?.state || '').toLowerCase();
        if (!state) return true;
        return !['done', 'closed', 'resolved', 'mitigado', 'mitigada'].some((token) => state.includes(token));
    }

    // lastFeedMessages: { Codex: msg, Antigravity: msg, Claude: msg, OpenClaw: msg }
    let lastFeedMessages = {};

    // Cache de ia_status — se actualiza desde hydrate y desde SSE.
    // renderIaStatus lo usa directamente sin hacer un fetch extra.
    let cachedIaStatus = {};

    function updateFeedMessages(messages) {
        // Keep the most recent crew message per agent
        const agents = ['Codex', 'Antigravity', 'Claude', 'OpenClaw'];
        agents.forEach(agent => {
            const msg = [...messages].reverse().find(m =>
                m.senderRole === 'agent' && m.sender && m.sender.toLowerCase().includes(agent.toLowerCase())
            );
            if (msg) lastFeedMessages[agent] = msg;
        });
    }

    function formatIaStatusLineLegacy(task, feedMsg) {
        if (task) {
            const prefix = task.status === 'in_progress' ? 'Ã¢Â¬Â¤ En curso' : 'Ã¢â€”â€¹ Pendiente';
            return `${prefix}: ${compactTaskTitle(task.title || '')}`;
        }
        if (feedMsg) {
            const text = (feedMsg.text || '').split('\n')[0].slice(0, 60);
            return `Ã¢Å“â€œ ÃƒÅ¡ltimo: ${text}${feedMsg.text && feedMsg.text.length > 60 ? 'Ã¢â‚¬Â¦' : ''}`;
        }
        return 'Sin orden activa';
    }

    // Canonical status formatter (overrides previous mojibake-prone variant).
    function formatIaStatusLine(task, feedMsg, apiStatus) {
        if (apiStatus && apiStatus.status === 'restricted') {
            return `RESTRINGIDO: ${apiStatus.task || 'Tokens agotados'}`;
        }
        // Si el agente está activo y tiene una tarea registrada en state, tiene prioridad
        // sobre el work packet que assignTask pueda inferir de la cola genérica.
        if (apiStatus && apiStatus.status === 'active' && apiStatus.task_subject) {
            return `En misión: ${apiStatus.task_subject}`;
        }
        if (task) {
            return `En misión: ${task.title}`;
        }
        if (feedMsg) {
            return `Reportando: ${feedMsg.summary}`;
        }
        return 'Standby';
    }

    async function renderIaStatus(tasks) {
        const activeTasks = tasks.filter((task) => task.status !== 'done');
        // Usar el cache actualizado por hydrate y SSE — no hacer fetch redundante
        const apiStatusMap = cachedIaStatus;
        const genericQueue = activeTasks.filter((task) => isGenericOwner(task.owner));
        let genericIndex = 0;

        const assignTask = (agentName) => {
            const direct = activeTasks.find((task) => isTaskAssignedTo(task, agentName));
            if (direct) return direct;

            if (genericIndex < genericQueue.length) {
                const sharedTask = genericQueue[genericIndex];
                genericIndex += 1;
                return sharedTask;
            }
            return null;
        };

        const targets = [
            { name: 'Codex', selectors: ['#ia-status-codex', '[data-ia-status="Codex"]'] },
            { name: 'Antigravity', selectors: ['#ia-status-antigravity', '[data-ia-status="Antigravity"]'] },
            { name: 'Claude', selectors: ['#ia-status-claude', '[data-ia-status="Claude"]'] },
            { name: 'OpenClaw', selectors: ['#ia-status-openclaw', '[data-ia-status="OpenClaw"]'] }
        ];

        targets.forEach((target) => {
            const node = target.selectors
                .map((selector) => document.querySelector(selector))
                .find(Boolean);
            if (!node) return;

            const apiStatus = apiStatusMap[target.name];
            const task = assignTask(target.name);
            const feedMsg = lastFeedMessages[target.name];
            
            node.textContent = formatIaStatusLine(task, feedMsg, apiStatus);
            
            // Colores por estado
            if (apiStatus && apiStatus.status === 'restricted') {
                node.style.color = '#ffa500'; // Warning Orange
            } else if (task || (apiStatus && apiStatus.status === 'active')) {
                node.style.color = 'var(--accent-neon)';
            } else {
                node.style.color = ''; // Default
            }
        });
    }
    function updateTaskSelection() {
        const toolbar = document.getElementById('task-toolbar');
        const selectAllCheckbox = document.getElementById('select-all-tasks');
        const selectionCounter = document.getElementById('selection-counter');
        const selectedCountSpan = document.getElementById('selected-count');
        const deleteBtn = document.getElementById('btn-delete-tasks');

        if (!toolbar) return;

        const count = selectedTasks.size;
        if (count > 0) {
            selectionCounter.style.display = 'block';
            selectedCountSpan.textContent = String(count);
            deleteBtn.style.display = 'block';
        } else {
            selectionCounter.style.display = 'none';
            deleteBtn.style.display = 'none';
        }

        const allSelected = pendingTasks.length > 0 && selectedTasks.size === pendingTasks.length;
        if (selectAllCheckbox) {
            selectAllCheckbox.checked = allSelected;
            selectAllCheckbox.indeterminate = selectedTasks.size > 0 && !allSelected;
        }

        // Update task item visual state
        document.querySelectorAll('.task-item').forEach(item => {
            const checkbox = item.querySelector('.task-checkbox');
            if (checkbox && checkbox.checked) {
                item.classList.add('selected');
            } else {
                item.classList.remove('selected');
            }
        });
    }

    function belongsToProject(id, project) {
        if (!id) return false;
        id = id.toUpperCase();
        if (project === 'argos') return id.startsWith('ARG-');
        if (project === 'sciclass') return id.startsWith('SCI') || id.startsWith('M8');
        if (project === 'comenio') return id.startsWith('COM');
        if (project === 'lola') return id.startsWith('LOLA');
        if (project === 'xuanshu') return id.startsWith('XUAN');
        return true;
    }

    function renderTasks(tasks) {
        if (expandedTaskList) expandedTaskList.innerHTML = '';
        const visibleTasks = tasks.filter((task) => !isLolaPacket(task) && belongsToProject(task.id, currentProject));
        latestVisibleTasks = visibleTasks;
        pendingTasks = visibleTasks;
        const openTasks = visibleTasks.filter((task) => task.status !== 'done');
        const activeCount = openTasks.length;
        activeMissionsCount.innerText = String(activeCount);
        renderIaStatus(visibleTasks);
        renderMonitorInbox(openTasks);

        // Reset selection when rendering new tasks
        selectedTasks.clear();
        updateTaskSelection();

        if (pendingTasks.length === 0) {
            if (expandedTaskList) expandedTaskList.innerHTML = '<p class="empty-copy">No hay work packets disponibles.</p>';
            return;
        }

        pendingTasks.forEach((task) => {
            const item = document.createElement('div');
            const isDone = task.status === 'done';
            const priority = task.priority || 'low';
            item.className = `task-item ${isDone ? 'done' : ''} priority-group-${priority}`;

            // Render only if expandedTaskList exists (Orders tab)
            if (!expandedTaskList) return;

            let statusColor = '#a0aab0'; // grey for open
            if (task.status === 'in_progress') statusColor = 'var(--accent-amber)'; // yellow
            if (task.status === 'review') statusColor = 'var(--accent-neon)'; // green
            if (task.status === 'done') statusColor = 'var(--accent-neon)';

            const zone = task.zone || 'inbox';
            let statusMarkup = '';
            
            if (task.status === 'done') {
                statusMarkup = `<div class="status-box-done">DONE</div>`;
            } else {
                statusMarkup = `
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="${statusColor}" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="status-clock-svg">
                        <circle cx="12" cy="12" r="10"></circle>
                        <polyline points="12 6 12 12 16 14"></polyline>
                    </svg>
                `;
            }

            item.innerHTML = `
                <div class="task-status">
                    ${statusMarkup}
                </div>
                <div class="task-info">
                    <h4>
                        <span class="priority-tag priority-${priority}">${priority}</span>
                        ${safeHtml(task.title)}
                    </h4>
                    <div class="task-meta">
                        <span>ID: <span class="task-id-link">${safeHtml(task.id)}</span></span>
                        <span class="task-zone ${safeHtml(zone)}">${safeHtml(zone)}</span>
                        <span>|</span>
                        <span>Dirigido a: ${safeHtml(task.owner)}</span>
                        <span>|</span>
                        <span>${safeHtml(task.time || 'Ahora')}</span>
                        ${task.tokens_spent ? `<span>| <span style="color:var(--accent-neon);opacity:0.7">~${task.tokens_spent.toLocaleString()} tokens</span></span>` : ''}
                    </div>
                    <div class="task-actions">
                        <button type="button" class="task-edit-btn" data-task-id="${safeHtml(task.id)}">Editar</button>
                    </div>
                </div>
                <label class="task-checkbox-wrapper">
                    <input type="checkbox" class="task-checkbox" data-task-id="${safeHtml(task.id)}" />
                    <span class="custom-checkbox"></span>
                </label>
            `;

            const checkbox = item.querySelector('.task-checkbox');
            checkbox.addEventListener('change', (e) => {
                e.stopPropagation();
                if (checkbox.checked) {
                    selectedTasks.add(task.id);
                } else {
                    selectedTasks.delete(task.id);
                }
                updateTaskSelection();
            });

            const idLink = item.querySelector('.task-id-link');
            if (idLink) {
                idLink.addEventListener('click', (ev) => {
                    ev.stopPropagation();
                    window.openEventInPanel(task.id);
                });
            }

            item.addEventListener('click', (e) => {
                if (e.target === checkbox || e.target.classList.contains('task-checkbox')) return;
                // Si hizo click en cualquier otra area que no sea el link, togglear el checkbox para facilitar seleccion
                checkbox.checked = !checkbox.checked;
                checkbox.dispatchEvent(new Event('change'));
            });



            const editBtn = item.querySelector('.task-edit-btn');
            if (editBtn) {
                editBtn.addEventListener('click', async (ev) => {
                    ev.stopPropagation();
                    await editTaskPacket(task.id);
                });
            }

            if (expandedTaskList) expandedTaskList.appendChild(item);
        });
    }

    function renderMonitorInbox(openTasks) {
        if (!monitorInboxList) return;
        monitorInboxList.innerHTML = '';

        if (!openTasks || openTasks.length === 0) {
            monitorInboxList.innerHTML = '<p class="empty-copy">Sin ordenes abiertas en este momento.</p>';
            return;
        }

        openTasks.forEach((task) => {
            const item = document.createElement('div');
            item.className = 'monitor-inbox-item';
            item.innerHTML = `
                <div class="monitor-inbox-item-title">${safeHtml(task.title || 'Sin asunto')}</div>
                <div class="monitor-inbox-item-meta">
                    <span>ID: ${safeHtml(task.id || '--')}</span>
                    <span>${safeHtml(task.status || 'open')}</span>
                    <span>${safeHtml(task.owner || 'Sin duenio')}</span>
                </div>
            `;

            item.addEventListener('click', () => {
                activateView('view-ordenes');
                window.openEventInPanel(task.id);
            });

            monitorInboxList.appendChild(item);
        });
    }

    async function loadVectorMap() {
        if (!vectorContainer) return;

        try {
            const res = await fetch(`${API_URL}/vector`);
            const data = await res.json();
            renderVector(data.categories || []);
        } catch (e) {
            console.warn('Fallo exhumando el Vector de ruta', e);
        }
    }

    function renderVector(categories) {
        if (!vectorContainer) return;
        vectorContainer.innerHTML = '';

        if (categories.length === 0) {
            vectorContainer.innerHTML = '<p class="empty-copy">Vector estacionario. Sin rumbos definidos.</p>';
            return;
        }

        categories.forEach(cat => {
            const catDiv = document.createElement('div');
            catDiv.className = 'vector-cat';
            
            catDiv.innerHTML = `
                <div class="vector-cat-title">${safeHtml(cat.title)}</div>
                <div class="vector-goals">
                    ${cat.goals.map(goal => `
                        <div class="vector-goal ${goal.status === 'done' ? 'done' : ''}">
                            <div class="goal-bullet"></div>
                            <span class="goal-text">${safeHtml(goal.text)}</span>
                        </div>
                    `).join('')}
                </div>
            `;
            vectorContainer.appendChild(catDiv);
        });
    }

    function splitMessageParts(msg) {
        const summary = String(msg.summary || '').trim();
        const details = String(msg.details || '').trim();
        if (summary || details) return { summary, details };
        const text = String(msg.text || '');
        const parts = text.split('\n');
        return {
            summary: String(parts.shift() || '').trim(),
            details: parts.join('\n').trim()
        };
    }

    async function editChatMessage(msg) {
        if (!msg?.id) {
            showToast('Este mensaje no tiene ID editable.');
            return;
        }
        const current = splitMessageParts(msg);
        const nextSummaryRaw = window.prompt('Editar resumen del mensaje:', current.summary);
        if (nextSummaryRaw === null) return;
        const nextSummary = String(nextSummaryRaw || '').trim();
        if (!nextSummary) {
            showToast('El resumen no puede quedar vacio.');
            return;
        }
        const nextDetailsRaw = window.prompt('Editar detalles (opcional):', current.details);
        if (nextDetailsRaw === null) return;
        const nextDetails = String(nextDetailsRaw || '').trim();

        try {
            const response = await fetch(`${API_URL}/chat/edit`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ messageId: msg.id, summary: nextSummary, details: nextDetails })
            });
            if (!response.ok) {
                showToast('No se pudo editar el mensaje.');
                return;
            }
            showToast(`Mensaje ${msg.id} actualizado.`);
            await hydrate();
        } catch (error) {
            showToast('Fallo de red al editar mensaje.');
        }
    }

    async function editTaskPacket(packetId) {
        if (!packetId) return;
        try {
            const readResponse = await fetch(`${API_URL}/tasks/get?packetId=${encodeURIComponent(packetId)}`);
            if (!readResponse.ok) {
                showToast(`No pude leer ${packetId}.`);
                return;
            }
            const payload = await readResponse.json();
            const packet = payload.packet || {};
            const nextSubjectRaw = window.prompt(`Editar asunto de ${packetId}:`, packet.subject || '');
            if (nextSubjectRaw === null) return;
            const nextSubject = String(nextSubjectRaw || '').trim();
            if (!nextSubject) {
                showToast('El asunto no puede quedar vacio.');
                return;
            }

            const nextOwnerRaw = window.prompt(`Editar responsable de ${packetId}:`, packet.owner || 'Cualquiera');
            if (nextOwnerRaw === null) return;
            const nextOwner = String(nextOwnerRaw || '').trim();
            if (!nextOwner) {
                showToast('El responsable no puede quedar vacio.');
                return;
            }

            const nextStatusRaw = window.prompt(`Editar estado (open | in_progress | done) de ${packetId}:`, packet.status || 'open');
            if (nextStatusRaw === null) return;
            const nextStatus = String(nextStatusRaw || '').trim();
            if (!nextStatus) {
                showToast('El estado no puede quedar vacio.');
                return;
            }

            const nextObjectiveRaw = window.prompt(`Editar objetivo de ${packetId}:`, packet.objective || '');
            if (nextObjectiveRaw === null) return;
            const nextObjective = String(nextObjectiveRaw || '').trim();
            if (!nextObjective) {
                showToast('El objetivo no puede quedar vacio.');
                return;
            }

            const updateResponse = await fetch(`${API_URL}/tasks/update`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    packetId,
                    subject: nextSubject,
                    owner: nextOwner,
                    status: nextStatus,
                    objective: nextObjective,
                    actor: 'Thor'
                })
            });

            if (!updateResponse.ok) {
                showToast(`No se pudo editar ${packetId}.`);
                return;
            }

            showToast(`Work packet ${packetId} actualizado.`);
            await hydrate();
        } catch (error) {
            showToast('Fallo de red editando el work packet.');
        }
    }

    function renderChat(messages) {
        updateFeedMessages(messages);
        chatContainer.innerHTML = '';
        messages.forEach((msg) => {
            const wrap = document.createElement('div');
            wrap.className = `chat-message ${msg.type}`;
            const senderLabel = msg.sender || msg.senderName || msg.speaker || 'Tripulacion';
            const canEdit = msg.type === 'sent' && !!msg.id;
            const editedTag = msg.editedAt ? '<span class="chat-edited-tag">editado</span>' : '';
            const editButton = canEdit ? '<button type="button" class="chat-edit-btn">Editar</button>' : '';
            const transcriptRef = msg.transcriptRef || msg.transcript_ref || '';
            const transcriptBtn = transcriptRef
                ? `<button type="button" class="chat-transcript-btn" data-ref="${safeHtml(transcriptRef)}" title="Ver transcript literal">📄</button>`
                : '';

            wrap.innerHTML = `
                <span class="sender">${safeHtml(senderLabel)}</span>
                <p>${renderMultiline(msg.text || '')}</p>
                <div class="chat-meta-bottom">
                    <div class="chat-meta-left">${editedTag}${editButton}${transcriptBtn}</div>
                    <span class="time">${safeHtml(msg.time || '--:--')}</span>
                </div>
            `;

            if (canEdit) {
                const editBtn = wrap.querySelector('.chat-edit-btn');
                if (editBtn) {
                    editBtn.addEventListener('click', async (event) => {
                        event.stopPropagation();
                        await editChatMessage(msg);
                    });
                }
            }
            // Handler del botón de transcript
            const tBtn = wrap.querySelector('.chat-transcript-btn');
            if (tBtn) {
                tBtn.addEventListener('click', async (e) => {
                    e.stopPropagation();
                    await showTranscriptOverlay(tBtn.dataset.ref);
                });
            }

            chatContainer.appendChild(wrap);
        });

        chatContainer.scrollTop = chatContainer.scrollHeight;
        renderIaStatus(latestVisibleTasks);
    }

    // Muestra el transcript literal en el overlay de eventos existente
    async function showTranscriptOverlay(transcriptRef) {
        if (!transcriptRef) return;
        // Formato ref: "transcripts/FECHA_AGENTE.md#PACKET-ID"  o  "transcripts/FECHA_AGENTE.md"
        const [filePart, packetId] = transcriptRef.replace('transcripts/', '').split('#');
        const [datePart, ...agentParts] = filePart.replace('.md', '').split('_');
        const agent = agentParts.join('_');

        try {
            const params = new URLSearchParams({ agent, date: datePart });
            if (packetId) params.set('packetId', packetId);
            const resp = await fetch(`${API_URL}/transcript?${params}`);
            if (!resp.ok) {
                showTranscriptModal('Transcript no disponible', `No se encontró el bloque para ${transcriptRef}`);
                return;
            }
            const data = await resp.json();
            showTranscriptModal(
                `Transcript: ${agent} · ${datePart}${packetId ? ` · ${packetId}` : ''}`,
                data.content || 'Vacío'
            );
        } catch (err) {
            showTranscriptModal('Error', String(err));
        }
    }

    function showTranscriptModal(title, content) {
        if (!overlay || !modalQueryTitle || !modalEventsList) return;
        modalQueryTitle.textContent = title;
        modalEventsList.innerHTML = '';
        const pre = document.createElement('pre');
        pre.style.cssText = 'white-space:pre-wrap;word-break:break-word;font-size:0.85rem;line-height:1.5;padding:1rem;';
        pre.textContent = content;
        modalEventsList.appendChild(pre);
        overlay.classList.remove('hidden');
    }

    function setRowExpanded(row, expanded) {
        row.classList.toggle('is-row-expanded', expanded);
        Array.from(row.querySelectorAll('.cell-bubble')).forEach((bubble) => {
            bubble.classList.toggle('is-expanded', expanded);
        });
    }

    function collapseExpandedLogbookRow() {
        if (!expandedLogbookRow) return;
        setRowExpanded(expandedLogbookRow, false);
        expandedLogbookRow = null;
    }

    function collapseExpandedEventRow() {
        if (!expandedEventRow) return;
        setRowExpanded(expandedEventRow, false);
        expandedEventRow = null;
    }

    function mapEventSourceToLabel(source) {
        const value = String(source || '').toLowerCase();
        if (value.includes('shadow')) return 'shadow_log';
        if (value.includes('glitch')) return 'glitch_log';
        if (value.includes('transcript')) return 'transcript';
        if (value.includes('captain_feed') || value.includes('argos.events')) return 'captain_feed';
        if (value.includes('work packet')) return 'work_packet';
        if (value.includes('bug')) return 'bug';
        if (value.includes('global_log') || value.includes('argos_global_log')) return 'log';
        return 'otros';
    }

    function renderEventHitsInModal(hits) {
        modalEventsList.innerHTML = '';
        collapseExpandedEventRow();

        if (!hits || hits.length === 0) {
            modalEventsList.innerHTML = '<p class="empty-copy">No hay cruces para esa ID.</p>';
            return;
        }

        const legend = document.createElement('div');
        legend.className = 'event-legend';
        const counts = new Map();
        hits.forEach((hit) => {
            const label = mapEventSourceToLabel(hit.source);
            counts.set(label, (counts.get(label) || 0) + 1);
        });
        Array.from(counts.entries()).forEach(([label, count]) => {
            const chip = document.createElement('span');
            chip.className = 'meta-chip meta-chip-quiet';
            chip.textContent = `${label}: ${count}`;
            legend.appendChild(chip);
        });
        modalEventsList.appendChild(legend);

        const tableWrap = document.createElement('div');
        tableWrap.className = 'logbook-table-wrap';
        const table = document.createElement('table');
        table.className = 'logbook-table event-logbook-table';
        table.innerHTML = `
            <thead>
                <tr>
                    <th class="col-actor">Fuente</th>
                    <th class="col-summary">Registro</th>
                </tr>
            </thead>
            <tbody></tbody>
        `;
        const tbody = table.querySelector('tbody');

        hits.forEach((hit) => {
            const row = document.createElement('tr');
            row.className = 'logbook-row event-hit-row';

            const sourceTd = document.createElement('td');
            sourceTd.className = 'col-actor';
            sourceTd.appendChild(buildBubbleCell(mapEventSourceToLabel(hit.source)));

            const contentTd = document.createElement('td');
            contentTd.className = 'col-summary';
            contentTd.appendChild(buildBubbleCell(hit.content || '--'));

            row.appendChild(sourceTd);
            row.appendChild(contentTd);

            row.addEventListener('click', (event) => {
                event.stopPropagation();
                const shouldExpand = expandedEventRow !== row;
                collapseExpandedEventRow();
                if (shouldExpand) {
                    setRowExpanded(row, true);
                    expandedEventRow = row;
                }
            });

            tbody.appendChild(row);
        });

        tableWrap.appendChild(table);
        modalEventsList.appendChild(tableWrap);
    }

    function ensureLogbookSelection(snapshot) {
        const modules = snapshot.modules || [];
        if (modules.length === 0) {
            viewState.moduleId = null;
            viewState.streamId = null;
            return null;
        }

        let currentModule = modules.find((module) => module.id === viewState.moduleId);
        if (!currentModule) {
            currentModule = modules[0];
            viewState.moduleId = currentModule.id;
        }

        const streams = currentModule.streams || [];
        // Excluir glitch si no tiene entradas (tab oculto)
        const visibleStreams = streams.filter((s) => s.id !== 'glitch' || (s.entries || []).length > 0);

        // 'transcript' es un tab virtual — no existe en el snapshot, pero es válido
        if (viewState.streamId === 'transcript') {
            return { currentModule, currentStream: null };
        }

        let currentStream = visibleStreams.find((stream) => stream.id === viewState.streamId);
        if (!currentStream) {
            currentStream = visibleStreams[0] || streams[0];
            viewState.streamId = currentStream ? currentStream.id : null;
        }

        return { currentModule, currentStream };
    }

    function renderModuleTabs(snapshot) {
        moduleTabs.innerHTML = '';
        (snapshot.modules || []).forEach((module) => {
            const button = document.createElement('button');
            button.type = 'button';
            button.className = `sheet-tab ${module.id === viewState.moduleId ? 'is-active' : ''} ${module.status === 'pending' ? 'is-pending' : ''}`.trim();
            button.textContent = module.label;
            button.addEventListener('click', () => {
                viewState.moduleId = module.id;
                viewState.streamId = null;
                renderLogbook(snapshot);
            });
            moduleTabs.appendChild(button);
        });
    }

    function renderStreamTabs(currentModule, snapshot) {
        streamTabs.innerHTML = '';
        (currentModule.streams || []).forEach((stream) => {
            // Glitch stream: solo mostrar si tiene entradas
            const entries = stream.entries || [];
            if (stream.id === 'glitch' && entries.length === 0) return;

            const button = document.createElement('button');
            button.type = 'button';
            button.className = `sheet-tab ${stream.id === viewState.streamId ? 'is-active' : ''}`.trim();
            button.textContent = stream.label;
            button.addEventListener('click', () => {
                viewState.streamId = stream.id;
                renderLogbook(snapshot);
            });
            streamTabs.appendChild(button);
        });

        // Tab especial Transcript — siempre visible, fuera del snapshot
        const transcriptBtn = document.createElement('button');
        transcriptBtn.type = 'button';
        transcriptBtn.className = `sheet-tab ${viewState.streamId === 'transcript' ? 'is-active' : ''}`.trim();
        transcriptBtn.textContent = '📄 Transcripts';
        transcriptBtn.addEventListener('click', () => {
            viewState.streamId = 'transcript';
            renderLogbook(snapshot);
        });
        streamTabs.appendChild(transcriptBtn);
    }

    function renderLogbookTable(snapshot, currentModule, currentStream) {
        const columns = snapshot.columns || [];
        logbookHead.innerHTML = '';
        logbookBody.innerHTML = '';
        if (logbookTable) logbookTable.classList.remove('transcript-table');

        const headRow = document.createElement('tr');
        columns.forEach((column) => {
            const th = document.createElement('th');
            th.className = `col-${column.id}`;
            th.textContent = column.label;
            headRow.appendChild(th);
        });
        logbookHead.appendChild(headRow);

        const entries = currentStream.entries || [];
        if (entries.length === 0) {
            const emptyRow = document.createElement('tr');
            emptyRow.innerHTML = `
                <td colspan="${columns.length}" class="logbook-empty">
                    ${safeHtml(currentStream.empty_state || `${currentModule.label} todavia no tiene entradas visibles en este stream.`)}
                </td>
            `;
            logbookBody.appendChild(emptyRow);
            return;
        }

        entries.forEach((entry) => {
            const row = document.createElement('tr');
            row.className = 'logbook-row';
            row.addEventListener('click', (event) => {
                event.stopPropagation();
                const shouldExpand = expandedLogbookRow !== row;
                collapseExpandedLogbookRow();
                if (shouldExpand) {
                    setRowExpanded(row, true);
                    expandedLogbookRow = row;
                }
            });

            columns.forEach((column) => {
                const td = document.createElement('td');
                td.className = `col-${column.id}`;
                let value = entry[column.id] || '--';
                if (column.id === 'timestamp_label') {
                    value = formatMaritimeDate(value, entry.timestamp_precision);
                }

                // transcriptRef — render as 📄 button instead of raw text
                if (column.id === 'transcriptRef') {
                    if (value && value !== '--') {
                        const btn = document.createElement('button');
                        btn.type = 'button';
                        btn.className = 'transcript-btn';
                        btn.title = value;
                        btn.textContent = '📄';
                        btn.addEventListener('click', (ev) => {
                            ev.stopPropagation();
                            showTranscriptOverlay(value);
                        });
                        td.appendChild(btn);
                    } else {
                        const empty = document.createElement('span');
                        empty.className = 'logbook-cell-empty';
                        empty.textContent = '—';
                        td.appendChild(empty);
                    }
                    row.appendChild(td);
                    return;
                }

                let extraClass = '';
                if (column.id === 'timestamp_label' && entry.timestamp_precision !== 'minute') {
                    extraClass = 'is-imprecise';
                } else if (column.id === 'actor' && value !== '--') {
                    extraClass = `bubble-agent-${value.toLowerCase().replace(/\s+/g, '-')}`;
                }

                const bubble = buildBubbleCell(value, extraClass);
                if (column.id === 'id' && value !== '--') {
                    bubble.classList.add('event-link');
                    bubble.addEventListener('click', (ev) => {
                        ev.stopPropagation();
                        window.openEventInPanel(value);
                    });
                }
                td.appendChild(bubble);
                row.appendChild(td);
            });

            logbookBody.appendChild(row);
        });
    }

    function renderLogbookMeta(snapshot, currentModule, currentStream) {
        const moduleDescription = currentModule.description || '';
        const sourceLabel = currentStream.source || 'Fuente no declarada';
        const updatedAt = snapshot.updated_at || 'sin marca';
        const precisionNote = snapshot.timestamp_policy?.legacy_precision_note || '';

        logbookMeta.innerHTML = `
            <span class="meta-chip event-link" style="cursor:pointer; background: rgba(24, 169, 107, 0.4);" onclick="window.openEventInPanel('${safeHtml(currentModule.id)}')">Proyecto Holografico: ${safeHtml(currentModule.label)}</span>
            <span class="meta-chip meta-chip-quiet">${safeHtml(currentStream.label)}</span>
            <span class="meta-chip meta-chip-quiet">Fuente: ${safeHtml(sourceLabel)}</span>
            <span class="meta-chip meta-chip-quiet">Actualizado: ${safeHtml(updatedAt)}</span>
            <div class="logbook-meta-copy">
                <strong>${safeHtml(moduleDescription)}</strong><br>
                ${safeHtml(precisionNote)}
            </div>
        `;
    }

    function renderLogbook(snapshot) {
        viewState.logbook = snapshot;
        const selection = ensureLogbookSelection(snapshot);

        if (!selection) {
            moduleTabs.innerHTML = '';
            streamTabs.innerHTML = '';
            logbookMeta.innerHTML = '<p class="empty-copy">No hay snapshot tabular disponible.</p>';
            logbookHead.innerHTML = '';
            logbookBody.innerHTML = '';
            return;
        }

        renderModuleTabs(snapshot);
        renderStreamTabs(selection.currentModule, snapshot);

        if (viewState.streamId === 'transcript') {
            logbookMeta.innerHTML = `
                <span class="meta-chip meta-chip-quiet">📄 Transcripts literales</span>
                <span class="meta-chip meta-chip-quiet">Fuente: transcripts/FECHA_AGENTE.md</span>
                <div class="logbook-meta-copy"><strong>Exchanges literales entre IAs y Capitán, indexados por work packet.</strong></div>
            `;
            renderTranscriptTab();
            return;
        }

        renderLogbookMeta(snapshot, selection.currentModule, selection.currentStream);
        renderLogbookTable(snapshot, selection.currentModule, selection.currentStream);
    }

    async function renderTranscriptTab() {
        logbookHead.innerHTML = '';
        logbookBody.innerHTML = '';
        if (logbookTable) logbookTable.classList.add('transcript-table');

        // Header fijo
        const headRow = document.createElement('tr');
        headRow.innerHTML = `
            <th class="col-ts-fit">Tiempo</th>
            <th class="col-voz-fit">Voz</th>
            <th class="col-id-fit">ID</th>
            <th class="col-transcript-text">Transcript</th>
        `;
        logbookHead.appendChild(headRow);

        // Cargar datos
        const today = new Date().toISOString().slice(0, 10);
        let entries = [];
        try {
            const res = await fetch(`${API_URL}/transcript/feed?date=${today}`);
            if (res.ok) {
                const data = await res.json();
                entries = data.entries || [];
            }
        } catch (e) {
            console.warn('Fallo cargando transcript feed:', e);
        }

        if (entries.length === 0) {
            const emptyRow = document.createElement('tr');
            emptyRow.innerHTML = `<td colspan="4" class="logbook-empty">Sin transcripts para hoy.</td>`;
            logbookBody.appendChild(emptyRow);
            return;
        }

        entries.forEach((entry) => {
            const row = document.createElement('tr');
            row.className = 'logbook-row transcript-feed-row';

            // Timestamp
            const tsTd = document.createElement('td');
            tsTd.className = 'col-ts-fit';
            tsTd.appendChild(buildBubbleCell(entry.timestamp || '--'));

            // Voz / agent
            const vozTd = document.createElement('td');
            vozTd.className = 'col-voz-fit';
            const agentClass = `bubble-agent-${(entry.agent || '').toLowerCase().replace(/\s+/g, '-')}`;
            vozTd.appendChild(buildBubbleCell(entry.agent || '--', agentClass));

            // PacketId — clickable → abre visor
            const idTd = document.createElement('td');
            idTd.className = 'col-id-fit';
            const idBubble = buildBubbleCell(entry.packetId || '--');
            if (entry.packetId) {
                idBubble.classList.add('event-link');
                idBubble.addEventListener('click', () => window.openEventInPanel(entry.packetId));
            }
            idTd.appendChild(idBubble);

            // Transcript content — no expandable, texto directo
            const textTd = document.createElement('td');
            textTd.className = 'col-transcript-text';
            const pre = document.createElement('pre');
            pre.className = 'transcript-feed-text';
            pre.textContent = entry.content || '';
            textTd.appendChild(pre);

            row.appendChild(tsTd);
            row.appendChild(vozTd);
            row.appendChild(idTd);
            row.appendChild(textTd);

            logbookBody.appendChild(row);
        });
    }

    async function loadLogbookSnapshot() {
        try {
            const response = await fetch(`${API_URL}/logbook`);
            if (!response.ok) return;
            const logbookData = await response.json();
            renderLogbook(logbookData);
        } catch (error) {
            console.warn('Fallo cargando bitacora tabular bajo demanda.', error);
        }
    }

    function applyIaStatusToPanel(iaStatus) {
        ['Claude', 'Antigravity', 'Codex', 'OpenClaw'].forEach(agent => {
            const node = document.querySelector(`[data-ia-status="${agent}"]`);
            if (!node) return;
            const s = iaStatus[agent];
            if (s && s.status === 'active') {
                const label = s.task_subject
                    ? s.task_subject
                    : (s.task || 'En mision');
                node.textContent = `En mision: ${label}`;
                node.style.color = 'var(--accent-neon)';
            } else {
                // Evita que un standby remoto tape una mision detectada por tareas visibles.
                const current = String(node.textContent || '').trim();
                const hasTaskSignal = current.startsWith('[EN CURSO]') || current.startsWith('[PENDIENTE]') || current.startsWith('[OK]');
                if (!hasTaskSignal) {
                    node.textContent = 'Standby';
                }
                node.style.color = 'var(--text-secondary)';
            }
        });
    }

    async function hydrate() {
        const endpoints = {
            status: `${API_URL.replace('/api', '')}/health`,
            state: `${API_URL}/state`,
            tasks: `${API_URL}/tasks`,
            chat: `${API_URL}/chat`,
            vector: `${API_URL}/vector`,
            iaStatus: `${API_URL}/ia/status`
        };

        const [statusReq, stateReq, tasksReq, chatReq, vectorReq, iaStatusReq] = await Promise.allSettled([
            fetch(endpoints.status),
            fetch(endpoints.state),
            fetch(endpoints.tasks),
            fetch(endpoints.chat),
            fetch(endpoints.vector),
            fetch(endpoints.iaStatus)
        ]);

        const stateOk = stateReq.status === 'fulfilled' && stateReq.value.ok;
        if (stateOk) {
            statusSpan.innerText = 'Runtime Argos Activo';
            statusSpan.style.color = 'var(--text-secondary)';
        } else {
            statusSpan.innerText = 'Desconexion parcial';
            statusSpan.style.color = '#db9d1e';
        }

        if (stateReq.status === 'fulfilled' && stateReq.value.ok) {
            const stateData = await stateReq.value.json();
            const missionsCount = stateData.open_packets?.length || 0;
            if (activeMissionsCount) activeMissionsCount.innerText = missionsCount;
        }

        // Actualizar cachedIaStatus ANTES de renderTasks/renderChat para que
        // renderIaStatus use datos frescos sin hacer fetches redundantes.
        if (iaStatusReq.status === 'fulfilled' && iaStatusReq.value.ok) {
            const iaData = await iaStatusReq.value.json();
            cachedIaStatus = iaData.ia_status || {};
        }

        if (tasksReq.status === 'fulfilled' && tasksReq.value.ok) {
            const taskData = await tasksReq.value.json();
            allRawTasks = taskData.tasks || [];
            renderTasks(allRawTasks);
        } else {
            allRawTasks = defaultTasks;
            renderTasks(allRawTasks);
        }

        if (chatReq.status === 'fulfilled' && chatReq.value.ok) {
            const chatData = await chatReq.value.json();
            renderChat(chatData.messages || []);
        }

        if (vectorReq.status === 'fulfilled' && vectorReq.value.ok) {
            const vectorData = await vectorReq.value.json();
            renderVector(vectorData.categories || []);
        }

        // applyIaStatusToPanel como paso final por si renderTasks/renderChat
        // hubiesen dejado algo desalineado
        applyIaStatusToPanel(cachedIaStatus);
    }
    function showToast(text) {
        const bin = document.getElementById('toast-bin');
        const toast = document.createElement('div');
        toast.className = 'toast';
        toast.innerHTML = `<span class="toast-mark">^</span> ${safeHtml(text)}`;
        bin.appendChild(toast);
        setTimeout(() => toast.remove(), 4000);
    }

    const btnSendCmd = document.getElementById('btn-send-cmd');
    const inputCmd = document.getElementById('simple-cmd-input');

    btnSendCmd.onclick = async () => {
        const rawSpeech = String(inputCmd.value || '').trim();
        if (!rawSpeech) return;

        await fireTask(rawSpeech);
        inputCmd.value = '';
        inputCmd.style.height = '';
    };

    inputCmd.addEventListener('input', () => {
        inputCmd.style.height = 'auto';
        inputCmd.style.height = `${Math.min(inputCmd.scrollHeight, 120)}px`;
    });

    inputCmd.addEventListener('keydown', (event) => {
        if (event.key === 'Enter' && !event.shiftKey) {
            event.preventDefault();
            btnSendCmd.click();
        }
    });

    async function fireTask(rawText) {
        showToast('Senal enviada a cubierta. Inyectando fisicamente.');
        try {
            const response = await fetch(`${API_URL}/tasks`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ rawText })
            });

            if (!response.ok) throw new Error('500 internal');
            const data = await response.json();
            showToast(`Orden inyectada: ${data.id} (${data.tokens} tokens)`);
            await hydrate();
        } catch (error) {
            showToast('La API esta dormida o rechazo el comando.');
        }
    }

    const overlay = document.getElementById('event-viewer-overlay');
    const btnCloseModal = document.getElementById('btn-close-modal');
    const modalQueryTitle = document.getElementById('modal-query-title');
    const modalEventsList = document.getElementById('modal-events-list');

    btnCloseModal.addEventListener('click', () => {
        collapseExpandedEventRow();
        overlay.classList.add('hidden');
    });

    overlay.addEventListener('click', (e) => {
        if(e.target === overlay) {
            collapseExpandedEventRow();
            overlay.classList.add('hidden');
        }
    });

    document.addEventListener('click', (event) => {
        if (expandedLogbookRow && !expandedLogbookRow.contains(event.target)) {
            collapseExpandedLogbookRow();
        }
        if (expandedEventRow && !expandedEventRow.contains(event.target)) {
            collapseExpandedEventRow();
        }
    });

    function renderBugs(bugs) {
        const bugsBody = document.getElementById('bugs-body');
        const historyBody = document.getElementById('bugs-history-body');
        const bugChip = document.getElementById('bug-count-chip');
        if (!bugsBody || !historyBody) return;

        bugsBody.innerHTML = '';
        historyBody.innerHTML = '';

        const pendingStatuses = ['open', 'active', 'in_progress', 'inbox'];
        
        // 0. Filter by Project
        const projectBugs = bugs.filter(b => belongsToProject(b.id, currentProject));

        // 1. Separar Activos de Historial
        const activeItems = projectBugs.filter(b => pendingStatuses.includes((b.status || '').toLowerCase()));
        const historyItems = projectBugs.filter(b => !pendingStatuses.includes((b.status || '').toLowerCase()));

        // 2. Contador de Bugs (Excluir Glitches y Lola Risks de los vivos)
        if (bugChip) {
            const realOpenBugs = activeItems.filter(b => b.type === 'bug');
            if (realOpenBugs.length > 0) {
                bugChip.textContent = String(realOpenBugs.length);
                bugChip.style.display = 'inline-block';
            } else {
                bugChip.style.display = 'none';
            }
        }

        // 3. Renderizar Activos
        if (activeItems.length === 0) {
            bugsBody.innerHTML = '<tr><td colspan="6" class="logbook-empty">Sin incidencias activas. El sistema esta limpio.</td></tr>';
        } else {
            activeItems.forEach(item => bugsBody.appendChild(createBugRow(item)));
        }

        // 4. Renderizar Historial
        if (historyItems.length === 0) {
            historyBody.innerHTML = '<tr><td colspan="6" class="logbook-empty">Historial vacio.</td></tr>';
        } else {
            historyItems.forEach(item => historyBody.appendChild(createBugRow(item)));
        }
    }

    function createBugRow(item) {
        const sevLabel = { 
            critical: 'Ã°Å¸â€Â´ CRITICAL', 
            high: 'Ã°Å¸Å¸Â  HIGH', 
            medium: 'Ã°Å¸Å¸Â¡ MEDIUM', 
            low: 'Ã°Å¸Å¸Â¢ LOW', 
            glitch: 'Ã°Å¸Å¸Â£ GLITCH',
            lola: 'Ã°Å¸â€˜ÂÃ¯Â¸Â LOLA'
        };
        const sevClass = { 
            critical: 'sev-critical', 
            high: 'sev-high', 
            medium: 'sev-medium', 
            low: 'sev-low', 
            glitch: 'sev-glitch',
            lola: 'sev-lola'
        };

        const tr = document.createElement('tr');
        tr.className = 'logbook-row';
        const bugId = String(item.id || '').trim();
        
        // Determinar severidad y clase
        let sev = (item.severity || 'medium').toLowerCase();
        if (item.type === 'glitch') sev = 'glitch';
        if (item.type === 'lola_alert') sev = 'lola';

        const dateStr = item.reportedAt ? item.reportedAt.replace('Atlantic/Canary', '').trim() : '--';
        const sevText = {
            critical: 'CRITICAL',
            high: 'HIGH',
            medium: 'MEDIUM',
            low: 'LOW',
            glitch: 'GLITCH',
            lola: 'LOLA'
        }[sev] || sev.toUpperCase();
        
        tr.innerHTML = `
            <td class="col-sev"><span class="sev-chip ${sevClass[sev] || 'sev-medium'}">${sevText}</span></td>
            <td class="col-id"><span class="event-link bug-id-link">${safeHtml(item.id)}</span></td>
            <td class="col-voice">${safeHtml(item.reportedBy || (item.type === 'lola_alert' ? 'LOLA' : '--'))}</td>
            <td class="col-subject">${safeHtml(item.subject || item.snippet || '--')}</td>
            <td class="col-status"><span class="task-zone ${safeHtml(item.status)}">${safeHtml(item.status)}</span></td>
            <td class="col-date">${safeHtml(formatMaritimeDate(dateStr, item.timestamp_precision || 'minute'))}</td>
        `;

        if (bugId) {
            tr.addEventListener('click', () => window.openEventInPanel(bugId));
            const idLink = tr.querySelector('.bug-id-link');
            if (idLink) {
                idLink.addEventListener('click', (ev) => {
                    ev.stopPropagation();
                    window.openEventInPanel(bugId);
                });
            }
        }
        return tr;
    }

    async function loadBugs() {
        try {
            // Cargar Bugs y Riesgos en paralelo
            const [bugsRes, risksRes] = await Promise.all([
                fetch(`${API_URL}/bugs`),
                fetch(`${API_URL}/risks`)
            ]);
            
            const bugsData = await bugsRes.json();
            const risksData = await risksRes.json();
            
            const allBugs = (bugsData.bugs || []).map(b => {
                let type = b.type;
                if (!type && b.severity && b.severity.toLowerCase() === 'glitch') type = 'glitch';
                if (!type) type = 'bug';
                return { ...b, type };
            });
            const lolaAlerts = (risksData.risks || [])
                .filter(r => r.id.startsWith('LOLA-RISK-'))
                .map(r => ({
                    id: r.id,
                    type: 'lola_alert',
                    severity: 'lola',
                    reportedBy: 'LOLA',
                    subject: r.snippet,
                    status: (r.state || 'active').toLowerCase() === 'mitigado' ? 'done' : 'active',
                    reportedAt: r.id.split('-').pop().slice(0, 10) // Mock date from ID
                }));

            allRawBugs = [...allBugs, ...lolaAlerts];
            renderBugs(allRawBugs);
        } catch(e) {
            console.log('Error silente al cargar incidencias', e);
        }
    }

    const lolaAlertsHistory = new Set();

    async function loadRisks() {
        const lolaChip = document.getElementById('lola-count-chip-main');
        
        try {
            const res = await fetch(`${API_URL}/risks`);
            const data = await res.json();
            const activeRisks = data.risks || [];
            
            // Eliminado conflicto de contador: las misiones se gestionan en hydrate() desde el state real.
            // if (activeMissionsCount) activeMissionsCount.textContent = String(data.active_missions || 0);

            const lolaRisks = activeRisks.filter((risk) => isLolaRiskRecord(risk));
            const generalRisks = activeRisks.filter((risk) => !isLolaRiskRecord(risk));

            // Contador principal: alertas operativas no-Lola.
            if (activeAlertsCount) activeAlertsCount.textContent = String(generalRisks.length);

            if (lolaChip) {
                lolaChip.textContent = String(lolaRisks.length);
            }

            lolaRisks.forEach(risk => {
                if (!lolaAlertsHistory.has(risk.id)) {
                    lolaAlertsHistory.add(risk.id);
                    showLolaToast(risk.snippet);
                }
            });

        } catch(e) {
            console.log('Error silente al procesar riesgos', e);
            if (activeAlertsCount) activeAlertsCount.innerText = '--';
        }
    }

    function showLolaToast(message) {
        const bin = document.getElementById('toast-bin');
        const toast = document.createElement('div');
        toast.className = 'toast lola-alert-toast';
        toast.innerHTML = `
            <div class="toast-header">
                <span class="lola-eye">Ã°Å¸â€˜ÂÃ¯Â¸Â</span>
                <strong>ALERTA DE LA SOMBRA (LOLA)</strong>
            </div>
            <p>${safeHtml(message)}</p>
        `;
        const eye = toast.querySelector('.lola-eye');
        if (eye) eye.textContent = 'LOLA';
        bin.appendChild(toast);
        setTimeout(() => toast.remove(), 8000);
    }

    async function loadForest() {
        if (!forestContainer) return;
        try {
            const res = await fetch(`${API_URL}/files`);
            const data = await res.json();
            renderForest(data.tree || []);
            forestLoaded = true;
        } catch (e) {
            forestContainer.innerHTML = '<p class="empty-copy">Error conectando con el Bosque.</p>';
        }
    }

    function renderForest(tree) {
        forestContainer.innerHTML = `
            <div class="card glass-panel">
                <div class="card-header">
                    <h3>Explorador del Bosque</h3>
                    <p class="logbook-subtitle">Navegacion fisica del runtime local.</p>
                </div>
                <div class="forest-layout">
                    <div class="forest-tree" id="forest-tree-root"></div>
                    <div class="forest-preview" id="forest-preview-pane">
                        <p class="empty-copy">Selecciona un archivo para previsualizar su esencia.</p>
                    </div>
                </div>
            </div>
        `;

        const root = document.getElementById('forest-tree-root');
        renderTreeLevel(tree, root);
    }

    function renderTreeLevel(nodes, container) {
        nodes.forEach(node => {
            const div = document.createElement('div');
            div.className = `tree-node ${node.isDir ? 'is-directory' : 'is-file'}`;
            
            const label = document.createElement('div');
            label.className = 'node-label';
            label.innerHTML = `
                <span class="node-icon">${node.isDir ? 'Ã°Å¸â€œÂ' : 'Ã°Å¸â€œâ€ž'}</span>
                <span class="node-name">${safeHtml(node.name)}</span>
            `;
            const nodeIcon = label.querySelector('.node-icon');
            if (nodeIcon) nodeIcon.textContent = node.isDir ? '[DIR]' : '[FILE]';

            if (node.isDir) {
                const childrenContainer = document.createElement('div');
                childrenContainer.className = 'node-children hidden';
                renderTreeLevel(node.children || [], childrenContainer);
                
                label.onclick = (e) => {
                    e.stopPropagation();
                    childrenContainer.classList.toggle('hidden');
                };
                div.appendChild(label);
                div.appendChild(childrenContainer);
            } else {
                label.onclick = () => previewFile(node.path);
                div.appendChild(label);
            }
            container.appendChild(div);
        });
    }

    async function previewFile(path) {
        const pane = document.getElementById('forest-preview-pane');
        pane.innerHTML = '<p class="empty-copy">Extrayendo datos...</p>';
        try {
            const res = await fetch(`${API_URL}/files/content?path=${encodeURIComponent(path)}`);
            const data = await res.json();
            pane.innerHTML = `
                <div class="preview-header">
                    <h4>${safeHtml(path)}</h4>
                </div>
                <div class="preview-content">
                    <pre><code>${safeHtml(data.content)}</code></pre>
                </div>
            `;
        } catch (e) {
            pane.innerHTML = '<p class="empty-copy" style="color:var(--accent-neon)">Fallo al leer el archivo fÃƒÂ­sico.</p>';
        }
    }

    async function loadVellocino() {
        if (!vellocinoContainer) return;
        try {
            const res = await fetch(`${API_URL}/knowledge`);
            const data = await res.json();
            renderVellocino(data.items || []);
            vellocinoLoaded = true;
        } catch (e) {
            vellocinoContainer.innerHTML = '<p class="empty-copy">Error invocando el Vellocino.</p>';
        }
    }

    // --- HERMENEUTICA / GLOBAL SEARCH ---
    const hermeneuticOverlay = overlay;
    const hermeneuticSearchInput = document.getElementById('hermeneutic-search-input');
    const btnHermeneutics = document.getElementById('btn-hermeneutics');
    const btnRunHermeneutics = document.getElementById('btn-run-hermeneutics');

    function openHermeneutics(defaultQuery = '') {
        hermeneuticOverlay.style.display = '';
        hermeneuticOverlay.classList.remove('hidden');
        if (defaultQuery) {
            hermeneuticSearchInput.value = defaultQuery;
            runHermeneuticSearch(defaultQuery);
        }
        hermeneuticSearchInput.focus();
    }

    function closeHermeneutics() {
        hermeneuticOverlay.classList.add('hidden');
        hermeneuticOverlay.style.display = '';
    }

    async function runHermeneuticSearch(query) {
        if (!query) return;
        modalEventsList.innerHTML = '<p class="empty-copy">Exhumando registros transversales...</p>';

        try {
            const res = await fetch(`${API_URL}/events?query=${encodeURIComponent(query)}`);
            const data = await res.json();
            renderHermeneuticHits(data.hits || []);
        } catch (e) {
            modalEventsList.innerHTML = '<p class="empty-copy" style="color:#ff5555">Error en la conexion hermeneutica.</p>';
        }

        // Si la query parece un packet ID, también cargar transcripts de todas las IAs
        if (/^(ARG|ID)-\d+$/i.test(query.trim())) {
            renderPacketTranscripts(query.trim());
        }
    }

    async function renderPacketTranscripts(packetId) {
        try {
            const res = await fetch(`${API_URL}/transcript/packet?packetId=${encodeURIComponent(packetId)}`);
            if (!res.ok) return;
            const data = await res.json();
            const blocks = data.transcripts || [];
            if (blocks.length === 0) return;

            const section = document.createElement('div');
            section.className = 'hermeneutic-transcript-section';
            section.innerHTML = `<h4 class="transcript-section-title">📄 Transcripts — ${safeHtml(packetId)}</h4>`;

            blocks.forEach((block) => {
                const div = document.createElement('div');
                div.className = 'hermeneutic-hit glass-panel';
                div.innerHTML = `
                    <span class="hit-source">${safeHtml(block.agent)} · ${safeHtml(block.date || '')}</span>
                    <div class="hit-content transcript-block-content">${renderMultiline(block.content || '')}</div>
                `;
                section.appendChild(div);
            });

            modalEventsList.appendChild(section);
        } catch (err) {
            console.warn('No se pudo cargar el transcript del packet:', err);
        }
    }

    function renderHermeneuticHits(hits) {
        modalEventsList.innerHTML = '';
        if (hits.length === 0) {
            modalEventsList.innerHTML = '<p class="empty-copy">No se han encontrado resonancias para este patron.</p>';
            return;
        }

        hits.forEach(hit => {
            const div = document.createElement('div');
            div.className = 'hermeneutic-hit glass-panel';
            div.innerHTML = `
                <span class="hit-source">${safeHtml(hit.source)}</span>
                <div class="hit-content">${renderMultiline(hit.content)}</div>
            `;
            modalEventsList.appendChild(div);
        });
    }

    btnHermeneutics.addEventListener('click', () => openHermeneutics());
    btnCloseModal.addEventListener('click', closeHermeneutics);
    btnRunHermeneutics.addEventListener('click', () => runHermeneuticSearch(hermeneuticSearchInput.value));
    
    hermeneuticSearchInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') runHermeneuticSearch(hermeneuticSearchInput.value);
    });

    // Vinculo global: clicks en ID de tareas abren hermeneutica
    window.openEventInPanel = (id) => {
        openHermeneutics(id);
    };

    // ============ DELETE CONFIRMATION MODAL ============
    const deleteConfirmationModal = document.getElementById('delete-confirmation-modal');
    const btnCloseDeleteModal = document.getElementById('btn-close-delete-modal');
    const btnCancelDelete = document.getElementById('btn-cancel-delete');
    const btnConfirmDelete = document.getElementById('btn-confirm-delete');
    const btnDeleteTasks = document.getElementById('btn-delete-tasks');
    const selectAllCheckbox = document.getElementById('select-all-tasks');
    const deleteTaskList = document.getElementById('delete-task-list');

    function openDeleteConfirmation() {
        if (!deleteConfirmationModal || selectedTasks.size === 0) return;

        // Build list of tasks to delete
        deleteTaskList.innerHTML = '';
        selectedTasks.forEach(taskId => {
            const task = pendingTasks.find(t => t.id === taskId);
            if (task) {
                const item = document.createElement('div');
                item.className = 'task-delete-item';
                item.innerHTML = `
                    <span class="task-delete-item-id">${safeHtml(task.id)}</span>
                    <span class="task-delete-item-title">${safeHtml(task.title)}</span>
                `;
                deleteTaskList.appendChild(item);
            }
        });

        // Update count
        const deleteCount = document.getElementById('delete-count');
        if (deleteCount) deleteCount.textContent = String(selectedTasks.size);

        deleteConfirmationModal.classList.remove('hidden');
        deleteConfirmationModal.style.display = 'flex';
    }

    function closeDeleteConfirmation() {
        if (deleteConfirmationModal) {
            deleteConfirmationModal.classList.add('hidden');
            deleteConfirmationModal.style.display = 'none';
        }
    }

    async function confirmDelete() {
        closeDeleteConfirmation();
        showToast('Borrando ordenes seleccionadas...');

        try {
            const taskIds = Array.from(selectedTasks);
            const response = await fetch(`${API_URL}/tasks/delete`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ taskIds })
            });

            if (!response.ok) {
                showToast('Error al borrar ordenes.');
                return;
            }

            showToast(`âœ“ ${taskIds.length} orden(es) movida(s) a papelera.`);
            selectedTasks.clear();
            updateTaskSelection();

            // Reload tasks
            await hydrate();
        } catch (e) {
            showToast('Error de conexion al borrar ordenes.');
            console.error('Delete error:', e);
        }
    }

    // Event listeners for delete modal
    btnDeleteTasks?.addEventListener('click', openDeleteConfirmation);
    btnCloseDeleteModal?.addEventListener('click', closeDeleteConfirmation);
    btnCancelDelete?.addEventListener('click', closeDeleteConfirmation);
    btnConfirmDelete?.addEventListener('click', confirmDelete);

    selectAllCheckbox?.addEventListener('change', (e) => {
        if (e.target.checked) {
            pendingTasks.forEach(task => selectedTasks.add(task.id));
        } else {
            selectedTasks.clear();
        }
        updateTaskSelection();

        // Update all checkboxes
        document.querySelectorAll('.task-checkbox').forEach(checkbox => {
            checkbox.checked = e.target.checked;
        });
    });

    function renderVellocino(items) {
        vellocinoContainer.innerHTML = `
            <div class="card glass-panel">
                <div class="card-header">
                    <h3>El Vellocino de Oro</h3>
                    <p class="logbook-subtitle">Protocolos, KIs y Sabiduria Estructural.</p>
                </div>
                <div class="ki-grid"></div>
            </div>
        `;

        const grid = vellocinoContainer.querySelector('.ki-grid');
        items.forEach(item => {
            const card = document.createElement('div');
            card.className = 'ki-card glass-panel';
            card.innerHTML = `
                <div class="ki-icon">*</div>
                <h4>${safeHtml(item.name)}</h4>
                <p>Archivo: ${safeHtml(item.path)}</p>
                <button class="btn btn-small">Consultar</button>
            `;
            card.onclick = () => previewFile(item.path);
            grid.appendChild(card);
        });
    }

    async function loadSources() {
        if (!sourcesBody) return;
        sourcesBody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding: 20px;">Sincronizando con el puente de mando...</td></tr>';
        try {
            const res = await fetch(`${API_URL}/sources`);
            const data = await res.json();
            renderSources(data.sources || []);
            sourcesLoaded = true;
        } catch (e) {
            sourcesBody.innerHTML = '<tr><td colspan="5" style="text-align:center; color: var(--accent-neon); padding: 20px;">Fallo al contactar con el muelle de carga (API).</td></tr>';
        }
    }

    function renderSources(sources) {
        sourcesBody.innerHTML = '';
        if (sources.length === 0) {
            sourcesBody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding: 20px;">No se han detectado repositorios GitHub en la carpeta ARGOS.</td></tr>';
            return;
        }

        sources.forEach(source => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td><strong>${safeHtml(source.name)}</strong></td>
                <td>${safeHtml(source.branch)}</td>
                <td><span class="task-zone ${source.status === 'clean' ? 'done' : 'open'}">${safeHtml(source.status)}</span></td>
                <td style="font-family: monospace; font-size: 0.85em;">${safeHtml(source.remote)}</td>
                <td>
                    <button class="btn btn-secondary btn-sync" data-name="${safeHtml(source.name)}">
                        Sincronizar
                    </button>
                </td>
            `;
            
            const syncBtn = tr.querySelector('.btn-sync');
            syncBtn.onclick = async () => {
                syncBtn.disabled = true;
                syncBtn.textContent = 'Sincronizando...';
                try {
                    const res = await fetch(`${API_URL}/sources/sync`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ name: source.name })
                    });
                    const result = await res.json();
                    if (result.ok) {
                        showToast(`Sincronizado: ${source.name}`);
                    } else {
                        showToast(`Error: ${result.error || 'Fallo desconocido'}`);
                    }
                } catch (e) {
                    showToast(`Error de red al sincronizar ${source.name}`);
                } finally {
                    loadSources();
                }
            };
            
            sourcesBody.appendChild(tr);
        });
    }

    // Refresco periodico ligero: evita endpoints pesados en cada ciclo.
    const originalHydrate = hydrate;
    hydrate = async function() {
        await originalHydrate();
        await Promise.all([loadRisks(), loadBugs(), loadTokens()]);
    };

    await hydrate();
    if (initialTarget === 'view-bitacora') await loadLogbookSnapshot();
    if (initialTarget === 'view-bosque') await loadForest();
    if (initialTarget === 'view-vellocino') await loadVellocino();
    if (initialTarget === 'view-fuentes') await loadSources();
    setInterval(() => {
        hydrate();
    }, 10000);

    // ============ SUBSCRIBE TO TOKENS UPDATES VIA SSE ============
    // When API publishes tokens:updated event, refresh token display immediately
    try {
        const eventSource = new EventSource(`${API_URL.replace('/api', '')}/api/subscribe/dashboard`);
        eventSource.addEventListener('message', (event) => {
            try {
                const data = JSON.parse(event.data);
                if (data.topic === 'tokens:updated') {
                    loadTokens();
                }
                // Actualizar Estado de IAs en tiempo real sin esperar al polling
                if (data.topic === 'ia:status_changed' && data.payload) {
                    const { agent, status, subject, task } = data.payload;
                    // Mantener el cache sincronizado con el evento SSE
                    if (agent && cachedIaStatus[agent] !== undefined) {
                        cachedIaStatus[agent] = {
                            ...(cachedIaStatus[agent] || {}),
                            status,
                            task: task || '',
                            task_subject: subject || ''
                        };
                    }
                    const node = document.querySelector(`[data-ia-status="${agent}"]`);
                    if (node) {
                        if (status === 'restricted') {
                            node.textContent = `RESTRINGIDO: ${task || 'Tokens agotados'}`;
                            node.style.color = '#ffa500';
                        } else if (status === 'active') {
                            const label = subject ? subject : (task || 'En misión');
                            node.textContent = `En misión: ${label}`;
                            node.style.color = 'var(--accent-neon)';
                        } else {
                            node.textContent = 'Standby';
                            node.style.color = 'var(--text-secondary)';
                        }
                    }
                }
            } catch (e) {
                // Ignore parsing errors
            }
        });
        eventSource.addEventListener('error', () => {
            console.log('SSE connection closed or error');
            eventSource.close();
        });
    } catch (e) {
        console.warn('Could not establish SSE connection for token updates:', e);
    }
});

// Heartbeat check for Autonomous Watcher
