
FistMissileP3 = Missile:subclass('FistMissileP3')
function FistMissileP3:draw()
	if self.dt < 0.3 then
		love.graphics.setColor(255,160,40,self.dt/0.3*255)
	elseif self.dt > 0.7 then
		love.graphics.setColor(255,255,255,(1-self.dt)/0.3*255)
	else
		love.graphics.setColor(255,160,40)
	end
--	love.graphics.setColor(255,255,255)
	love.graphics.circle('fill',self.x,self.y,self.body:getAngle(),100)
	love.graphics.draw(myimg.missile.FistMissileP3,self.x,self.y,self.body:getAngle(),0.6,0.6,200,100)
	love.graphics.setColor(255,255,255)
end
function FistMissileP3:add(unit,coll)
	if (self.controller=='playerMissile' and unit.controller=='enemy') or (self.controller == 'enemyMissile' and unit.controller=='player') then
		if not unit.bht[self] then
			if self.effect then self.effect:effect(unit,self,self.skill) end
			unit.bht[self] = true
			self.draw = function() end
			self.add = function() end
		end
	end
end

function FistMissileP3:createBody(world)
	self.body = love.physics.newBody(world,self.x,self.y,'dynamic')
	self.shape = love.physics.newRectangleShape(50,300)
	self.fixture = love.physics.newFixture(self.body,self.shape)
	if self.controller then
		category,masks = unpack(typeinfo[self.controller])
		self.fixture:setCategory(category)
		self.fixture:setDensity(self.mass/5)
		
		self.fixture:setMask(unpack(masks))
	end
	self.body:resetMassData()
	self.body:setLinearVelocity(self.dx*self.vi,self.dy*self.vi)
	self.body:setBullet(true)
	self.body:setAngle(math.atan2(self.dy,self.dx))
	self.fixture:setUserData(self)
end


FistP1MEffect = UnitEffect:new()
FistP1MEffect:addAction(function (unit,caster,skill)
	unit:damage('Bullet',caster.unit:getDamageDealing(skill.damage,'Bullet'),caster.unit)
	unit:addBuff(b_Stun(100),3)
end)

FistP1Effect = ShootMissileEffect:new()
FistP1Effect:addAction(function(point,caster,skill)
	local Missile = FistMissileP3:new(1,skill.bulletmass,skill.range/1,caster.x,caster.y,unpack(point))
	Missile.controller = caster.controller..'Missile'
	Missile.effect = FistP1MEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	TEsound.play({'sound/sword1.wav','sound/sword2.wav','sound/sword3.wav'})
end)

FistP1 = Skill:subclass'FistP1'
function FistP1:initialize(unit)
	super.initialize(self)
	self.unit = unit
	self.name = 'Fist'
	self.effecttime = 0.02
	self.casttime = 1
	self.damage = 50
	self.bulletmass = 1
	self.range = 300
	self.effect = FistP1Effect
end

function FistP1:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end


FistP2MEffect = UnitEffect:new()
FistP2MEffect:addAction(function (unit,caster,skill)
	unit:damage('Bullet',caster.unit:getDamageDealing(skill.damage,'Bullet'),caster.unit)
	unit:addBuff(b_Stun(100),2)
end)

FistP2Effect = ShootMissileEffect:new()
FistP2Effect:addAction(function(point,caster,skill)
	local Missile = FistMissileP3:new(1,skill.bulletmass,skill.range/1,caster.x,caster.y,unpack(point))
	Missile.controller = caster.controller..'Missile'
	Missile.effect = FistP1MEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	TEsound.play{'sound/sword1.wav','sound/sword2.wav','sound/sword3.wav'}
end)

FistP2 = Skill:subclass'FistP1'
function FistP2:initialize(unit)
	super.initialize(self)
	self.unit = unit
	self.name = 'Fist'
	self.effecttime = 0.02
	self.casttime = 1
	self.damage = 50
	self.bulletmass = 0.5
	self.range = 200
	self.effect = FistP2Effect
end

function FistP2:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

-------------------- BEAUTIFUL SPLIT LINE --------------------


FistMissileP3 = Missile:subclass('FistMissileP3')
function FistMissileP3:initialize(...)
	super.initialize(self,...)
	self.p = particlemanager.getsystem'meteor'
	self.p:start()
end
function FistMissileP3:update(dt)
	super.update(self,dt)
	self.p:setPosition(self.x,self.y)
	self.p:update(dt)
end
function FistMissileP3:draw()
	
	love.graphics.draw(self.p)
end
function FistMissileP3:add(unit,coll)
	if (self.controller=='playerMissile' and unit.controller=='enemy') or (self.controller == 'enemyMissile' and unit.controller=='player') then
		if not unit.bht[self] then
			if self.effect then self.effect:effect(unit,self,self.skill) end
			unit.bht[self] = true
			self.draw = function() end
			self.add = function() end
		end
	end
end

function FistMissileP3:createBody(world)
	self.body = love.physics.newBody(world,self.x,self.y,'dynamic')
	self.shape = love.physics.newCircleShape(20)
	self.fixture = love.physics.newFixture(self.body,self.shape)
	if self.controller then
		category,masks = unpack(typeinfo[self.controller])
		self.fixture:setCategory(category)
		self.fixture:setDensity(self.mass/5)
		
		self.fixture:setMask(unpack(masks))
	end
	self.body:resetMassData()
	self.body:setLinearVelocity(self.dx*self.vi,self.dy*self.vi)
	self.body:setBullet(true)
	self.body:setAngle(math.atan2(self.dy,self.dx))
	self.fixture:setUserData(self)
end


FistP3MEffect = UnitEffect:new()
FistP3MEffect:addAction(function (unit,caster,skill)
	unit:damage('Bullet',caster.unit:getDamageDealing(skill.damage,'Bullet'),caster.unit)
	unit:addBuff(b_Stun(100),0.5)
end)

FistP3Effect = ShootMissileEffect:new()
FistP3Effect:addAction(function(point,caster,skill)
	local Missile = FistMissileP3:new(5,skill.bulletmass,skill.range/1,caster.x,caster.y,unpack(point))
	Missile.controller = caster.controller..'Missile'
	Missile.effect = FistP3MEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
end)

requireImage('assets/electrician/lightningball.png','KickP2')
FistP3Unit = Missile:subclass('FistP3Unit')

function FistP3Unit:preremove()
	super.preremove(self)
	--self.skill.bulleteffect:effect({self.x,self.y},self.unit,self.skill)
	local ip = LightningImpact:new(self,30,0.25,0.05,1,{255,255,255},1)
	map:addUpdatable(ip)
end

function FistP3Unit:update(dt)
	super.update(self,dt)
	if self.dt>1 then
		self.body:setLinearVelocity(0,0)
	end
end

function FistP3Unit:draw()
	love.graphics.draw(img.KickP2,self.x,self.y,math.random(),1,1,32,32)
end

FistMEffect = ShootMissileEffect:new()
FistMEffect:addAction(function(point,caster,skill)
	local sx,sy = point[1]-caster.x,point[2]-caster.y
	local v = math.sqrt(sx*sx+sy*sy)
	sx,sy=normalize(sx,sy)
	local Missile = FistP3Unit:new(1,1,v,caster.x,caster.y,sx,sy)
	local ip = LightningImpact:new(Missile,30,0.1,0.05,4,{255,255,255},0.3)
	map:addUpdatable(ip)
	Missile.controller = caster.controller..'Missile'
	Missile.effect = CrackDamageEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	Timer(0.08,30,function()
		FistP3Effect:effect({normalize(math.random()-0.5,math.random()-0.5)},caster,skill)
	end)
end)


FistP3 = ActiveSkill:subclass('FistP3')
function FistP3:initialize(unit)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.bullettype = FistP3MEffect
	self.name = 'FistP3'
	self.effecttime = 0.1
	self.damage = 200
	self.effect = FistMEffect
	self.manacost = 20
	self.cd=1
	self.cdtime = 0
	self.impact = 300
end

function FistP3:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	if self.unit:getMP()<self.manacost then
		return false,'Not enough MP'
	end
	self.unit.mp = self.unit.mp - self.manacost
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function FistP3:geteffectinfo()
	return GetOrderPoint(),self.unit,self
end
