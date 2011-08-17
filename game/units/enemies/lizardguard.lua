foreguard = love.graphics.newImage('assets/lizardguard/foreguard.png')
LizardForeguard = Unit:subclass('LizardForeguard')
function LizardForeguard:initialize(x,y,controller)
--	print (x,y)
	super.initialize(self,x,y,32,10)
	self.controller = controller
	self.skills = {pistol = LizardPistol:new(self),
	melee = Melee:new(self)}
	self.behavior = RangedEnemyAttacker
end

function LizardForeguard:update(dt)
	manfire:update(dt)
end

function LizardForeguard:draw()
	local facing = GetOrderDirection()
	facing = self.body:getAngle()
--	love.graphics.draw(foreguard,self.x,self.y,facing,1,1,32,32)
	manfire:draw(self.x,self.y,facing)
	self:drawBuff()
end

LizardSoidier = Unit:subclass('LizardSoidier')