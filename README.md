# EchoesOfSin
Prototipo 2D de terror psicológico en Godot para el TFG “Echoes of Sin”.

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

## Cómo abrir el proyecto

1. Clonar el repositorio:

   ```bash
   git clone https://github.com/nnoriegac/EchoesOfSin.git

2. Ir a la carpeta de export de la PEC2:
EchoesOfSin/export/PEC2/

3. Ejecutar:
EchoesOfSin_PEC2.exe

(probado en Windows 10/11).
No es necesario tener Godot instalado para jugar la build exportada.

## Controles

Movimiento: WASD o flechas

Interacción: acercarse al objeto (arma); la recogida se realiza automáticamente al entrar en el área.

## Contenido del prototipo (PEC2)

En esta versión se ha implementado:

- Escena inicial: jardín invernal abandonado, construido con un TileMap y tiles 32×32
que simulan barro, piedras y charcos.

- Personaje jugable:
  - Movimiento en 2D con CharacterBody2D.
  - Colisiones básicas contra los límites de la zona.
  - Cámara que sigue al jugador mediante Camera2D.

- Interacción clave:
  -Objeto recogible (arma) en el jardín.
  - Al recogerlo se muestra un mensaje en pantalla:
    "Has recogido el arma"
  - El objeto desaparece tras ser recogido.

- HUD simple:
  - Capa CanvasLayer con un Label para mostrar mensajes temporales.
  - El mensaje se oculta automáticamente tras unos segundos.

## Errores conocidos

Durante la ejecución en el editor de Godot pueden aparecer avisos en la consola tipo:
- The TileSetAtlasSource atlas has no tile at (x, y)
- Cannot create tile. The tile is outside the texture or tiles are already present in the space the tile would cover

Estos mensajes están relacionados con la edición del TileSet y el TileMap (celdas que en algún momento apuntaban a tiles que ya no existen en el atlas), pero no afectan a la jugabilidad ni impiden la ejecución de la build exportada.
Se consideran una mejora técnica pendiente para iteraciones futuras.
