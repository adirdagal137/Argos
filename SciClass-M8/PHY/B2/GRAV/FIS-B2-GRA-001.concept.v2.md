# FIS-B2-GRA-001 — Concepto nuclear

## Concepto
Campo gravitatorio e intensidad del campo gravitatorio.

## Intuición física / matemática
Una masa no solo "atrae" cuando otra masa está tocándola o muy cerca. Modifica el espacio que la rodea de tal forma que cualquier otra masa situada allí experimenta una interacción dirigida hacia ella.

El campo gravitatorio es precisamente esa forma de describir la influencia de una masa fuente sin tener que hablar cada vez de la fuerza concreta entre dos cuerpos completos. Primero describimos el campo creado por la masa fuente; después, si colocamos una masa de prueba en un punto, obtenemos la fuerza multiplicando por esa masa.

La idea decisiva es ésta: **campo no es fuerza**. El campo pertenece al espacio generado por la masa fuente; la fuerza aparece cuando una segunda masa entra en juego.

## Definición operativa
La intensidad del campo gravitatorio en un punto se define como la fuerza gravitatoria por unidad de masa que experimentaría una masa de prueba colocada en ese punto.

En forma operativa:
- escalar radial en módulo: g = GM / r^2
- vectorial: **g** = - GM / r^2 · **u_r**
- relación con la fuerza: **F** = m **g**

Donde:
- G es la constante de gravitación universal
- M es la masa fuente
- r es la distancia al centro de la masa fuente en los casos esféricos o puntuales
- **u_r** es el vector unitario radial saliente
- el signo menos indica que el campo apunta hacia la masa fuente

## Condiciones de uso
- válida de forma exacta para masas puntuales
- válida para distribuciones esféricamente simétricas, en el exterior, como si toda la masa estuviera concentrada en el centro
- en proximidad de la superficie terrestre puede aproximarse por un campo casi uniforme con g ≈ 9,8 m/s²
- requiere distinguir entre la masa fuente M y la masa de prueba m
- cuando se use forma vectorial, debe explicitarse la dirección radial y el sentido entrante del campo

## Límites y malentendidos frecuentes
- **No confundir campo con fuerza.** El campo no depende de la masa de prueba; la fuerza sí.
- **No usar g = 9,8 m/s² fuera de contexto.** Ese valor es una aproximación local cerca de la superficie terrestre, no una ley universal constante.
- **No olvidar el carácter vectorial.** El campo tiene módulo, dirección y sentido.
- **No borrar el centro físico del problema.** La distancia r se mide al centro de la masa fuente cuando el modelo es esférico.
- **No mezclar intensidad de campo con potencial.** El campo es vectorial; el potencial es escalar.
- **No pensar que un objeto en órbita está fuera del campo gravitatorio.** Está justamente inmerso en él.

## Mini ejemplo
Calcular la intensidad del campo gravitatorio creado por la Tierra a una altura h sobre su superficie.

Datos:
- masa de la Tierra: M_T
- radio terrestre: R_T
- distancia al centro: r = R_T + h

Resultado:
- módulo del campo: g(h) = G M_T / (R_T + h)^2
- dirección: radial hacia el centro de la Tierra

Lectura física:
Si h aumenta, el campo disminuye con 1/r². No desaparece de golpe; se debilita progresivamente.

## Conexiones curriculares
- prepara el paso a potencial gravitatorio y energía potencial
- fundamenta el estudio de trabajo y conservación de la energía en gravitación
- sirve de base para movimiento orbital y velocidad orbital
- conecta con el concepto previo de campo eléctrico por analogía estructural, aunque con signo físico distinto en la interacción

## Enlaces internos
- problema asociado: pendiente
- ficha de clase asociada: pendiente
