SniperRoundTrail = Object:subclass('SniperRoundTrail')
function SniperRoundTrail:initialize(b)
	self.bullet = b
	local p = love.graphics.newParticleSystem(img.part1, 1000)
	p:setEmissionRate(500)
	p:setSpeed(0, 0)
	p:setSize(0.25, 1)
	p:setColor(26,183,255,255,255,255,255,0)
	p:setPosition(400, 300)
	p:setLifetime(1)
	p:setParticleLife(0.5)
	self.p = p
	self.dt = 0
end

function SniperRoundTrail:update(dt)
	self.dt = self.dt + dt
	if self.dt>2 then
		map:removeUpdatable(self)
	end
	if self.dt<1 then
		self.p:setPosition(self.bullet.x,self.bullet.y)
		self.p:start()
	end
	self.p:update(dt)
end

function SniperRoundTrail:draw()
	love.graphics.draw(self.p)
end
SniperRound = Missile:subclass('SniperRound')
function SniperRound:persist(unit,coll)
	if (self.controller=='playerMissile' and unit.controller=='enemy') or (self.controller == 'enemyMissile' and unit.controller=='player') then
		if not unit.bht[self] then
			if self.effect then self.effect:effect(unit,self,self.skill) end
			unit.bht[self] = true
			self.draw = function() end
			self.persist = function() end
			self.trail.dt = 1
		end
	end
end

function SniperRound:initialize(...)
	super.initialize(self,...)
	self.trail = SniperRoundTrail:new(self)
	map:addUpdatable(self.trail)
end

function SniperRound:draw()
	love.graphics.draw(img.bullet,self.x,self.y,self.body:getAngle(),1,1,16,16)
end

SnipeBulletEffect = UnitEffect:new()
SnipeBulletEffect:addAction(function (unit,caster,skill)
	unit:damage('Bullet',caster.unit:getDamageDealing(skill.damage,'Bullet'),caster.unit)
	
end)
SnipeEffect = ShootMissileEffect:new()
SnipeEffect:addAction(function(point,caster,skill)
	local Missile = skill.bullettype:new(1,3,1000,caster.x,caster.y,unpack(point))
	Missile.controller = caster.controller..'Missile'
	Missile.effect = skill.bulleteffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
end)
Snipe = ActiveSkill:subclass('Snipe')
function Snipe:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Snipe'
	self.effecttime = -1
	self.effect = SnipeEffect
	self.bulleteffect = SnipeBulletEffect
	self.bullettype = SniperRound
	self.cd = 2
	self.cdtime = 0
	self.damage = 300
	self.available = true
	self:setLevel(level)
	self.manacost = 50
end

function Snipe:active()

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



function Snipe:getPanelData()
	return{
		title = 'Snipe',
		type = 'ACTIVE',
		attributes = {
			{text = 'Fire a devastating shot.'},
			{text = 'Damage',data = function()return self.damage end,image = icontable.weapon},
		}
	}
end
function Snipe:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function Snipe:stop()
	self.time = 0
end

function Snipe:setLevel(lvl)
	self.level = lvl
	self.damage = 300+lvl*100
end

SnipeDWSEffect = ShootMissileEffect:new()
SnipeDWSEffect:addAction(
	function(point,caster,skill)Timer:new(0.1,3,function ()
		local Missile = skill.bullettype:new(1,3,1000,caster.x,caster.y,unpack(point))
		Missile.controller = caster.controller..'Missile'
		Missile.effect = skill.bulleteffect
		Missile.skill = skill
		Missile.unit = caster
		Missile.trail.p:setColor(255, 125, 0, 255, 255, 0, 0, 0)
		map:addUnit(Missile)
	end,
	true,true)
end)

local SnipeDWS = Snipe:addState('DWS')
function SnipeDWS:enterState()
	self.originaleffect = self.effect
	self.effect = SnipeDWSEffect
end

function SnipeDWS:exitState()
	self.effect = self.originaleffect
end