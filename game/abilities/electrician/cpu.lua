
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

function CPU:getSublevel(skill,n)
	if skill:isKindOf(Prism) then
		return math.floor(self.level/10)+n
	elseif skill:isKindOf(LightningBolt) then
		return math.floor(math.clamp(math.floor((self.level+1)/3)+1,1,4))
	elseif skill:isKindOf(ChainLightning) then
		return math.floor(math.clamp(math.floor((self.level+2)/3)+2,1,4))
	elseif skill:isKindOf(OrbLightning) then
		return math.floor(math.clamp(math.floor((self.level+3)/3)+3,1,4))
	end
end

function CPU:getPanelData()
	return{
		title = 'HOLLY',
		type = 'Centrual Processing Unit',
		attributes = {
			{text = "The energy source which maintains the functionalities of HOLLY and the life of the electrician himself."},
			{text = "Provide 1 unit of energy supply per level. Energy supply restrict the electrician's other chips."},
			{text = "Upgrades increase the effeciency of draining."},
			{text = "Ultimate upgrade",data='Automatic Drain'},
		}
	}
end

function CPU:setLevel(lvl)
	print (lvl)
	self.level = lvl
	if lvl>1 then
		return {
		}
		else
		return {}
	end
end

BoltTrail = Object:subclass('BoltTrail')
function BoltTrail:initialize(b)
	self.bullet = b
	local p = love.graphics.newParticleSystem(pulse, 1000)
	p:setEmissionRate(200)
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
	love.graphics.draw(pulse,self.x,self.y,0,1,1,16,16)
	love.graphics.setColor(255,255,255,255)
end
function BoltMissile:add(unit,coll)
	if (self.controller=='playerMissile' and unit.controller=='enemy') or (self.controller == 'enemyMissile' and unit.controller=='player') then
		if not unit.bht[self] then
			if self.effect then self.effect:effect(unit,self,self.skill) end
			unit.bht[self] = true
			self.trail.dt = 99
			self.draw = function() end
			self.persist = function() end
			local ip = LightningImpact:new(10,0.1,0.05,1,{255,255,255},0.3)
			ip.x,ip.y = unit.x,unit.y
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

b_Ionicform = Buff:subclass('b_Ionicform')
function b_Ionicform:initialize(point,caster,skill)
	self.point = point
	self.skill = skill
end

function b_Ionicform:start(unit)
	self.trail = BoltTrail:new(unit)
	unit.movementspeedbuffpercent = unit.movementspeedbuffpercent + self.skill.movementspeedbuffpercent
	self.beam = Beam:new({x=unit.x,y=unit.y},unit,1,100,{255,255,255})
	map:addUpdatable(self.trail)
	map:addUpdatable(self.beam)
	unit.shape:setSensor(true)
end

function b_Ionicform:stop(unit)
	unit.state = 'slide'
	unit.movementspeedbuffpercent = unit.movementspeedbuffpercent - self.skill.movementspeedbuffpercent
	unit.body:setLinearVelocity(0,0)
	unit.shape:setSensor(false)
	self.trail.dt = 99
	self.beam.life = 0.5
end

function b_Ionicform:buff(unit,dt)
	unit.direction = self.point;
	unit.state = 'move';
	self.beam.x2,self.beam.y2 = unit.x,unit.y
	unit.mp = unit.mp-dt*self.skill.manacost
	if unit.mp<200 then
		unit:stop()
	end
end

IonicformEffect = ShootMissileEffect:new()
IonicformEffect:addAction(function(point,caster,skill)
	local buff = b_Ionicform:new(point,caster,skill)
	caster:addBuff(buff,99)
	skill.buff = buff
end)

Ionicform = Skill:subclass('Ionicform')
function Ionicform:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Ionicform'
	self.effecttime = 9999
	self.effect = IonicformEffect
	self:setLevel(level)
	self.movementspeedbuffpercent = 10
	self.maxlevel = 3
	self.manacost = 30
end

function Ionicform:getPanelData()
	return{
		title = 'Ionicform',
		type = 'PRIMARY WEAPON',
		attributes = {
			{text = "Purely awesome weapon."},
			{text = 'Firerate (per second)',data = function()return  string.format('%.1f',1/self.casttime) end},
			{text = 'Damage',data = function()return  self.damage end},
		}
	}
end

function Ionicform:startChannel()
	if self.unit.mp<200 then return end
	self.effect:effect(self:getorderinfo())
	self.unit:playAnimation('ionicform',1,true)
end

function Ionicform:endChannel()
	print 'end'
	if self.buff then
		for k,v in pairs(self.unit.buffs) do
			print (k,v,'before')
		end
		self.unit:removeBuff(self.buff)
		for k,v in pairs(self.unit.buffs) do
			print (k,v,'after')
		end
	end
	self.unit:resetAnimation()
	self.buff = nil
end

function Ionicform:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function Ionicform:stop()
	self.time = 0
end

function Ionicform:setLevel(lvl)
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
	print (#units,units)
	for i = 1,math.min(#units,skill.jumpcount) do
		print (i)
		Timer:new(0.2*i-0.2,1,function(t)
			local l = Beam:new(units[i-1],units[i],1,1,{255,255,255})
			map:addUpdatable(l)
			units[i]:damage('Electric',skill.damage*math.pow(skill.damagedecay,i),caster)
			local ip = LightningImpact:new(10,0.1,0.05,1,{255,255,255},0.3)
			ip.x,ip.y = units[i].x,units[i].y
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
		type = 'PRIMARY WEAPON',
		attributes = {
			{text = "Purely awesome weapon."},
			{text = 'Firerate (per second)',data = function()return  string.format('%.1f',1/self.casttime) end},
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
