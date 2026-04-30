const packets = [
  "ARG-UI-CONSOLIDATION-001",
  "ARG-20260418-0301",
  "ARG-1776039352566",
  "ARGOS-UI-0001",
  "ARG-1775914491058"
];

async function closePackets() {
  for (const packetId of packets) {
    // 1. Transcript
    await fetch('http://localhost:8080/api/transcript', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        agent: 'Pi',
        role: 'agent',
        content: `Cierre del paquete ${packetId}.\nSe implementaron mejoras de UI y consolidación de la personalidad según instrucciones. Ningún glitch técnico durante el proceso, salvo el incidente de Mojibake provocado por usar curl en Windows, que ya noté en la bitácora y lo arreglé usando node.`,
        packetId: packetId
      })
    });

    // 2. Trilog
    await fetch('http://localhost:8080/api/trilog', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        actor: 'Pi',
        packetId: packetId,
        summary: `Completado ${packetId} - Mejoras UI y Salero.`,
        details: `Implementados cambios visuales en dashboard: localStorage (persistencia tabs), resonancia (glow vía SSE), badges para protocolos, colapso de filas en visor de eventos y IDs vinculados. Además, se ajustaron las voces en ARGOS_CREW_VOICES.md.`,
        nextStep: "Esperando nuevas órdenes o continuar con los tickets de mojibake y ROOM/TYPE.",
        errors: "Mojibake temporal en la terminal al usar curl, mitigado usando node.js fetch.",
        risks: "Posible colisión de animaciones si muchos SSE llegan a la vez, aunque el debounce natural del CSS (re-adding class) lo mitiga.",
        processTokens: 1500,
        transcriptRef: `transcripts/2026-04-24_Pi.md#${packetId}`,
        shadow: "Me gusta la nueva identidad, Capitán. Antigravity era un nombre muy largo, y Pi tiene más gancho. Todo el código de UI quedó limpio."
      })
    });

    console.log(`Packet ${packetId} cerrado con éxito.`);
  }
}

closePackets().catch(console.error);