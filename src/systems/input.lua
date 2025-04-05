---@diagnostic disable: undefined-global
local input = {
    drag_start = {},
    is_dragging = false,
    current_drag = {},
    initial_selection = {},  -- Guarda el estado inicial de selección
    has_moved = false       -- Para distinguir entre click y arrastre
}

--- Verifica si una bola está dentro de un rectángulo
--- @param bola table
--- @param x1 number
--- @param y1 number
--- @param x2 number
--- @param y2 number
--- @return boolean
local function is_ball_in_rect(bola, x1, y1, x2, y2)
    -- Si es un fantasma, no se puede seleccionar
    if bola.is_ghost then return false end
    
    local min_x = math.min(x1, x2)
    local max_x = math.max(x1, x2)
    local min_y = math.min(y1, y2)
    local max_y = math.max(y1, y2)
    
    return bola.position[1] >= min_x and bola.position[1] <= max_x and
           bola.position[2] >= min_y and bola.position[2] <= max_y
end

--- Actualiza la selección de bolas basada en el rectángulo actual
--- @param world table El mundo del juego
--- @param shift boolean
function input:update_selection(world, shift)
    -- Si no está presionado shift, deseleccionar todas las bolas al empezar el arrastre
    if not shift and self.has_moved then
        for _, bola in ipairs(world.bolas) do
            bola.selected = false
        end
    end
    
    -- Seleccionamos las bolas dentro del rectángulo
    for _, bola in ipairs(world.bolas) do
        if is_ball_in_rect(bola, self.drag_start[1], self.drag_start[2], 
                          self.current_drag[1], self.current_drag[2]) then
            bola.selected = true
        end
    end
end

--- Dibuja la caja de selección si está activa
function input:draw()
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
end

--- Maneja el evento de click del mouse
--- @param world table El mundo del juego
--- @param x number
--- @param y number
--- @param button number
--- @param shift boolean
function input:handle_mouse_click(world, x, y, button, shift)
    if button == 1 then  -- Click izquierdo: selección
        -- Guardar estado inicial de selección
        self.initial_selection = {}
        for i, bola in ipairs(world.bolas) do
            self.initial_selection[i] = bola.selected
        end

        -- Iniciar potencial arrastre
        self.drag_start = {x, y}
        self.current_drag = {x, y}
        self.is_dragging = true
        self.has_moved = false
        
        -- Verificar si hizo click directamente en una bola
        local clicked_ball = false
        for _, bola in ipairs(world.bolas) do
            -- Si es un fantasma, no se puede seleccionar
            if not bola.is_ghost then
                local distancia = math.sqrt((x - bola.position[1])^2 + (y - bola.position[2])^2)
                if distancia <= bola.radio then
                    clicked_ball = true
                    if not shift then
                        -- Si no está presionado shift, deseleccionar todas las demás
                        for _, otraBola in ipairs(world.bolas) do
                            otraBola.selected = false
                        end
                    end
                    bola.selected = true
                    break
                end
            end
        end
        
        -- Si no hizo click en ninguna bola y no está presionado shift, deseleccionar todas
        if not clicked_ball and not shift then
            for _, bola in ipairs(world.bolas) do
                bola.selected = false
            end
        end
    elseif button == 2 then  -- Click derecho: mover
        -- Obtener todas las bolas seleccionadas
        local selected_balls = {}
        for _, bola in ipairs(world.bolas) do
            if bola.selected and not bola.is_ghost then
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
--- @param world table El mundo del juego
--- @param x number
--- @param y number
function input:handle_mouse_moved(world, x, y)
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
            self:update_selection(world, shift)
        end
    end
end

--- Maneja el evento de soltar el click del mouse
--- @param world table El mundo del juego
--- @param x number
--- @param y number
--- @param button number
--- @param shift boolean
function input:handle_mouse_released(world, x, y, button, shift)
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

return input
