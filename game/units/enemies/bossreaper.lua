
function AI.Reaper1(boss,target)
	local meleeseq = Sequence:new()
	meleeseq:push(OrderWait:new(1))
	meleeseq:push(OrderMoveTowardsRange:new(target,70))
	meleeseq:push(OrderStop:new())
	meleeseq:push(OrderChannelSkill:new(boss.skills.melee,function()return {normalize(target.x-boss.x,target.y-boss.y)},boss,boss.skills.melee end))
	meleeseq:push(OrderWaitUntil:new(function() boss:setAngle(math.atan2(target.y-boss.y,target.x-boss.x))return getdistance(target,boss)>100 or target.invisible end))
	meleeseq:push(OrderStop:new())
--	meleeseq.loop = true
	meleeseq.timelimit = 7
	
	local hellnetseq = Sequence()
	hellnetseq:push(OrderWait(1))
	hellnetseq:push(OrderStop())
	hellnetseq:push(OrderActiveSkill(boss.skills.hellnet,function()return target,boss,boss.skills.hellnet end))
	hellnetseq:push(OrderWait(5))
	hellnetseq:push(OrderStop())
	
	local demoselector = Selector:new()
	local count = 0
	demoselector:push(function ()
		count = count + 1
		local choice = math.random(3)
		if choice == 1 then
			return meleeseq
		elseif choice == 2 then
			local ps = function(target)
				return {x=target.x+math.random(-300,300),y=target.y+math.random(-300,300)}
			end
			local vanishseq = Sequence:new()
			vanishseq:push(OrderWait:new(1))
			vanishseq:push(OrderStop:new())
			vanishseq:push(OrderActiveSkill:new(boss.skills.vanish,function() return boss,boss,boss.skills.vanish end))
			for i=1,5 do
				vanishseq:push(OrderActiveSkill(boss.skills.summon,function() return {boss.x,boss.y},boss,boss.skills.summon end))
				vanishseq:push(OrderMoveTowardsRange(ps(target),50))
--				vanishseq:push(OrderWait(1))
			end
			vanishseq:push(OrderStop:new())
			vanishseq:push(OrderWait(1))
			vanishseq:push(OrderActiveSkill:new(boss.skills.strike,function() return target,boss,boss.skills.strike end))
			vanishseq:push(OrderStop:new())
			vanishseq:push(OrderWait(2))
			vanishseq.loop = true
			vanishseq.timelimit = 7
			return vanishseq
		else
			return hellnetseq
		end
--		print ('volcseq',count)
	end)
	local AIDemo = Sequence:new()
	AIDemo:push(demoselector)
	AIDemo.loop = true
	return AIDemo
end
--[[
function AI.Reaper2(boss,target)
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
	meleeseq:push(OrderChannelSkill:new(boss.skills.melee,function()return {normalize(target.x-boss.x,target.y-boss.y)},boss,boss.skills.melee end))
	meleeseq:push(OrderWaitUntil:new(function() boss:setAngle(math.atan2(target.y-boss.y,target.x-boss.x))return getdistance(target,boss)>100 or target.invisible end))
	meleeseq:push(OrderStop:new())
	meleeseq.loop = true
	meleeseq.timelimit = 7
	
	local volcseq = Sequence:new()
	volcseq:push(OrderWait:new(1))
	volcseq:push(OrderStop:new())
	volcseq:push(OrderChannelSkill:new(boss.skills.volcano,function()return table.remove(positionquery),boss,boss.skills.volcano end))
	volcseq:push(OrderWaitUntil:new(function() boss:setAngle(math.atan2(target.y-boss.y,target.x-boss.x))return target.invisible or not target.allowskill end))
	volcseq:push(OrderStop:new())
	volcseq:push(OrderMoveTowardsRange:new(target,200))
	volcseq:push(OrderActiveSkill:new(boss.skills.dance,function() return {normalize(target.x-boss.x,target.y-boss.y)},boss,boss.skills.dance end))
	volcseq:push(OrderWait:new(3))
	volcseq:push(OrderStop:new())
	
	local stompseq = Sequence:new()
	stompseq:push(OrderWait:new(0.5))
	stompseq:push(OrderActiveSkill:new(boss.skills.stomp,function() return {boss.x,boss.y},boss,boss.skills.stomp end))
	stompseq:push(OrderWait:new(1))
	stompseq:push(OrderStop:new())
	
	local demoselector = Selector:new()
	local count = 0
	demoselector:push(function ()
		count = count + 1
		local d = getdistance(boss,target)
		if d< 100 then
			return stompseq
		elseif d<200 then
			if math.random() > 0.5 then
				return meleeseq
			end
		elseif boss:getHPPercent()< 0.5 then
			if math.random() < 0.33 then
				-- summon minion
			end
			return volcseq
		end
--		print ('volcseq',count)
		return volcseq
	end)
	local AIDemo = Sequence:new()
	AIDemo:push(demoselector)
	AIDemo.loop = true
	return AIDemo
end
]]--
ReaperMissileDead = Object:subclass('ReaperMissileDead')
function ReaperMissileDead:initialize(x,y)
	self.x,self.y=x,y
	local p = love.graphics.newParticleSystem(img.part1, 1000)
	p:setEmissionRate(options.particlerate*200)
	p:setSpeed(300, 400)
	p:setSize(1, 2)
	p:setColor(255, 255, 255, 255, 255, 128, 128, 0)
	p:setPosition(400, 300)
	p:setLifetime(1)
	p:setParticleLife(2)
	p:setDirection(0)
	p:setSpread(360)
	p:setTangentialAcceleration(2000)
	p:setRadialAcceleration(-8000)
	p:start()
	self.system=p
	self.dt = 0
	self.time = 1
	self.visible = true
	print 'REAPERDEAD INITED'
end


function ReaperMissileDead:reset()
	self.dt = 0
	self.visible = true
end

function ReaperMissileDead:update(dt)
	self.dt = self.dt+dt
	if self.dt>self.time then
		self.system:update(dt)
		if self.dt>self.time+1 then
			self.visible = false
			map:removeUpdatable(self)
		end
	else
		self.system:setPosition(self.x,self.y)
		self.system:update(dt)
	end
end

function ReaperMissileDead:draw()
	if not self.visible then return end
	love.graphics.draw(self.system,0,0)
end

ReaperMeleeMissile = MeleeMissile:subclass'ReaperMeleeMissile'
requireImage'assets/dungeon/reapermelee.png'
function ReaperMeleeMissile:draw()
	love.graphics.draw(img.reapermelee,self.x,self.y,self.body:getAngle(),1,1,15,30)
	super.draw(self)
end

function ReaperMeleeMissile:add(unit,coll)
	if (self.controller=='playerMissile' and unit.controller=='enemy') or (self.controller == 'enemyMissile' and unit.controller=='player') then
		if not unit.bht[self] then
			if self.effect then self.effect:effect(unit,self,self.skill) end
			unit.bht[self] = true
			self.draw = function() end
			self.persist = function() end
			map:addUpdatable(ReaperMissileDead(self.x,self.y))
		end
	end
end

animation.reaper = Animation:new(love.graphics.newImage('assets/dungeon/reaper.png'),52,90,0.04,1.8,1.8,10,29)

ReaperMeleeEffect = ShootMissileEffect:new()
ReaperMeleeEffect:addAction(function(point,caster,skill)
	local Missile = MeleeMissile:new(0.05,1,2000,caster.x,caster.y,unpack(point))
	Missile.controller = caster.controller..'Missile'
	Missile.effect = BulletEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	TEsound.play({'sound/sword1.wav','sound/sword2.wav','sound/sword3.wav'})
end)
ReaperMelee = Melee:subclass('ReaperMelee')
function ReaperMelee:initialize(unit)
	super.initialize(self,unit)
	self.damage = 60
	self.effect = ReaperMeleeEffect
end

ReaperStrikeBulletEffect = UnitEffect:new()
ReaperStrikeBulletEffect:addAction(function (unit,caster,skill)
	unit:damage('Bullet',caster.unit:getDamageDealing(skill.damage,'Bullet'),caster.unit)
	
end)

ReaperStrikeEffect = ShootMissileEffect:new()
ReaperStrikeEffect:addAction(function(unit,caster,skill)
	local r = math.random()*math.pi*2
	local x,y = math.cos(r),math.sin(r)
	caster.body:setPosition(unit.x-x*100,unit.y-y*100)
	caster.x,caster.y = caster.body:getPosition()
	caster.body:setLinearVelocity(0,0)
	caster:setAngle(math.atan2(unit.y-caster.y,unit.x-caster.x))
--	caster.r = r
	print (caster.body:getAngle(),r)
	caster:playAnimation('attack',0.3,false)
	Timer(0.5,3,function()
	
		local Missile = skill.bullettype:new(3,3,500,caster.x+x*30,caster.y+y*30,x,y)
		Missile.controller = caster.controller..'Missile'
		Missile.effect = skill.bulleteffect
		Missile.skill = skill
		Missile.unit = caster
		map:addUnit(Missile)
	end)
end)

ReaperStrike = ActiveSkill:subclass('ReaperStrike')
function ReaperStrike:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'ReaperStrike'
	self.effecttime = -1
	self.effect = ReaperStrikeEffect
	self.bulleteffect = ReaperStrikeBulletEffect
	self.bullettype = ReaperMeleeMissile
	self.cd = 2
	self.cdtime = 0
	self.damage = 300
	self.available = true
	self:setLevel(level)
	self.manacost = 50
end

function ReaperStrike:active()

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

function ReaperStrike:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function ReaperStrike:stop()
	self.time = 0
end

function ReaperStrike:setLevel(lvl)
	self.level = lvl
	self.damage = 300+lvl*100
end

b_Vanish = b_Stim:subclass'b_Vanish'
function b_Vanish:initialize(...)
	super.initialize(self,...)
	local p = love.graphics.newParticleSystem(img.cloud2, 1000)
	p:setEmissionRate(options.particlerate*100)
	p:setSpeed(200, 250)
	p:setGravity(100, 200)
	p:setSize(1, 1)
	p:setColor(0, 0, 0, 255, 0, 0, 0, 0)
	p:setPosition(400, 300)
	p:setLifetime(3600)
	p:setParticleLife(1)
	p:setDirection(180)
	p:setSpread(20)
	self.p = p
end

function b_Vanish:buff(unit,dt)
	super.buff(self,unit,dt)
	self.p:setPosition(unit.x,unit.y)
	self.p:update(dt)
end

function b_Vanish:draw()
	love.graphics.draw(self.p)
end

VanishEffect = UnitEffect:new()
VanishEffect:addAction(function (unit,caster,skill)
	unit:addBuff(b_Vanish:new(skill.movementspeedbuffpercent,skill.movementspeedbuffpercent),skill.stimtime)
end)

Vanish = ActiveSkill:subclass('Vanish')
function Vanish:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Vanish'
	self.effecttime = -1
	self.effect = VanishEffect
	self.cd = 3
	self.cdtime = 0
	self.stimtime = 5
	self.available = true
	self:setLevel(level)
end

function Vanish:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	if self.unit:getHPPercent()<0.2 then
		return false,'Not enough HP'
	end
	
	super.active(self)
--	self.unit:damage('Cost',self.unit:getMaxHP()*0.2)
	self.effect:effect(self:getorderinfo())
	return true
end

function Vanish:geteffectinfo()
	return self.unit,self.unit,self
end

function Vanish:stop()
	self.time = 0
end

function Vanish:setLevel(lvl)
	self.movementspeedbuffpercent = 0.5*lvl
	self.spellspeedbuffpercent = 0.5*lvl
	self.level = lvl
end

HellNetMissileEffect = ShootMissileEffect:new()
HellNetMissileEffect:addAction(function(point,caster,skill)
	local x,y = unpack(point)
	local Missile = ReaperMeleeMissile(5,0.2,600,caster.x,caster.y,x,y)
	Missile.controller = caster.controller..'Missile'
	Missile.effect = BulletEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
end)

HellNetEffect = UnitEffect:new()
HellNetEffect:addAction(function (unit,caster,skill)
	local choice = math.random(3)
	if choice==1 then
		Timer(0.5,3,function()
		for i=1,15 do
			caster.x=unit.x-512+i*60
			caster.y=unit.y-512
			SkeletonSpearEffect:effect({0,1},caster,skill)
		end
		
		caster.x,caster.y = caster.body:getPosition()
		end)
		Timer(2,1,function()
	
			for i=1,15 do
				caster.x=unit.x-512+i*60
				caster.y=unit.y-512
				HellNetMissileEffect:effect({0,1},caster,caster.skills.strike)
			end
		
			caster.x,caster.y = caster.body:getPosition()
		end)
		
	elseif choice==2 then
		local orix,oriy = caster.x,caster.y
		Timer(0.5,3,function()
		for i=1,15 do
			caster.x=unit.x+512-i*60
			caster.y=unit.y+512
			SkeletonSpearEffect:effect({0,-1},caster,skill)
		end
		
		caster.x,caster.y = caster.body:getPosition()
		end)
		Timer(2,1,function()
	
			local orix,oriy = caster.x,caster.y
			for i=1,15 do
				caster.x=unit.x+512-i*60
				caster.y=unit.y+512
				HellNetMissileEffect:effect({0,-1},caster,caster.skills.strike)
			end
		
			
			caster.x,caster.y = caster.body:getPosition()
		end)
		
	else
		Timer(0.5,3,function()
				local orix,oriy = caster.x,caster.y
			for i=1,7 do
				caster.x=unit.x-512+i*100
				caster.y=unit.y-512
				SkeletonSpearEffect:effect({0.707,0.707},caster,skill)
			end
			for i=1,7 do
				caster.x=unit.x+512-i*100
				caster.y=unit.y-512
				SkeletonSpearEffect:effect({-0.707,0.707},caster,skill)
			end
			
			caster.x,caster.y = caster.body:getPosition()
		end)
		Timer(2,1,function()

			local orix,oriy = caster.x,caster.y
			for i=1,7 do
				caster.x=unit.x-512+i*100
				caster.y=unit.y-512
				HellNetMissileEffect:effect({0.707,0.707},caster,skill)
			end
			for i=1,7 do
				caster.x=unit.x+512-i*100
				caster.y=unit.y-512
				HellNetMissileEffect:effect({-0.707,0.707},caster,skill)
			end

			
			caster.x,caster.y = caster.body:getPosition()
		end)
	end
end)

HellNet = ActiveSkill:subclass('HellNet')
function HellNet:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'HellNet'
	self.effecttime = -1
	self.effect = HellNetEffect
	self.cd = 3
	self.cdtime = 0
	self.stimtime = 5
	self.damage = 15
	self.available = true
	self:setLevel(level)
end

function HellNet:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	if self.unit:getHPPercent()<0.2 then
		return false,'Not enough HP'
	end
	
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function HellNet:geteffectinfo()
	return self.unit,self.unit,self
end

function HellNet:stop()
	self.time = 0
end

function HellNet:setLevel(lvl)
	self.movementspeedbuffpercent = 0.5*lvl -- inversely proportional
	self.spellspeedbuffpercent = 0.5*lvl
	self.level = lvl
end

ReaperSummonEffect = UnitEffect:new()
ReaperSummonEffect:addAction(function (unit,caster,skill)
	local enemy = {SkeletonSwordsman,
	SkeletonSpearman,
	WhiteWraith,
	BlueWraith,
	BlackWraith,
	SkeletonMagician}
	local e = enemy[math.random(6)](caster.x,caster.y,caster.controller)
	map:addUnit(e)
	e:enableAI()
	
end)

ReaperSummon = ActiveSkill:subclass'ReaperSummon'
function ReaperSummon:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'ReaperSummon'
	self.effecttime = -1
	self.effect = ReaperSummonEffect
	self.cd = 3
	self.cdtime = 0
	self.stimtime = 5
	self.available = true
	self:setLevel(level)
end

function ReaperSummon:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	if self.unit:getHPPercent()<0.2 then
		return false,'Not enough HP'
	end
	
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function ReaperSummon:geteffectinfo()
	return self.unit,self.unit,self
end

function ReaperSummon:stop()
	self.time = 0
end

function ReaperSummon:setLevel(lvl)
	self.movementspeedbuffpercent = 0.5*lvl
	self.spellspeedbuffpercent = 0.5*lvl
	self.level = lvl
end



animation.reaper = Animation(love.graphics.newImage'assets/dungeon/reaper.png',99,86,0.04,1,1,12,46)
BossReaper = AnimatedUnit:subclass('BossReaper')
function BossReaper:initialize(x,y,controller)
	super.initialize(self,x,y,32,10)
	self.hp = 20000
	self.maxhp = 20000
	self.mp = 50000
	self.maxmp = 50000
	self.skills = {
		melee = ReaperMelee:new(self),
		strike = ReaperStrike:new(self),
		vanish = Vanish(self,3),
		hellnet = HellNet(self),
		summon = ReaperSummon(self),
	}
	self.animation = {
		stand = animation.reaper:subSequence(1,1),
		attack = {
			animation.reaper:subSequence(1,7),
		}
	}
	self:resetAnimation()
	self.controller = controller
	self.movementspeedbuffpercent = 4
end

function BossReaper:damage(...)
	super.damage(self,...)
end

function BossReaper:update(dt)
	super.update(self,dt)
end

function BossReaper:draw()
	super.draw(self)
end

function BossReaper:skilleffect(skill)
	if skill then
		self:playAnimation('attack',0.6,false)
	end
end

function BossReaper:enableAI(ai)
	self.ai = ai or AI.Reaper1(self,GetCharacter())
end
