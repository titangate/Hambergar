require 'MiddleClass'
require 'lighter'
local l = Lighter()
l:addLighterObject(LightSource(100,100,{0,255,0},0))
l:addLighterObject(LightSource(500,200,{0,255,255},-math.pi/4))
l:addLighterObject(Filter(400,100,{255,0,0},0))
p1 = Portal(300,200,0)
p2 = Portal(400,200,0)
p1:link(p2)
l:addLighterObject(p1)
l:addLighterObject(p2)
local m = Mirror(600,100,-math.pi/3)
l:addLighterObject(m)
function love.update(dt)
	local x,y = love.mouse.getPosition()
	m.direction = math.atan2(y-m.y,x-m.x)
	l:update(dt)
end

function love.draw()
	l:draw()
end

function love.mousepressed(x,y,b)
	
end