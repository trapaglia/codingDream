---@diagnostic disable: undefined-global
local bola = require "src/entities/bola"
local physics = require "src/systems/physics"

--- @class world
--- @field bolas table Lista de bolas en el mundo
--- @field bola_selected bola Bola actualmente seleccionada
--- @field drag_start table Punto inicial del arrastre {x, y}
--- @field is_dragging boolean Si está arrastrando para selección múltiple
--- @field current_drag table Punto actual del arrastre {x, y}
--- @field initial_selection table Estado de selección al iniciar el arrastre
--- @field has_moved boolean Si el mouse se ha movido desde el click inicial
local world = {
    bolas = {},
    bola_selected = nil,
    drag_start = {},
    is_dragging = false,
    current_drag = {},
    initial_selection = {},  -- Guarda el estado inicial de selección
    has_moved = false       -- Para distinguir entre click y arrastre
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

--- Verifica si una bola está dentro de un rectángulo
--- @param bola table
--- @param x1 number
--- @param y1 number
--- @param x2 number
--- @param y2 number
--- @return boolean
local function is_ball_in_rect(bola, x1, y1, x2, y2)
    local min_x = math.min(x1, x2)
    local max_x = math.max(x1, x2)
    local min_y = math.min(y1, y2)
    local max_y = math.max(y1, y2)
    
    return bola.position[1] >= min_x and bola.position[1] <= max_x and
           bola.position[2] >= min_y and bola.position[2] <= max_y
end

--- Actualiza la selección de bolas basada en el rectángulo actual
--- @param shift boolean
function world:update_selection(shift)
    -- Si no está presionado shift, deseleccionar todas las bolas al empezar el arrastre
    if not shift and self.has_moved then
        for _, bola in ipairs(self.bolas) do
            bola.selected = false
        end
    end
    
    -- Seleccionamos las bolas dentro del rectángulo
    for _, bola in ipairs(self.bolas) do
        if is_ball_in_rect(bola, self.drag_start[1], self.drag_start[2], 
                          self.current_drag[1], self.current_drag[2]) then
            bola.selected = true
        end
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
    -- Dibujar la caja de selección si está arrastrando
    if self.is_dragging and self.drag_start and self.current_drag then
        love.graphics.setColor(1, 1, 1, 0.3)  -- Blanco semi-transparente
        love.graphics.rectangle("fill", 
            self.drag_start[1], 
            self.drag_start[2], 
            self.current_drag[1] - self.drag_start[1], 
            self.current_drag[2] - self.drag_start[2]
        )
        love.graphics.setColor(1, 1, 1, 0.8)  -- Borde más visible
        love.graphics.rectangle("line", 
            self.drag_start[1], 
            self.drag_start[2], 
            self.current_drag[1] - self.drag_start[1], 
            self.current_drag[2] - self.drag_start[2]
        )
    end

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
        -- Guardar estado inicial de selección
        self.initial_selection = {}
        for i, bola in ipairs(self.bolas) do
            self.initial_selection[i] = bola.selected
        end

        -- Iniciar potencial arrastre
        self.drag_start = {x, y}
        self.current_drag = {x, y}
        self.is_dragging = true
        self.has_moved = false
        
        -- Verificar si hizo click directamente en una bola
        local clicked_ball = false
        for _, bola in ipairs(self.bolas) do
            local distancia = math.sqrt((x - bola.position[1])^2 + (y - bola.position[2])^2)
            if distancia <= bola.radio then
                clicked_ball = true
                if not shift then
                    -- Si no está presionado shift, deseleccionar todas las demás
                    for _, otraBola in ipairs(self.bolas) do
                        otraBola.selected = false
                    end
                end
                bola.selected = true
                break
            end
        end
        
        -- Si no hizo click en ninguna bola y no está presionado shift, deseleccionar todas
        if not clicked_ball and not shift then
            for _, bola in ipairs(self.bolas) do
                bola.selected = false
            end
        end
    elseif button == 2 then  -- Click derecho: mover
        -- Obtener todas las bolas seleccionadas
        local selected_balls = {}
        for _, bola in ipairs(self.bolas) do
            if bola.selected then
                table.insert(selected_balls, bola)
            end
        end
        
        -- Mover todas las bolas seleccionadas
        for _, bola in ipairs(selected_balls) do
            if not shift then
                bola.path_queue = {}
            end
            bola:add_target(x, y)
        end
    end
end

--- Maneja el evento de movimiento del mouse
--- @param x number
--- @param y number
function world:handle_mouse_moved(x, y)
    if self.is_dragging then
        -- Verificar si el mouse se ha movido lo suficiente para considerarlo un arrastre
        local dx = x - self.drag_start[1]
        local dy = y - self.drag_start[2]
        if math.abs(dx) > 5 or math.abs(dy) > 5 then
            self.has_moved = true
        end

        self.current_drag = {x, y}
        if self.has_moved then
            local shift = love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')
            self:update_selection(shift)
        end
    end
end

--- Maneja el evento de soltar el click del mouse
--- @param x number
--- @param y number
--- @param button number
--- @param shift boolean
function world:handle_mouse_released(x, y, button, shift)
    if button == 1 and self.is_dragging then
        if not self.has_moved then
            -- Si no hubo movimiento significativo, mantener la selección que se hizo en el click
            -- No hacemos nada aquí porque ya se manejó en handle_mouse_click
        end
        
        -- Resetear el estado del arrastre
        self.is_dragging = false
        self.has_moved = false
        self.drag_start = {}
        self.current_drag = {}
        self.initial_selection = {}
    end
end

return world
