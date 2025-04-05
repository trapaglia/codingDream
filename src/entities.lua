require "conf"

--- @class bola
--- @field color table
--- @field radio number
--- @field position table
--- @field selected boolean
--- @field target_location
local bola = {}

function bola.new()
    local self = {}
    self.color = {math.random(0, 255)/255, math.random(0, 255)/255, math.random(0, 255)/255}
    self.radio = math.random(15, 30)
    self.position = {0, 0}
    self.selected = false
    return self
end

return bola