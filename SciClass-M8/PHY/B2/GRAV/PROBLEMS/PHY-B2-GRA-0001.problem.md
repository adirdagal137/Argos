# PHY-B2-GRA-0001 — Problema

## Metadatos mínimos
- id: PHY-B2-GRA-0001
- entity_role: problem
- título: Campo gravitatorio terrestre a 400 km de altura
- disciplina: Física
- nivel: 2º de Bachillerato
- tema: campo gravitatorio
- tags: gravitación, campo gravitatorio, fuerza gravitatoria, órbita baja, PAU
- estado: drafting
- prioridad: high
- dificultad: media

## Convención canónica
- ID nuclear: `PHY-B2-GRA-0001`
- disciplinas: `PHY / CHE / MAT / BIO / TEC`
- nombre de archivo recomendado: `PHY-B2-GRA-0001.problem.md`

## Enunciado
Un objeto de masa `75 kg` se encuentra a `400 km` sobre la superficie terrestre. Suponiendo la Tierra esférica y usando:

- `G = 6,67 · 10^-11 N·m²/kg²`
- `M_T = 5,97 · 10^24 kg`
- `R_T = 6,37 · 10^6 m`

calcula:

1. la intensidad del campo gravitatorio terrestre en esa posición,
2. la fuerza gravitatoria que actúa sobre el objeto,
3. el porcentaje que representa ese campo respecto al valor superficial calculado con los mismos datos.

## Datos
- masa del objeto: `m = 75 kg`
- altura sobre la superficie: `h = 400 km = 4,00 · 10^5 m`
- radio terrestre: `R_T = 6,37 · 10^6 m`
- masa terrestre: `M_T = 5,97 · 10^24 kg`
- constante gravitatoria: `G = 6,67 · 10^-11 N·m²/kg²`
- distancia al centro terrestre: `r = R_T + h = 6,77 · 10^6 m`

## Objetivo
Distinguir entre campo gravitatorio y fuerza gravitatoria, y evitar el error de usar la altura como si fuera la distancia al centro de la Tierra.

## Resolución por capas

### Capa 1 — Núcleo intuitivo
A `400 km` de altura no se está "fuera de la gravedad". La distancia al centro de la Tierra ha aumentado poco comparada con el radio terrestre, así que el campo debe ser algo menor que en la superficie, pero todavía intenso.

### Capa 2 — Formalización y magnitudes
La intensidad del campo gravitatorio creado por la Tierra a distancia `r` del centro es:

`g(r) = G M_T / r²`

La fuerza sobre una masa `m` situada en ese campo es:

`F = m g(r)`

Para comparar con la superficie:

`g_0 = G M_T / R_T²`

### Capa 3 — Desarrollo matemático
Distancia correcta al centro:

`r = R_T + h = 6,37 · 10^6 + 4,00 · 10^5 = 6,77 · 10^6 m`

Campo a esa altura:

`g(r) = (6,67 · 10^-11 · 5,97 · 10^24) / (6,77 · 10^6)^2`

`g(r) ≈ 8,69 N/kg`

Fuerza sobre el objeto:

`F = 75 · 8,69 ≈ 6,52 · 10^2 N`

Campo superficial con los mismos datos:

`g_0 = (6,67 · 10^-11 · 5,97 · 10^24) / (6,37 · 10^6)^2 ≈ 9,81 N/kg`

Comparación:

`g(r) / g_0 · 100 ≈ 88,5 %`

### Capa 4 — Verificación del resultado
El resultado es físicamente razonable: el campo disminuye al alejarse del centro de la Tierra, pero a `400 km` de altura sigue siendo casi el `90 %` del valor superficial. Esto desmonta la idea de que en órbita baja "casi no hay gravedad".

## Respuesta final
- intensidad del campo gravitatorio: `g ≈ 8,69 N/kg`
- fuerza sobre el objeto: `F ≈ 6,52 · 10^2 N`
- comparación con el valor superficial: `g ≈ 88,5 % de g_0`

## Errores típicos
- usar `r = 400 km` en lugar de `r = R_T + h`
- confundir `g` con una constante universal igual a `9,8 m/s²`
- creer que el campo depende de la masa del objeto de `75 kg`
- calcular la fuerza sin distinguir antes el campo
- interpretar la ingravidez orbital como ausencia de campo gravitatorio

## Variantes
1. Repetir el cálculo para `h = 1000 km`.
2. Calcular a qué altura el campo se reduce a la mitad del valor superficial.
3. Comparar la fuerza sobre objetos de `50 kg`, `75 kg` y `100 kg` manteniendo la misma posición.
4. Conectar el resultado con una discusión sobre caída libre orbital.

## Enlaces internos
- concepto asociado: FIS-B2-GRA-001 — Campo gravitatorio e intensidad del campo gravitatorio
- concepto asociado: FIS-B2-GRA-004 — Órbitas, velocidad orbital y velocidad de escape
- ficha de clase asociada: CLS-PHY-B2-GRA-0001_v01.md
- assets asociados: pendiente
