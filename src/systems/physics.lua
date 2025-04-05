--- Sistema de física y colisiones
local physics = {}

--- Verifica colisión entre dos bolas
--- @param bola1 bola
--- @param bola2 bola
--- @return boolean
function physics.check_collision(bola1, bola2)
    local dx = bola2.position[1] - bola1.position[1]
    local dy = bola2.position[2] - bola1.position[2]
    local distancia = math.sqrt(dx * dx + dy * dy)
    local distancia_minima = bola1.radio + bola2.radio
    
    if distancia < distancia_minima then
        -- Calculamos la dirección de rebote
        local nx = dx / distancia  -- Vector normal X
        local ny = dy / distancia  -- Vector normal Y
        
        -- Separamos las bolas para evitar que se peguen
        local overlap = (distancia_minima - distancia) / 2
        bola1.position[1] = bola1.position[1] - nx * overlap
        bola1.position[2] = bola1.position[2] - ny * overlap
        bola2.position[1] = bola2.position[1] + nx * overlap
        bola2.position[2] = bola2.position[2] + ny * overlap
        
        -- Aplicamos un pequeño impulso en direcciones opuestas
        local impulso = 50  -- Fuerza del rebote
        bola1:add_impulse(-nx * impulso, -ny * impulso)
        bola2:add_impulse(nx * impulso, ny * impulso)
        
        return true
    end
    return false
end

--- Maneja las colisiones con los bordes de la ventana
--- @param bola bola
--- @param ancho number
--- @param alto number
function physics.handle_border_collision(bola, ancho, alto)
    local rebote = 0.8  -- Factor de rebote contra las paredes
    
    if bola.position[1] - bola.radio < 0 then
        bola.position[1] = bola.radio
        if bola.impulse then bola.impulse[1] = -bola.impulse[1] * rebote end
    elseif bola.position[1] + bola.radio > ancho then
        bola.position[1] = ancho - bola.radio
        if bola.impulse then bola.impulse[1] = -bola.impulse[1] * rebote end
    end
    
    if bola.position[2] - bola.radio < 0 then
        bola.position[2] = bola.radio
        if bola.impulse then bola.impulse[2] = -bola.impulse[2] * rebote end
    elseif bola.position[2] + bola.radio > alto then
        bola.position[2] = alto - bola.radio
        if bola.impulse then bola.impulse[2] = -bola.impulse[2] * rebote end
    end
end

--- Actualiza la física para una bola
--- @param bola bola
--- @param dt number
function physics.update_physics(bola, dt)
    -- Aplicamos el impulso si existe
    if bola.impulse then
        bola.position[1] = bola.position[1] + bola.impulse[1] * dt
        bola.position[2] = bola.position[2] + bola.impulse[2] * dt
        
        -- Reducimos el impulso gradualmente
        bola.impulse[1] = bola.impulse[1] * 0.96
        bola.impulse[2] = bola.impulse[2] * 0.96
        
        -- Si el impulso es muy pequeño, lo eliminamos
        if math.abs(bola.impulse[1]) < 0.1 and math.abs(bola.impulse[2]) < 0.1 then
            bola.impulse = nil
        end
    end
end

return physics
