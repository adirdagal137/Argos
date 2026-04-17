# FIS-B2-GRA-004 — Concepto nuclear

## Concepto
Órbitas, velocidad orbital y velocidad de escape.

## Intuición física / matemática
Una órbita no es una caída cancelada por una fuerza misteriosa. Es una caída continua en la que el cuerpo posee suficiente velocidad tangencial para no chocar con el astro y seguir “rodeándolo”.

La gravedad no desaparece en órbita: precisamente mantiene la curvatura de la trayectoria. Sin gravedad, el cuerpo se movería en línea recta; con gravedad, su dirección cambia continuamente.

La pregunta clave no es solo “qué fuerza actúa”, sino “qué combinación de distancia, velocidad y energía permite que el movimiento sea ligado o no ligado”.

La velocidad orbital expresa la rapidez necesaria para mantener una órbita circular a un cierto radio. La velocidad de escape expresa la rapidez mínima para que la energía mecánica total deje de ser negativa y el cuerpo pueda alejarse indefinidamente sin aporte posterior.

## Definición operativa
Para una órbita circular de radio r alrededor de una masa M:
- fuerza gravitatoria = fuerza centrípeta
- GMm / r^2 = m v_orb^2 / r
- velocidad orbital: v_orb = √(GM / r)

Periodo orbital de la órbita circular:
- T = 2πr / v_orb = 2π √(r^3 / GM)

Velocidad de escape desde una distancia r al centro:
- condición energética mínima: Em = 0
- 1/2 m v_esc^2 - GMm / r = 0
- velocidad de escape: v_esc = √(2GM / r)

Relación útil:
- v_esc = √2 · v_orb

Lectura energética:
- órbita ligada: Em < 0
- caso límite de escape: Em = 0
- trayectoria no ligada: Em > 0

## Condiciones de uso
- la fórmula de velocidad orbital dada aquí vale para órbitas circulares
- la velocidad de escape se obtiene suponiendo ausencia de rozamiento y sin impulso posterior tras el lanzamiento
- el modelo supone masa del satélite despreciable frente a la masa central
- la distancia r debe medirse al centro del astro, no a la superficie salvo que luego se sustituya r = R
- conviene distinguir claramente entre velocidad orbital, velocidad de escape y periodo orbital; no son variantes de una misma magnitud

## Límites y malentendidos frecuentes
- **No decir que en órbita “no hay gravedad”.** Hay gravedad; de hecho, es la causa de la órbita.
- **No confundir ingravidez aparente con ausencia de campo gravitatorio.** Un astronauta puede estar en caída libre dentro de un campo intenso.
- **No usar la fórmula de velocidad orbital para trayectorias no circulares sin justificarlo.**
- **No pensar que escapar significa dejar de notar gravedad instantáneamente.** Significa poder alejarse indefinidamente con energía total no negativa.
- **No medir r desde la superficie cuando la fórmula exige distancia al centro.**
- **No separar dinámica y energía como si fueran mundos distintos.** La órbita circular puede leerse por fuerza centrípeta y también por balance energético.

## Mini ejemplo
Un satélite orbita la Tierra en una órbita circular de radio r medido desde el centro terrestre.

Velocidad orbital:
- v_orb = √(GM_T / r)

Periodo:
- T = 2π √(r^3 / GM_T)

Velocidad de escape desde esa misma distancia:
- v_esc = √(2GM_T / r)

Comparación:
- v_esc = √2 · v_orb

Lectura física:
La velocidad orbital permite seguir ligado a la Tierra en órbita circular. La velocidad de escape marca el umbral para dejar de estar gravitatoriamente ligado sin necesidad de nuevo empuje.

## Conexiones curriculares
- se apoya en FIS-B2-GRA-001 sobre campo gravitatorio
- se apoya en FIS-B2-GRA-002 sobre potencial y energía potencial
- se apoya en FIS-B2-GRA-003 sobre trabajo gravitatorio y conservación de la energía
- prepara la lectura física de Kepler como expresión de la dinámica gravitatoria
- sirve de puente entre problemas de satélites, energía orbital y aplicaciones astrofísicas elementales

## Enlaces internos
- problema asociado: pendiente
- ficha de clase asociada: pendiente
