require "conf"

--- @class bola
--- @field color table
--- @field radio number
--- @field position table
--- @field selected boolean
--- @field target_location table
--- @field speed number
--- @field path_queue table Lista de puntos objetivo {x, y}
--- @field impulse table Vector de impulso para colisiones
local bola = {
    mt = {}
}
bola.mt.__index = bola

function bola.new()
    local self = {}
    self.color = {math.random(0, 255)/255, math.random(0, 255)/255, math.random(0, 255)/255}
    self.radio = math.random(15, 30)
    self.position = {0, 0}
    self.target_location = {0, 0}
    self.selected = false
    self.speed = 200  -- velocidad en píxeles por segundo
    self.path_queue = {}  -- Cola de puntos objetivo
    self.impulse = nil  -- Vector de impulso para colisiones
    setmetatable(self, bola.mt)
    return self
end

--- Agrega un nuevo punto objetivo a la cola
--- @param x number
--- @param y number
function bola:add_target(x, y)
    table.insert(self.path_queue, {x, y})
    if #self.path_queue == 1 then
        self.target_location[1] = x
        self.target_location[2] = y
    end
end

--- Aplica un impulso a la bola para las colisiones
--- @param x number
--- @param y number
function bola:add_impulse(x, y)
    if not self.impulse then
        self.impulse = {x, y}
    else
        self.impulse[1] = self.impulse[1] + x
        self.impulse[2] = self.impulse[2] + y
    end
end

--- Actualiza el objetivo actual si es necesario
function bola:update_target()
    if #self.path_queue > 0 then
        local distancia = math.sqrt(
            (self.target_location[1] - self.position[1])^2 + 
            (self.target_location[2] - self.position[2])^2
        )
        
        if distancia <= 2 then  -- Aumentamos el umbral a 2 píxeles
            -- Forzamos la posición exacta antes de cambiar de objetivo
            self.position[1] = self.target_location[1]
            self.position[2] = self.target_location[2]
            
            table.remove(self.path_queue, 1)  -- Removemos el punto actual
            if #self.path_queue > 0 then
                local next_target = self.path_queue[1]
                self.target_location[1] = next_target[1]
                self.target_location[2] = next_target[2]
            end
        end
    end
end

return bola