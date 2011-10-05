Transmitter = Skill:subclass('Transmitter')
function Transmitter:initialize(unit,level)
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

function Transmitter:getSublevel(skill)
	if skill:isKindOf(Icarus) then
		return math.floor(self.level/2)
	else
		return math.min(math.ceil(self.level/2),3)
	end
end

function Transmitter:getPanelData()
	return{
		title = 'Quantum Teleportation Device',
		type = 'Transmitter',
		attributes = {
			{text = "The primary joint between parts of Electrician."},
			{text = "Upgrades increase the effect of Ionic Form."},
			{text = "Upgrades increase the effect of ICARUS."},
			{text = "Ultimate upgrade",data='Powerup Prism'},
		}
	}
end

function Transmitter:setLevel(lvl)
	print (lvl)
	self.level = lvl
	if lvl>1 then
		return {
			self.unit.skills.ionicform,
			self.unit.skills.icarus,
		}
		else
		return {}
	end
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
	assert(unit.shape)
	self.mask = {unit.shape:getMask()}
	unit.shape:setMask(3,4,5)
	--unit.shape:setSensor(true)
end

function b_Ionicform:stop(unit)
	unit.state = 'slide'
	unit.movementspeedbuffpercent = unit.movementspeedbuffpercent - self.skill.movementspeedbuffpercent
	unit.body:setLinearVelocity(0,0)
--	unit.shape:setSensor(false)
	unit.shape:setMask(unpack(self.mask))
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
		title = 'Ionic Form',
		type = 'Channel',
		attributes = {
			{text = "Dissemble yourself into hyper ions and quickly travel through space."},
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

requireImage('assets/ripcircle.png','ripcircle')
IcarusActor = Object:subclass('IcarusActor')
function IcarusActor:initialize(x,y)
	self.x,self.y=x,y
	local p = love.graphics.newParticleSystem(img.pulse, 1000)
	p:setEmissionRate(300)
	p:setSpeed(100, 200)
	p:setGravity(0)
	p:setSize(1, 0.5)
	p:setColor(255, 255, 255, 255, 255, 255, 255, 0)
	p:setPosition(self.x,self.y)
	p:setLifetime(0.5)
	p:setParticleLife(0.5)
	p:setDirection(0)
	p:setSpread(360)
	p:setRadialAcceleration(-500)
	p:setTangentialAcceleration(1500)
	p:stop()
	self.system=p
	self.dt = 0
	self.time = 1
	self.visible = true
end


function IcarusActor:reset()
	self.dt = 0
	self.visible = true
end

function IcarusActor:update(dt)
	self.dt = self.dt+dt
	if self.dt>self.time then
		self.system:update(dt)
		if self.dt>self.time+1 then
			self.visible = false
			map:removeUpdatable(self)
		end
	else
		self.system:setPosition(self.x,self.y)
		self.system:start()
		self.system:update(dt)
	end
end

function IcarusActor:draw()
	if not self.visible then return end
	love.graphics.draw(self.system)
	local scale = self.dt/self.time
	love.graphics.setColor(255,255,255,255*(1-scale))
	love.graphics.draw(img.ripcircle,self.x,self.y,0,scale,scale,128,128)
	love.graphics.setColor(255,255,255,255)
end

IcarusEffect = CircleAoEEffect:new(150)
IcarusEffect:addAction(function (area,caster,skill)
	local impact = skill.impact
	caster:playAnimation('active',1,false)
	if caster:getMP()<skill.manacost then return end
	caster.mp = caster.mp-20
	local actor = IcarusActor:new(area.x,area.y)
	map:addUpdatable(actor)
	actor.x,actor.y=area.x,area.y
	local units = map:findUnitsInArea(area)
	for k,v in pairs(units) do
		if v:isKindOf(Unit) and v:isEnemyOf(caster) then
			v:addBuff(b_Stun:new(100,nil),1)
			v:damage('Electric',caster:getDamageDealing(100,'Electric'),caster)
			local x,y=normalize(v.x-area.x,v.y-area.y)
			x,y=x*impact,y*impact
			if buff then v.buffs[buff:new()] = true end
			if v.body and not v.immuneimpact then
				v.body:applyImpulse(x,y)
			end
		end
	end
	TEsound.play('sound/thunderclap.wav')
end)

Icarus = ActiveSkill:subclass('Icarus')
function Icarus:initialize(unit,level)	
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Icarus'
	self.effecttime = -1
	self.effect = IcarusEffect
	self.cd = 5
	self.cdtime = 0
	self.available = true
	self:setLevel(level)
	self.manacost = 50
	self.impact = 50
end


function Icarus:getPanelData()
	return{
		title = 'Icarus',
		type = 'ACTIVE',
		attributes = {
			{text = "Blast enemies around you away."},
			{text = 'Impact',data = function()return  self.impact end},
			{text = 'Damage',data = function()return  self.damage end},
		}
	}
end


function Icarus:geteffectinfo()
	return {self.unit.x,self.unit.y},self.unit,self
end

function Icarus:setLevel(lvl)
	self.level = lvl
	self.invistime = lvl*5
end


function Icarus:active()
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