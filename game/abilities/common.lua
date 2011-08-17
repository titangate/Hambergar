
BloodTrail = Object:subclass('FlamingSpearTrail')
function BloodTrail:initialize(b)
	self.bullet = b
	local p = love.graphics.newParticleSystem(part1, 1000)
	p:setEmissionRate(30)
	p:setSpeed(100, 100)
	p:setGravity(0)
	p:setSize(0.5, 0.25)
	p:setColor(255, 58, 58, 255, 140, 26, 26, 0)
	p:setPosition(400, 300)
	p:setLifetime(0.5)
	p:setParticleLife(0.5)
	p:setDirection(0)
	p:setSpread(360)
	p:setRadialAcceleration(0)
	p:setTangentialAcceleration(250)
	self.p = p
	self.dt = 0
end

function BloodTrail:update(dt)
	self.dt = self.dt + dt
	if self.dt>1 then
		map:removeUpdatable(self)
	end
	if self.dt<0.5 then
		self.p:setPosition(self.bullet.x,self.bullet.y)
		self.p:start()
	end
	self.p:update(dt)
end

function BloodTrail:draw()
	love.graphics.draw(self.p)
end

MeleeEffect = ShootMissileEffect:new()
MeleeEffect:addAction(function(point,caster,skill)
	local Missile = MeleeMissile:new(0.5,1,2000,caster.x,caster.y,unpack(point))
	Missile.controller = caster.controller..'Missile'
	Missile.effect = BulletEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	TEsound.play({'sound/sword1.wav','sound/sword2.wav','sound/sword3.wav'})
end)

MeleeMissile = Missile:subclass('MeleeMissile')
function MeleeMissile:draw()
	super.draw(self)
end
function MeleeMissile:add(unit,coll)
	if (self.controller=='playerMissile' and unit.controller=='enemy') or (self.controller == 'enemyMissile' and unit.controller=='player') then
		if not unit.bht[self] then
			if self.effect then self.effect:effect(unit,self,self.skill) end
			unit.bht[self] = true
			self.draw = function() end
			self.persist = function() end
		end
	end
end

Melee = Skill:subclass('Melee')
function Melee:initialize(unit)
	super.initialize(self)
	self.unit = unit
	self.name = 'Melee'
	self.effecttime = 0.02
	self.casttime = 1
	self.damage = 50
	self.effect = MeleeEffect
end

function Melee:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function Melee:stop()
	self.time = 0
end

MachineGunMissile = Missile:subclass('MachineGunMissile')
function MachineGunMissile:draw()
	love.graphics.setColor(255,169,142,255)
	love.graphics.draw(bullet,self.x,self.y,self.body:getAngle(),1,1,16,16)
	love.graphics.setColor(255,255,255,255)
end
function MachineGunMissile:add(unit,coll)
	if (self.controller=='playerMissile' and unit.controller=='enemy') or (self.controller == 'enemyMissile' and unit.controller=='player') then
		if not unit.bht[self] then
			if self.effect then self.effect:effect(unit,self,self.skill) end
			unit.bht[self] = true
			self.draw = function() end
			self.persist = function() end
		end
	end
end

MachineGunEffect = ShootMissileEffect:new()
MachineGunEffect:addAction(function(point,caster,skill)
	local Missile = MachineGunMissile:new(5,0.2,2000,caster.x,caster.y,unpack(point))
	Missile.controller = caster.controller..'Missile'
	Missile.effect = BulletEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
end)

MachineGun = Skill:subclass('MachineGun')
function MachineGun:initialize(unit)
	super.initialize(self)
	self.unit = unit
	self.name = 'MachineGun'
	self.effecttime = 0.02
	self.casttime = 1
	self.damage = 50
	self.effect = MachineGunEffect
end

function MachineGun:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function MachineGun:stop()
	self.time = 0
end

ShotgunMissile = Missile:subclass('ShotgunMissile')
function ShotgunMissile:draw()
	love.graphics.setColor(124,169,255,255)
	love.graphics.draw(bullet,self.x,self.y,self.body:getAngle(),2,2,16,16)
	love.graphics.setColor(255,255,255,255)
end
function ShotgunMissile:add(unit,coll)
	if (self.controller=='playerMissile' and unit.controller=='enemy') or (self.controller == 'enemyMissile' and unit.controller=='player') then
		if not unit.bht[self] then
			if self.effect then self.effect:effect(unit,self,self.skill) end
			unit.bht[self] = true
			self.draw = function() end
			self.persist = function() end
		end
	end
end
ThreewayShotgunEffect = ShootMissileEffect:new()
ThreewayShotgunEffect:addAction(function(point,caster,skill)
	local x,y = unpack(point)
	local Missile = ShotgunMissile:new(5,0.2,1000,caster.x,caster.y,x,y)
	Missile.controller = caster.controller..'Missile'
	Missile.effect = BulletEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	local Missile = ShotgunMissile:new(5,0.2,1000,caster.x,caster.y,0.866*x+0.5*y,0.5*x+0.866*y) -- complex number math
	Missile.controller = caster.controller..'Missile'
	Missile.effect = BulletEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	local Missile = ShotgunMissile:new(5,0.2,1000,caster.x,caster.y,0.866*x-0.5*y,-0.5*x+0.866*y)
	Missile.controller = caster.controller..'Missile'
	Missile.effect = BulletEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	TEsound.play({'sound/shoot2.wav','sound/shoot3.wav'})
end)

ThreewayShotgun = Skill:subclass('ThreewayShotgun')
function ThreewayShotgun:initialize(unit)
	super.initialize(self)
	self.unit = unit
	self.name = 'ThreewayShotgun'
	self.effecttime = 0.02
	self.casttime = 1
	self.damage = 50
	self.effect = ThreewayShotgunEffect
end

function ThreewayShotgun:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function ThreewayShotgun:stop()
	self.time = 0
end

