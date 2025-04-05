require "conf"

local bola = {}

function bola.new()
    local self = {}
    self.color = {math.random(0, 255)/255, math.random(0, 255)/255, math.random(0, 255)/255}
    self.radio = math.random(15, 30)
    -- x e y se establecerán después de crear el objeto
    self.x = 0
    self.y = 0
    self.selected = false
    return self
end

return bola