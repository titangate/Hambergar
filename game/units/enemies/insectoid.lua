
LadybugMelee = Melee:subclass('LadybugMelee')
function LadybugMelee:initialize(unit)
	super.initialize(self,unit)
	self.damage = 50
	self.bulletmass = 0.5
end
--[[
IALMachineGun = MachineGun:subclass('IALMachineGun')
function IALMachineGun:initialize(unit)
	super.initialize(self,unit)
	self.damage = 20
	self.casttime = 0.25
end

IALThreewayShotgun = ThreewayShotgun:subclass('IALThreewayShotgun')
function IALThreewayShotgun:initialize(unit)
	super.initialize(self,unit)
	self.damage = 50
end]]--

animation.ladybug = Animation:new(love.graphics.newImage('assets/insectoid/ladybug.png'),48,48,0.08,1,1,12,24)
Ladybug = AnimatedUnit:subclass('Ladybug')
function Ladybug:initialize(x,y,controller)
	super.initialize(self,x,y,16,10)
	self.controller = controller
	self.hp = 100
	self.maxhp = 100
	self.mp = 500
	self.maxmp = 500
	self.skills = {
		melee = LadybugMelee:new(self)
	}
	self.animation = {
		stand = animation.ladybug:subSequenceIndex(1,2,3,4,5,6,7,6,5,4,3,2),
		attack = animation.ladybug:subSequence(3,5)
	}
	self:resetAnimation()
	self.speedlimit = self.speedlimit * 1.5
end

function Ladybug:skilleffect(skill)
	if skill then
		self:playAnimation('attack',0.4,false)
	end
end

function Ladybug:enableAI(ai)
	self.ai = ai or AI.ApproachAndAttack(self,GetCharacter(),self.skills.melee,50,100)
end


animation.dragonfly = Animation:new(love.graphics.newImage('assets/insectoid/dragonfly.png'),64,64,0.04,1,1,8,32)
Dragonfly = AnimatedUnit:subclass('Dragonfly')
function Dragonfly:initialize(x,y,controller)
	super.initialize(self,x,y,16,10)
	self.controller = controller
	self.hp = 300
	self.maxhp = 300
	self.mp = 500
	self.maxmp = 500
	self.skills = {
		melee = IALSwordsmanMelee:new(self),
		gun = SmallRocketGun:new(self)
	}
	self.animation = {
		stand = animation.dragonfly:subSequenceIndex(1,2,3,4,3,2),
		attack = animation.dragonfly:subSequence(1,4)
	}
	self:resetAnimation()
end

function Dragonfly:skilleffect(skill)
	if skill then
		self:playAnimation('attack',0.4,false)
	end
end

function Dragonfly:enableAI(ai)
	self.ai = ai or AI.ApproachAndAttack(self,GetCharacter(),self.skills.gun,300,400)
end

SmallRocketTrail = Object:subclass('SniperRoundTrail')
function SmallRocketTrail:initialize(b)
	self.bullet = b
	local p = love.graphics.newParticleSystem(img.part1, 1000)
	p:setEmissionRate(500)
	p:setSpeed(50, 80)
	p:setSize(0.25, 0.5)
	p:setColor(255,255,255,255,188,188,188,0)
	p:setPosition(400, 300)
	p:setLifetime(1)
	p:setParticleLife(0.5)
	p:setSpread(360)
	p:setRadialAcceleration(-500)
	self.p = p
	self.dt = 0
end

function SmallRocketTrail:update(dt)
	self.dt = self.dt + dt
	if self.dt>2 then
		map:removeUpdatable(self)
	end
	if self.dt<1 then
		self.p:setPosition(self.bullet.x,self.bullet.y)
		self.p:start()
	end
	self.p:update(dt)
end

function SmallRocketTrail:draw()
	love.graphics.draw(self.p)
end
smallrocket = Animation:new(love.graphics.newImage('assets/insectoid/rocket.png'),17,12,0.08,3,3,6,5)
SmallRocket = Missile:subclass('SmallRocket')
function SmallRocket:initialize(...)
	super.initialize(self,...)
	self.anim = smallrocket:subSequence(1,3)
	self.trail = SmallRocketTrail:new(self)
	map:addUpdatable(self.trail)
end
function SmallRocket:update(dt)
	super.update(self,dt)
	self.anim:update(dt)
end
function SmallRocket:draw()
--	love.graphics.setColor(255,169,142,255)
	self.anim:draw(self.x,self.y,self.body:getAngle())
	--love.graphics.draw(img.bullet,self.x,self.y,self.body:getAngle(),1,1,16,16)
--	love.graphics.setColor(255,255,255,255)
end
function SmallRocket:add(unit,coll)
--	print ('adddclo')
	if (self.controller=='playerMissile' and unit.controller=='enemy') or (self.controller == 'enemyMissile' and unit.controller=='player') then
--	
		if not unit.bht[self] then
			if self.effect then self.effect:effect(unit,self,self.skill) end
			unit.bht[self] = true
			self.draw = function() end
			self.persist = function() end
		end
	end
end

SmallRocketEffect = ShootMissileEffect:new()
SmallRocketEffect:addAction(function(point,caster,skill)
	local Missile = SmallRocket:new(5,0.2,500,caster.x,caster.y,unpack(point))
	Missile.controller = caster.controller..'Missile'
	Missile.effect = BulletEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
end)

SmallRocketGun = Skill:subclass('SmallRocketGun')
function SmallRocketGun:initialize(unit)
	super.initialize(self)
	self.unit = unit
	self.name = 'SmallRocketGun'
	self.effecttime = 0.02
	self.casttime = 1
	self.damage = 15
	self.effect = SmallRocketEffect
end

function SmallRocketGun:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function SmallRocketGun:stop()
	self.time = 0
end

BeeMelee = Melee:subclass('BeeMelee')
function BeeMelee:initialize(unit)
	super.initialize(self,unit)
	self.damage = 30
	self.bulletmass = 0.5
end

animation.bee = Animation:new(love.graphics.newImage('assets/insectoid/bee.png'),42,48,0.08,1,1,32,24)
Bee = AnimatedUnit:subclass('Bee')
function Bee:initialize(x,y,controller)
	super.initialize(self,x,y,16,10)
	self.controller = controller
	self.hp = 100
	self.maxhp = 100
	self.mp = 500
	self.maxmp = 500
	self.skills = {
		melee = BeeMelee:new(self)
	}
	self.animation = {
		stand = animation.bee:subSequenceIndex(1,2,3,4),
		attack = animation.bee:subSequence(3,4)
	}
	self:resetAnimation()
	self.speedlimit = self.speedlimit * 1.5
end

function Bee:skilleffect(skill)
	if skill then
		self:playAnimation('attack',0.4,false)
	end
end

function Bee:enableAI(ai)
	self.ai = ai or AI.ApproachAndAttack(self,GetCharacter(),self.skills.melee,50,100)
end
