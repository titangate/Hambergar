--[[require 'libraries.scene'
require 'libraries.unit'
require 'libraries.hud'
require 'libraries.conversation']]
tibetbackground = {cloudtime = 0}
batches = nil
requireImage('assets/tile/cloud.png','cloud')
img.cloud:setWrap('repeat','repeat')
cloudquad = love.graphics.newQuad(0,0,8000,8000,600,600)
function tibetbackground:update(dt)
	self.cloudtime = self.cloudtime + dt*50
end
function tibetbackground:draw()
	if self.cloudtime > 3000 then
		self.cloudtime = 0
	end
	local x,y = map.camera.x,map.camera.y
	for j = 1,2 do
		map.camera:push(Camera:new(0,0,1.2,1.2))
		map.camera:apply()
		love.graphics.setColor(255,255,255,175)
		love.graphics.drawq(img.cloud,cloudquad,self.cloudtime,-j*40,0,2,2,4000,4000)
		love.graphics.setColor(255,255,255,255)	
		map.camera:revert()
	end
	map.camera:clear()
	for i,v in ipairs(batches) do
		love.graphics.draw(v,0,0,0,1,1,1000,1000)
	end
	for j = 1,2 do
		map.camera:push(Camera:new(0,0,1.2,1.2))
		map.camera:apply()
		love.graphics.setColor(255,255,255,175)
		love.graphics.drawq(img.cloud,cloudquad,self.cloudtime,-j*40,0,2,2,4000,4000)
		love.graphics.setColor(255,255,255,255)	
		map.camera:revert()
	end	
	map.camera:clear()
end