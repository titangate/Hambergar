
PortalOfMiseryEffect = ShootMissileEffect()
PortalOfMiseryEffect:addAction(function(point,caster,skill)
	local s = caster.skills.weaponskill
	assert(s)
	if not s.effect then return end
	s.effect:effect(point,
		caster,s)
end)

PortalOfMisery = Skill:subclass'PortalOfMisery'
function PortalOfMisery:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.effecttime = 0.1
	self.damage = 50
	self.effect = PortalOfMiseryEffect
	self:setLevel(level)
	self.icon = requireImage'assets/item/theravada.png'
end
--[[
function PortalOfMisery:setMomentumBullet(state)
--	print ("Momentum",state)
	if state then
		self.bullettype = MomentumBullet
	else
		self.bullettype = Bullet
	end
end
]]
function PortalOfMisery:getPanelData()
	return{
		title = LocalizedString'Portal Of Misery',
		type = LocalizedString'PRIMARY WEAPON',
		attributes = {
			{text = LocalizedString"Summon countless bullets from the portal to damage enemy"},
			{text = LocalizedString'Firerate (per second)',data = function()return  string.format('%.1f',1/self.casttime) end},
		}
	}
end


function PortalOfMisery:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function PortalOfMisery:setLevel(lvl)
	self.casttime = 0.2/(1+lvl*0.2) -- inversely proportional
	self.level = lvl
--	if self.unit.skills then self.unit.skills.PortalOfMiserydwsalt:setLevel(lvl) end
end


DragonTrail = Object:subclass('DragonTrail')
function DragonTrail:draw()
	if self.dt < 0.3 then
		love.graphics.setColor(255,255,255,self.dt/0.3*255)
	elseif self.dt > 0.7 then
		love.graphics.setColor(255,255,255,math.max(0,(1-self.dt)/0.3*255))
	else
		love.graphics.setColor(255,255,255)
	end
	love.graphics.circle('fill',self.x,self.y,self.r,100)
	love.graphics.draw(requireImage'assets/mastery/missile/birdmissile.png',self.x,self.y,self.r,1,1,400-self.dt*200,100)
	love.graphics.setColor(255,255,255)
end

function DragonTrail:update(dt)
	if self.dt > 1 then
		map:removeUpdatable(self)
		return
	end
	assert(self.unit)
	self.x,self.y = self.unit:getPosition()
	self.r = self.unit:getAngle()
	self.dt = self.dt + dt
--	self.x = self.x or 0
--	self.y = self.y or 0
	-- TODO:INVETIGATE
end

function DragonTrail:initialize(unit)
	self.dt = 0
	self.unit = unit
	self.x,self.y = 0,0
	self.r = 0
end

DragonEyeMissile = Missile:subclass('DragonEyeMissile')
function DragonEyeMissile:initialize(...)
	super.initialize(self,...)
	self.p = particlemanager.getsystem'meteor'
	self.p:start()
end
function DragonEyeMissile:update(dt)
	super.update(self,dt)
	self.p:setPosition(self.x,self.y)
	self.p:update(dt)
end
function DragonEyeMissile:draw()
	
	love.graphics.draw(self.p)
end
function DragonEyeMissile:add(unit,coll)
	if (self.controller=='playerMissile' and unit.controller=='enemy') or (self.controller == 'enemyMissile' and unit.controller=='player') then
		if not unit.bht[self] then
			if self.effect then self.effect:effect(unit,self,self.skill) end
			unit.bht[self] = true
			self.draw = function() end
			self.add = function() end
		end
	end
end

function DragonEyeMissile:createBody(world)
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
	self.updateShapeData = true
--	self.fixture:setUserData(self)
end


DragonEyeM2Effect = UnitEffect:new()
DragonEyeM2Effect:addAction(function (unit,caster,skill)
	unit:damage('Bullet',caster.unit.unit:getDamageDealing(skill.damage,'Bullet'),caster.unit)
end)

DragonEyeEffect = ShootMissileEffect:new()
DragonEyeEffect:addAction(function(point,caster,skill)
	local Missile = DragonEyeMissile:new(5,skill.bulletmass,skill.range/1,caster.x,caster.y,unpack(point))
	Missile.controller = caster.controller
	Missile.effect = DragonEyeM2Effect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
end)

DragonEyeUnit = Missile:subclass('DragonEyeUnit')

function DragonEyeUnit:preremove()
	super.preremove(self)
	--self.skill.bulleteffect:effect({self.x,self.y},self.unit,self.skill)
--	local ip = LightningImpact:new(self,30,0.25,0.05,1,{255,255,255},1)
--	map:addUpdatable(ip)
end

function DragonEyeUnit:update(dt)
	super.update(self,dt)
	if self.dt>1 then
		self.body:setLinearVelocity(0,0)
	end
end


function DragonEyeUnit:createBody(world)
	self.body = love.physics.newBody(world,self.x,self.y,'kinematic')
	self.shape = love.physics.newCircleShape(80)
	self.fixture = love.physics.newFixture(self.body,self.shape)
	if self.controller then
		local category,masks = unpack(typeinfo[self.controller])
		self.fixture:setCategory(category)
		self.fixture:setDensity(self.mass/5)
		
		self.fixture:setMask(unpack(masks))
	end
	self.body:resetMassData()
	self.body:setLinearVelocity(self.dx*self.vi,self.dy*self.vi)
	self.body:setBullet(true)
	self.body:setAngle(math.atan2(self.dy,self.dx))
	self.updateShapeData = true
--	self.fixture:setUserData(self)
end

function DragonEyeUnit:add()
end

function DragonEyeUnit:draw()
	love.graphics.draw(requireImage('assets/electrician/lightningball.png'),self.x,self.y,math.random(),1,1,32,32)
end

function DragonEyeUnit:initialize(...)
	super.initialize(self,...)
	map:addUpdatable(DragonTrail(self))
end

DragonEyeMEffect = ShootMissileEffect:new()
DragonEyeMEffect:addAction(function(point,caster,skill)
	assert(point[1],'point has to have x')
	assert(caster.x,'caster needs a position')
	local sx,sy = point[1]-caster.x,point[2]-caster.y
	local v = math.sqrt(sx*sx+sy*sy)
	sx,sy=normalize(sx,sy)
	local Missile = DragonEyeUnit(2.4,1,v,caster.x,caster.y,sx,sy)
	Missile.controller = caster.controller..'Missile'
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	Timer(0.08,skill.shots,function()
		DragonEyeEffect:effect({normalize(math.random()-0.5,math.random()-0.5)},Missile,skill)
	end)
end)


DragonEye = ActiveSkill:subclass('DragonEye')
function DragonEye:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'DragonEye'
	self.effecttime = 0.1
	self.damage = 20
	self.effect = DragonEyeMEffect
	self.manacost = 20
	self.cd=1
	self.cdtime = 0
	self.impact = 300
	self.bulletmass = 0.2
	self.range = 1000
	self.shots = 30
	self:setLevel(level)
	
end

function DragonEye:setLevel(lvl)
	self.level = lvl
end

function DragonEye:active()
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

function DragonEye:geteffectinfo()
	return GetOrderPoint(),self.unit,self
end

function DragonEye:getPanelData()
	return{
		title = LocalizedString"Phoenix's grace",
		type = LocalizedString'ACTIVE',
		attributes = {
			{text = LocalizedString"Summon a phoniex, spreads light beams all around itself."},
			{text = LocalizedString'Damage',data = function()return self.damage end},
			{text = LocalizedString'Shots',data = function()return self.shots end},
		}
	}
end


MantraShieldUnit = Unit:subclass'MantraShieldUnit'

function MantraShieldUnit:initialize(x,y,controller)
	super.initialize(self,x,y,100,0)
	self.controller = controller
	map.anim:easy(self,'r',0,10,10)
	self.maxhp = 100000
	self.hp = self.maxhp
end


function MantraShieldUnit:update(dt)
	super.update(self,dt)
	self:damage('self',self.maxhp*dt/10)
end

function MantraShieldUnit:createBody(...)
	super.createBody(self,...)
end

function MantraShieldUnit:draw()
	love.graphics.draw(requireImage'assets/assassin/gate.png',self.x,self.y,self.r,1,1,128,128)
end

function MantraShieldUnit:add(b,coll)
	if self:isEnemyOf(b) and b:isKindOf(Missile) then
		map:changeOwner(b,'playerMissile')
		if not b.unit then return end
		local angle = anglebetween(self,b.unit)
		local category,masks = unpack(typeinfo.playerMissile)
		b.fixture:setCategory(category)
		b.fixture:setMask(unpack(masks))
		b.body:setAngle(angle)
		b.body:setAngularVelocity(0)
		b.body:setLinearVelocity(math.cos(angle)*500,math.sin(angle)*500)
		
	end
end


MantraShieldEffect = UnitEffect()
MantraShieldEffect:addAction(function(unit,caster,skill)
	local x,y = unit:getPosition()
	map:addUnit(MantraShieldUnit(x,y,unit.controller))
end)

MantraShield = ActiveSkill:subclass('MantraShield')
function MantraShield:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'DragonEye'
	self.effecttime = 0.1
	self.damage = 20
	self.effect = MantraShieldEffect
	self.manacost = 20
	self.cd=1
	self.cdtime = 0
	self.impact = 300
	self.bulletmass = 0.2
	self.duration = 5
	self:setLevel(level)
end

function MantraShield:setLevel(lvl)
	self.level = lvl
end

function MantraShield:active()
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

function MantraShield:getPanelData()
	return{
		title = LocalizedString"Mantra Shield",
		type = LocalizedString'ACTIVE',
		attributes = {
			{text = LocalizedString"Creates a shield on the ground, reflects enemies' projectiles back to the enemies."},
			{text = LocalizedString"Duration",data = self.duration},
		}
	}
end



function MantraShield:geteffectinfo()
	return self.unit,self.unit,self
end

KoDPowerUpActor = Object:subclass'KoDPowerUpActor'
function KoDPowerUpActor:initialize(unit)
	self.hpregen = hpregen
	self.particle = {}
	self.unit = unit
	self.p = particlemanager.getsystem'goldensparkle'
	self.p:setLifetime(10)
	self.p:start()
	self.r = 0
end

function KoDPowerUpActor:update(dt)
	local r = math.random()*math.pi*2
	table.insert(self.particle,{
		life = 1,
		x = math.cos(r)*500,
		y = math.sin(r)*500,
	})
	
	self.particle[#self.particle].vx = -self.particle[#self.particle].x
	self.particle[#self.particle].vy = -self.particle[#self.particle].y
	for i,v in ipairs(self.particle) do
		v.life = v.life - dt
		if v.life > 0 then
			v.x = v.x + v.vx * dt
			v.y = v.y + v.vy * dt
		end
	end
	self.r = self.r + dt
	local x,y = displacement(0,0,self.r,1000-self.r*100)
	self.p:setPosition(x,y)
	self.p:update(dt)
end

requireImage'assets/sparkle.png'
function KoDPowerUpActor:draw()
	local unit = self.unit
	for i,v in ipairs(self.particle) do
		if v.life > 0 then
			love.graphics.draw(img.sparkle,unit.x + v.x,unit.y + v.y,0,2,2,16,16)
		end
	end
	for i=1,3 do
		love.graphics.draw(self.p,unit.x,unit.y,math.pi*2/3*i)
	end
end