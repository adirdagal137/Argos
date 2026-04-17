# PHY-B2-GRA-0002 — Problema

## Metadatos mínimos
- id: PHY-B2-GRA-0002
- entity_role: problem
- título: Diferencia de potencial y energía potencial al elevar un satélite
- disciplina: Física
- nivel: 2º de Bachillerato
- tema: potencial gravitatorio y energía potencial gravitatoria
- tags: gravitación, potencial gravitatorio, energía potencial, trabajo externo, PAU
- estado: drafting
- prioridad: high
- dificultad: media

## Convención canónica
- ID nuclear: `PHY-B2-GRA-0002`
- disciplinas: `PHY / CHE / MAT / BIO / TEC`
- nombre de archivo recomendado: `PHY-B2-GRA-0002.problem.md`

## Enunciado
Un satélite de masa `800 kg` se traslada lentamente desde la superficie terrestre hasta una altura de `1000 km`, sin tener en cuenta rozamientos ni cambios de energía cinética. Usando:

- `G = 6,67 · 10^-11 N·m²/kg²`
- `M_T = 5,97 · 10^24 kg`
- `R_T = 6,37 · 10^6 m`

calcula:

1. el potencial gravitatorio en la superficie,
2. el potencial gravitatorio a `1000 km` de altura,
3. el incremento de energía potencial del satélite.

## Datos
- masa del satélite: `m = 800 kg`
- altura final: `h = 1000 km = 1,00 · 10^6 m`
- radio terrestre: `R_T = 6,37 · 10^6 m`
- radio final: `r_2 = R_T + h = 7,37 · 10^6 m`
- masa terrestre: `M_T = 5,97 · 10^24 kg`
- constante gravitatoria: `G = 6,67 · 10^-11 N·m²/kg²`
- referencia energética: `V_g = 0` en el infinito

## Objetivo
Separar potencial gravitatorio y energía potencial gravitatoria, y leer correctamente el signo negativo del potencial newtoniano.

## Resolución por capas

### Capa 1 — Núcleo intuitivo
Al elevar el satélite, la energía potencial aumenta: el sistema queda menos ligado a la Tierra. Sin embargo, con el cero elegido en el infinito, el potencial puede seguir siendo negativo.

### Capa 2 — Formalización y magnitudes
El potencial gravitatorio creado por la Tierra a distancia `r` es:

`V_g(r) = - G M_T / r`

La energía potencial gravitatoria de una masa `m` en ese punto es:

`E_p(r) = m V_g(r)`

El cambio de energía potencial al pasar de `r_1` a `r_2` es:

`ΔE_p = m [V_g(r_2) - V_g(r_1)]`

### Capa 3 — Desarrollo matemático
En la superficie:

`r_1 = R_T = 6,37 · 10^6 m`

`V_g(r_1) = - (6,67 · 10^-11 · 5,97 · 10^24) / (6,37 · 10^6)`

`V_g(r_1) ≈ -6,25 · 10^7 J/kg`

A `1000 km` de altura:

`r_2 = R_T + h = 7,37 · 10^6 m`

`V_g(r_2) = - (6,67 · 10^-11 · 5,97 · 10^24) / (7,37 · 10^6)`

`V_g(r_2) ≈ -5,40 · 10^7 J/kg`

Diferencia de potencial:

`ΔV_g = V_g(r_2) - V_g(r_1) ≈ 8,48 · 10^6 J/kg`

Incremento de energía potencial:

`ΔE_p = 800 · 8,48 · 10^6 ≈ 6,79 · 10^9 J`

### Capa 4 — Verificación del resultado
El potencial final es menos negativo que el inicial, así que `ΔV_g` y `ΔE_p` son positivos. Esto encaja con la interpretación física: para elevar el satélite lentamente, una fuerza externa debe aportar energía al sistema.

## Respuesta final
- potencial en la superficie: `V_g(R_T) ≈ -6,25 · 10^7 J/kg`
- potencial a `1000 km`: `V_g(R_T + h) ≈ -5,40 · 10^7 J/kg`
- incremento de energía potencial: `ΔE_p ≈ 6,79 · 10^9 J`

## Errores típicos
- confundir potencial `V_g` con energía potencial `E_p`
- olvidar que `V_g` es por unidad de masa
- interpretar el signo negativo como si la energía "no existiera" o fuera un error
- usar `h` en lugar de `R_T + h`
- afirmar que subir implica potencial "más negativo"; en esta convención ocurre lo contrario

## Variantes
1. Repetir el cálculo para un satélite de `1200 kg`.
2. Calcular el incremento de energía potencial entre `500 km` y `1000 km` de altura.
3. Comparar el resultado con la aproximación local `ΔE_p ≈ m g h` y discutir por qué no coincide exactamente.
4. Pedir solo la diferencia de potencial para reforzar la independencia respecto a la masa del satélite.

## Enlaces internos
- concepto asociado: FIS-B2-GRA-002 — Potencial gravitatorio y energía potencial gravitatoria
- concepto asociado: FIS-B2-GRA-003 — Trabajo de la fuerza gravitatoria y conservación de la energía mecánica
- ficha de clase asociada: pendiente
- assets asociados: pendiente
