# Coding Dream - Batalla de Bolas

Un juego de estrategia desarrollado con LÖVE (Love2D) donde controlas equipos de bolas que luchan entre sí.

## Características

- **Sistema de Batalla**
  - Dos equipos: Azul y Verde
  - Estadísticas aleatorias para cada bola:
    - Ataque (1-100)
    - Salud (50-150)
    - Velocidad de ataque (0.5-2s)
  - Combate automático entre equipos
  - Sistema de escape estratégico

- **Sistema de Control**
  - Click izquierdo: Seleccionar bolas
  - Shift + Click izquierdo: Selección múltiple
  - Click derecho: Mover bolas seleccionadas
  - Shift + Click derecho: Agregar puntos a la trayectoria
  - Arrastrar: Selección por área

- **Física y Movimiento**
  - Colisiones realistas entre bolas
  - Impulsos y rebotes dinámicos
  - Velocidad aumentada al escapar
  - Trayectorias suaves con interpolación

- **Visualización**
  - Color basado en el equipo y poder
  - Tamaño basado en la salud máxima
  - Barra de vida dinámica
  - Efectos visuales de ataque
  - Líneas de trayectoria

## Estructura del Proyecto

```
📁 codingDream/
 ├── 📄 main.lua           # Punto de entrada del juego
 ├── 📄 conf.lua           # Configuración de LÖVE
 ├── 📁 src/
 │    ├── 📁 entities/     # Entidades del juego
 │    │    └── bola.lua    # Clase bola con lógica de combate
 │    ├── 📁 systems/      # Sistemas del juego
 │    │    ├── physics.lua # Sistema de física y colisiones
 │    │    └── input.lua   # Sistema de control
 │    └── 📁 game/         # Lógica del juego
 │         └── world.lua   # Gestión del mundo y equipos
 └── 📁 assets/            # Recursos (futuros)
```

## Mecánicas de Juego

1. **Selección y Control**
   - Selecciona bolas individuales con click izquierdo
   - Usa Shift para selección múltiple
   - Arrastra para seleccionar un área
   - Click derecho para mover las bolas seleccionadas

2. **Combate**
   - Las bolas de equipos diferentes luchan automáticamente al colisionar
   - El daño se basa en el poder de ataque
   - La velocidad de ataque determina la frecuencia de golpes
   - La salud determina cuánto daño pueden recibir

3. **Estrategia**
   - Usa la selección múltiple para coordinar ataques
   - Planifica rutas de escape para bolas débiles
   - Aprovecha el tamaño y velocidad de cada bola
   - Mantén las bolas del mismo equipo cerca para apoyo

## Detalles Técnicos

- **Sistema de Física**
  - Detección precisa de colisiones
  - Impulsos variables según el estado
  - Fricción dinámica
  - Rebotes elásticos en bordes

- **Sistema de Combate**
  - Daño = 10% del poder de ataque
  - Velocidad de ataque personalizada
  - Sistema de destello visual
  - Cambio aleatorio de objetivos

## Próximas Mejoras

- [ ] Habilidades especiales por equipo
- [ ] Powerups y mejoras temporales
- [ ] Modos de juego adicionales
- [ ] Sistema de progresión
- [ ] Efectos de sonido
- [ ] Partículas y efectos visuales mejorados
- [ ] Mapas con obstáculos
- [ ] IA para modo un jugador
