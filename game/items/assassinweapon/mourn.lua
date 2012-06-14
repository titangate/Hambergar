
MournWeapon = Weapon:subclass'MournWeapon' 
function MournWeapon:initialize(x,y)
	super.initialize(self,'Assassin',x,y)
	self:setSkill(Mourn)
	self.name = 'The Mourn'
end

function MournWeapon:drawBody(x,y,r)
--	love.graphics.draw(img.assassinpistol,x,y,r,1,1,20,32)
end

function MournWeapon:getPanelData()
	return {
		title = LocalizedString(self.name),
		type = LocalizedString(self.type),
		attributes = {
			{text=LocalizedString"M1911, The original Assassin weapon."},
			{text = LocalizedString'Basic Damage',data = function()
				return 100
			end}
		}
	}
end

function MournWeapon:draw(x,y)
	if not x then
		x,y = self.body:getPosition()
	end
		love.graphics.draw(requireImage'assets/item/morne.png',x,y,0,0.375,0.375,64,64)
end

MournEffect = ShootMissileEffect()
MournEffect:addAction(function(point,caster,skill,snipe)
	assert(skill)
	assert(skill.bullettype)
	local sx,sy
	if caster.missileSpawnPoint then
		sx,sy = caster:missileSpawnPoint()
	else
		sx,sy = caster.x,caster.y
	end
	local Missile = skill.bullettype(1,1,500,sx,sy,unpack(point))
	Missile.controller = caster.controller..'Missile'
	Missile.effect = skill.bulleteffect
	Missile.skill = skill
	Missile.unit = caster
	Missile.snipe = snipe
	map:addUnit(Missile)
	if snipe then
		local trail = SniperRoundTrail(Missile)
		map:addUpdatable(trail)
	end
--	TEsound.play'sound/shoot4.wav'
end)

Mourn = Skill:subclass'Mourn'
function Mourn:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.bullettype = MournMissile
	self.name = 'Mourn'
	self.effecttime = 0.1
	self.damage = 50
	self.effect = MournEffect
	self.bulleteffect = MournMissileEffect
	self.dwsbulleteffect = MournMissileEffect
	self.bullettype = MournMissile
	self.dwsbullettype = MournDWSMissile
	self:setLevel(level)
	self.icon = requireImage'assets/item/morne.png'
end

function Mourn:setMomentumBullet(state)
	if state then
		self.bullettype = MomentumMournMissile
		self.dwsbullettype = MomentumMournDWSMissile
	else
		self.bullettype = MournMissile
		self.dwsbullettype = MournDWSMissile
	end
end

function Mourn:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function Mourn:setLevel(lvl)
	self.casttime = 0.7/(1+lvl*0.2) -- inversely proportional
	self.level = lvl
--	if self.unit.skills then self.unit.skills.pistoldwsalt:setLevel(lvl) end
end

MournDWSEffect = ShootMissileEffect:new()
MournDWSEffect:addAction(function(point,caster,skill,snipe)
	assert(skill)
	assert(skill.bullettype)
	local sx,sy
	if caster.missileSpawnPoint then
		sx,sy = caster:missileSpawnPoint()
	else
		sx,sy = caster.x,caster.y
	end
	local Missile = skill.dwsbullettype(1,1,500,sx,sy,unpack(point))
	Missile.controller = caster.controller..'Missile'
	Missile.effect = skill.bulleteffect
	Missile.skill = skill
	Missile.unit = caster
	Missile.snipe = snipe
	map:addUnit(Missile)
	if snipe then
		local trail = SniperRoundTrail(Missile)
		map:addUpdatable(trail)
	end
end)

local MournDWS = Mourn:addState('DWS')
function MournDWS:enterState()
	self.originaleffect = self.effect
	self.effect = MournDWSEffect
end

function MournDWS:exitState()
	self.effect = self.originaleffect
end

MournMissile = Bullet:subclass'MournMissile'

function MournMissile:initialize(...)
	super.initialize(self,...)
end
function MournMissile:draw()
	love.graphics.draw(requireImage'assets/assassin/mornenorm.png',self.x,self.y,self.body:getAngle(),1,1,32,32)
end

MomentumMournMissile = MomentumBullet:subclass('MomentumMournMissile')
function MomentumMournMissile:draw()
	love.graphics.setColor(80,234,255,255)
	love.graphics.draw(requireImage'assets/assassin/mornenorm.png',self.x,self.y,self.body:getAngle(),1,1,32,32)
	love.graphics.setColor(255,255,255,255)
end

MournDWSMissile = MournMissile:subclass'MournDWSMissile'
function MournDWSMissile:draw()
	love.graphics.draw(requireImage'assets/assassin/mornemissile.png',self.x,self.y,self.dt*10,0.5,0.5,48,48)
end

MomentumMournDWSMissile = MomentumMournMissile:subclass'MomentumMournDWSMissile'
function MomentumMournDWSMissile:draw()
	love.graphics.setColor(80,234,255,255)
	love.graphics.draw(requireImage'assets/assassin/mornemissile.png',self.x,self.y,self.dt*10,0.5,0.5,48,48)
	love.graphics.setColor(255,255,255,255)
end

return MournWeapon