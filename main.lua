function love.load()
    love.window.setTitle("Coding Dream")
    love.graphics.setBackgroundColor(0.1568627450980392, 0.1568627450980392, 0.1568627450980392) -- dark gray
    love.graphics.setFont(love.graphics.newFont(16))

    anchoVentana, altoVentana = love.graphics.getDimensions()
    numBolas = 3  
    bolas = {}

    for i = 1, numBolas do
        local bola = {}
        bola.color = {math.random(0, 255)/255, math.random(0, 255)/255, math.random(0, 255)/255}
        bola.radio = math.random(15, 30)
        bola.x = math.random(bola.radio, anchoVentana - bola.radio)
        bola.y = math.random(bola.radio, altoVentana - bola.radio)
        bola.selected = false
        table.insert(bolas, bola)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then  
        local bola_selected = false
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
    end
end

function love.update()
end

function love.draw()
    love.graphics.setColor(1, 1, 1) 
    love.graphics.print("Coding Dream", 10, 10)

    for _, bola in ipairs(bolas) do
        love.graphics.setColor(bola.color)
        love.graphics.circle("fill", bola.x, bola.y, bola.radio)
        
        if bola.selected then
            love.graphics.setColor(1, 1, 1) 
            love.graphics.circle("line", bola.x, bola.y, bola.radio + 4)
        end
    end
end