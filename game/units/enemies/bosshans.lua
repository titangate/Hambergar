
function AI.Hans1(hans,target)
	hans.skills.melee.getorderinfo = function()return {normalize(target.x-hans.x,target.y-hans.y)},hans,hans.skills.melee end
	local meleeseq = Sequence:new()
	meleeseq:push(OrderWait:new(1))
	meleeseq:push(OrderMoveTowardsRange:new(target,70))
	meleeseq:push(OrderStop:new())
	meleeseq:push(OrderChannelSkill:new(hans.skills.melee,function()return {normalize(target.x-hans.x,target.y-hans.y)},hans,hans.skills.melee end))
	meleeseq:push(OrderWaitUntil:new(function() hans:setAngle(math.atan2(target.y-hans.y,target.x-hans.x))return getdistance(target,hans)>100 or target.invisible end))
	meleeseq:push(OrderWait:new(1))
	meleeseq:push(OrderStop:new())
	meleeseq.timelimit = 7
	local danceseq = Sequence:new()
	danceseq:push(OrderWait:new(1))
	danceseq:push(OrderMoveTowardsRange:new(target,175))
	danceseq:push(OrderActiveSkill:new(hans.skills.dance,function() return {normalize(target.x-hans.x,target.y-hans.y)},hans,hans.skills.dance end))
	danceseq:push(OrderWait:new(3))
	danceseq:push(OrderStop:new())
	
	local spearend = false
	local spearseq = Sequence:new()
	spearseq:push(OrderWait:new(1))
	spearseq:push(OrderMoveTowardsRange:new(target,500))
	spearseq:push(OrderStop:new())
	spearseq:push(OrderChannelSkill:new(hans.skills.flamingspear,function()return {normalize(target.x-hans.x,target.y-hans.y)},hans,hans.skills.flamingspear end))
	spearseq:push(OrderWaitUntil:new(function(dt,owner) hans:setAngle(math.atan2(target.y-hans.y,target.x-hans.x))return getdistance(target,hans)>600 or target.invisible end))
	spearseq:push(OrderWait:new(1))
	spearseq:push(OrderStop:new())
	spearseq.timelimit = 6
	
	local demoselector = Selector:new()
	demoselector:push(function ()
		if hans:getHPPercent()<0.5 then
			hans.ai = AI.Hans2(hans,target)
		end
		local d = getdistance(hans,target)
		if math.random()<0.33 then
			hans.p:setColors(255,0,0,255,255,0,0,0)
			return spearseq
		elseif math.random()>0.5 then
			hans.p:setColors(0,0,0,255,0,0,0,0)
			return danceseq
		else
			hans.p:setColors(255,255,0,255,255,255,0,0)
			return meleeseq
		end
	end)
	local AIDemo = Sequence:new()
	AIDemo:push(demoselector)
	AIDemo.loop = true
	return AIDemo
end

function AI.Hans2(hans,target)
	local positionquery = {}
	local t = Timer:new(0.1,-1,function(timer)
		if #positionquery>5 then
			table.remove(positionquery)
		end
		table.insert(positionquery,1,{target.x,target.y})
	end,true,false)
	local meleeseq = Sequence:new()
	meleeseq:push(OrderWait:new(1))
	meleeseq:push(OrderMoveTowardsRange:new(target,70))
	meleeseq:push(OrderStop:new())
	meleeseq:push(OrderChannelSkill:new(hans.skills.melee,function()return {normalize(target.x-hans.x,target.y-hans.y)},hans,hans.skills.melee end))
	meleeseq:push(OrderWaitUntil:new(function() hans:setAngle(math.atan2(target.y-hans.y,target.x-hans.x))return getdistance(target,hans)>100 or target.invisible end))
	meleeseq:push(OrderStop:new())
	meleeseq.loop = true
	meleeseq.timelimit = 7
	
	local volcseq = Sequence:new()
	volcseq:push(OrderWait:new(1))
	volcseq:push(OrderStop:new())
	volcseq:push(OrderChannelSkill:new(hans.skills.volcano,function()return table.remove(positionquery),hans,hans.skills.volcano end))
	volcseq:push(OrderWaitUntil:new(function() hans:setAngle(math.atan2(target.y-hans.y,target.x-hans.x))return target.invisible or not target.allowskill end))
	volcseq:push(OrderStop:new())
	volcseq:push(OrderMoveTowardsRange:new(target,200))
	volcseq:push(OrderActiveSkill:new(hans.skills.dance,function() return {normalize(target.x-hans.x,target.y-hans.y)},hans,hans.skills.dance end))
	volcseq:push(OrderWait:new(3))
	volcseq:push(OrderStop:new())
	
	local stompseq = Sequence:new()
	stompseq:push(OrderWait:new(0.5))
	stompseq:push(OrderActiveSkill:new(hans.skills.stomp,function() return {hans.x,hans.y},hans,hans.skills.stomp end))
	stompseq:push(OrderWait:new(1))
	stompseq:push(OrderStop:new())
	
	local demoselector = Selector:new()
	local count = 0
	demoselector:push(function ()
		count = count + 1
		local d = getdistance(hans,target)
		if d< 100 then
			return stompseq
		elseif d<200 then
			if math.random() > 0.5 then
				return meleeseq
			end
		elseif hans:getHPPercent()< 0.5 then
			if math.random() < 0.33 then
				-- summon minion
			end
			return volcseq
		end
		return volcseq
	end)
	local AIDemo = Sequence:new()
	AIDemo:push(demoselector)
	AIDemo.loop = true
	return AIDemo
end

animation.manfire = Animation:new(love.graphics.newImage('assets/ial/manfire.png'),52,90,0.04,1.8,1.8,10,29)
animation.manfireattack2 = Animation:new(love.graphics.newImage('assets/ial/manfireattack2.png'),50,50,0.04,1.8,1.8,10,29)

HansMeleeEffect = ShootMissileEffect:new()
HansMeleeEffect:addAction(function(point,caster,skill)
	local Missile = MeleeMissile:new(0.05,1,2000,caster.x,caster.y,unpack(point))
	Missile.controller = caster.controller..'Missile'
	Missile.effect = BulletEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	TEsound.play({'sound/sword1.wav','sound/sword2.wav','sound/sword3.wav'})
end)
HansMelee = Melee:subclass('HansMelee')
function HansMelee:initialize(unit)
	super.initialize(self,unit)
	self.damage = 60
	self.effect = HansMeleeEffect
end
FlamingSpearTrail = Object:subclass('FlamingSpearTrail')
function FlamingSpearTrail:initialize(b)
	self.bullet = b
	local p = love.graphics.newParticleSystem(img.part1, 1000)
	p:setEmissionRate(100)
	p:setSpeed(100, 100)
	p:setGravity(0)
	p:setSizes(2, 1)
	p:setColors(255, 128, 58, 255, 255, 170, 96, 0)
	p:setPosition(400, 300)
	p:setLifetime(1)
	p:setParticleLife(1)
	p:setDirection(0)
	p:setSpread(360)
	p:setRadialAcceleration(0)
	p:setTangentialAcceleration(250)
	self.p = p
	self.dt = 0
end

function FlamingSpearTrail:update(dt)
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

function FlamingSpearTrail:draw()
	love.graphics.draw(self.p)
end
requireImage('assets/missile/flamingspear.png','flamingspear')
FlamingSpearMissile = Missile:subclass('FlamingSpearMissile')
function FlamingSpearMissile:initialize(...)
	super.initialize(self,...)
	self.trail = FlamingSpearTrail:new(self)
	map:addUpdatable(self.trail)
end
function FlamingSpearMissile:draw()
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(img.flamingspear,self.x,self.y,self.body:getAngle(),2,2,16,16)
	love.graphics.setColor(255,255,255,255)
end
function FlamingSpearMissile:add(unit,coll)
	if (self.controller=='playerMissile' and unit.controller=='enemy') or (self.controller == 'enemyMissile' and unit.controller=='player') then
		if not unit.bht[self] then
			if self.effect then self.effect:effect(unit,self,self.skill) end
			unit.bht[self] = true
			self.draw = function() end
			self.add = function() end
		end
	end
end

FlamingSpearEffect = ShootMissileEffect:new()
FlamingSpearEffect:addAction(function(point,caster,skill)
	local Missile = FlamingSpearMissile:new(5,15,1000,caster.x,caster.y,point[1],point[2],60)
	Missile.controller = caster.controller..'Missile'
	Missile.effect = BulletEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	TEsound.play('sound/spear.wav')
end)

FlamingSpear = Skill:subclass('FlamingSpear')
function FlamingSpear:initialize(unit)
	super.initialize(self)
	self.unit = unit
	self.name = 'FlamingSpear'
	self.effecttime = 0.02
	self.casttime = 2
	self.damage = 100
	self.effect = FlamingSpearEffect
end

function FlamingSpear:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function FlamingSpear:stop()
	self.time = 0
end

requireImage('assets/ial/volcano.png','volcano')
VolcanoActor = Object:subclass('FlamingSpearTrail')
function VolcanoActor:initialize(x,y)
	self.x,self.y = x,y
	local p = love.graphics.newParticleSystem(img.pulse, 1000)
	p:setEmissionRate(300)
	p:setSpeed(100, 200)
	p:setGravity(0)
	p:setSizes(2, 1)
	p:setColors(255, 220, 58, 255, 255, 185, 26, 0)
	p:setPosition(self.x, self.y)
	p:setLifetime(1)
	p:setParticleLife(1)
	p:setDirection(0)
	p:setSpread(360)
	p:setRadialAcceleration(0)
	p:setTangentialAcceleration(0)
	self.p = p
	self.dt = 0
	self.r = math.random(math.pi*2)
end

function VolcanoActor:update(dt)
	self.dt = self.dt + dt
	if self.dt>3 then
		map:removeUpdatable(self)
		map:removeUnit(self)
	end
	if self.dt>1 then
		self.p:setColors(255, 58, 58, 255, 255, 26, 26, 0)
	end
	if self.dt<2 then
		self.p:start()
	end
	self.p:update(dt)
end

function VolcanoActor:draw()
	love.graphics.setColors(255,255,255,math.min(3-self.dt,1)*255)
	love.graphics.draw(img.volcano,self.x,self.y,self.r,1,1,128,128)
	love.graphics.setColors(255,255,255,255)
	love.graphics.draw(self.p)
end


VolcanoEffect = CircleAoEEffect:new(100)
VolcanoEffect:addAction(function (area,caster,skill)
	local impact = 200
	if caster:getMP()<skill.manacost then return end
	caster.mp = caster.mp-20
	local actor = VolcanoActor:new(area.x,area.y)
	map:addUnit(actor)
	actor.x,actor.y=area.x,area.y
	local units = map:findUnitsInArea(area)
	for k,v in pairs(units) do
		if v:isKindOf(Unit) then
			v:addBuff(b_Stun:new(100,nil),1.5)
			v:damage('Fire',caster:getDamageDealing(50,'Fire'),caster)
			local x,y=normalize(v.x-area.x,v.y-area.y)
			x,y=x*impact,y*impact
			if buff then v.buffs[buff:new()] = true end
--			if v.body and not v.immuneimpact then
--				v.body:applyImpulse(x,y)
--			end
		end
	end
	map.camera:shake(30,1)
	TEsound.play('sound/thunderclap.wav')
end)


Volcano = Skill:subclass('Volcano')

function Volcano:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Volcano'
	self.effecttime = 0.05
	self.casttime = 2
	self.effect = VolcanoEffect
	self:setLevel(level)
	self.manacost = 20
end

function Volcano:stop()
	self.time = 0
end

function Volcano:setLevel(lvl)
	self.level = lvl
end

function Volcano:startChannel()
	super.startChannel(self)
	self.point = GetOrderPoint()
end

function Volcano:geteffectinfo()
	return self.point,self.unit,self
end

NineSwordDanceActor = Object:subclass('NineSwordDanceActor')
function NineSwordDanceActor:initialize(b,cha)
	self.unit = b
	self.cha = cha
	self.dt = 0
end

function NineSwordDanceActor:update(dt)
	self.dt = self.dt + dt
	if self.dt> 0.25 then
		map:removeUpdatable(self)
	end
end

function NineSwordDanceActor:draw()
	love.graphics.setColor(255,255,255,255*(1-self.dt))
	love.graphics.draw(self.cha,self.unit.x,self.unit.y,0,1-self.dt,1-self.dt,self.cha:getWidth()/2,self.cha:getHeight()/2)
	love.graphics.setColor(255,255,255,255)
end
NineSwordDanceEffect = ShootMissileEffect:new()
NineSwordDanceEffect:addAction(function(point,caster,skill)
	local buff = b_Dash:new(point,caster,skill)
	caster:addBuff(buff,1)
	Timer:new(1,1,function()caster.add=nil end,true,true)
	function caster:add(b,coll)
		if b:isKindOf(Unit) and b.controller ~= self.controller then
			caster:removeBuff(buff)
			--caster.ai = nil
			caster:stop()
			caster.state = 'slide'
			caster.body:setLinearVelocity(0,0)
			caster.add = nil
			local count = 1
			Timer:new(0.25,9,function(timer)
				if b.invisible or (not b.body) then
					timer.count = 1
				end
				local angle = math.random(math.pi*2)
				local x,y = math.cos(angle)*30,math.sin(angle)*30
				caster.body:setPosition(b.x-x,b.y-y)
				caster.x,caster.y = b.x-x,b.y-y
				caster.skills.melee.effect:effect({normalize(x,y)},caster,caster.skills.melee)
				caster:skilleffect(caster.skills.melee)
				self:setAngle(angle)
				if timer.count <= 1 then
		--			caster.skills.melee.casttime = oricasttime
				end
				local c = 1
				for k,v in pairs(character) do
					if c == count then
						map:addUpdatable(NineSwordDanceActor:new(b,v))
						count = count + 1
						return
					end
					c = c+1
				end
			end,true,true)
		end
	end
end)

NineSwordDance = ActiveSkill:subclass('NineSwordDance')
function NineSwordDance:initialize(unit)
	super.initialize(self)
	self.unit = unit
	self.name = 'NineSwordDance'
	self.effect = NineSwordDanceEffect
	self.cd = 8
	self.cdtime = 0
	self.available = true
	self.movementspeedbuffpercent = 12
	self.manacost = 30
end

function NineSwordDance:stop()
	self.time = 0
end

function NineSwordDance:active()
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

function NineSwordDance:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

StompActor = Object:subclass('StompActor')
function StompActor:initialize(x,y)
	self.x,self.y=x,y
	local p = love.graphics.newParticleSystem(img.rip, 1000)
	p:setEmissionRate(500)
	p:setSpeed(300, 400)
	p:setGravity(0)
	p:setSizes(1, 0.5)
	p:setColors(0, 0, 0, 0, 255, 0, 0, 0)
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


function StompActor:reset()
	self.dt = 0
	self.visible = true
end

function StompActor:update(dt)
	self.dt = self.dt+dt
	if self.dt>self.time then
		self.system:update(dt)
		if self.dt>self.time+1 then
			self.visible = false
			map:removeUnit(self)
		end
	else
		self.system:setPosition(self.x,self.y)
		self.system:start()
		self.system:update(dt)
	end
end

function StompActor:draw()
	if not self.visible then return end
	love.graphics.draw(self.system,0,0)
	local scale = self.dt/self.time
	love.graphics.setColors(0,0,0,255*(1-scale))
	love.graphics.draw(img.ripcircle,self.x,self.y,0,scale*2,scale*2,128,128)
	love.graphics.setColors(255,255,255,255)
end

StompEffect = CircleAoEEffect:new(100)
StompEffect:addAction(function (area,caster,skill)
	local impact = 100
	if caster:getMP()<skill.manacost then return end
	caster.mp = caster.mp-20
	local actor = StompActor:new(area.x,area.y)
	map:addUnit(actor)
	actor.x,actor.y=area.x,area.y
	local units = map:findUnitsInArea(area)
	for k,v in pairs(units) do
		if v:isKindOf(Unit) then
			v:addBuff(b_Stun:new(100,nil),1)
			v:damage('Fire',caster:getDamageDealing(100,'Fire'),caster)
			local x,y=normalize(v.x-area.x,v.y-area.y)
			x,y=x*impact,y*impact
			if buff then v.buffs[buff:new()] = true end
			if v.body and not v.immuneimpact then
				v.body:applyLinearImpulse(x,y)
			end
		end
	end
end)

Stomp = ActiveSkill:subclass('Stomp')
function Stomp:initialize(unit,level)	
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Stomp'
	self.effecttime = -1
	self.effect = StompEffect
	self.cd = 5
	self.cdtime = 0
	self.available = true
	self:setLevel(level)
	self.manacost = 50
end

function Stomp:geteffectinfo()
	return self.unit,self.unit,self
end

function Stomp:setLevel(lvl)
	self.level = lvl
	self.invistime = lvl*5
end


function Stomp:active()
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


BossHans = AnimatedUnit:subclass('BossHans')
function BossHans:initialize(x,y,controller)
	super.initialize(self,x,y,32,10)
	self.hp = 20000
	self.maxhp = 20000
	self.mp = 50000
	self.maxmp = 50000
	self.skills = {
		melee = HansMelee:new(self),
		flamingspear = FlamingSpear:new(self),
		volcano = Volcano:new(self,1),
		dance = NineSwordDance:new(self),
		stomp = Stomp:new(self)
	}
	self.animation = {
		stand = animation.manfire:subSequence(1,9),
		attack = {
			animation.manfire:subSequence(10,#animation.manfire.quad),
			animation.manfireattack2:subSequence(10,#animation.manfireattack2.quad),
		}
	}
	self:resetAnimation()
	self.controller = controller
	local p = love.graphics.newParticleSystem(img.part1, 1000)
	p:setEmissionRate(200)
	p:setSpeed(300, 250)
	p:setSizes(0.25, 1)
	p:setColors(220, 105, 20, 255, 194, 30, 18, 0)
	p:setPosition(400, 300)
	p:setLifetime(0.5)
	p:setParticleLife(0.5)
	p:setDirection(0)
	p:setSpread(360)
	p:setRadialAcceleration(-1000)
	p:stop()
	self.p = p
	self.movementspeedbuffpercent = 4
end

function BossHans:damage(...)
	super.damage(self,...)
end

function BossHans:update(dt)
	super.update(self,dt)
	local cosr,sinr = math.cos(self.body:getAngle())*15,math.sin(self.body:getAngle())*15
	self.p:setPosition(self.x+cosr,self.y+sinr)
	self.p:setDirection(math.pi+self.body:getAngle())
	self.p:start()
	self.p:update(dt)
end

function BossHans:draw()
	love.graphics.draw(self.p)
	super.draw(self)
end

function BossHans:skilleffect(skill)
	if skill then
		self:playAnimation('attack',0.6,false)
	end
end

function BossHans:enableAI(ai)
	self.ai = ai or AI.Hans1(self,GetCharacter())
end
