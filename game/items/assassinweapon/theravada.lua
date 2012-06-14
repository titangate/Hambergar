
requireImage('assets/assassin/assassinpistol copy.png','assassinpistol')
Theravada = Weapon:subclass'Theravada' --小乘佛法
function Theravada:initialize(x,y)
	super.initialize(self,'Assassin',x,y)
	self:setSkill(Pistol)
	self.name = 'Theravada'
end

function Theravada:drawBody(x,y,r)
	love.graphics.draw(img.assassinpistol,x,y,r,1,1,20,32)
end

function Theravada:getPanelData()
	return {
		title = LocalizedString(self.name),
		type = LocalizedString(self.type),
		attributes = {
			{text=LocalizedString"M1911, The original Assassin weapon."},
			{text = LocalizedString'Basic Damage',data = function()
				return 50
			end}
		}
	}
end

function Theravada:draw(x,y)
		love.graphics.draw(requireImage'assets/item/theravada.png',x,y,0,0.375,0.375,64,64)
end


PistolEffect = ShootMissileEffect()
PistolEffect:addAction(function(point,caster,skill,snipe)
	assert(skill)
	assert(skill.bullettype)
	local sx,sy
	if caster.missileSpawnPoint then
		sx,sy = caster:missileSpawnPoint()
	else
		sx,sy = caster.x,caster.y
	end
	local Missile = skill.bullettype(1,1,1000,sx,sy,unpack(point))
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
	TEsound.play'sound/shoot4.wav'
end)

Pistol = Skill:subclass'Pistol'
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
	self.icon = requireImage'assets/item/theravada.png'
end

function Pistol:setMomentumBullet(state)
--	print ("Momentum",state)
	if state then
		self.bullettype = MomentumBullet
	else
		self.bullettype = Bullet
	end
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

function Pistol:setLevel(lvl)
	self.casttime = 0.7/(1+lvl*0.2) -- inversely proportional
	self.level = lvl
--	if self.unit.skills then self.unit.skills.pistoldwsalt:setLevel(lvl) end
end

PistolDWSEffect = ShootMissileEffect:new()
PistolDWSEffect:addAction(function(point,caster,skill,snipe)
	Timer(0.1,3,function ()
			local sx,sy = caster:missileSpawnPoint()
			local Missile = skill.bullettype:new(1,1,1000,sx,sy,unpack(point))
			Missile.controller = caster.controller..'Missile'
			Missile.effect = skill.bulleteffect
			Missile.skill = skill
			Missile.unit = caster
			map:addUnit(Missile)
			Missile.snipe = snipe

			map:addUnit(Missile)
			if snipe then
				local trail = SniperRoundTrail:new(Missile)
				map:addUpdatable(trail)
			end
--			TEsound.play('sound/shoot4.wav')
		end)
		TEsound.play'sound/shoot4.wav'
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
--	TEsound.play('sound/shoot4.wav')
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

return Theravada