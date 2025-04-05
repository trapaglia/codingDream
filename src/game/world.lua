local bola = require "src/entities/bola"
local physics = require "src/systems/physics"

--- @class world
--- @field bolas table Lista de bolas en el mundo
--- @field bola_selected bola Bola actualmente seleccionada
local world = {
    bolas = {},
    bola_selected = nil
}

--- Inicializa el mundo con un número de bolas
--- @param num_bolas number
--- @param ancho number
--- @param alto number
function world:init(num_bolas, ancho, alto)
    self.bolas = {}
    for _ = 1, num_bolas do
        local nueva_bola = bola.new()
        nueva_bola.position[1] = math.random(nueva_bola.radio, ancho - nueva_bola.radio)
        nueva_bola.position[2] = math.random(nueva_bola.radio, alto - nueva_bola.radio)
        nueva_bola.target_location[1] = nueva_bola.position[1]
        nueva_bola.target_location[2] = nueva_bola.position[2]
        table.insert(self.bolas, nueva_bola)
    end
end

--- Actualiza la lógica del mundo
--- @param dt number
--- @param ancho number
--- @param alto number
function world:update(dt, ancho, alto)
    -- Primero actualizamos posiciones y física
    for _, bola in ipairs(self.bolas) do
        -- Actualizar el objetivo actual si es necesario
        bola:update_target()
        -- Actualizar movimiento
        bola:update_movement(dt)
        -- Actualizar física
        physics.update_physics(bola, dt)
        physics.handle_border_collision(bola, ancho, alto)
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

        -- Dibujamos la bola
        love.graphics.setColor(bola.color)
        love.graphics.circle("fill", bola.position[1], bola.position[2], bola.radio)
        
        if bola.selected then
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("line", bola.position[1], bola.position[2], bola.radio + 4)
        end
    end
end

--- Maneja el evento de click del mouse
--- @param x number
--- @param y number
--- @param button number
--- @param shift boolean
function world:handle_mouse_click(x, y, button, shift)
    if button == 1 then  -- Click izquierdo: selección
        self.bola_selected = nil
        for _, bola in ipairs(self.bolas) do
            local distancia = math.sqrt((x - bola.position[1])^2 + (y - bola.position[2])^2)
            if distancia <= bola.radio then
                for _, otraBola in ipairs(self.bolas) do
                    otraBola.selected = false
                end
                bola.selected = true
                self.bola_selected = bola
                break
            end
        end
        if not self.bola_selected then
            for _, bola in ipairs(self.bolas) do
                bola.selected = false
            end
        end
    elseif button == 2 and self.bola_selected then  -- Click derecho: mover
        if not shift then
            self.bola_selected.path_queue = {}
        end
        self.bola_selected:add_target(x, y)
    end
end

return world
