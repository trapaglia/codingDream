require "conf"
local love = require "love"

--- @class bola
--- @field color table Color RGB de la bola
--- @field radio number Radio de la bola en píxeles
--- @field position table Posición actual {x, y}
--- @field target_location table Objetivo actual {x, y}
--- @field selected boolean Si la bola está seleccionada
--- @field speed number Velocidad en píxeles por segundo
--- @field path_queue table Lista de puntos objetivo {x, y}
--- @field impulse table Vector de impulso para colisiones
--- @field team string Equipo al que pertenece la bola ('blue' o 'green')
--- @field fighting boolean Si la bola está en combate
--- @field opponents table Lista de bolas contra las que está luchando
--- @field trying_to_escape boolean Si la bola está intentando escapar
--- @field attack number Poder de ataque (1-100)
--- @field max_health number Salud máxima (50-150)
--- @field health number Salud actual
--- @field attack_speed number Tiempo entre ataques en segundos
--- @field attack_timer number Tiempo restante para el próximo ataque
--- @field flash_timer number Tiempo restante del destello de ataque
local bola = {
    mt = {}
}
bola.mt.__index = bola

--- Crea una nueva instancia de bola
--- @param team string Equipo al que pertenece la bola ('blue' o 'green')
--- @return bola
function bola.new(team)
    local self = {}
    self.team = team or 'blue'  -- Por defecto equipo azul
    
    -- Stats aleatorios
    self.attack = math.random(1, 100)  -- Ataque entre 1 y 100
    self.max_health = math.random(50, 150)  -- Salud entre 50 y 150
    self.health = self.max_health  -- Salud inicial al máximo
    self.attack_speed = 0.5 + math.random() * 1.5  -- Entre 0.5 y 2 segundos
    self.attack_timer = 0  -- Contador para el próximo ataque
    self.flash_timer = 0  -- Duración del destello
    
    -- Color según el equipo y el ataque
    -- Más ataque = más brillante
    local brillo = 0.5 + (self.attack / 100) * 0.5  -- Entre 0.5 y 1.0
    if self.team == 'blue' then
        self.color = {0, 0.5 * brillo, brillo}  -- Azul más brillante
    else
        self.color = {0, brillo, 0}  -- Verde más brillante
    end
    
    -- Radio según la vida máxima
    -- Más vida = más grande
    local min_radio = 15
    local max_radio = 30
    self.radio = min_radio + ((self.max_health - 50) / 100) * (max_radio - min_radio)
    
    self.position = {0, 0}
    self.target_location = {0, 0}
    self.selected = false
    self.speed = 120  -- velocidad en píxeles por segundo
    self.path_queue = {}  -- Cola de puntos objetivo
    self.impulse = nil  -- Vector de impulso para colisiones
    self.fighting = false  -- Estado de lucha
    self.opponents = {}  -- Lista de bolas contra las que lucha
    self.trying_to_escape = false  -- Si está intentando escapar
    setmetatable(self, bola.mt)
    return self
end

--- Agrega un nuevo punto objetivo a la cola
--- @param x number
--- @param y number
function bola:add_target(x, y)
    -- Si estamos luchando, marcamos que intentamos escapar
    if self.fighting then
        self.trying_to_escape = true
    end
    
    -- Siempre permitimos agregar objetivos
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

--- Comienza una lucha con otra bola
--- @param other bola
function bola:start_fight(other)
    -- Si son del mismo equipo, no luchan
    if self.team == other.team then
        return
    end

    -- Limpiamos la trayectoria y el impulso
    self.fighting = true
    self.trying_to_escape = false
    self.path_queue = {}
    self.target_location[1] = self.position[1]
    self.target_location[2] = self.position[2]
    self.impulse = nil

    -- Lo mismo para el otro
    other.fighting = true
    other.trying_to_escape = false
    other.path_queue = {}
    other.target_location[1] = other.position[1]
    other.target_location[2] = other.position[2]
    other.impulse = nil

    -- Agregamos a la lista de oponentes si no está ya
    local already_fighting = false
    for _, opponent in ipairs(self.opponents) do
        if opponent == other then
            already_fighting = true
            break
        end
    end
    if not already_fighting then
        table.insert(self.opponents, other)
        table.insert(other.opponents, self)
    end
end

--- Recibe daño de un oponente
--- @param attacker bola
function bola:take_damage(attacker)
    -- El daño es proporcional al ataque del atacante
    local damage = attacker.attack * 0.1  -- 10% del ataque como daño
    self.health = self.health - damage
    
    -- Si la salud llega a 0, la bola es derrotada
    if self.health <= 0 then
        self.health = 0
        -- Terminamos todas las luchas
        while #self.opponents > 0 do
            self:end_fight_with(self.opponents[1])
        end
    end
end

--- Termina la lucha con un oponente específico
--- @param other bola
function bola:end_fight_with(other)
    -- Removemos al oponente de nuestra lista
    for i, opponent in ipairs(self.opponents) do
        if opponent == other then
            table.remove(self.opponents, i)
            break
        end
    end

    -- Removemos a nosotros de su lista
    for i, opponent in ipairs(other.opponents) do
        if opponent == self then
            table.remove(other.opponents, i)
            break
        end
    end

    -- Si ya no tenemos oponentes, terminamos de luchar
    if #self.opponents == 0 then
        self.fighting = false
        self.trying_to_escape = false
    end
    if #other.opponents == 0 then
        other.fighting = false
        other.trying_to_escape = false
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

--- Actualiza la posición de la bola hacia su objetivo
--- @param dt number Delta time
function bola:update_movement(dt)
    -- Si estamos intentando escapar o no estamos luchando, nos movemos
    if self.trying_to_escape or not self.fighting then
        local distancia = math.sqrt(
            (self.target_location[1] - self.position[1])^2 + 
            (self.target_location[2] - self.position[2])^2
        )
        
        if distancia > 2 then
            -- Calculamos la dirección normalizada
            local dx = (self.target_location[1] - self.position[1]) / distancia
            local dy = (self.target_location[2] - self.position[2]) / distancia
            
            -- Calculamos el movimiento en este frame
            local movement = self.speed * dt
            
            -- Si estamos escapando, nos movemos mucho más rápido
            if self.trying_to_escape then
                movement = movement * 3  -- Triple de velocidad al escapar
                -- Agregamos un impulso extra en la dirección del escape
                self:add_impulse(dx * 200, dy * 200)
            end
            
            -- Si la distancia restante es menor que el movimiento que haríamos,
            -- nos movemos directamente al objetivo
            if distancia < movement then
                self.position[1] = self.target_location[1]
                self.position[2] = self.target_location[2]
            else
                -- Si no, aplicamos el movimiento normal
                self.position[1] = self.position[1] + dx * movement
                self.position[2] = self.position[2] + dy * movement
            end
            
            -- Si estamos escapando y nos hemos movido lo suficiente,
            -- terminamos todas las luchas
            if self.trying_to_escape and distancia > 100 then  -- Distancia de escape
                while #self.opponents > 0 do
                    self:end_fight_with(self.opponents[1])
                end
            end
        end
    end
end

--- Actualiza la bola
--- @param dt number Delta time
function bola:update(dt)
    -- Actualizamos el timer de ataque si estamos luchando
    if self.fighting then
        self.attack_timer = self.attack_timer - dt
        if self.attack_timer <= 0 then
            -- Reseteamos el timer y atacamos a todos los oponentes
            self.attack_timer = self.attack_speed
            self.flash_timer = 0.1  -- Duración del destello
            for _, opponent in ipairs(self.opponents) do
                opponent:take_damage(self)
            end
        end
    end
    
    -- Actualizamos el timer del destello
    if self.flash_timer > 0 then
        self.flash_timer = self.flash_timer - dt
    end
    
    -- Actualizamos movimiento
    self:update_target()
    self:update_movement(dt)
end

--- Dibuja la bola
--- @param selected boolean Si la bola está seleccionada
function bola:draw(selected)
    local r, g, b = unpack(self.color)
    
    -- Si está destellando, aumentamos el brillo
    if self.flash_timer > 0 then
        local flash_intensity = self.flash_timer / 0.1  -- 0.1 es la duración del destello
        r = r + (1 - r) * flash_intensity
        g = g + (1 - g) * flash_intensity
        b = b + (1 - b) * flash_intensity
    end
    
    -- Dibujamos el círculo exterior (tamaño máximo)
    love.graphics.setColor(r * 0.5, g * 0.5, b * 0.5, 0.5)  -- Versión más oscura y transparente
    love.graphics.circle("fill", self.position[1], self.position[2], self.radio)
    
    -- Dibujamos el círculo interior que representa la vida actual
    love.graphics.setColor(r, g, b)
    local radio_actual = self.radio * (self.health / self.max_health)
    love.graphics.circle("fill", self.position[1], self.position[2], radio_actual)
    
    -- Si está seleccionada, dibujamos un borde
    if selected then
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("line", self.position[1], self.position[2], self.radio + 2)
    end
end

return bola