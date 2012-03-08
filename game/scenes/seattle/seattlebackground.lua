SeattleBackground = Object:subclass'SeattleBackground'
requireImage'assets/seattle/cloud.png'
requireImage'assets/seattle/road.png'

local traffic = require 'scenes.seattle.traffic'

local roadquad = {
	lr=love.graphics.newQuad(0,0,64,64,256,128),
	tb=love.graphics.newQuad(192,0,64,64,256,128),
	rt=love.graphics.newQuad(64,0,64,64,256,128),
	lt=love.graphics.newQuad(0,64,64,64,256,128),
	cross=love.graphics.newQuad(128,0,64,64,256,128),
	rb=love.graphics.newQuad(128,64,64,64,256,128),
	lb=love.graphics.newQuad(192,64,64,64,256,128),
}

TrafficMap = Object:subclass'TrafficMap'
function TrafficMap:initialize(traffic)
	self.batch = love.graphics.newSpriteBatch(img.road,4000)
	self.traffic = traffic
	for j,v1 in ipairs(traffic) do
		for i,v2 in ipairs(v1) do
			print (i,v2)
			if v2==0 then
			elseif roadquad[v2] then
				self.batch:addq(roadquad[v2],j*64-2048,i*64-2048)
			else
				self.batch:addq(roadquad.cross,j*64-2048,i*64-2048)
			end
		end
	end
end

function TrafficMap:draw()
	love.graphics.draw(self.batch)
end

local mapsize = 64*64
local cw,ch = img.cloud:getWidth(),img.cloud:getHeight()
function SeattleBackground:initialize()
	self.dt =0
	self.road = TrafficMap(traffic)
end

function SeattleBackground:update(dt)
	dt = dt * 10
	self.dt = (self.dt + dt)%mapsize
end

img.cloud:setWrap('repeat','repeat')
local cloudquad = love.graphics.newQuad(0,0,16384,16384,16384,16384)
function SeattleBackground:draw()

	love.graphics.push()
	love.graphics.scale(1/8)
	for i=3,1,-1 do
		local x,y = GetCharacter().body:getPosition()
		love.graphics.translate(-x*(0.5^i),-y*(0.5^i))
			love.graphics.setColor(255,255,255,255)
			love.graphics.drawq(img.cloud,cloudquad,self.dt-8192,self.dt-8192)
			love.graphics.setColor(255,255,255,255)
		self.road:draw()
		love.graphics.scale(2)
		
	end
	
	love.graphics.pop()
	
	love.graphics.setColor(255,255,255,255)
	love.graphics.push()
	
	love.graphics.translate(-map.w/2,-map.h/2)
	self.m:draw()
	love.graphics.pop()
end