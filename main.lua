---@diagnostic disable: undefined-global
local game_world = require "src/game/world"

function love.load()
    local ancho = love.graphics.getWidth()
    local alto = love.graphics.getHeight()
    
    -- Inicializar el mundo con los dos equipos
    game_world:init(ancho, alto)
end

function love.update(dt)
    game_world:update(dt)
end

function love.draw()
    game_world:draw()
end

function love.mousepressed(x, y, button)
    local shift = love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')
    game_world:handle_mouse_click(x, y, button, shift)
end

function love.mousemoved(x, y)
    game_world:handle_mouse_moved(x, y)
end

function love.mousereleased(x, y, button)
    local shift = love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')
    game_world:handle_mouse_released(x, y, button, shift)
end
