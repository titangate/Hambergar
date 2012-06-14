
TempestWeapon = Weapon:subclass'TempestWeapon' 
function TempestWeapon:initialize(x,y)
	super.initialize(self,'Assassin',x,y)
	self:setSkill(Tempest)
	self.name = 'The Tempest'
end

function TempestWeapon:drawBody(x,y,r)
--	love.graphics.draw(img.assassinpistol,x,y,r,1,1,20,32)
end

function TempestWeapon:getPanelData()
	return {
		title = self.name,
		type = self.type,
		attributes = {
			{text="M1911, The original Assassin weapon."},
			{text = 'Basic Damage',data = function()
				return 100
			end}
		}
	}
end

function TempestWeapon:draw(x,y)
	if not x then
		x,y = self.body:getPosition()
	end
		love.graphics.draw(requireImage'assets/item/tempest.png',x,y,0,0.375,0.375,64,64)
end


TempestEffect = ShootMissileEffect()
TempestEffect:addAction(function(point,caster,skill,snipe)
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

Tempest = Skill:subclass'Tempest'
function Tempest:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.bullettype = TempestMissile
	self.name = 'Tempest'
	self.effecttime = 0.1
	self.damage = 100
	self.effect = TempestEffect
	self.bulleteffect = StunBulletEffect
	self.bullettype = TempestMissile
	self:setLevel(level)
	self.icon = requireImage'assets/item/tempest.png'
end

function Tempest:setMomentumBullet(state)
	if state then
		self.bullettype = MomentumTempestMissile
	else
		self.bullettype = TempestMissile
	end
end

function Tempest:getPanelData()
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

function Tempest:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function Tempest:setLevel(lvl)
	self.casttime = 0.7/(1+lvl*0.2) -- inversely proportional
	self.level = lvl
end

TempestDWSEffect = ShootMissileEffect:new()
TempestDWSEffect:addAction(function(point,caster,skill,snipe)
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
		end)
		TEsound.play'sound/shoot4.wav'
end)

local TempestDWS = Tempest:addState('DWS')
function TempestDWS:enterState()
	self.originaleffect = self.effect
	self.effect = TempestDWSEffect
end

function TempestDWS:exitState()
	self.effect = self.originaleffect
end

TempestDWSAltEffect = ShootMissileEffect:new()
TempestDWSAltEffect:addAction(function(point,caster,skill)
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

TempestDWSAlt = Skill:subclass('TempestDWSAlt')
function TempestDWSAlt:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.bullettype = TempestMissile
	self.name = 'TempestDWSAlt'
	self.effecttime = 0.1
	self.damage = 50
	self.effect = TempestDWSAltEffect
	self.bulleteffect = StunBulletEffect
	self.bullettype = TempestMissile
	self:setLevel(level)
end

function TempestDWSAlt:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function TempestDWSAlt:stop()
	self.time = 0
end
function TempestDWSAlt:setLevel(lvl)
	self.casttime = 0.7/(1+lvl*0.2) -- inversely proportional
	self.level = lvl
end


TempestMissile = Bullet:subclass'TempestMissile'

function TempestMissile:draw()
	love.graphics.draw(img.bullet,self.x,self.y,self.body:getAngle(),1,1,16,16)
	love.graphics.setColor(255,255,255,255*math.random())
	love.graphics.draw(requireImage'assets/assassin/tempestflare.png',self.x,self.y,0,1,0.5,64,32)
	love.graphics.setColor(255,255,255,255)
end

MomentumTempestMissile = MomentumBullet:subclass('MomentumTempestMissile')
function MomentumTempestMissile:draw()
	love.graphics.setColor(80,234,255,255)
	love.graphics.draw(img.bullet,self.x,self.y,self.body:getAngle(),1,1,16,16)
	love.graphics.draw(requireImage'assets/assassin/tempestflare.png',self.x,self.y,0,1,1,64,32)
	love.graphics.setColor(255,255,255,255)
end

return TempestWeapon
