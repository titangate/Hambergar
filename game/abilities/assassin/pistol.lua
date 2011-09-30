requireImage('assets/assassin/bullet.png','bullet')

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
	love.graphics.draw(img.bullet,self.x,self.y,self.body:getAngle(),1,1,16,16)
	love.graphics.setColor(255,255,255,255)
end

explosiveBulletEffect = CircleAoEEffect:new(50)
StunBulletEffect = UnitEffect:new()
StunBulletEffect:addAction(function (unit,caster,skill,Missile)
	unit:damage('Bullet',caster.unit:getDamageDealing(skill.damage,'Bullet'),caster.unit)
	if caster.unit.skills.stunbullet and math.random()< caster.unit.skills.stunbullet.stunchance then
		unit:addBuff(b_Stun:new(100,nil),0.5)
	end
	if caster.unit.skills.explosivebullet and math.random()< caster.unit.skills.explosivebullet.explosivechance then
		explosiveBulletEffect:effect({caster.x,caster.y},caster,skill)
	end
end)


Pistol = Skill:subclass('Pistol')
function Pistol:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.bullettype = Bullet
	self.name = 'Pistol'
	self.effecttime = 0.1
	self.damage = 50
	self.effect = PistolEffect
	self.bulleteffect = StunBulletEffect
	self.bullettype = Bullet
	self:setLevel(level)
end

function Pistol:getPanelData()
	return{
		title = 'PISTOL',
		type = 'PRIMARY WEAPON',
		attributes = {
			{text = "Purely awesome weapon."},
			{text = 'Firerate (per second)',data = function()return  string.format('%.1f',1/self.casttime) end},
			{text = 'Damage',data = function()return  self.damage end},
		}
	}
end

function Pistol:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function Pistol:stop()
	self.time = 0
end

function Pistol:setLevel(lvl)
	self.casttime = 0.7/(1+lvl*0.2) -- inversely proportional
	self.level = lvl
	if lvl == 2 then
		if self.unit.skills.stunbullet then
			return {self.unit.skills.stunbullet}
		end
	elseif lvl == 4 then
		if self.unit.skills.explosivebullet then
			return {self.unit.skills.explosivebullet}
		end
	elseif lvl == 6 then
		if self.unit.skills.momentumbullet then
			return {self.unit.skills.momentumbullet}
		end
	end
	if self.unit.skills then self.unit.skills.pistoldwsalt:setLevel(lvl) end
end

PistolDWSEffect = ShootMissileEffect:new()
PistolDWSEffect:addAction(function(point,caster,skill)
	Timer:new(0.1,3,function ()
			local Missile = skill.bullettype:new(1,1,1000,caster.x,caster.y,unpack(point))
			Missile.controller = caster.controller..'Missile'
			Missile.effect = skill.bulleteffect
			Missile.skill = skill
			Missile.unit = caster
			map:addUnit(Missile)
			TEsound.play('sound/shoot4.wav')
		end,
		true,true)
end)

local PistolDWS = Pistol:addState('DWS')
function PistolDWS:enterState()
	self.originaleffect = self.effect
	self.effect = PistolDWSEffect
end

function PistolDWS:exitState()
	self.effect = self.originaleffect
end

PistolDWSAltEffect = ShootMissileEffect:new()
PistolDWSAltEffect:addAction(function(point,caster,skill)
	local Missile = skill.bullettype:new(1,1,1000,caster.x,caster.y,0,-1)
	Missile.controller = caster.controller..'Missile'
	Missile.effect = skill.bulleteffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	local Missile = skill.bullettype:new(1,1,1000,caster.x,caster.y,0.866,0.5)
	Missile.controller = caster.controller..'Missile'
	Missile.effect = skill.bulleteffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	local Missile = skill.bullettype:new(1,1,1000,caster.x,caster.y,-0.866,0.5)
	Missile.controller = caster.controller..'Missile'
	Missile.effect = skill.bulleteffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	TEsound.play('sound/shoot4.wav')
end)

PistolDWSAlt = Skill:subclass('PistolDWSAlt')
function PistolDWSAlt:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.bullettype = Bullet
	self.name = 'PistolDWSAlt'
	self.effecttime = 0.1
	self.damage = 50
	self.effect = PistolDWSAltEffect
	self.bulleteffect = StunBulletEffect
	self.bullettype = Bullet
	self:setLevel(level)
end

function PistolDWSAlt:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function PistolDWSAlt:stop()
	self.time = 0
end
function PistolDWSAlt:setLevel(lvl)
	self.casttime = 0.7/(1+lvl*0.2) -- inversely proportional
	self.level = lvl
end

StunBullet = Skill:subclass('StunBullet')
function StunBullet:initialize(unit,level)
	level = level or -1
	super.initialize(self)
	self.unit = unit
	self.name = 'StunBullet'
	self:setLevel(level)
	self.stunchance = 0
end

function StunBullet:setLevel(lvl)
	self.stunchance = 0.1+0.04*lvl
	self.level = lvl
end


function StunBullet:getPanelData()
	return{
		title = 'STUN BULLET',
		type = 'PASSIVE',
		attributes = {
			{text = "Assassin inject mindpower into his bullets, chance to stun enemy."},
			{text = 'Chance',data = function()return  string.format('%.1f',self.stunchance*100) end},
		}
	}
end

ExplosiveBullet = Skill:subclass('ExplosiveBullet')
function ExplosiveBullet:initialize(unit,level)
	level = level or -1
	super.initialize(self)
	self.unit = unit
	self.name = 'ExplosiveBullet'
	self:setLevel(level)
	self.explosivechance = 0
	self.impactforce = 0
end
function ExplosiveBullet:setLevel(lvl)
	if lvl>0 then
		self.explosivechance = 0.1+0.04*lvl
		self.impactforce = 30+lvl*10
		explosiveBulletEffect.actions={}
		explosiveBulletEffect:addAction(getExplosionAction(self.impactforce,nil,function(unit)return not unit:isKindOf(Missile) end))
	end
	self.level = lvl
end


function ExplosiveBullet:getPanelData()
	return{
		title = 'EXPLOSIVE BULLET',
		type = 'PASSIVE',
		attributes = {
			{text = "Assassin inject mindpower into his bullets, chance to stun enemy."},
			{text = 'Chance',data = function()return  string.format('%.1f',self.explosivechance*100) end},
			{text = 'Impact Force',data = function()return  self.impactforce end},
		}
	}
end

function ExplosiveBullet:getdescription()
	a='Explosive Bullet\nAssassin tweaks his ammo, make them possible to create a small area impact in target area.(massive units are unaffected)\nChance:\nImpact Force:\nCurrent Level:'
	return a
end

function ExplosiveBullet:getdescriptiondata()
	return '\n\n\n'..string.format('%.1f',self.explosivechance*100)..' % chance to stun enemy\n'..self.impactforce..' Impact force\n'..self.level
end

function ExplosiveBullet:fillAttPanel(panel)
	panel:addItem(DescriptionAttributeItem:new(function()
		return "EXPLOSIVE BULLET" end,
		panel.w,30))
	panel:addItem(DescriptionAttributeItem:new(function()
		return "Assassin tweaks his ammo, make them possible to create a small area impact in target area." end,
		panel.w,30))
	panel:addItem(SimpleAttributeItem:new(
		function()
		return string.format('%.1f%%',self.explosivechance*100) end,
		function()
		return "Chance" end,
		nil,panel.w))
	panel:addItem(SimpleAttributeItem:new(
		function()
		return self.impactforce end,
		function()
		return "Impact Force" end,
		nil,panel.w))
	panel:addItem(SimpleAttributeItem:new(
		function()
		return self.level end,
		function()
		return "Current Level" end,
		nil,panel.w))
end
AbsoluteMomentum = Skill:subclass('AbsoluteMomentum')

function AbsoluteMomentum:initialize(unit,level)
	level = level or -1
	super.initialize(self)
	self.unit = unit
	self.name = 'MomentumBullet'
	self:setLevel(level)
end

function AbsoluteMomentum:setLevel(lvl)
	if lvl>0 then
		self.unit.skills.pistol.bullettype = MomentumBullet
	end
	self.level = lvl
end


function AbsoluteMomentum:getPanelData()
	return{
		title = 'ABSOLUTE MOMENTUM',
		type = 'PASSIVE',
		attributes = {
			{text = "Every bullet you fire will possess absolute momentum, penetrating your enemies unstopping."},
		}
	}
end