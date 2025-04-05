local bola = require "src/entities/bola"
local desiredFPS = 30
local desiredFrameTime = 1 / desiredFPS

local bolas = {}
function love.load()
    anchoVentana, altoVentana = love.graphics.getDimensions()
    for _ = 1, 3 do
        local nueva_bola = bola.new()
        nueva_bola.position[1] = math.random(nueva_bola.radio, anchoVentana - nueva_bola.radio)
        nueva_bola.position[2] = math.random(nueva_bola.radio, altoVentana - nueva_bola.radio)
        nueva_bola.target_location[1] = nueva_bola.position[1]
        nueva_bola.target_location[2] = nueva_bola.position[2]
        table.insert(bolas, nueva_bola)
    end
end

function love.update(dt)
    for _, bola in ipairs(bolas) do
        -- Actualizar el objetivo actual si es necesario
        bola:update_target()

        local distancia = math.sqrt(
            (bola.target_location[1] - bola.position[1])^2 + 
            (bola.target_location[2] - bola.position[2])^2
        )
        
        if distancia > 2 then  -- Aumentamos el umbral a 2 píxeles
            -- Calculamos la dirección normalizada
            local dx = (bola.target_location[1] - bola.position[1]) / distancia
            local dy = (bola.target_location[2] - bola.position[2]) / distancia
            
            -- Calculamos el movimiento en este frame
            local movement = bola.speed * dt
            
            -- Si la distancia restante es menor que el movimiento que haríamos,
            -- nos movemos directamente al objetivo
            if distancia < movement then
                bola.position[1] = bola.target_location[1]
                bola.position[2] = bola.target_location[2]
            else
                -- Si no, aplicamos el movimiento normal
                bola.position[1] = bola.position[1] + dx * movement
                bola.position[2] = bola.position[2] + dy * movement
            end
        end
    end
end

function love.draw()
    -- Frame limiter: wait if the frame was processed too fast
    -- local frameTime = love.timer.getDelta()
    -- if frameTime < desiredFrameTime then
    --     love.timer.sleep(desiredFrameTime - frameTime)
    -- end

    love.graphics.setColor(1, 1, 1) -- white
    love.graphics.print("Coding Dream", 10, 10)

    for _, bola in ipairs(bolas) do
        -- Dibujamos las líneas de trayectoria
        if #bola.path_queue > 0 then
            love.graphics.setLineWidth(4)  -- Línea gruesa
            love.graphics.setColor(bola.color[1], bola.color[2], bola.color[3], 0.5)  -- Color semi-transparente
            
            -- Dibujamos una línea desde la posición actual al primer objetivo
            love.graphics.line(bola.position[1], bola.position[2], bola.target_location[1], bola.target_location[2])
            
            -- Dibujamos líneas entre todos los puntos de la cola
            for i = 1, #bola.path_queue - 1 do
                local punto_actual = bola.path_queue[i]
                local punto_siguiente = bola.path_queue[i + 1]
                love.graphics.line(punto_actual[1], punto_actual[2], punto_siguiente[1], punto_siguiente[2])
            end
            
            love.graphics.setLineWidth(1)  -- Restauramos el grosor normal
        end

        -- Dibujamos la bola
        love.graphics.setColor(bola.color)
        love.graphics.circle("fill", bola.position[1], bola.position[2], bola.radio)
        
        if bola.selected then
            love.graphics.setColor(1, 1, 1) -- white
            love.graphics.circle("line", bola.position[1], bola.position[2], bola.radio + 4)
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then  
        bola_selected = nil
        for _, bola in ipairs(bolas) do
            local distancia = math.sqrt((x - bola.position[1])^2 + (y - bola.position[2])^2)
            if distancia <= bola.radio then
                for _, otraBola in ipairs(bolas) do
                    otraBola.selected = false
                end
                bola.selected = true
                bola_selected = bola
                break
            end
        end
        if not bola_selected then
            for _, bola in ipairs(bolas) do
                bola.selected = false
            end
        end
    elseif button == 2 and bola_selected then
        -- Si shift está presionado, agregamos a la cola
        -- Si no, reemplazamos la cola actual
        if not love.keyboard.isDown('lshift') and not love.keyboard.isDown('rshift') then
            bola_selected.path_queue = {}  -- Limpiamos la cola si no está shift presionado
        end
        bola_selected:add_target(x, y)
    end
end
