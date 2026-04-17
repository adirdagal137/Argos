# PHY-B2-GRA-0003 — Problema

## Metadatos mínimos
- id: PHY-B2-GRA-0003
- entity_role: problem
- título: Caída radial desde 2000 km usando conservación de la energía
- disciplina: Física
- nivel: 2º de Bachillerato
- tema: trabajo gravitatorio y conservación de la energía mecánica
- tags: gravitación, conservación de la energía, caída radial, energía potencial, PAU
- estado: drafting
- prioridad: high
- dificultad: media-alta

## Convención canónica
- ID nuclear: `PHY-B2-GRA-0003`
- disciplinas: `PHY / CHE / MAT / BIO / TEC`
- nombre de archivo recomendado: `PHY-B2-GRA-0003.problem.md`

## Enunciado
Una cápsula de masa `1000 kg` se suelta desde el reposo a una altura de `2000 km` sobre la superficie terrestre y cae radialmente hacia la Tierra. Desprecia el rozamiento atmosférico y considera que solo actúa la fuerza gravitatoria. Usando:

- `G = 6,67 · 10^-11 N·m²/kg²`
- `M_T = 5,97 · 10^24 kg`
- `R_T = 6,37 · 10^6 m`

calcula la rapidez con la que llegaría a la superficie terrestre según el modelo ideal.

## Datos
- masa de la cápsula: `m = 1000 kg`
- altura inicial: `h = 2000 km = 2,00 · 10^6 m`
- radio inicial: `r_1 = R_T + h = 8,37 · 10^6 m`
- radio final: `r_2 = R_T = 6,37 · 10^6 m`
- velocidad inicial: `v_1 = 0`
- masa terrestre: `M_T = 5,97 · 10^24 kg`
- constante gravitatoria: `G = 6,67 · 10^-11 N·m²/kg²`

## Objetivo
Usar conservación de la energía mecánica con energía potencial gravitatoria negativa, sin recurrir a la aproximación de campo uniforme.

## Resolución por capas

### Capa 1 — Núcleo intuitivo
La cápsula parte del reposo y cae hacia una región de potencial más negativo. La energía potencial disminuye y esa diferencia se transforma en energía cinética. Por tanto, la velocidad final debe ser positiva y elevada.

### Capa 2 — Formalización y magnitudes
Como solo actúa la fuerza gravitatoria, la energía mecánica se conserva:

`E_c1 + E_p1 = E_c2 + E_p2`

Con:

- `E_c = 1/2 m v²`
- `E_p = - G M_T m / r`

Como `v_1 = 0`:

`- G M_T m / r_1 = 1/2 m v_2² - G M_T m / r_2`

La masa de la cápsula se cancela:

`v_2 = sqrt[2 G M_T (1/r_2 - 1/r_1)]`

### Capa 3 — Desarrollo matemático
Radios:

`r_1 = 6,37 · 10^6 + 2,00 · 10^6 = 8,37 · 10^6 m`

`r_2 = 6,37 · 10^6 m`

Sustitución:

`v_2 = sqrt[2 · 6,67 · 10^-11 · 5,97 · 10^24 · (1/(6,37 · 10^6) - 1/(8,37 · 10^6))]`

Resultado:

`v_2 ≈ 5,47 · 10^3 m/s`

Equivalente:

`v_2 ≈ 5,47 km/s`

### Capa 4 — Verificación del resultado
La velocidad no depende de la masa de la cápsula, porque tanto la energía cinética como la energía potencial contienen el factor `m`. El resultado es mayor que el que se obtendría con una caída cotidiana, pero el modelo ignora atmósfera, frenado y límites materiales.

## Respuesta final
La rapidez ideal de llegada a la superficie sería:

`v_2 ≈ 5,47 · 10^3 m/s ≈ 5,47 km/s`

## Errores típicos
- usar `E_p = m g h` en un salto de altura demasiado grande sin justificar la aproximación
- perder el signo negativo de `E_p = -G M_T m / r`
- medir `r_1` como `2000 km` en lugar de `R_T + h`
- pensar que la masa de `1000 kg` debe afectar a la velocidad final
- usar conservación de energía sin comprobar que no se han incluido rozamientos o motores

## Variantes
1. Repetir el problema con altura inicial `1000 km`.
2. Calcular la energía cinética final de la cápsula de `1000 kg`.
3. Resolver el problema inverso: hallar desde qué altura debe soltarse para llegar a `3,00 km/s`.
4. Comparar con la estimación `v = sqrt(2gh)` y discutir el límite de la aproximación de campo uniforme.

## Enlaces internos
- concepto asociado: FIS-B2-GRA-002 — Potencial gravitatorio y energía potencial gravitatoria
- concepto asociado: FIS-B2-GRA-003 — Trabajo de la fuerza gravitatoria y conservación de la energía mecánica
- ficha de clase asociada: pendiente
- assets asociados: pendiente
