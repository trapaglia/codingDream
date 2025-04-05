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
        -- Vector normal de colisión
        local nx = dx / distancia
        local ny = dy / distancia
        
        -- Si son del mismo equipo o alguna está escapando, rebotan
        if bola1.team == bola2.team or bola1.trying_to_escape or bola2.trying_to_escape then
            -- Separamos las bolas para evitar que se peguen
            local overlap = (distancia_minima - distancia) / 2
            bola1.position[1] = bola1.position[1] - nx * overlap
            bola1.position[2] = bola1.position[2] - ny * overlap
            bola2.position[1] = bola2.position[1] + nx * overlap
            bola2.position[2] = bola2.position[2] + ny * overlap
            
            -- Aplicamos un impulso en direcciones opuestas
            local impulso = 50  -- Fuerza del rebote base
            -- Si alguna está escapando, el impulso es mucho mayor
            if bola1.trying_to_escape or bola2.trying_to_escape then
                impulso = 300  -- 6 veces más fuerte al escapar
            end
            bola1:add_impulse(-nx * impulso, -ny * impulso)
            bola2:add_impulse(nx * impulso, ny * impulso)
        else
            -- Si son de equipos diferentes y ninguna está escapando, comienzan a luchar
            bola1:start_fight(bola2)
            
            -- Las posicionamos una frente a la otra con una pequeña separación
            local separacion = distancia_minima * 1.1  -- 10% más que la distancia mínima
            local punto_medio_x = (bola1.position[1] + bola2.position[1]) / 2
            local punto_medio_y = (bola1.position[2] + bola2.position[2]) / 2
            
            bola1.position[1] = punto_medio_x - nx * separacion/2
            bola1.position[2] = punto_medio_y - ny * separacion/2
            bola2.position[1] = punto_medio_x + nx * separacion/2
            bola2.position[2] = punto_medio_y + ny * separacion/2
            
            -- Si están luchando, aplicamos movimiento aleatorio
            if bola1.fighting and bola2.fighting then
                -- Movimiento aleatorio de lucha
                local shake = 2  -- Intensidad del movimiento
                bola1.position[1] = bola1.position[1] + (math.random() - 0.5) * shake
                bola1.position[2] = bola1.position[2] + (math.random() - 0.5) * shake
                bola2.position[1] = bola2.position[1] + (math.random() - 0.5) * shake
                bola2.position[2] = bola2.position[2] + (math.random() - 0.5) * shake
            end
        end
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
    -- Si está escapando, el rebote es mayor
    if bola.trying_to_escape then
        rebote = 1.2  -- Rebote más elástico al escapar
    end
    
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
    -- Aplicamos física si no está luchando o está intentando escapar
    if not bola.fighting or bola.trying_to_escape then
        -- Aplicamos el impulso si existe
        if bola.impulse then
            bola.position[1] = bola.position[1] + bola.impulse[1] * dt
            bola.position[2] = bola.position[2] + bola.impulse[2] * dt
            
            -- Reducimos el impulso gradualmente
            -- Si está escapando, la reducción es mucho menor
            local reduccion = bola.trying_to_escape and 0.99 or 0.96
            bola.impulse[1] = bola.impulse[1] * reduccion
            bola.impulse[2] = bola.impulse[2] * reduccion
            
            -- Si el impulso es muy pequeño, lo eliminamos
            if math.abs(bola.impulse[1]) < 0.1 and math.abs(bola.impulse[2]) < 0.1 then
                bola.impulse = nil
            end
        end
    end
end

return physics
