bullet = love.graphics.newImage('assets/assassin/bullet.png')

Bullet = Missile:subclass('Bullet')
function Bullet:initialize(...)
	super.initialize(self,...)
end
function Bullet:persist(unit,coll)
	if (self.controller=='playerMissile' and unit.controller=='enemy') or (self.controller == 'enemyMissile' and unit.controller=='player') then
		if not unit.bht[self] then
			if self.effect then self.effect:effect(unit,self,self.skill) end
			unit.bht[self] = true
			self.draw = function() end
			self.persist = function() end
		end
	end
end

function Bullet:draw()
	love.graphics.draw(bullet,self.x,self.y,self.body:getAngle(),1,1,16,16)
end
MomentumBullet = Missile:subclass('MomentumBullet')
function MomentumBullet:createBody(world)
	super.createBody(self,world)
	self.shape:setSensor(true)
end

function MomentumBullet:persist(unit,coll)
	if (self.controller=='playerMissile' and unit.controller=='enemy') or (self.controller == 'enemyMissile' and unit.controller=='player') then
		if not unit.bht[self] then
			if self.effect then self.effect:effect(unit,self,self.skill) end
			unit.bht[self] = true
		end
	end
end

function MomentumBullet:draw()
	love.graphics.setColor(80,234,255,255)
	love.graphics.draw(bullet,self.x,self.y,self.body:getAngle(),1,1,16,16)
	love.graphics.setColor(255,255,255,255)
end