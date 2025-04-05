require "math"

function love.conf(t)
    t.window.title = "Coding Dream"
    math.randomseed(os.time())
    -- t.graphics.backgroundColor = {0.1568627450980392, 0.1568627450980392, 0.1568627450980392} -- dark gray
    -- t.graphics.font = love.graphics.newFont(16)
end