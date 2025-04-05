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
        local distancia = math.sqrt(
            (bola.target_location[1] - bola.position[1])^2 + 
            (bola.target_location[2] - bola.position[2])^2
        )
        
        if distancia > 1 then  -- Si está a más de 1 píxel de distancia
            -- Calculamos la dirección normalizada
            local dx = (bola.target_location[1] - bola.position[1]) / distancia
            local dy = (bola.target_location[2] - bola.position[2]) / distancia
            
            -- Aplicamos la velocidad considerando el delta time
            bola.position[1] = bola.position[1] + dx * bola.speed * dt
            bola.position[2] = bola.position[2] + dy * bola.speed * dt
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
        -- Dibujamos la línea de trayectoria si la bola está en movimiento
        local distancia = math.sqrt(
            (bola.target_location[1] - bola.position[1])^2 + 
            (bola.target_location[2] - bola.position[2])^2
        )
        if distancia > 1 then
            love.graphics.setLineWidth(4)  -- Línea gruesa
            love.graphics.setColor(bola.color[1], bola.color[2], bola.color[3], 0.5)  -- Color semi-transparente
            love.graphics.line(bola.position[1], bola.position[2], bola.target_location[1], bola.target_location[2])
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
        bola_selected.target_location[1] = x
        bola_selected.target_location[2] = y
    end
end
