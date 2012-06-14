
b_Burn = Buff:subclass('b_Burn')
function b_Burn:initialize(dps,source)
	self.source = source
	self.dps = dps
	self.icon = requireImage'assets/item/cvolcano.png'
	self.genre = 'debuff'
	self.p = particlemanager.getsystem'smallfire'
	self.p:setLifetime(5)
	self.p:start()
end
function b_Burn:start(unit)
	
end
function b_Burn:stop(unit)
end

function b_Burn:draw(unit)
	love.graphics.draw(self.p)
end

function b_Burn:buff(unit,dt)
	unit:damage('Fire',self.dps*dt,self.source)
	self.p:setPosition(unit:getPosition())
	self.p:update(dt)
end

function b_Burn:getPanelData()
	return {
		title = LocalizedString'Burn',
		type = LocalizedString'Debuff',
		attributes = {
			{text = 'Taking damage over time.'}}
	}
end

CVolcanoWeapon = Weapon:subclass'CVolcanoWeapon' 
function CVolcanoWeapon:initialize(x,y)
	super.initialize(self,'Assassin',x,y)
	self:setSkill(CVolcano)
	self.name = 'The CVolcano'
	print (self.type,'cvolcanotype')
end

function CVolcanoWeapon:drawBody(x,y,r)
--	love.graphics.draw(img.assassinpistol,x,y,r,1,1,20,32)
end

function CVolcanoWeapon:getPanelData()
	return {
		title = LocalizedString(self.name),
		type = LocalizedString(self.type),
		attributes = {
			{text=LocalizedString"A sword that wield the rage of the earth."},
			{text = LocalizedString'Basic Damage',data = function()
				return 100
			end}
		}
	}
end

function CVolcanoWeapon:draw(x,y)
	if not x then
		x,y = self.body:getPosition()
	end
		love.graphics.draw(requireImage'assets/item/cvolcano.png',x,y,0,0.375,0.375,64,64)
end


CVolcanoEffect = ShootMissileEffect()
CVolcanoEffect:addAction(function(point,caster,skill,snipe)
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
--	TEsound.play'sound/shoot4.wav'
end)

CVolcano = Skill:subclass'CVolcano'
function CVolcano:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.bullettype = CVolcanoMissile
	self.name = 'CVolcano'
	self.effecttime = 0.1
	self.damage = 50
	self.effect = CVolcanoEffect
	self.bulleteffect = CVolcanoMissileEffect
	self.bullettype = CVolcanoMissile
	self:setLevel(level)
	self.icon = requireImage'assets/item/cvolcano.png'
	self.duration = 3
end

function CVolcano:setMomentumBullet(state)
	if state then
		self.bullettype = MomentumCVolcanoMissile
	else
		self.bullettype = CVolcanoMissile
	end
end


function CVolcano:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function CVolcano:setLevel(lvl)
	self.casttime = 0.7/(1+lvl*0.2) -- inversely proportional
	self.level = lvl
--	if self.unit.skills then self.unit.skills.pistoldwsalt:setLevel(lvl) end
end

CVolcanoDWSEffect = ShootMissileEffect:new()
CVolcanoDWSEffect:addAction(function(point,caster,skill,snipe)
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

local CVolcanoDWS = CVolcano:addState('DWS')
function CVolcanoDWS:enterState()
	self.originaleffect = self.effect
	self.effect = CVolcanoDWSEffect
end

function CVolcanoDWS:exitState()
	self.effect = self.originaleffect
end

CVolcanoMissile = Bullet:subclass'CVolcanoMissile'

function CVolcanoMissile:initialize(...)
	super.initialize(self,...)
	self.p = particlemanager.getsystem'smallfire'
	self.p:start()
	self.p:setLifetime(5)
end

function CVolcanoMissile:update(dt)
	super.update(self,dt)
	self.p:setPosition(self.body:getPosition())
	self.p:update(dt)
end

function CVolcanoMissile:draw()
	love.graphics.draw(self.p)
end


MomentumCVolcanoMissile = MomentumBullet:subclass('MomentumCVolcanoMissile')
function MomentumCVolcanoMissile:draw()
	love.graphics.setColor(80,234,255,255)
	love.graphics.draw(self.p)
	love.graphics.draw(requireImage'assets/assassin/tempestflare.png',self.x,self.y,0,1,1,64,32)
	love.graphics.setColor(255,255,255,255)
end

return CVolcanoWeapon
