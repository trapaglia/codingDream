local world = require "src/game/world"

local desiredFPS = 30
local desiredFrameTime = 1 / desiredFPS
local game_world = world

function love.load()
    local anchoVentana, altoVentana = love.graphics.getDimensions()
    game_world:init(5, anchoVentana, altoVentana)
end

function love.update(dt)
    local anchoVentana, altoVentana = love.graphics.getDimensions()
    game_world:update(dt, anchoVentana, altoVentana)
end

function love.draw()
    love.graphics.setColor(1, 1, 1) -- white
    love.graphics.print("Coding Dream", 10, 10)
    game_world:draw()
end

function love.mousepressed(x, y, button)
    local shift = love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')
    game_world:handle_mouse_click(x, y, button, shift)
end
