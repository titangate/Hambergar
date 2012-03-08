Helicopter = Unit:subclass('Helicopter')
function Helicopter:initialize(x,y,controller)
	super.initialize(self,x,y,16,10)
	self.controller = controller
	self.hp = 500
	self.maxhp = 500
	self.mp = 500
	self.maxmp = 500
	self.skills = {
	}
	self.dt = 0
end

function Helicopter:enableAI(ai)
end

requireImage'assets/seattle/helicopter.png'
requireImage'assets/seattle/helicopterwing.png'
function Helicopter:draw()
	local r = self:getAngle()
	local cosr,sinr = math.cos(r+math.pi),math.sin(r+math.pi)
	self.x,self.y = self.body:getPosition()
	love.graphics.draw(img.helicopter,self.x,self.y,self:getAngle(),1,1,128,128)
	love.graphics.draw(img.helicopterwing,self.x+cosr*70-sinr*62,self.y+sinr*70+cosr*62,self.dt*6.28,1,1,102.5,102.5)
	love.graphics.draw(img.helicopterwing,self.x+cosr*(-70)-sinr*62,self.y+sinr*(-70)+cosr*62,self.dt*6.28,1,1,102.5,102.5)
end

function Helicopter:update(dt)
	super.update(self,dt)
	self.dt = (self.dt+dt)%0.5
end

