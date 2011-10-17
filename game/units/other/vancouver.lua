Mat = Unit:subclass'Mat'

function Mat:initialize(...)
	super.initialize(self,...)
	self.controller = 'player'
end

local meditation1 = require 'scenes.vancouver.meditation'
function Mat:interact(unit)
	if unit:isKindOf(Assassin) then
		meditation1()
	end
end

function Mat:createBody(world)
	super.createBody(self,world)
	self.shape:setSensor(true)
end

requireImage('assets/vancouver/mat.png','mat')
function Mat:draw()
	love.graphics.draw(img.mat,self.x,self.y,0,1,1,64,64)
end