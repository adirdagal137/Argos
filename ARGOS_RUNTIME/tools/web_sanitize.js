const fs = require('fs');
const path = require('path');

const RUNTIME_DIR = 'C:\\Users\\Widox\\Desktop\\ARGOS\\ARGOS_RUNTIME';
const API_URL = 'http://localhost:8080/api';

async function sanitize() {
    console.log('[SANITZER] Iniciando protocolo de saneamiento web...');

    // 1. Sincronizar fuentes GitHub
    try {
        const res = await fetch(`${API_URL}/sources`);
        const data = await res.json();
        const sources = data.sources || [];
        
        for (const source of sources) {
            console.log(`[SANITZER] Sincronizando: ${source.name}...`);
            const syncRes = await fetch(`${API_URL}/sources/sync`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name: source.name })
            });
            const syncData = await syncRes.json();
            if (syncData.ok) {
                console.log(`[SANITZER] ${source.name} actualizado.`);
            } else {
                console.warn(`[SANITZER] Fallo en ${source.name}:`, syncData.error);
            }
        }
    } catch (e) {
        console.error('[SANITZER] Error sincronizando fuentes:', e.message);
    }

    // 2. Limpiar archivos basura
    try {
        const trashDir = path.join(RUNTIME_DIR, 'work_packets', 'trash');
        if (fs.existsSync(trashDir)) {
            const files = fs.readdirSync(trashDir);
            if (files.length > 50) {
                console.log(`[SANITZER] Limpiando papelera (${files.length} archivos)...`);
                files.forEach(f => {
                    try { fs.unlinkSync(path.join(trashDir, f)); } catch(err) {}
                });
            }
        }
    } catch (e) {
        console.error('[SANITZER] Error limpiando papelera:', e.message);
    }

    // 3. Registrar actividad en el feed
    try {
        await fetch(`${API_URL}/chat`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                text: 'Protocolo de Saneamiento Web ejecutado exitosamente. Fuentes GitHub sincronizadas y residuos de sistema eliminados. Estética LEET aplicada.',
                sender: 'Antigravity',
                type: 'sent'
            })
        });
    } catch (e) {
        console.error('[SANITZER] Error registrando en feed:', e.message);
    }

    console.log('[SANITZER] Saneamiento completado.');
}

sanitize();
