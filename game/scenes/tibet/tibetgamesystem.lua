--[[require 'libraries.scene'
require 'libraries.unit'
require 'libraries.hud'
require 'libraries.conversation']]
tibetbackground = {cloudtime = 0}
requireImage('assets/tile/cloud.png','cloud')
img.cloud:setWrap('repeat','repeat')
cloudquad = love.graphics.newQuad(0,0,8000,8000,600,600)
requireImage('maps/snowcliff.png','snowcliff')
requireImage('maps/snowbg.png','snowbg')

function tibetbackground:update(dt)
	self.cloudtime = self.cloudtime + dt*50
end
function tibetbackground:draw()
	if self.cloudtime > 3000 then
		self.cloudtime = 0
	end
	local x,y = map.camera.x,map.camera.y
	love.graphics.push()
	--	love.graphics.scale(0.3)
		love.graphics.translate(-x*0.3,-y*0.3)
		love.graphics.scale(2)
		love.graphics.draw(img.snowbg,0,0,0,1,1,img.snowbg:getWidth()/2,img.snowbg:getHeight()/2)
	love.graphics.pop()
	for j = 1,2 do
		love.graphics.push()
		love.graphics.scale(1.2)
		love.graphics.setColor(255,255,255,120)
		love.graphics.drawq(img.cloud,cloudquad,self.cloudtime,-j*40,0,2,2,4000,4000)
		love.graphics.setColor(255,255,255,255)	
	end
	for j = 1,2 do 
		
		love.graphics.pop()
	end
end