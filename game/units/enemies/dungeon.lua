
require 'units.class.chain'
animation.skeletonsword = Animation(love.graphics.newImage('assets/dungeon/skeletonsword.png'),99,86,0.04,1,1,12,46)


SkeletonSwordsmanMelee = Melee:subclass('IALSwordsmanMelee')
function SkeletonSwordsmanMelee:initialize(unit)
	super.initialize(self,unit)
	self.damage = 50
end
SkeletonSwordsman = AnimatedUnit:subclass('SkeletonSwordsman')
function SkeletonSwordsman:initialize(x,y,controller)
	super.initialize(self,x,y,16,10)
	self.controller = controller
	self.hp = 500
	self.maxhp = 500
	self.mp = 500
	self.maxmp = 500
	self.skills = {
		melee = SkeletonSwordsmanMelee:new(self),
		tornado = SkeletonTornado(self),
	}
	self.animation = {
		stand = animation.skeletonsword:subSequence(1,1),
		attack = animation.skeletonsword:subSequence(2,7),
		spin = animation.skeletonsword:subSequence(8,8)
	}
	self:resetAnimation()
	self.speedlimit = self.speedlimit * 2
end

function SkeletonSwordsman:skilleffect(skill)
	if skill then
		self:playAnimation('attack',0.4,false)
	end
end

function SkeletonSwordsman:kill(...)
	super.kill(self,...)
	local body = SkeletonDead(self.x,self.y,self.controller)
	map:addUnit(body)
end

function SkeletonSwordsman:enableAI(ai)
	local t = self:getOffenceTarget()
	local t2 = self
	local normalattack = Sequence:new()
--	normalattack:push(OrderWait(3))
	normalattack:push(OrderMoveTowardsRange:new(t,80))
	
	normalattack:push(OrderStop())
	normalattack:push(OrderChannelSkill:new(self.skills.melee,function()t2:setAngle(math.atan2(t.y-t2.y,t.x-t2.x))return {normalize(t.x-t2.x,t.y-t2.y)},t2,self.skills.melee end))
	normalattack:push(OrderWait(1))
	normalattack:push(OrderStop())
	
	
	local tornadoseq = Sequence:new()
	tornadoseq:push(OrderWait(3))
	tornadoseq:push(OrderMoveTowardsRange:new(t,400))
--	tornadoseq:push(OrderStop())
	tornadoseq:push(OrderActiveSkill:new(self.skills.tornado,function() return self,self,t2.skills.tornado end))
--	tornadoseq:push(OrderWait(1))
--	normalattack:push(OrderWaitUntil:new(function()return getdistance(t,t2)>firerange or t.invisible end))
	tornadoseq:push(OrderMoveTowardsRange:new(t,50))
	tornadoseq:push(OrderStop())
	tornadoseq:push(OrderWait(3))
	
	local demoselector = Selector:new()
	demoselector:push(function ()
		if math.random()>0.5 then
			return normalattack
		else
			return tornadoseq
		end
	end)
	local AIDemo = Sequence:new()
	AIDemo:push(demoselector)
	AIDemo.loop = true
	self.ai = AIDemo
end

local tornado = SkeletonSwordsman:addState'tornado'
function tornado:enterState()
	self.cr = 0
	self:playAnimation('tornado',1,true)
end

function tornado:exitState()
	self:resetAnimation()
end

function tornado:update(dt)
	SkeletonSwordsman.update(self,dt)
	self.cr = self.cr + dt * 20
	self.body:setAngle(self.cr)
end

b_SkeletonTornado = Buff:subclass('b_SkeletonTornado')

function b_SkeletonTornado:stop(unit)
--	unit:morphEnd()
	unit:gotoState()
	unit:resetAnimation()
--	unit:stop()
end
function b_SkeletonTornado:buff(unit,dt)
	local units = map:findUnitsInArea({
		type = 'circle',
		range = 80,
		x=unit.x,
		y=unit.y
	})
	for k,v in pairs(units) do
		if v:isKindOf(Unit) and v:isEnemyOf(unit) then
			v:addBuff(b_Stun:new(100,nil),dt)
			v:damage('Bullet',unit:getDamageDealing(50*dt,'Bullet'),unit)
		end
	end
end
function b_SkeletonTornado:start(unit)
	unit:gotoState'tornado'
	unit:playAnimation('spin',0.4,true)
end

SkeletonTornadoEffect = UnitEffect:new()
SkeletonTornadoEffect:addAction(function (unit,caster,skill)
	unit:addBuff(b_SkeletonTornado(),3)
end)

SkeletonTornado = ActiveSkill:subclass('SkeletonTornado')
function SkeletonTornado:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Skeleton Tornado'
	self.effecttime = -1
	self.effect = SkeletonTornadoEffect
	self.cd = 2
	self.cdtime = 0
	self.SkeletonTornadotime = 45
	self.available = true
	self:setLevel(level)
end

function SkeletonTornado:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	if self.unit:getMPPercent()<1 then
		return false,'Not enough MP'
	end
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function SkeletonTornado:geteffectinfo()
	return self.unit,self.unit,self
end

function SkeletonTornado:setLevel(lvl)
	self.level = lvl
end

requireImage('assets/dungeon/spear.png','spear')
Spear = Missile:subclass'Spear'
function Spear:draw()
	love.graphics.draw(img.spear,self.x,self.y,self.body:getAngle(),1,1,50,28)
end

function Spear:add(unit,coll)
	if (self.controller=='playerMissile' and unit.controller=='enemy') or (self.controller == 'enemyMissile' and unit.controller=='player') then
		if not unit.bht[self] then
			if self.effect then self.effect:effect(unit,self,self.skill) end
			unit.bht[self] = true
			self.draw = function() end
			self.persist = function() end
		end
	end
end
SkeletonSpearEffect = ShootMissileEffect:new()
SkeletonSpearEffect:addAction(function(point,caster,skill)
	local x,y = unpack(point)
	local Missile = Spear:new(5,0.2,600,caster.x,caster.y,x,y)
	Missile.controller = caster.controller..'Missile'
	Missile.effect = BulletEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
end)

SkeletonSpear = Skill:subclass'SkeletonSpear'
function SkeletonSpear:initialize(unit)
	super.initialize(self)
	self.unit = unit
	self.name = 'SkeletonSpear'
	self.effecttime = 0.02
	self.casttime = 4
	self.damage = 50
	self.effect = SkeletonSpearEffect
end

function SkeletonSpear:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

SkeletonSpearman = AnimatedUnit:subclass'SkeletonSpearman'
function SkeletonSpearman:initialize(x,y,controller)
	super.initialize(self,x,y,16,10)
	self.controller = controller
	self.hp = 500
	self.maxhp = 500
	self.mp = 500
	self.maxmp = 500
	self.skills = {
		gun = SkeletonSpear:new(self),
		tornado = SkeletonTornado(self),
		
	}
	self.animation = {
		stand = animation.skeletonsword:subSequence(1,1),
		attack = animation.skeletonsword:subSequence(2,7),
	}
	self:resetAnimation()
	self.speedlimit = self.speedlimit * 2
end

function SkeletonSpearman:skilleffect(skill)
	if skill then
		self:playAnimation('attack',0.4,false)
	end
end

function SkeletonSpearman:enableAI(ai)
	self.ai = ai or AI.ApproachAndAttack(self,GetCharacter(),self.skills.gun,450,500)
end


function SkeletonSpearman:kill(...)
	super.kill(self,...)
	local body = SkeletonDead(self.x,self.y,self.controller)
	map:addUnit(body)
end

IceBoltTrail = Object:subclass('IceBoltTrail')
function IceBoltTrail:initialize(b)
	self.bullet = b
	local p = love.graphics.newParticleSystem(img.pulse, 1000)
	p:setEmissionRate(20)
	p:setSpeed(50, 100)
	p:setGravity(0)
	p:setSize(0.25, 0.15)
	p:setLifetime(0.5)
	p:setParticleLife(0.5)
	p:setDirection(0)
	p:setSpread(360)
	p:setColor(255,255,255,255,80,80,255,0)
	p:setRadialAcceleration(-500)
	self.p = p
	self.dt = 0
end

function IceBoltTrail:update(dt)
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

function IceBoltTrail:draw()
	love.graphics.draw(self.p)
end


SkeletonShootBoltEffect = ShootMissileEffect:new()
SkeletonShootBoltEffect:addAction(function(point,caster,skill)
	assert(skill)
	assert(skill.bullettype)
	local Missile = skill.bullettype(1,1,1000,caster.x,caster.y,unpack(point))
	Missile.controller = caster.controller..'Missile'
	Missile.effect = skill.bulleteffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
end)

SkeletonBoltMissile = Missile:subclass'SkeletonBoltMissile'
function SkeletonBoltMissile:initialize(...)
	super.initialize(self,...)
	self.trail = IceBoltTrail:new(self)
	map:addUpdatable(self.trail)
	self.trail.dt = 95
end
function SkeletonBoltMissile:draw()
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(img.pulse,self.x,self.y,0,1,1,16,16)
	love.graphics.setColor(255,255,255,255)
end
function SkeletonBoltMissile:add(unit,coll)
	if (self.controller=='playerMissile' and unit.controller=='enemy') or (self.controller == 'enemyMissile' and unit.controller=='player') then
		if not unit.bht[self] then
			self.add = nil
			if self.effect then self.effect:effect(unit,self,self.skill) end
			unit.bht[self] = true
			self.trail.dt = 99
			self.draw = function() end
			self.persist = function() end
		end
	end
end

SkeletonBoltEffect = UnitEffect:new()
SkeletonBoltEffect:addAction(function (unit,caster,skill)
	unit:damage('Ice',caster.unit:getDamageDealing(skill.damage,'Ice'),caster)
end)

SkeletonBolt = Skill:subclass('SkeletonBolt')
function SkeletonBolt:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.bullettype = SkeletonBoltMissile
	self.name = 'SkeletonBolt'
	self.effecttime = 0.1
	self.casttime = 0.8
	self.damage = 50
	self.effect = SkeletonShootBoltEffect
	self.bulleteffect = SkeletonBoltEffect
	self:setLevel(level)
	self.manacost = 20
end

function SkeletonBolt:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function SkeletonBolt:setLevel(lvl)
	self.level = lvl
end


SkeletonSpiralEffect = UnitEffect:new()
SkeletonSpiralEffect:addAction(function(unit,caster,skill)
	local shots = skill.shots
	function fire(timer)
		local cosx,sinx = math.cos(math.pi/shots*timer.count*2),math.sin(math.pi/shots*timer.count*2)
		SkeletonShootBoltEffect:effect({cosx,sinx},caster,caster.skills.gun)
	end
	local t = Timer:new(0.05,shots*3,fire,true)
	t.selfdestruct = true
end)

SkeletonSpiral = ActiveSkill:subclass('SkeletonSpiral')
function SkeletonSpiral:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'SkeletonSpiral'
	self.effecttime = -1
	self.effect = SkeletonSpiralEffect
	self.cd = 2
	self.cdtime = 0
	self.shots = 12
	self.available = true
end

function SkeletonSpiral:active()
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end


animation.skeletonmagician = Animation(love.graphics.newImage('assets/dungeon/skeletonmagician.png'),99,86,0.04,1,1,12,46)
SkeletonMagician = AnimatedUnit:subclass('SkeletonSwordsman')
function SkeletonMagician:initialize(x,y,controller)
	super.initialize(self,x,y,16,10)
	self.controller = controller
	self.hp = 500
	self.maxhp = 500
	self.mp = 500
	self.maxmp = 500
	self.skills = {
		gun = SkeletonBolt:new(self),
--		teleport = SkeletonTeleport(self),
		spiral = SkeletonSpiral(self),
		
	}
	self.animation = {
		stand = animation.skeletonmagician:subSequence(1,1),
		attack = animation.skeletonmagician:subSequence(2,7),
--		spin = animation.skeletonsword:subSequence(8,8)
	}
	self:resetAnimation()
	self.speedlimit = self.speedlimit * 2
	self.trail = IceBoltTrail:new(self)
	map:addUpdatable(self.trail)
	self.trail.dt = 0
end

function SkeletonMagician:skilleffect(skill)
	if skill then
		self:playAnimation('attack',0.4,false)
	end
end

function SkeletonMagician:kill(...)
	super.kill(self,...)	
	self.trail.dt = 99
end

function SkeletonMagician:enableAI(ai)
	local t = self:getOffenceTarget()
	local t2 = self
	local normalattack = Sequence:new()
	normalattack:push(OrderMoveTowardsRange:new(t,400))
	
	normalattack:push(OrderStop())
	normalattack:push(OrderChannelSkill:new(self.skills.gun,function()t2:setAngle(math.atan2(t.y-t2.y,t.x-t2.x))return {normalize(t.x-t2.x,t.y-t2.y)},t2,self.skills.gun end))
	normalattack:push(OrderWait(8))
	normalattack:push(OrderStop())
	
	
	local spiralseq = Sequence:new()
	spiralseq:push(OrderWait(3))
	spiralseq:push(OrderMoveTowardsRange:new(t,100))
	spiralseq:push(OrderActiveSkill:new(self.skills.spiral,function() return self,self,t2.skills.spiral end))
	spiralseq:push(OrderStop())
	spiralseq:push(OrderWait(3))
	
	local demoselector = Selector:new()
	demoselector:push(function ()
		if math.random()>0.5 then
			return normalattack
		else
			return spiralseq
		end
	end)
	local AIDemo = Sequence:new()
	AIDemo:push(demoselector)
	AIDemo.loop = true
	self.ai = AIDemo
end

requireImage'assets/whistler/guardian.png'
local ox,oy = img.guardian:getWidth()/2,img.guardian:getHeight()/2
Guardian = Unit:subclass'Guardian'
function Guardian:initialize(x,y,controller)
	super.initialize(self,x,y,16,0)
	self.hp = 100
	self.maxhp = 100
	self.controller = controller
	self.chain = Chain(self,8,8)
	self.chain:setChainMask({},cc.enemymissile)
end

function Guardian:createBody(world)
	super.createBody(self,world)
	self.chain:createBody(world)
	self.chain:setSensor(false)
	self.chain:setAngle(self.body:getAngle())
	self.chain:stab(self.body:getAngle())
end

function Guardian:launch()
end

function Guardian:loose()
end

function Guardian:update(dt)
	super.update(self,dt)
	if self.dt then
		self.dt = self.dt - dt
		if self.dt <= 0 then
			self.present = self.target
			self.dt = nil
		end
	end
	self.chain:update(dt)
end

function Guardian:preremove()
	super.preremove(self)
	self.chain:preremove()
end

function Guardian:destroy()
	
	super.destroy(self)
	self.chain:destroy()
end

function Guardian:damage(type,amount,source)
	if type == 'Bomb' then -- only bomb can destroy Guardians
		super.damage(self,type,amount,source)
	end
--	self:switch(self.switchStates[math.random(#self.switchStates)])
end

function Guardian:draw()
	love.graphics.draw(img.guardian,self.x,self.y,self.body:getAngle(),1,1,ox,oy)
	self.chain:draw()
end

GuardianSpear = SkeletonSpear:subclass'GuardianSpear'
function GuardianSpear:initialize(...)
	super.initialize(self,...)
	self.casttime = 0.5
end

ArcherGuardian = Unit:subclass'ArcherGuardian'
function ArcherGuardian:initialize()
	super.initialize(self,x,y,16,0)
	self.hp = 100
	self.maxhp = 100
	self.controller = controller
	self.skills = {
		gun = GuardianSpear(self)
	}
end

function ArcherGuardian:damage(type,amount,source)
	if type == 'Bomb' then -- only bomb can destroy Guardians
		super.damage(self,type,amount,source)
	end
end

function ArcherGuardian:enableAI(ai)
	self.ai = ai or AI.Attack(self,self.skills.gun)
end

function ArcherGuardian:draw()
	love.graphics.draw(img.guardian,self.x,self.y,self.body:getAngle(),1,1,ox,oy)
end


GuardianFlameEffect = ShootMissileEffect:new()
GuardianFlameEffect:addAction(function(point,caster,skill)
	local x,y = unpack(point)
	local angles = {
		{x,y},
		{-x,-y},
		{-y,x},
		{y,-x},
	}
	for i,v in ipairs(angles) do
		local Missile = MeleeMissile:new(0.5,skill.bulletmass,skill.range/0.5,caster.x,caster.y,unpack(v))
		Missile.controller = caster.controller..'Missile'
		Missile.effect = BulletEffect
		Missile.skill = skill
		Missile.unit = caster
		map:addUnit(Missile)
	end
end)
GuardianFlame = Melee:subclass'GuardianFlame'
function GuardianFlame:initialize(unit)
	super.initialize(self,unit)
	self.damage = 25
	self.casttime = 0.2
	self.effect = GuardianFlameEffect
end

FlameGuardian = Unit:subclass'BlameGuardian'
function FlameGuardian:initialize()
	super.initialize(self,x,y,16,0)
	self.hp = 1000
	self.maxhp = 1000
	self.skills = {
		gun = GuardianFlame(self)
	}
	
	local p = love.graphics.newParticleSystem(img.square, 1000)
	p:setEmissionRate(60)
	p:setSpeed(200, 200)
	p:setGravity(100, 0)
	p:setSize(1, 2)
	p:setColor(240, 3, 176, 255, 204, 240, 3, 0)
	p:setPosition(0,0)
	p:setLifetime(1000)
	p:setParticleLife(2)
	p:setDirection(0)
	p:setSpread(0)
	p:setSpin(300, 800)
	p:stop()
	self.p = p
end

function FlameGuardian:switchChannelSkill(skill)
	super.switchChannelSkill(self,skill)
	if skill then
		self.p:start()
	else
		self.p:stop()
	end
end

function FlameGuardian:enableAI(ai)
	local flameai = Sequence()
	flameai:push(OrderChannelSkill(self.skills.gun,function()
		return {math.cos(self.body:getAngle()),math.sin(self.body:getAngle())},self,self.skills.gun
	end))
	flameai:push(OrderWaitUntil(function(dt,owner)
		self.body:setAngle(self.body:getAngle()+dt*0.3)
		return false
	end))
	self.ai = ai or flameai
end

function FlameGuardian:update(dt)
	super.update(self,dt)
	self.p:update(dt)
end

function FlameGuardian:draw()
	for i=1,4 do
		love.graphics.draw(self.p,self.x,self.y,self.body:getAngle()+i*math.pi/2)
	end
	love.graphics.draw(img.guardian,self.x,self.y,self.body:getAngle(),1,1,ox,oy)
end


blackwraithsuicideeffect = CircleAoEEffect:new(200)
blackwraithsuicideeffect:addAction(function (area,caster,skill)
	local units = map:findUnitsInArea(area)
	for k,v in pairs(units) do
		if v:isKindOf(Unit) then
			local impact = skill.impact
			local x,y=normalize(v.x-area.x,v.y-area.y)
			x,y=x*impact,y*impact
			if v.body and not v.immuneimpact then
				v.body:applyImpulse(x,y)
			end
			v:damage('Bullet',skill.damage,caster)
		end
	end
	TEsound.play('sound/thunderclap.wav')
	caster:kill(caster)
end)

BlackWraithSuicide = ActiveSkill:subclass('BlackWraithSuicide')
function BlackWraithSuicide:initialize(unit)
	super.initialize(self,unit)
	self.unit = unit
	self.effect = blackwraithsuicideeffect
	self.damage = 80
	self.impact = 50
end


function BlackWraithSuicide:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function BlackWraithSuicide:geteffectinfo()
	return {self.unit.x,self.unit.y},self.unit,self
end

requireImage'assets/dungeon/blackwraith.png'
animation.blackwraith = Animation(img.blackwraith,100,86,0.04,1,1,24,43)
BlackWraith = AnimatedUnit:subclass'BlackWraith'
function BlackWraith:initialize(x,y,controller)
	super.initialize(self,x,y,8,5)
	self.hp=200
	self.maxhp=200
	self.controller = controller
	self.skills = {
		explode = BlackWraithSuicide:new(self),
	}
	self.animation = {
		attack = animation.blackwraith:subSequence(1,7),
		stand = animation.blackwraith:subSequence(1,3)
	}
	self:resetAnimation()
end

function BlackWraith:setTarget(t)
	self.target=t
end

function BlackWraith:kill(...)
	super.kill(self,...)
end

function BlackWraith:enableAI(ai)
	local target = self:getOffenceTarget()
	danceseq=Sequence()
	danceseq:push(OrderMoveTowardsRange(target,50))
	danceseq:push(OrderActiveSkill(self.skills.explode,function() return {self.x,self.y},self,self.skills.explode end))
	danceseq:push(OrderWait:new(3))
	self.ai = ai or danceseq
end


function BlackWraith:skilleffect(skill)
	if skill then
		self:playAnimation('attack',0.4,false)
	end
end


requireImage'assets/dungeon/whitewraith.png'
animation.whitewraith = Animation(img.whitewraith,100,86,0.04,1,1,24,43)
WhiteWraith = AnimatedUnit:subclass'WhiteWraith'
function WhiteWraith:initialize(x,y,controller)
	super.initialize(self,x,y,8,5)
	self.hp=200
	self.maxhp=200
	self.controller = controller
	self.skills = {
		gun = SkeletonBolt(self),
	}
	self.animation = {
		attack = animation.whitewraith:subSequence(1,7),
		stand = animation.whitewraith:subSequence(1,1)
	}
	self:resetAnimation()
end

function WhiteWraith:kill(...)
	super.kill(self,...)
end

function WhiteWraith:enableAI(ai)
--	self.ai = ai or AI.ApproachAndAttack(self,GetCharacter(),self.skills.gun,300,400)
	local hans = self
	local target = self:getOffenceTarget()
	local reviving
	local meleeseq = Sequence:new()
	meleeseq:push(OrderWait:new(1))
	meleeseq:push(OrderMoveTowardsRange:new(target,300))
	meleeseq:push(OrderStop:new())
	meleeseq:push(OrderChannelSkill:new(hans.skills.gun,function()return {normalize(target.x-hans.x,target.y-hans.y)},hans,hans.skills.gun end))
	meleeseq:push(OrderWaitUntil:new(function() hans:setAngle(math.atan2(target.y-hans.y,target.x-hans.x))return getdistance(target,hans)>400 or target.invisible end))
	meleeseq:push(OrderStop:new())
	meleeseq.loop = true
	meleeseq.timelimit = 7
	
	
	
	local demoselector = Selector:new()
	local count = 0
	demoselector:push(function()
		reviving = self:findUnitByType(SkeletonDead)
		if reviving then
			local revive = Sequence:new()
			revive:push(OrderWait:new(0.5))
			revive:push(OrderMoveTo(reviving.x,reviving.y))
			revive:push(OrderStop:new())
			revive:push(OrderWait:new(1))
			return revive
		end
		return meleeseq
	end)
	local AIDemo = Sequence()
	AIDemo:push(demoselector)
	AIDemo.loop = true
	self.ai = AIDemo
	return AIDemo
end


function WhiteWraith:skilleffect(skill)
	if skill then
		self:playAnimation('attack',0.4,false)
	end
end

bluewraithexplode = UnitEffect:new()
bluewraithexplode:addAction(function(unit,caster,skill)
	local shots = 9
	for i=1,9 do
		local cosx,sinx = math.cos(math.pi/shots*i*2),math.sin(math.pi/shots*i*2)
		WraithShootBoltEffect:effect({cosx,sinx},caster,caster.skills.gun)
	end
end)


WraithShootBoltEffect = ShootMissileEffect:new()
WraithShootBoltEffect:addAction(function(point,caster,skill)
	assert(skill)
	assert(skill.bullettype)
	local Missile = skill.bullettype(1,1,300,caster.x,caster.y,unpack(point))
	Missile.controller = caster.controller..'Missile'
	Missile.effect = skill.bulleteffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
end)

WraithBolt = Skill:subclass('WraithBolt')
function WraithBolt:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.bullettype = SkeletonBoltMissile
	self.name = 'SkeletonBolt'
	self.effecttime = 0.1
	self.casttime = 0.8
	self.damage = 50
	self.effect = WraithShootBoltEffect
	self.bulleteffect = SkeletonBoltEffect
	self:setLevel(level)
	self.manacost = 20
end


function WraithBolt:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function WraithBolt:setLevel(lvl)
	self.level = lvl
end

requireImage'assets/dungeon/bluewraith.png'
animation.bluewraith = Animation(img.bluewraith,100,86,0.04,1,1,24,43)
BlueWraith = AnimatedUnit:subclass'BlueWraith'
function BlueWraith:initialize(x,y,controller)
	super.initialize(self,x,y,8,5)
	self.hp=200
	self.maxhp=200
	self.controller = controller
	self.skills = {
		gun = WraithBolt(self),
	}
	self.animation = {
		attack = animation.bluewraith:subSequence(1,7),
		stand = animation.bluewraith:subSequence(1,1)
	}
	self:resetAnimation()
end

function BlueWraith:kill(...)
	bluewraithexplode:effect(self,self,self.skills.gun)
	super.kill(self,...)
end


function BlueWraith:skilleffect(skill)
	if skill then
		self:playAnimation('attack',0.4,false)
	end
end

function BlueWraith:enableAI(ai)
	self.ai = ai or AI.ApproachAndAttack(self,GetCharacter(),self.skills.gun,300,400)
end

requireImage'assets/dungeon/skeletondead.png'
SkeletonDead = Unit:subclass'SkeletonDead'
function SkeletonDead:initialize(x,y,controller)
	super.initialize(self,x,y,64,0)
	self.ignorelock = true
	self.controller = controller
	self.hpregen = 10
end

function SkeletonDead:createBody(world)
	super.createBody(self,world)
	self.shape:setSensor(true)
end

function SkeletonDead:draw()
	love.graphics.draw(img.skeletondead,self.x,self.y,self.body:getAngle(),1,1,64,64)
end

function SkeletonDead:add(b,coll)
	if b:isKindOf(WhiteWraith) then
		b:kill(b)
		self:kill(b)
		local u = SkeletonSwordsman(self.x,self.y,self.controller)
		u:enableAI()
		map:addUnit(u)
	end
end
