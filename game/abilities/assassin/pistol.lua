
WeaponMastery = Skill:subclass('WeaponMastery')
function WeaponMastery:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.bullettype = Bullet
	self.name = 'WeaponMastery'
	self.effecttime = 0.1
	self.damage = 50
	self.effect = WeaponMasteryEffect
	self.bulleteffect = StunBulletEffect
	self.bullettype = Bullet
	self:setLevel(level)
end

function WeaponMastery:getPanelData()
	return{
		title = 'Weapon Mastery',
		type = 'PRIMARY WEAPON',
		attributes = {
			{text = "Increase the effect of your weapon."},
			--{text = 'Firerate (per second)',data = function()return  string.format('%.1f',1/self.casttime) end},
			{text = 'DPS',data = function()
				local s = self.unit.skills.weaponskill
				if s.damage then
					return  string.format("%.2f",s.damage/s.casttime) 
				else
					return 'N/A'
				end
			end},
		}
	}
end

function WeaponMastery:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function WeaponMastery:setLevel(lvl)
	self.level = lvl
	self.unit:reequip()
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
--	if self.unit.skills then self.unit.skills.pistoldwsalt:setLevel(lvl) end
end

function WeaponMastery:getEnabled()
	local enabled = {}
	if self.level>=2 then
		table.insert(enabled,self.unit.skills.stunbullet)
		if self.level>=4 then
			table.insert(enabled,self.unit.skills.explosivebullet)
			if self.level>=6 then
				table.insert(enabled,self.unit.skills.momentumbullet)
			end
		end
	end
	return enabled
end

Assassin.weaponbulleteffect = function (unit,caster,skill)
	unit:damage('Bullet',caster.unit:getDamageDealing(skill.damage,'Bullet'),caster.unit)
	if caster.unit.skills.stunbullet and math.random()< caster.unit.skills.stunbullet.stunchance then
		unit:addBuff(b_Stun:new(100,nil),0.5)
	end
	if caster.unit.skills.explosivebullet and math.random()< caster.unit.skills.explosivebullet.explosivechance then
		explosiveBulletEffect:effect({caster.x,caster.y},caster,skill)
	end
end

explosiveBulletEffect = CircleAoEEffect:new(50)
StunBulletEffect = UnitEffect:new()
StunBulletEffect:addAction(Assassin.weaponbulleteffect)

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
	if lvl <= 0 then
		self.stunchance = 0
		return
	end
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
		self.impactforce = 100+lvl*100
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
		self.unit.skills.weaponskill:setMomentumBullet(true)
	end
	self.level = lvl
end


function AbsoluteMomentum:getPanelData()
	return{
		title = 'ABSOLUTE MOMENTUM',
		type = 'PASSIVE',
		attributes = {
			{text = "Every bullet you fire will possess absolute momentum, penetrating your enemies non-stopping."},
		}
	}
end


--- other bullets

CVolcanoMissileEffect = UnitEffect:new()
CVolcanoMissileEffect:addAction(Assassin.weaponbulleteffect)



CVolcanoMissileEffect:addAction(function(unit,caster,skill)
	unit:addBuff(b_Burn(skill.damage,caster),skill.duration)
end)