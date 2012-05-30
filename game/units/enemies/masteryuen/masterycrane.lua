
CraneP1MEffect = UnitEffect:new()
CraneP1MEffect:addAction(function (unit,caster,skill)
	unit:damage('Bullet',caster.unit:getDamageDealing(skill.damage,'Bullet'),caster.unit)
	unit:addBuff(b_Stun(100),3)
end)

CraneP1Effect = ShootMissileEffect:new()
CraneP1Effect:addAction(function(point,caster,skill)
	local x,y  = unpack(point)
	local Missile = CraneMissile:new(1,skill.bulletmass,skill.range/1,caster.x,caster.y,x,y)
	Missile.controller = caster.controller..'Missile'
	Missile.effect = CraneP1MEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)

	local Missile = CraneMissile:new(1,skill.bulletmass,skill.range/1,caster.x,caster.y,0.866*x-0.5*y,0.5*x+0.866*y)
	Missile.controller = caster.controller..'Missile'
	Missile.effect = CraneP1MEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)

	local Missile = CraneMissile:new(1,skill.bulletmass,skill.range/1,caster.x,caster.y,0.866*x+0.5*y,-0.5*x+0.866*y)
	Missile.controller = caster.controller..'Missile'
	Missile.effect = CraneP1MEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	TEsound.play({'sound/sword1.wav','sound/sword2.wav','sound/sword3.wav'})
end)

CraneMissile = Missile:subclass('CraneMissile')
function CraneMissile:draw()
	if self.dt < 0.3 then
		love.graphics.setColor(255,160,40,self.dt/0.3*255)
	elseif self.dt > 0.7 then
		love.graphics.setColor(255,255,255,(1-self.dt)/0.3*255)
	else
		love.graphics.setColor(255,160,40)
	end
	love.graphics.circle('fill',self.x,self.y,self.body:getAngle(),100)
	love.graphics.draw(myimg.missile.birdmissile,self.x,self.y,self.body:getAngle(),0.5,0.5,200,100)
	love.graphics.setColor(255,255,255)
end
function CraneMissile:add(unit,coll)
	if (self.controller=='playerMissile' and unit.controller=='enemy') or (self.controller == 'enemyMissile' and unit.controller=='player') then
		if not unit.bht[self] then
			if self.effect then self.effect:effect(unit,self,self.skill) end
			unit.bht[self] = true
			self.body:setLinearVelocity(0,0)
			self.body:setAngularVelocity(0,0)
			self.dt = 0.3
			self.add = function() end
		end
	end
end

function CraneMissile:createBody(world)
	self.body = love.physics.newBody(world,self.x,self.y,'dynamic')
	self.shape = love.physics.newRectangleShape(30,30)
	self.fixture = love.physics.newFixture(self.body,self.shape)
	if self.controller then
		category,masks = unpack(typeinfo[self.controller])
		self.fixture:setCategory(category)
		self.fixture:setDensity(self.mass/5)
		
		self.fixture:setMask(unpack(masks))
	end
	self.body:resetMassData()
	self.body:setLinearVelocity(self.dx*self.vi,self.dy*self.vi)
	self.body:setBullet(true)
	self.body:setAngle(math.atan2(self.dy,self.dx))
	self.fixture:setUserData(self)
end

CraneP1 = Skill:subclass'CraneP1'
function CraneP1:initialize(unit)
	super.initialize(self)
	self.unit = unit
	self.name = 'Crane'
	self.effecttime = 0.02
	self.casttime = 1
	self.damage = 50
	self.bulletmass = 1
	self.range = 1*400
	self.effect = CraneP1Effect
end

function CraneP1:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end


cranemissilesuicideeffect = CircleAoEEffect:new(200)
cranemissilesuicideeffect:addAction(function (area,caster,skill)
	local units = map:findUnitsInArea(area)
	for k,v in pairs(units) do
		if v:isKindOf(Unit) then
			local impact = skill.impact
			local x,y=normalize(v.x-area.x,v.y-area.y)
			x,y=x*impact,y*impact
			if v.body and not v.immuneimpact then
				v.body:applyLinearImpulse(x,y)
			end
			v:damage('Bullet',skill.damage,caster)
		end
	end
	TEsound.play('sound/thunderclap.wav')
	caster:kill(caster)
end)

CraneMissileSuicide = ActiveSkill:subclass('CraneMissileSuicide')
function CraneMissileSuicide:initialize(unit)
	super.initialize(self,unit)
	self.unit = unit
	self.effect = cranemissilesuicideeffect
	self.damage = 80
	self.impact = 50
end


function CraneMissileSuicide:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function CraneMissileSuicide:geteffectinfo()
	return {self.unit.x,self.unit.y},self.unit,self
end


CraneMissileP2 = Unit:subclass('CraneMissileP2')
function CraneMissileP2:initialize(x,y,controller)
	super.initialize(self,x,y,8,5)
	self.hp=1000
	self.maxhp=1000
	self.controller = controller
	self.movementspeedbuffpercent = 2
	self.skills = {
		explode = CraneMissileSuicide(self),
	}
	local t = UnitTrail(self,'cranes',10,0.5)
	map:addUpdatable(t)
	self.trail = t
end

function CraneMissileP2:createBody(...)
	super.createBody(self,...)
	self.fixture:setSensor(true)
end

function CraneMissileP2:draw()
	love.graphics.draw(myimg.missile.birdmissile,self.x,self.y,self.body:getAngle(),1,1,300,100)
	love.graphics.setColor(255,255,255,255)
	filtermanager:requestFilter('Gaussianblur',function()
		love.graphics.draw(myimg.missile.birdmissile,self.x,self.y,self.body:getAngle(),1,1,300,100)
	end)
end

function CraneMissileP2:setTarget(t)
	self.target = t
end

function CraneMissileP2:update(dt)
	self:damage('Bullet',dt*self.maxhp/5)
	super.update(self,dt)
end

function CraneMissileP2:kill(...)
	map:removeUpdatable(self.trail)
	super.kill(self,...)
end

function CraneMissileP2:enableAI(ai)
	local target = self.target
	danceseq=Sequence:new()
	danceseq:push(OrderMoveTowardsRange:new(target,50))
	danceseq:push(OrderActiveSkill:new(self.skills.explode,function() return {self.x,self.y},self,self.skills.explode end))
	danceseq:push(OrderWait:new(3))
	self.ai = ai or danceseq
end

cranemissilelauncheffect = ShootMissileEffect:new()
cranemissilelauncheffect:addAction(function (unit,caster,skill)
	local x,y = displacement(caster.x,caster.y,caster.body:getAngle(),-300)
	local missile = CraneMissileP2:new(x,y,caster.controller)
	missile:setTarget(unit)
	map:addUnit(missile)
	missile:enableAI()
end)

CraneP2 = ActiveSkill:subclass('CraneP2')
function CraneP2:initialize(unit)
	super.initialize(self)
	self.unit = unit
	self.effect = cranemissilelauncheffect
	self.casttime = 3
end

function CraneP2:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function CraneP2:geteffectinfo()
	return GetOrderUnit(),self,self
end

CraneCircleP3 = Object:subclass'CraneCircleP3'

function CraneCircleP3:initialize(unit,my)
	self.unit = unit
	self.my = my
	self.image = {}
	for i = 1,7 do
		local r = math.pi*2/7*i
		local x,y = math.cos(r),math.sin(r)
		table.insert(self.image,{
			x = -x*100,
			y = -y*100,
			r = r,
			actor = MasterYuenAnimation(),
			opacity = 0,
		})
		map.anim:easy(self.image[i],'opacity',0,255,2)
	end
	self.real = math.random(7)
	Timer(1,7,function(timer)
		if #self.image < 1 then
			timer:kill()
			return
		end
		if timer.count == self.real then
			self:strike()
		else
			self:phantom()
		end
	end)
	my.actor:playAnimation'pray'
	my.actor:setEffect'invis'
end

function CraneCircleP3:update(dt)
	for i,v in ipairs(self.image) do
		v.actor:update(dt)
	end
end

function CraneCircleP3:draw()
	local x,y = self.unit:getPosition()
	for i,v in ipairs(self.image) do
		love.graphics.setColor(255,255,255,v.opacity)
		v.actor:draw(x+v.x,y+v.y,v.r)
	end
	love.graphics.setColor(255,255,255)
end
local am = {'fist','kick','crane'}
function CraneCircleP3:phantom()
	local i=math.random(#self.image)
	local v = self.image[i]
	v.actor:playAnimation(am[math.random(3)],1.5)
	Trigger(function()
		map.anim:easy(v,'x',v.x,0,1)
		map.anim:easy(v,'y',v.y,0,1)
		wait(0.7)
		map.anim:easy(v,'opacity',255,0,0.3)
		wait(0.3)
		table.remove(self.image,i)
	end):run()
end

function CraneCircleP3:strike()
	local i=math.random(#self.image)
	local v = self.image[i]
	local a = am[math.random(3)]
	my.actor:setEffect()
	my:setPosition(v.x+self.unit.x,v.y+self.unit.y)
	my:face(self.unit)
	my:dashStrike(a,2300,0.7)
	table.remove(self.image,i)
	Trigger(function()
--		map.anim:easy(v,'x',v.x,0,1)
--		map.anim:easy(v,'y',v.y,0,1)
		wait(0.3)
		self.image = {}
--		map.anim:easy(v,'opacity',255,0,0.3)
		wait(0.7)
		map:removeUpdatable(self)
--		table.remove(self.image,i)
	end):run()
end