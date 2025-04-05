# Coding Dream - Simulador de Bolas Interactivas

Un juego interactivo desarrollado con LÖVE (Love2D) que simula la física de bolas con colisiones y trayectorias múltiples.

## Características

- **Bolas Dinámicas**
  - Colores aleatorios
  - Tamaños variables
  - Colisiones realistas entre bolas
  - Rebotes en los bordes de la ventana

- **Sistema de Control**
  - Click izquierdo: Seleccionar una bola
  - Click derecho: Mover la bola seleccionada
  - Shift + Click derecho: Agregar puntos a la trayectoria

- **Física**
  - Sistema de colisiones entre bolas
  - Impulsos y rebotes realistas
  - Fricción gradual en los movimientos
  - Trayectorias suaves y precisas

- **Visualización**
  - Líneas de trayectoria semi-transparentes
  - Resaltado de la bola seleccionada
  - Visualización de toda la secuencia de movimientos

## Estructura del Proyecto

```
📁 codingDream/
 ├── 📄 main.lua           # Punto de entrada del juego
 ├── 📄 conf.lua           # Configuración de LÖVE
 ├── 📁 src/
 │    ├── 📁 entities/     # Entidades del juego
 │    │    └── bola.lua    # Clase bola
 │    ├── 📁 systems/      # Sistemas del juego
 │    │    └── physics.lua # Sistema de física
 │    └── 📁 game/         # Lógica del juego
 │         └── world.lua   # Gestión del mundo
 └── 📁 assets/            # Recursos (futuros)
```

## Cómo Jugar

1. **Seleccionar una Bola**
   - Usa el click izquierdo para seleccionar una bola
   - La bola seleccionada se resaltará con un contorno blanco

2. **Mover una Bola**
   - Click derecho para establecer un punto objetivo
   - La bola se moverá suavemente hacia ese punto

3. **Crear Secuencias de Movimiento**
   - Mantén presionado Shift
   - Usa click derecho para agregar puntos a la trayectoria
   - La bola seguirá la secuencia de puntos en orden

## Detalles Técnicos

- **Sistema de Física**
  - Detección de colisiones precisa
  - Factor de rebote: 0.8
  - Factor de fricción: 0.96
  - Umbral de movimiento: 2 píxeles

- **Arquitectura**
  - Programación orientada a objetos
  - Sistemas modulares y reutilizables
  - Separación clara de responsabilidades

## Próximas Mejoras

- [ ] Agregar efectos de sonido
- [ ] Implementar diferentes tipos de bolas
- [ ] Añadir obstáculos en el escenario
- [ ] Crear niveles predefinidos
- [ ] Mejorar efectos visuales
