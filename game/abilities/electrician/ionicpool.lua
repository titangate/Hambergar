
IonicPool = Skill:subclass('IonicPool')
function IonicPool:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'IonicShield'
	self.effecttime = 9999
	self.effect = IonicShieldEffect
	self:setLevel(level)
	self.movementspeedbuffpercent = 10
	self.maxlevel = 15
	self.isHub = true
end

function IonicPool:getSublevel(skill)
	if skill:isKindOf(CPU) then
		print (self.level,self.level*0.66)
		return math.ceil(self.level*0.66)
	elseif skill:isKindOf(Transmitter) then
		return math.floor((self.level)/2)
	end
	return math.floor(self.level/3.4+1)
end

function IonicPool:getPanelData()
	return{
		title = 'Ionic Pool',
		type = 'SUPPORTIVE CHIP',
		attributes = {
			{text = "A chip that controls the ion flow inside electrician's body."},
			{text = "Provide upgrades for supportive skills."},
			{text = "Upgrades increase the basic attributes of electrician"},
		}
	}
end

function IonicPool:setLevel(lvl)
	self.level = lvl
	if lvl>1 then
		return {
			self.unit.skills.ionicshield,
			self.unit.skills.thorn,
			self.unit.skills.illumination,
		}
	else
	return {}
end
end


b_IonicShield = Buff:subclass('b_IonicShield')
function b_IonicShield:initialize(unit,caster,skill)
	self.skill = skill
	self.damageabsord = skill.damageabsord
	self.sparkle = {}
	self.dt = 0
end

function b_IonicShield:start(u)
	local t = Trigger(function(trig,event)
		if event.unit == u then
			self.damageabsord = self.damageabsord - event.damage
			u.hp = u.hp + event.damage
			self:showeffect(u,event.source)
			if self.damageabsord<=0 then
				u:removeBuff(self)
			end
		end
	end)
	t:registerEventType'damage'
	self.t = t
end

function b_IonicShield:showeffect(unit,source)
	source = source or unit
	self.sparkle[{
		x=source.x,
		y=source.y,
		angle = math.atan2(source.y-unit.y,source.x-unit.x)
	}] = 1
end

function b_IonicShield:buff(unit,dt)
	for part,t in pairs(self.sparkle) do
		if t<=0 then
			self.sparkle[part] = nil
		else
			self.sparkle[part] = t-dt
		end
	end
	
	self.dt = self.dt + dt
end

function b_IonicShield:stop(unit)
	self.t:destroy()
end

requireImage'assets/electrician/ionicshield.png'
requireImage'assets/electrician/ionicshieldsparkle.png'
function b_IonicShield:draw(unit)
	love.graphics.draw(img.ionicshield,unit.x,unit.y,self.dt*50,1,1,64,64)
	
	for part,t in pairs(self.sparkle) do
		love.graphics.setColor(255,255,255,t*255)
		love.graphics.draw(img.ionicshieldsparkle,unit.x,unit.y,part.angle,1,1,0,32)
		
			love.graphics.setColor(255,255,255,255)
	end
end


IonicShieldEffect = UnitEffect:new()
IonicShieldEffect:addAction(function(unit,caster,skill)
	local buff = b_IonicShield:new(unit,caster,skill)
	caster:addBuff(buff,30)
	skill.buff = buff
end)

IonicShield = ActiveSkill:subclass('IonicShield')
function IonicShield:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'IonicShield'
	self.effecttime = 9999
	self.effect = IonicShieldEffect
	self:setLevel(level)
	self.manaregen = 10
	self.maxlevel = 5
	self.range = 200
	self.damageabsord = 100
	self.cd = 0
	self.cdtime  = 0
end

function IonicShield:getPanelData()
	return{
		title = 'Ionic Shield',
		type = 'ACTIVE',
		attributes = {
			{text = "IonicShield electronic energy from nearby environment."},
			{text = 'Type',data = function() if self.level==self.maxskill then return 'Automatic' else return 'Manually' end end},
			{text = 'Energy Regeneration',data = function()return self.manaregen end},
		}
	}
end

function IonicShield:active()
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function IonicShield:geteffectinfo()
	return GetOrderUnit(),self.unit,self
end

function IonicShield:setLevel(lvl)
	self.damageabsorb = lvl*50+5
	self.level = lvl
end


IlluminationEffect = CircleAoEEffect:new(600)
IlluminationEffect:addAction(function (area,caster,skill)
	caster:playAnimation('active',1,false)
	if caster:getMP()<skill.manacost then return end
	caster.mp = caster.mp-20
	local units = map:findUnitsInArea(area)
	for k,v in pairs(units) do
		if v:isKindOf(Unit) and v.mechanical then
			v:addBuff(b_Stun:new(100,nil),skill.stuntime)
			v:damage('Electric',caster:getDamageDealing(100,'Electric'),caster)
			local x,y=normalize(v.x-area.x,v.y-area.y)
			if buff then v.buffs[buff:new()] = true end
		end
	end
	Lighteffect.lightOn(caster)
	map.anim:easy(Lighteffect,'brightness',255,0,skill.stuntime)
	Timer(5,1,function()Lighteffect.stop()end)
end)

Illumination = ActiveSkill:subclass('Illumination')
function Illumination:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'IonicShield'
	self.effecttime = 9999
	self.effect = IlluminationEffect
	self:setLevel(level)
	self.manaregen = 10
	self.maxlevel = 5
	self.range = 200
	self.stuntime = 5
	self.cd = 0
	self.cdtime  = 0
	self.manacost = 50
end

function Illumination:getPanelData()
	return{
		title = 'Illumination',
		type = 'ACTIVE',
		attributes = {
			{text = "Temperarily disable small-sized mechanical units nearby."},
			{text = 'Stun time',data = function()return self.stuntime end},
		}
	}
end

function Illumination:active()
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function Illumination:geteffectinfo()
	return {self.unit.x,self.unit.y},self.unit,self
end

function Illumination:setLevel(lvl)
	self.damageabsorb = lvl*50+5
	self.level = lvl
end

ThornEffect = UnitEffect:new()
ThornEffect:addAction(function(unit,caster,skill)
	if unit:isKindOf(Missile) then
		unit = unit.unit
	end
	if not caster:isEnemyOf(unit) then
		return
	end
	local l = Beam:new(caster,unit,1,1,{255,255,255})
	map:addUpdatable(l)
	if unit.damage then
		unit:damage('Electric',skill.damagereflect,caster)
	end
	local ip = LightningImpact:new(unit,10,0.1,0.05,1,{255,255,255},0.3)
	map:addUpdatable(ip)
--	end
end)

Thorn = Skill:subclass('Thorn')
function Thorn:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Thorn'
	self:setLevel(level)
	self.damagereflect = 50
	self.effect = ThornEffect
end
function Thorn:getPanelData()
	return{
		title = 'EM-Weak field distortion',
		type = 'PASSIVE',
		attributes = {
			{text = "Whenever electrician takes damage, electrician reflect the damage through a high energy beam."},
			{text = 'Damage reflect',data = function()return self.damagereflect end},
		}
	}
end

function Thorn:setLevel(lvl)
	self.damageabsorb = lvl*25+50
	self.level = lvl
end

