---@diagnostic disable: undefined-global
local bola = require "src/entities/bola"
local physics = require "src/systems/physics"
local input = require "src/systems/input"

--- @class world
--- @field bolas table Lista de bolas en el mundo
local world = {
    bolas = {}
}

--- Inicializa el mundo con las bolas de cada equipo
--- @param ancho number
--- @param alto number
function world:init(ancho, alto)
    self.bolas = {}
    self.ancho = ancho
    self.alto = alto
    
    -- Configuración de equipos
    local bolas_por_equipo = 3
    local margen = 50  -- Margen desde los bordes
    local espaciado = 80  -- Espacio entre bolas del mismo equipo
    
    -- Crear equipo azul (arriba)
    local y_azul = margen
    for i = 1, bolas_por_equipo do
        local x = self.ancho/2 + (i - (bolas_por_equipo + 1)/2) * espaciado
        local nueva_bola = bola.new('blue', {x, y_azul})
        table.insert(self.bolas, nueva_bola)
    end
    
    -- Crear equipo verde (abajo)
    local y_verde = self.alto - margen
    for i = 1, bolas_por_equipo do
        local x = self.ancho/2 + (i - (bolas_por_equipo + 1)/2) * espaciado
        local nueva_bola = bola.new('green', {x, y_verde})
        table.insert(self.bolas, nueva_bola)
    end
end

--- Actualiza la lógica del mundo
--- @param dt number
function world:update(dt)
    -- Primero actualizamos posiciones y física
    for _, bola in ipairs(self.bolas) do
        -- Actualizar la bola (incluye ataque, movimiento y targets)
        bola:update(dt)
        -- Actualizar física
        physics.update_physics(bola, dt)
        physics.handle_border_collision(bola, self.ancho, self.alto)
    end
    
    -- Luego verificamos colisiones entre bolas
    for i = 1, #self.bolas - 1 do
        for j = i + 1, #self.bolas do
            physics.check_collision(self.bolas[i], self.bolas[j])
        end
    end
end

--- Dibuja todos los elementos del mundo
function world:draw()
    -- Dibujar la caja de selección si está arrastrando
    input:draw()

    for _, bola in ipairs(self.bolas) do
        -- Dibujamos las líneas de trayectoria
        if #bola.path_queue > 0 then
            love.graphics.setLineWidth(4)
            love.graphics.setColor(bola.color[1], bola.color[2], bola.color[3], 0.5)
            
            -- Dibujamos una línea desde la posición actual al primer objetivo
            love.graphics.line(bola.position[1], bola.position[2], 
                             bola.target_location[1], bola.target_location[2])
            
            -- Dibujamos líneas entre todos los puntos de la cola
            for i = 1, #bola.path_queue - 1 do
                local punto_actual = bola.path_queue[i]
                local punto_siguiente = bola.path_queue[i + 1]
                love.graphics.line(punto_actual[1], punto_actual[2], 
                                 punto_siguiente[1], punto_siguiente[2])
            end
            
            love.graphics.setLineWidth(1)
        end

        -- Dibujamos la bola con su barra de vida
        bola:draw(bola.selected)
    end
end

--- Maneja el evento de click del mouse
--- @param x number
--- @param y number
--- @param button number
--- @param shift boolean
function world:handle_mouse_click(x, y, button, shift)
    input:handle_mouse_click(self, x, y, button, shift)
end

--- Maneja el evento de movimiento del mouse
--- @param x number
--- @param y number
function world:handle_mouse_moved(x, y)
    input:handle_mouse_moved(self, x, y)
end

--- Maneja el evento de soltar el click del mouse
--- @param x number
--- @param y number
--- @param button number
--- @param shift boolean
function world:handle_mouse_released(x, y, button, shift)
    input:handle_mouse_released(self, x, y, button, shift)
end

return world
