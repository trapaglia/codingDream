local entities = require "src/entities"

bolas = {}
function love.load()
    anchoVentana, altoVentana = love.graphics.getDimensions()
    for _ = 1, 3 do
        local nueva_bola = entities.new()
        nueva_bola.x = math.random(nueva_bola.radio, anchoVentana - nueva_bola.radio)
        nueva_bola.y = math.random(nueva_bola.radio, altoVentana - nueva_bola.radio)
        table.insert(bolas, nueva_bola)
    end
end

function love.mousepressed(x, y, button)
    local bola_selected = false
    if button == 1 then  
        for _, bola in ipairs(bolas) do
            local distancia = math.sqrt((x - bola.x)^2 + (y - bola.y)^2)
            if distancia <= bola.radio then
                for _, otraBola in ipairs(bolas) do
                    otraBola.selected = false
                end
                bola.selected = true
                bola_selected = true
                break
            end
        end
        if not bola_selected then
            for _, bola in ipairs(bolas) do
                bola.selected = false
            end
        end
    elseif button == 2 and bola_selected then
        -- TODO: Implementar acción con click derecho
    end
end

function love.update()
end

function love.draw()
    love.graphics.setColor(1, 1, 1) -- white
    love.graphics.print("Coding Dream", 10, 10)

    for _, bola in ipairs(bolas) do
        love.graphics.setColor(bola.color)
        love.graphics.circle("fill", bola.x, bola.y, bola.radio)
        
        if bola.selected then
            love.graphics.setColor(1, 1, 1) -- white
            love.graphics.circle("line", bola.x, bola.y, bola.radio + 4)
        end
    end
end