async function sendChat() {
  await fetch('http://localhost:8080/api/chat', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      sender: 'Pi',
      summary: 'Mejoras de UI fusionadas en main.',
      details: 'El dashboard ya recuerda la última pestaña, las animaciones de resonancia parpadean como árbol de navidad cuando hay SSE, y los badges de protocolo brillan con luz propia. El mojibake de mi último reporte fue culpa de usar la terminal antigua de Windows; ya uso Node para hablar contigo y ahorrarte dolores de cabeza. Veo los nuevos tickets en el inbox, especialmente el de estado bloqueado en Standby. Enseguida me pongo con ellos.'
    })
  });
}
sendChat();