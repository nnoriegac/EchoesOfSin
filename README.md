
# Echoes of Sin – TFG Videojuego 2D

**Autor:** Natalia Noriega  
**Grado:** Ingeniería Informática – UOC  
**Curso:** Trabajo de Fin de Grado  
**Género:** Terror psicológico 2D (pixel art)

## Descripción del proyecto

Echoes of Sin es un prototipo jugable (MVP) de un videojuego 2D de terror psicológico desarrollado como Trabajo de Fin de Grado.  
El juego combina exploración, gestión limitada de recursos y decisiones narrativas que afectan al desarrollo de la historia y a su desenlace final.

El jugador despierta sin recuerdos en el jardín de una mansión siniestra y, a medida que avanza, descubre su pasado y debe enfrentarse a las consecuencias de sus decisiones.

## Estado del proyecto

Este repositorio contiene la **versión Gold Master (final)** correspondiente a la **PEC4**, junto con el código fuente completo y la documentación del proyecto.

## Tecnologías principales

- **Motor**: Godot Engine 4.x (2D)
- **Arte**: Aseprite (sprites y tilesets) y Piskel (bocetos rápidos, pruebas)
- **Control de versiones**: Git + GitHub

## Estructura del repositorio

- `/project/` – Archivos del proyecto de Godot  
  - `scenes/` – Escenas del juego (niveles, UI, etc.)  
  - `scripts/` – Scripts GDScript y lógica de juego  
  - `sprites/` – Sprites, tilesets y animaciones  
  - `sounds/` – Efectos de sonido y música  
  - `shaders/` – Shaders 2D para efectos de luz, distorsión, etc.  

- `/docs/` – Documentación del TFG (GDD, diagramas, capturas)  
- `/export/` – Builds jugables por PEC (no se versionan los ejecutables)
    /PEC2
    /PEC3
    /PEC4
        EchoesOfSin_PEC4.zip   <-- ejecutable final

## Cómo abrir el proyecto

1. Clonar el repositorio:

   ```bash
   git clone https://github.com/nnoriegac/EchoesOfSin.git

2. Ir a la carpeta de export de la PEC4:
EchoesOfSin/export/PEC2/

3. Ejecutar:
EchoesOfSin_PEC4.exe

(probado en Windows 10/11).
No es necesario tener Godot instalado para jugar la build exportada.

## Controles

Movimiento: WASD o flechas

Recoger armas, llaves, interactuar: Se mostrará un mensaje cuando puedas interactuar con un personaje u objeto, puslando la tecla E se realiza la interacción.

Disparar: Clic izquierdo del ratón.

Curarse: Clic derecgo del ratón.

Correr: Tecla Shift.
