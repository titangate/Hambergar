
require 'MiddleClass'
require 'MindState'
require 'stealth'
require 'stealthunit'

-- initializing test units
local units = {
	StealthUnit(50,50),
	StealthUnit(600,600)
}

-- initializing test map
local loader = require("AdvTiledLoader/Loader")
loader.path = "maps/"
local map = loader.load("test.tmx")
local layer = map.tl["Ground"]
local displayTime = 0 
local displayMax = 2
map.useSpriteBatch = true

-- initliazing stealthsystem
local sys = StealthSystem()
sys:setMap(map)
sys:setTarget(units[1])
-- initializing enemy AI
local u = units[2]
u.ai = StealthAI:new(sys)

-- player control
local dir = {
	a = {-1,0},
	d = {1,0},
	w = {0,-1},
	s = {0,1},
}
local ms = 200
-- debug functions & constants
debugc = {
	drawraycast = true
}
debugq = {}
function addDrawCommand(f)
	table.insert(debugq,f)
end
function love.update(dt)
	local u = units[1]
	u.vx,u.vy = 0,0
	for k,v in pairs(dir) do
		if love.keyboard.isDown(k) then
			u.vx,u.vy = u.vx+v[1]*ms,u.vy+v[2]*ms
		end
	end
	for _,v in ipairs(units) do
		v:update(dt)
	end
end
function love.draw()
	map:draw()
	local t,x,y = sys:getTile(units[1]:getPosition())
	love.graphics.print(tostring(t.properties.obstacle),10,10)
	love.graphics.print(tostring(x)..' '..tostring(y),10,30)
	for _,v in ipairs(units) do
		v:draw()
	end
	while #debugq>0 do
		table.remove(debugq)()
	end
end

function love.keypressed(key, u)
   --Debug
   if key == "lctrl" then --set to whatever key you want to use
      for i,v in pairs (debug) do 
		print (i,v)
	end
   end
end