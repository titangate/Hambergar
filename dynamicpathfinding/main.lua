require 'MiddleClass'
require 'pathmap'
map = PathMap()
local map = map

local ms = 50
Unit = Object:subclass'Unit'
function Unit:initialize(x,y)
	assert(x and y)
	self.x,self.y = x,y
end

function Unit:update(dt)
	for i,v in ipairs(map.regions) do
		if math.abs(self.x-v.x)<=v.w/2 and math.abs(self.y-v.y)<=v.h/2 then
			self.region = v
		end
	end
	if self.move then
		local dx,dy = unpack(map:getDirection(self,leon))
		assert(dx)
		assert(dy)
		dx,dy = dx*dt*ms,dy*dt*ms
		self.x,self.y = self.x+dx,self.y+dy
	end
end

function Unit:draw()
	love.graphics.circle('fill',self.x,self.y,16)
end

leon = Unit(150,50)
police = Unit(100,50)
police.move = true
	
local loader = require("AdvTiledLoader/Loader")
loader.path = ""
local m = loader.load'demo.tmx'
m.useSpriteBatch=true
m.drawObjects=false

local oj = m.objectLayers
for k,v in pairs(oj) do
	if v.name == 'pathmap' then
		for _,obj in pairs(v.objects) do
			local r = {
				x = obj.x+obj.width/2,
				y = obj.y+obj.height/2,
				w = obj.width,
				h = obj.height,
				name = obj.name
			}
			map:insertRegion(r)
		end
	end
end
local regions = map.regions
map:buildMap()
--map:printMap()
local path = map:getPath(regions[1],regions[4])
for i,v in ipairs(path) do
	print (v.name)
end

local cms = 200
function love.update(dt)
	leon:update(dt)
	police:update(dt)
	if love.keyboard.isDown'w' then
		leon.y = leon.y-dt*cms
	elseif love.keyboard.isDown's' then
		leon.y = leon.y+dt*cms
	elseif love.keyboard.isDown'a' then
		leon.x = leon.x-dt*cms
	elseif love.keyboard.isDown'd' then
		leon.x = leon.x+dt*cms
	end
end

function love.draw()
	love.graphics.setColor(255,255,255,100)
	for _,r in ipairs(map.regions) do
		love.graphics.rectangle('fill',r.x-r.w/2,r.y-r.h/2,r.w,r.h)
	end
	leon:draw()
	police:draw()
end