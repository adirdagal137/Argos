Sí, pero conviene corregir la imagen mental: **DeepSeek no va a “gestionar el runtime” de tu web**. Lo que vas a montar en tu máquina es un **servidor local de inferencia**; tu sitio web local lo consumirá por API, normalmente en `http://localhost`. DeepSeek será el **modelo**, no el proceso que sirve HTML, Node, PHP o Python. ([vLLM][1])

La vía más simple hoy para un entorno local es esta:

1. **Instalas Ollama** en tu máquina. Está disponible para macOS, Windows y Linux. En Windows sirve la API en `http://localhost:11434`, y localmente no requiere autenticación. ([Ollama][2])
2. **Descargas un modelo DeepSeek** con Ollama, por ejemplo `deepseek-r1:1.5b`, `7b`, `8b`, `14b`, `32b`, etc. La biblioteca de Ollama muestra esa familia y sus tamaños. ([Ollama][3])
3. **Tu web local** llama a la API de Ollama por HTTP. Ollama expone endpoints propios como `/api/chat` y también ofrece compatibilidad con parte de la API de OpenAI. ([Ollama][4])

## Qué necesitas de verdad

Depende del tamaño del modelo que quieras mover.

Para **probar y desarrollar**:

* CPU moderna
* **16 GB de RAM** como suelo mínimo razonable
* bastante disco libre
* mejor aún una GPU, pero no es obligatoria para arrancar modelos pequeños

Ollama indica que el binario en Windows necesita al menos **4 GB de espacio**, y luego los modelos pueden ocupar **decenas o cientos de GB**. Además, la capacidad de contexto y concurrencia depende de la memoria disponible, sea RAM en CPU o VRAM en GPU. ([Ollama][5])

Para que no te engañes:

* `deepseek-r1:1.5b` en Ollama pesa alrededor de **1.1 GB**. ([Ollama][3])
* El tag `deepseek-r1:latest` en Ollama aparece alrededor de **5.2 GB** y con ventana de contexto de **128K** en su ficha. ([Ollama][6])
* Ollama ajusta por defecto la longitud de contexto según la VRAM: menos de 24 GiB suele dejarlo en **4k**, entre 24 y 48 GiB en **32k**, y a partir de 48 GiB en **256k**. ([Ollama][7])

## Recomendación honesta

Si tu objetivo es **usar DeepSeek dentro de un sitio web local**, no empieces por un modelo enorme. Empieza así:

* **1.5B o 7B** si tu máquina es modesta
* **8B** si tienes una máquina decente
* **32B o más** solo si tienes hardware serio

El error típico aquí es querer “DeepSeek grande” en un portátil corriente y acabar con latencia insoportable o con el sistema muerto por memoria.

## Instalación rápida con Ollama

### En Linux

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

Ollama publica ese instalador para Linux. ([Ollama][8])

### En Windows

PowerShell:

```powershell
irm https://ollama.com/install.ps1 | iex
```

O descargas el instalador. Ollama pide Windows 10 22H2 o posterior; si tienes NVIDIA, recomienda driver 452.39 o más reciente; si tienes AMD, driver Radeon correspondiente. ([Ollama][9])

### En macOS

Se descarga desde Ollama; la página actual indica macOS 14 Sonoma o superior. ([Ollama][10])

## Descargar y arrancar DeepSeek

Ejemplo mínimo:

```bash
ollama run deepseek-r1:1.5b
```

Eso te baja el modelo y abre chat local. La ficha oficial de Ollama muestra justamente ese comando para `deepseek-r1:1.5b`. ([Ollama][3])

Si luego tu web quiere usarlo por API, puedes hacer algo así:

```bash
curl http://localhost:11434/api/chat -d '{
  "model": "deepseek-r1:1.5b",
  "messages": [
    { "role": "user", "content": "Hola" }
  ]
}'
```

Ese patrón está documentado por Ollama para sus modelos y su API local. ([Ollama][3])

## Cómo conectarlo a tu web local

### Backend Node.js

```js
const express = require('express');
const app = express();

app.use(express.json());

app.post('/ai', async (req, res) => {
  const prompt = req.body.prompt ?? '';

  const r = await fetch('http://localhost:11434/api/chat', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      model: 'deepseek-r1:1.5b',
      messages: [{ role: 'user', content: prompt }],
      stream: false
    })
  });

  const data = await r.json();
  res.json(data);
});

app.listen(3000, () => {
  console.log('Web local en http://localhost:3000');
});
```

La arquitectura correcta es:

* tu frontend llama a **tu backend**
* tu backend llama a **Ollama en localhost**
* Ollama responde con el texto del modelo

No expongas directamente el modelo al navegador salvo que sepas bien lo que haces.

## Cuándo usar vLLM en vez de Ollama

Si buscas algo más cercano a producción local, especialmente con GPU fuerte, **vLLM** puede ser mejor. Su servidor es compatible con la API de OpenAI y arranca con `vllm serve ...`; por defecto sirve en `http://localhost:8000/v1`. ([vLLM][1])

DeepSeek indica además que los modelos **DeepSeek-R1-Distill** pueden servirse con vLLM, por ejemplo:

```bash
vllm serve deepseek-ai/DeepSeek-R1-Distill-Qwen-32B --tensor-parallel-size 2 --max-model-len 32768 --enforce-eager
```

y también aclara que, para R1, **Transformers no estaba soportado directamente** en esa documentación. ([GitHub][11])

Eso te dice algo importante: si no tienes necesidad real de exprimir GPU o montar algo más robusto, **Ollama te ahorra dolor**.

## Si tienes GPU AMD o NVIDIA

Ollama soporta GPU AMD vía ROCm; en Linux pide ROCm v7 y en Windows ROCm v6.1 para ciertos modelos soportados. ([Ollama][12])
En Windows también exige drivers adecuados para NVIDIA o AMD. ([Ollama][13])

## Ruta recomendada para no perder tiempo

Haz esto en este orden:

```bash
# 1) Instalar Ollama
# Linux:
curl -fsSL https://ollama.com/install.sh | sh

# 2) Probar el modelo
ollama run deepseek-r1:1.5b

# 3) Llamarlo por API
curl http://localhost:11434/api/chat -d '{
  "model": "deepseek-r1:1.5b",
  "messages": [{"role": "user", "content": "Resume este texto"}]
}'
```

Luego conectas tu backend local a ese endpoint.

## Lo que probablemente estás omitiendo

No necesitas solo “instalar DeepSeek”. Necesitas decidir estas cuatro cosas:

* **sistema operativo**
* **RAM**
* **GPU y VRAM**
* **si quieres desarrollo cómodo o algo cercano a producción**

Sin eso, la pregunta técnica está coja. Un portátil sin GPU dedicada puede mover algo pequeño. Un modelo grande no. Ahí se rompe la fantasía.

Si me dices **tu sistema operativo, RAM, CPU y GPU**, te doy el plan exacto para tu máquina, con comandos concretos y qué tamaño de DeepSeek te conviene.

[1]: https://docs.vllm.ai/en/stable/serving/openai_compatible_server/ "OpenAI-Compatible Server - vLLM"
[2]: https://docs.ollama.com/quickstart "Quickstart - Ollama"
[3]: https://ollama.com/library/deepseek-r1%3A1.5b "deepseek-r1:1.5b"
[4]: https://docs.ollama.com/api/introduction?utm_source=chatgpt.com "Introduction"
[5]: https://docs.ollama.com/windows "Windows - Ollama"
[6]: https://ollama.com/library/deepseek-r1/tags?utm_source=chatgpt.com "Tags · deepseek-r1"
[7]: https://docs.ollama.com/context-length "Context length - Ollama"
[8]: https://ollama.com/?utm_source=chatgpt.com "Ollama"
[9]: https://ollama.com/download/windows?utm_source=chatgpt.com "Download Ollama on Windows"
[10]: https://ollama.com/download?utm_source=chatgpt.com "Download Ollama on Linux"
[11]: https://github.com/deepseek-ai/deepseek-r1 "GitHub - deepseek-ai/DeepSeek-R1 · GitHub"
[12]: https://docs.ollama.com/gpu "Hardware support - Ollama"
[13]: https://docs.ollama.com/windows?utm_source=chatgpt.com "Windows"
