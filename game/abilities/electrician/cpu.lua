
CPU = Skill:subclass('CPU')
function CPU:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.effecttime = 9999
	self.effect = DrainEffect
	self:setLevel(level)
	self.movementspeedbuffpercent = 10
	self.maxlevel = 1
	self.isHub = true
end

function CPU:getSublevel(skill)
	if skill:isKindOf(Prism) then
		return math.floor(self.level/10)
	elseif skill:isKindOf(LightningBolt) then
		return math.floor(math.clamp(math.floor((self.level+2)/3),1,3))
	elseif skill:isKindOf(LightningChain) then
		return math.floor(math.clamp(math.floor((self.level+1)/3),0,3))
	elseif skill:isKindOf(LightningBall) then
		return math.floor(math.clamp(math.floor((self.level)/3),0,3))
	end
end

function CPU:getPanelData()
	return{
		title = 'GP 8044',
		type = 'Centrual Processing Unit',
		attributes = {
			{text = "A extremely powerful quantum processer that can solve any NP-hard problems in constant time."},
			{text = "Upgrades increase the damage of Lightning Bolt."},
			{text = "Upgrades increase the effect of Chain Lightning."},
			{text = "Upgrades increase the effect of Ball Lightning."},
			{text = "Ultimate upgrade",data='Powerup Prism'},
		}
	}
end

function CPU:setLevel(lvl)
	self.level = lvl
	if lvl>1 then
		return {
			self.unit.skills.lightningbolt,
			self.unit.skills.lightningchain,
			self.unit.skills.lightningball,
		}
		else
		return {}
	end
end

BoltTrail = Object:subclass('BoltTrail')
function BoltTrail:initialize(b)
	self.bullet = b
	local p = love.graphics.newParticleSystem(img.pulse, 1000)
	p:setEmissionRate(options.particlerate*200)
	p:setSpeed(50, 100)
	p:setGravity(0)
	p:setSize(0.25, 0.15)
	p:setLifetime(0.5)
	p:setParticleLife(0.5)
	p:setDirection(0)
	p:setSpread(360)
	p:setRadialAcceleration(-500)
	self.p = p
	self.dt = 0
end

function BoltTrail:update(dt)
	self.dt = self.dt + dt
	if self.dt>100 then
		map:removeUpdatable(self)
	end
	if self.dt<99 then
		self.p:setPosition(self.bullet.x,self.bullet.y)
		self.p:start()
	end
	self.p:update(dt)
end

function BoltTrail:draw()
	love.graphics.draw(self.p)
end

BoltMissile = Missile:subclass('BoltMissile')
function BoltMissile:initialize(...)
	super.initialize(self,...)
	self.trail = BoltTrail:new(self)
	map:addUpdatable(self.trail)
	self.trail.dt = 95
end
function BoltMissile:draw()
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(img.pulse,self.x,self.y,0,1,1,16,16)
	love.graphics.setColor(255,255,255,255)
end
function BoltMissile:add(unit,coll)
	if (self.controller=='playerMissile' and unit.controller=='enemy') or (self.controller == 'enemyMissile' and unit.controller=='player') then
		if not unit.bht[self] then
			self.add = nil
			if self.effect then self.effect:effect(unit,self,self.skill) end
			unit.bht[self] = true
			self.trail.dt = 99
			self.draw = function() end
			self.persist = function() end
			local ip = LightningImpact:new(unit,10,0.1,0.05,1,{255,255,255},0.3)
			map:addUpdatable(ip)
		end
	end
end


BoltEffect = ShootMissileEffect:new()
BoltEffect:addAction(function(point,caster,skill)
	local Missile = skill.bullettype:new(1,1,1000,caster.x,caster.y,unpack(point))
	Missile.controller = caster.controller..'Missile'
	Missile.effect = skill.bulleteffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	caster:playAnimation('attack',1,false)
	TEsound.play('sound/lightningbolt.wav')
end)


BoltBulletEffect = UnitEffect:new()
BoltBulletEffect:addAction(function (unit,caster,skill)
	unit:damage('Electric',caster.unit:getDamageDealing(skill.damage,'Electric'),caster)
	TEsound.play('sound/lightningbolthit.wav')
end)

LightningBolt = Skill:subclass('LightningBolt')
function LightningBolt:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.bullettype = BoltMissile
	self.name = 'LightningBolt'
	self.effecttime = 0.1
	self.damage = 50
	self.effect = BoltEffect
	self.bulleteffect = BoltBulletEffect
	self:setLevel(level)
	self.manacost = 20
end

function LightningBolt:getPanelData()
	return{
		title = 'LIGHTNING BOLT',
		type = 'ACTIVE',
		attributes = {
			{text = "Fire lightning bolt towards enemy. Consumes energy."},
			{text = 'Firerate (per second)',data = function()return  string.format('%.1f',1/self.casttime) end},
			{text = 'Damage',data = function()return  self.damage end},
		}
	}
end

function LightningBolt:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function LightningBolt:stop()
	self.time = 0
end

function LightningBolt:setLevel(lvl)
	self.casttime = 0.7/(1+lvl*0.2) -- inversely proportional
	self.level = lvl
end

LightningChain = ActiveSkill:subclass('LightningChain')

LightningChainEffect = ShootMissileEffect:new()
LightningChainEffect:addAction(function(point,caster,skill)
	local units = map:findUnitsWithCondition(
		function(unit) 
			return withinfanarea(unit,caster.x,caster.y,400,math.atan2(point[2],point[1]),math.pi/3) and unit:isKindOf(Unit) and unit:isEnemyOf(caster)
		end
	)
	units[0] = caster
	caster:playAnimation('active',0.5,false)
	for i = 1,math.min(#units,skill.jumpcount) do
		Timer:new(0.2*i-0.2,1,function(t)
			local l = Beam:new(units[i-1],units[i],1,1,{255,255,255})
			map:addUpdatable(l)
			units[i]:damage('Electric',skill.damage*math.pow(skill.damagedecay,i),caster)
			local ip = LightningImpact:new(units[i],10,0.1,0.05,1,{255,255,255},0.3)
			map:addUpdatable(ip)
			TEsound.play('sound/chainlightning.wav')
		end,true,true)
	end
end)

function LightningChain:initialize(unit,level)
	super.initialize(self,unit)
	level = level or 0
	self.unit = unit
	self.name = 'LightningChain'
	self.effecttime = 9999
	self.effect = LightningChainEffect
	self:setLevel(level)
	self.cd = 1
	self.cdtime = 0
	self.manacost = 50
end
function LightningChain:getPanelData()
	return{
		title = 'Lightning Chain',
		type = 'ACTIVE',
		attributes = {
			{text = "Fire a lightning chain that jumps between enemies. Each jump decreases the damage of lightning chain by 30%"},
			{text = "Upgrade to increase the maximum jump count and damage"},
			{text = 'Jump count',data = function()return  self.jumpcount end},
			{text = 'Damage',data = function()return  self.damage end},
		}
	}
end

function LightningChain:active()
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

function LightningChain:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function LightningChain:stop()
	self.time = 0
end

function LightningChain:setLevel(lvl)
	self.casttime = 0.7/(1+lvl*0.2) -- inversely proportional
	self.level = lvl
	self.jumpcount = lvl+2
	self.damage = lvl * 100+200
	self.damagedecay = 0.7
end

requireImage('assets/electrician/lightningball.png','lightningball')
LightningBallUnit = Missile:subclass('LightningBallUnit')

function LightningBallUnit:preremove()
	super.preremove(self)
	self.skill.bulleteffect:effect({self.x,self.y},self.unit,self.skill)
	local ip = LightningImpact:new(self,30,0.25,0.05,1,{255,255,255},1)
	map:addUpdatable(ip)
end

function LightningBallUnit:update(dt)
	super.update(self,dt)
	if self.dt>1 then
		self.body:setLinearVelocity(0,0)
	end
end

function LightningBallUnit:draw()
	love.graphics.draw(img.lightningball,self.x,self.y,math.random(),1,1,32,32)
end

BallEffect = ShootMissileEffect:new()
BallEffect:addAction(function(point,caster,skill)
	local sx,sy = point[1]-caster.x,point[2]-caster.y
	local v = math.sqrt(sx*sx+sy*sy)
	sx,sy=normalize(sx,sy)
	local Missile = LightningBallUnit:new(4,1,v,caster.x,caster.y,sx,sy)
	local ip = LightningImpact:new(Missile,30,0.1,0.05,4,{255,255,255},0.3)
	map:addUpdatable(ip)
	Missile.controller = caster.controller..'Missile'
	Missile.effect = BallDamageEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	caster:playAnimation('attack',1,false)
end)

BallDamageEffect = CircleAoEEffect:new(200)
BallDamageEffect:addAction(function (area,caster,skill)
	local units = map:findUnitsInArea(area)
	for k,v in pairs(units) do
		if v:isKindOf(Unit) then
			local impact = skill.impact
			local x,y=normalize(v.x-area.x,v.y-area.y)
			x,y=x*impact,y*impact
			if v.body and not v.immuneimpact then
				v.body:applyImpulse(x,y)
			end
			v:damage('Electric',skill.damage,caster)
		end
	end
	TEsound.play('sound/thunderclap.wav')
end)


LightningBall = ActiveSkill:subclass('LightningBall')
function LightningBall:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.bullettype = BoltMissile
	self.name = 'LightningBall'
	self.effecttime = 0.1
	self.damage = 50
	self.effect = BallEffect
	self.bulleteffect = BallDamageEffect
	self:setLevel(level)
	self.manacost = 20
	self.cd=1
	self.cdtime = 0
	self.impact = 100
end


function LightningBall:getPanelData()
	return{
		title = 'Orb Lightning',
		type = 'ACTIVE',
		attributes = {
			{text = "Throw a sphere of highly concentrated electronic energy. When explode, deal damage to nearby units(friend or foe), and push them back."},
			{text = "Upgrade to increase the damage and impact"},
			{text = 'Impact',data = function()return  self.impact end},
			{text = 'Damage',data = function()return  self.damage end},
		}
	}
end

function LightningBall:active()
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

function LightningBall:geteffectinfo()
	return GetOrderPoint(),self.unit,self
end

function LightningBall:stop()
	self.time = 0
end

function LightningBall:setLevel(lvl)
	self.casttime = 0.7/(1+lvl*0.2) -- inversely proportional
	self.level = lvl
	self.damage = lvl * 75+100
end
