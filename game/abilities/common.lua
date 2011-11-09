
BulletEffect = UnitEffect:new()
BulletEffect:addAction(function (unit,caster,skill)
	unit:damage('Bullet',caster.unit:getDamageDealing(skill.damage,'Bullet'),caster)
--	print ('ttb dmg')
end)
BloodTrail = Object:subclass('FlamingSpearTrail')
function BloodTrail:initialize(b)
	self.bullet = b
	local p = love.graphics.newParticleSystem(img.part1, 1000)
	p:setEmissionRate(30)
	p:setSpeed(100, 100)
	p:setGravity(0)
	p:setSize(0.5, 0.25)
	p:setColor(255, 58, 58, 255, 140, 26, 26, 0)
	p:setPosition(400, 300)
	p:setLifetime(0.5)
	p:setParticleLife(0.25)
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

requireImage('assets/bloodstain.png','bloodstain')
local bloodstainquad = love.graphics.newQuad(0,0,64,64,128,128)
BloodStain = Object:subclass('BloodStain')
function BloodStain:initialize(x,y)
	self.x,self.y = x,y
	self.r = math.random(math.pi*2)
	self.hp = 5
	self.ox,self.oy = math.random(0,1)*64,math.random(0,1)*64
end

function BloodStain:update(dt)
	self.hp = self.hp - dt
	if self.hp<= 0 then
		map:removeUpdatable(self)
	end
end

function BloodStain:draw()
	bloodstainquad:setViewport(self.ox,self.oy,64,64,128,128)
	love.graphics.setColor(255,255,255,math.min(255,self.hp*255))
	love.graphics.drawq(img.bloodstain,bloodstainquad,self.x,self.y,self.r,1,1,32,32)
	love.graphics.setColor(255,255,255,255)
end

MeleeEffect = ShootMissileEffect:new()
MeleeEffect:addAction(function(point,caster,skill)
	local Missile = MeleeMissile:new(0.5,skill.bulletmass,skill.range/0.5,caster.x,caster.y,unpack(point))
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
	self.bulletmass = 1
	self.range = 0.5*2000
	self.effect = MeleeEffect
end

function Melee:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function Melee:stop()
	self.time = 0
end

requireImage('assets/assassin/bullet.png','bullet')
MachineGunMissile = Missile:subclass('MachineGunMissile')
function MachineGunMissile:draw()
	love.graphics.setColor(255,169,142,255)
	love.graphics.draw(img.bullet,self.x,self.y,self.body:getAngle(),1,1,16,16)
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
	love.graphics.draw(img.bullet,self.x,self.y,self.body:getAngle(),2,2,16,16)
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

PistolEffect = ShootMissileEffect:new()
PistolEffect:addAction(function(point,caster,skill)
	assert(skill)
	assert(skill.bullettype)
	local Missile = skill.bullettype(1,1,1000,caster.x,caster.y,unpack(point))
	Missile.controller = caster.controller..'Missile'
	Missile.effect = skill.bulleteffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	TEsound.play('sound/shoot4.wav')
end)


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
	love.graphics.draw(img.bullet,self.x,self.y,self.body:getAngle(),1,1,16,16)
end
