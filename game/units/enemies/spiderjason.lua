
	require 'units.enemies.spiderjasonphase2'


requireImage('assets/drainable/station.png','station')
SpiderStation = Unit:subclass('SpiderStation')
function SpiderStation:initialize(x,y)
	super.initialize(self,x,y,48,0)
	self.drainablemana = 100
	self.drain = function()end
end

function SpiderStation:createBody(world)
	super.createBody(self,world)
	self.shape:setMask(cc.enemy,cc.playermissile,cc.enemymissile)
end

function SpiderStation:draw()
	love.graphics.draw(img.station,self.x,self.y,self.body:getAngle(),1,1,48,48)
	if self.drainablemana then
		drawDrainLevel(self.x,self.y,3,3)
	end
end

function AI.Spider(unit,target)
	local missileseq = Sequence:new()
	missileseq:push(OrderWait:new(1))
	missileseq:push(OrderStop:new())
--	missileseq:push(OrderActiveSkill:new(unit.skills.spiral,function()return unit,unit,unit.skills.spiral end))
	missileseq:push(OrderChannelSkill:new(unit.skills.gun,function()return {normalize(target.x-unit.x,target.y-unit.y)},unit,unit.skills.gun end))
	missileseq:push(OrderWait:new(2))
	missileseq:push(OrderStop:new())
	
	local spiralseq = Sequence:new()
	spiralseq:push(OrderWait:new(1))
	spiralseq:push(OrderStop:new())
	spiralseq:push(OrderActiveSkill:new(unit.skills.spiral,function()return unit,unit,unit.skills.spiral end))
--	missileseq:push(OrderChannelSkill:new(unit.skills.gun,function()return {normalize(target.x-unit.x,target.y-unit.y)},unit,unit.skills.gun end))
	spiralseq:push(OrderWait:new(2))
	spiralseq:push(OrderStop:new())
	
	local demoselector = Selector:new()
	demoselector:push(function ()
		local d = getdistance(unit,target)
		if math.random(2)==1 then
			return missileseq
		else
			return spiralseq
		end
	end)
	local bodyai = Sequence:new()
	bodyai:push(demoselector)
	bodyai.loop = true
	
	local legseq = OrderWait(5)
	local legselector = Selector:new()
	legselector:push(function ()
		local i = math.random(#unit.frontlegs)
		unit:swipe(i)
		
		Timer(1.5,1,function()unit:revertLeg(i)end,true,true)
		return legseq
	end)
	
	local legai = Sequence()
	legai:push(legselector)
	legai.loop = true
	
	local AIDemo = Parallel:new()
	AIDemo:push(bodyai)
	AIDemo:push(legai)
	return AIDemo
end


function AI.Spider2(unit,target)
	local missileseq = Sequence:new()
	missileseq:push(OrderWait:new(1))
	missileseq:push(OrderStop:new())
--	missileseq:push(OrderActiveSkill:new(unit.skills.spiral,function()return unit,unit,unit.skills.spiral end))
	missileseq:push(OrderChannelSkill:new(unit.skills.gun,function()return {normalize(target.x-unit.x,target.y-unit.y)},unit,unit.skills.gun end))
	missileseq:push(OrderWait:new(2))
	missileseq:push(OrderStop:new())
	
	local spiralseq = Sequence:new()
	spiralseq:push(OrderWait:new(1))
	spiralseq:push(OrderStop:new())
	spiralseq:push(OrderActiveSkill:new(unit.skills.spiral,function()return unit,unit,unit.skills.spiral end))
--	missileseq:push(OrderChannelSkill:new(unit.skills.gun,function()return {normalize(target.x-unit.x,target.y-unit.y)},unit,unit.skills.gun end))
	spiralseq:push(OrderWait:new(2))
	spiralseq:push(OrderStop:new())
	
	local seekerseq = Sequence:new()
	seekerseq:push(OrderWait:new(1))
	seekerseq:push(OrderStop:new())
	seekerseq:push(OrderActiveSkill:new(unit.skills.missile,function()return target,unit,unit.skills.missile end))
--	missileseq:push(OrderChannelSkill:new(unit.skills.gun,function()return {normalize(target.x-unit.x,target.y-unit.y)},unit,unit.skills.gun end))
	seekerseq:push(OrderWait:new(2))
	seekerseq:push(OrderStop:new())
	
	
	local demoselector = Selector:new()
	demoselector:push(function ()
		local d = getdistance(unit,target)
		if math.random()<0.33 then
			return seekerseq
		elseif math.random()<0.5 then
			return missileseq
		else
			return spiralseq
		end
	end)
	local bodyai = Sequence:new()
	bodyai:push(demoselector)
	bodyai.loop = true
	
	local legseq = Sequence()
	legseq:push(OrderWait(8))
	legseq:push(OrderWaitUntil(function()
		return not legseq.leg.grabbing
	end))
	legseq:push(OrderWait(3))
	local legselector = Selector:new()
	legselector:push(function ()
		local i = math.random(#unit.frontlegs)
		unit:stab(target,i)
		legseq.leg = unit.frontlegs[i][1]
		Timer(1.5,1,function()
			unit:revertLeg(i)
			
			if not unit.frontlegs[i] then return end
			if unit.frontlegs[i][1].grabbing then
				unit.frontlegs[i][1]:bend(2.7,10)
			end
		end,true,true)
		return legseq
	end)
	
	local legai = Sequence()
	legai:push(legselector)
	legai.loop = true
	
	local AIDemo = Parallel:new()
	AIDemo:push(bodyai)
	AIDemo:push(legai)
	return AIDemo
end


function AI.SpiderLostLeg(unit,target)
	local legseq = OrderWait(10)
	local legselector = Selector:new()
	local p = false
	legselector:push(function ()
		if p then
			if #unit.frontlegs > 2 then
				unit.ai = AI.Spider(unit,target)
			elseif #unit.frontlegs > 0 then
				unit.ai = AI.Spider2(unit,target)
			else
				jasonPhase2(unit)
			end
		else
			for i = 1,#unit.frontlegs do
				unit:swipe(i)
				Timer(1.5,1,function()unit:revertLeg(i)end,true,true)
			end
			p = true
		end
		return legseq
	end)
	local legai = Sequence()
	legai:push(legselector)
	legai.loop = true
	return legai
end

SpiderShotgunEffect = ShootMissileEffect:new()
SpiderShotgunEffect:addAction(function(point,caster,skill)
	local x,y = unpack(point)
	local Missile = ShotgunMissile:new(5,0.2,300,caster.x,caster.y,x,y)
	Missile.controller = caster.controller..'Missile'
	Missile.effect = BulletEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	local Missile = ShotgunMissile:new(5,0.2,300,caster.x+30*0.866*x+30*0.5*y,caster.y+30*0.5*x+30*0.866*y,x,y) -- complex number math
	Missile.controller = caster.controller..'Missile'
	Missile.effect = BulletEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	local Missile = ShotgunMissile:new(5,0.2,300,caster.x-30*0.866*x-30*0.5*y,caster.y-30*0.5*x-30*0.866*y,x,y)
	Missile.controller = caster.controller..'Missile'
	Missile.effect = BulletEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	TEsound.play({'sound/shoot2.wav','sound/shoot3.wav'})
end)

SpiderShotgun = Skill:subclass('SpiderShotgun')
function SpiderShotgun:initialize(unit)
	super.initialize(self)
	self.unit = unit
	self.name = 'SpiderShotgun'
	self.effecttime = 0.02
	self.casttime = 1
	self.damage = 25
	self.effect = SpiderShotgunEffect
end

function SpiderShotgun:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function SpiderShotgun:stop()
	self.time = 0
end


SpiderLeg = Unit:subclass('SpiderLeg')

function SpiderLeg:initialize(x,y,r)
	super.initialize(self,x,y,40,40)
	self.direction = -1
	self.r = r
	self.state = 'swipe'
	self.controller = 'enemy'
	self.maxhp = 2500
	self.hp = 100
end

function SpiderLeg:add(b,c)
	if b==GetCharacter() then
		if self.grabbing then return end
		print (self.state)
		if self.state == 'swipe' then
			
			self.shapes[1]:setMask(cc.player,cc.enemy,cc.terrain)
			self.shapes[2]:setMask(cc.player,cc.enemy,cc.terrain)
			Timer:new(2,1,function()
				if not self.shapes[1] then return end
				self.shapes[1]:setMask(cc.enemy,cc.terrain)
				self.shapes[2]:setMask(cc.enemy,cc.terrain)
			end,true,true
			)
			b:damage('Bullet',30,self)
		else
			self.state = 'swipe'
			self.grabbing = b
			b:addBuff(b_Stun:new(100,nil),5)
			b.state = 'auto'
			b.shape:setSensor(true)
			self.legunitjoint = love.physics.newDistanceJoint(self.bodies[2],b.body,self.bodies[2]:getX(),self.bodies[2]:getY(),b.x,b.y)
			self.legunitjoint:setLength(50)
			
			Timer:new(6,1,function()
				if self.hp<0 then return end
				self:bend(0,-10)
				self.grabbing = nil
				b.state = 'slide'
			end,true,true
			)
			Timer:new(7,1,function()
				if self.hp<0 then return end
				self.legunitjoint:destroy()
				self.legunitjoint = nil
				b.body:applyImpulse(-200,0)
				self:bend(1.5,10)
				b.shape:setSensor(false)
			end,true,true
			)
		end
	end
end

function SpiderLeg:createBody(world)
	self.r = self.r or 0
	local x,y = self.x-150*math.cos(self.r),self.y-150*math.sin(self.r)
	local ulbody = love.physics.newBody(world,x,y,20,20)
	local ulshape = love.physics.newRectangleShape(ulbody,0,0,300,30,0)
	ulbody:setAngle(self.r)
	local x,y = self.x+250*math.cos(self.r),self.y+250*math.sin(self.r)
	local blbody = love.physics.newBody(world,x,y,20,20)
	local blshape = love.physics.newRectangleShape(blbody,0,0,600,30,0)
	blbody:setAngle(self.r)
	local legjoint = love.physics.newRevoluteJoint(ulbody,blbody,self.x,self.y)
	print (map.world:getJointCount(),'joints!')
	ulshape:setData(self)
	blshape:setData(self)
	legjoint:setLimitsEnabled(true)
	legjoint:setLimits(-0.3,0.3)
	ulshape:setMask(cc.enemy,cc.terrain)
	blshape:setMask(cc.enemy,cc.terrain)
	ulshape:setCategory(cc.enemy)
	blshape:setCategory(cc.enemy)
	self.bodies = {ulbody,blbody}
	self.shapes = {blshape,ulshape}
	self.joint = legjoint
end

function SpiderLeg:preremove()
	for _,v in ipairs(self.shapes) do
		v:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
	end
end

function SpiderLeg:destroy()
	self.joint:destroy()
	print (map.world:getJointCount(),'joints!')
	for _,v in ipairs(self.shapes) do
		v:destroy()
	end
	for _,v in ipairs(self.bodies) do
		v:destroy()
	end
	self.shapes = {}
	self.bodies = {}
end

function SpiderLeg:bend(angle,speed)
	speed = speed or 2
	speed = speed * self.direction
	local legjoint = self.joint
	local lower,upper
	if self.direction>0 then lower,upper = 0,angle*self.direction
	else lower,upper=angle*self.direction,0 end
	print (speed,lower,upper)
	legjoint:setLimits(lower-0.05,upper+0.05)
	legjoint:setMotorEnabled(true)
	legjoint:setMotorSpeed(speed)
	legjoint:setMaxMotorTorque(5000)
	self.bodies[1]:wakeUp()
end

function SpiderLeg:update(dt)
	for k,v in pairs(self.buffs) do
	if type(v)=='number' and v>=0 then
		self.buffs[k] = v-dt
		if self.buffs[k]<=0 then
			self.buffs[k]=nil
			if k.stop then k:stop(self) end
		end
	end
		if k.buff then
			k:buff(self,dt)
		end
	end
	self.x,self.y = self.bodies[2]:getPosition()
end


function SpiderLeg:kill(killer)
	super.kill(self,killer)
--	map:removeUnit(self)
	map:addUnit(LegDead:new(self.x,self.y))
end


requireImage('assets/spiderboss/frontleg.png','spiderfrontleg')
requireImage('assets/spiderboss/backleg.png','spiderbackleg')
function SpiderLeg:_draw()
	local x,y = self.bodies[1]:getPosition()
	local r = self.bodies[1]:getAngle()
	love.graphics.draw(img.spiderbackleg,x,y,r,1.2,1.2,150,22.5)
	local x,y = self.bodies[2]:getPosition()
	local r = self.bodies[2]:getAngle()
	love.graphics.draw(img.spiderfrontleg,x,y,r,1.5,1.5,200,22.5)
	love.graphics.setColor(255,255,255)
end

SpiderBlade = Unit:subclass('SpiderBlade')

requireImage('assets/spiderboss/spiderblade.png','spiderblade')
function SpiderBlade:initialize(x,y)
	super.initialize(self,x,y,40,40)
	self.controller = 'enemy'
end

function SpiderBlade:damage()
end

function SpiderBlade:add(b,coll)
	if b:isKindOf(Unit) and b:isEnemyOf(self) then
		TEsound.play{'sound/sword1.wav','sound/sword2.wav','sound/sword3.wav'}
		b:damage('Bullet',3,self)
	end
end

function SpiderBlade:createBody(world)
	local bladecount = 12
	local anglemulti = math.pi*2/12
	self.body = love.physics.newBody(world,self.x,self.y,10,10)
	self.shapes = {}
	for i=1,bladecount do
		local shape = love.physics.newRectangleShape(self.body,120*math.cos(anglemulti*i),120*math.sin(anglemulti*i),80,10,anglemulti*i)
		shape:setData(self)
		shape:setCategory(cc.enemy)
		shape:setMask(cc.enemy,cc.terrain)
		table.insert(self.shapes,shape)
		shape:setSensor(true)
	end
end

function SpiderBlade:update(dt)
	for k,v in pairs(self.buffs) do
	if type(v)=='number' and v>=0 then
		self.buffs[k] = v-dt
		if self.buffs[k]<=0 then
			self.buffs[k]=nil
			if k.stop then k:stop(self) end
		end
	end
		if k.buff then
			k:buff(self,dt)
		end
	end
	self.x,self.y = self.body:getPosition()
end

function SpiderBlade:_draw()
	local bladecount = 12
	local anglemulti = math.pi*2/12
	local x,y = self.body:getPosition()
	local r = self.body:getAngle()
	for i=1,bladecount do
		love.graphics.draw(img.spiderblade,x+120*math.cos(anglemulti*i+r),y+120*math.sin(anglemulti*i+r),r+anglemulti*i,1,1,20,10)
	end
end

SpiderBody = Unit:subclass('SpiderBody')

function SpiderBody:initialize(x,y)
	super.initialize(self,x,y,40,40)
end

function SpiderBody:damage()end

function SpiderBody:createBody(world)
	self.body = love.physics.newBody(world,self.x,self.y,300,0)
	self.shape = love.physics.newCircleShape(self.body,0,0,120)
	self.shape:setData(self)
	self.shape:setCategory(cc.enemy)
	self.shape:setMask(cc.enemy,cc.terrain)
	self.shape:setSensor(true)
end

requireImage('assets/spiderboss/body.png','spiderbody')

function SpiderBody:_draw()
	local x,y = self.body:getPosition()
	local r = self.body:getAngle()
	love.graphics.draw(img.spiderbody,x,y,r,1.5,1.5,106.5,78.5)
end

SpiderBoss = Unit:subclass('SpiderBoss')

function SpiderBoss:initialize(x,y)
	super.initialize(self,x,y,40,100)
	self.hp = 5000
	self.maxhp = 5000
	self.skills = {
		missile = SeekerMissileLaunch_alt:new(self),
		pistol = SpiderPistol(self),
		spiral = SpiderSpiral(self),
		gun = SpiderShotgun(self),
		charge = SpiderCharge(self)
	}
	self.lostlegtrig = Trigger:new(function(trig,event)
		if event.unit:isKindOf(SpiderLeg) then
			self.ai = AI.SpiderLostLeg(self,GetCharacter())
			for i=1,#self.frontlegs do
				if self.frontlegs[i][1] == event.unit then
					local leg,joint,_ = unpack(self.frontlegs[i])
					joint:destroy()
					table.remove(self.frontlegs,i)
					i = i-1
				end
			end
		end
	end)
	self.lostlegtrig:registerEventType('death')
	self.frontlegs = {} 
end

function SpiderBoss:createBody(world)
	self.spiderbody = SpiderBody:new(self.x,self.y)
	self.spiderblade = SpiderBlade:new(self.x,self.y)
	map:addUnit(self.spiderbody)
--	self.spiderbody.shape:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16) -- to prevent the collision when blade is added to the map
	map:addUnit(self.spiderblade)
	print (map.world:getJointCount(),'joints!')
	self.headbladejoint = love.physics.newRevoluteJoint(self.spiderbody.body,self.spiderblade.body,self.x,self.y)
	self.headbladejoint:setMotorEnabled(true)
	self.headbladejoint:setMotorSpeed(5)
	self.headbladejoint:setMaxMotorTorque(5000) -- To make blade rotate
	self.spiderbody.body:wakeUp() -- in case it is put to sleep
	self.backlegs = {}
	self.frontlegs = {}
	d = -1
	for i,angle in ipairs{-math.pi/3,-2/3*math.pi,-math.pi/2.5,-math.pi*1.5/2.5} do -- create Two back legs
		local leg = SpiderLeg(self.x+300*math.cos(angle),self.y+300*math.sin(angle),angle)
		map:addUnit(leg)
		d = d* -1
		leg.direction = d
		leg:bend(1.5,2)
		local joint = love.physics.newRevoluteJoint(self.spiderbody.body,leg.bodies[1],self.x,self.y)
		print (map.world:getJointCount(),'joints!')
		joint:setLimitsEnabled(true)
		print (angle,'is the limit angle')
		joint:setLimits(angle-0.05,angle+0.05)
		table.insert(self.backlegs,{leg,joint})
		leg.damage = function()end
	end
	-- building front legs(AI controllable)
	
	for i,angle in ipairs{-math.pi/5,math.pi/5,-0.2,0.2} do -- create Two back legs
		local leg = SpiderLeg(self.x+300,self.y,0)
		map:addUnit(leg)
		d = d* -1
		leg.direction = d
		leg:bend(1.5,2)
		local joint = love.physics.newRevoluteJoint(self.spiderbody.body,leg.bodies[1],self.x,self.y)
		print (map.world:getJointCount(),'joints!')
		joint:setLimitsEnabled(true)
		print (angle,'is the limit angle')
		joint:setLimits(angle-0.05,angle+0.05)
		table.insert(self.frontlegs,{leg,joint,angle})
	end
	
	for i,v in ipairs(self.backlegs) do -- revert mask
---		v[1].shapes[1]:setMask(1)
	end
	for i,v in ipairs(self.frontlegs) do -- revert mask
--		v[1].shapes[1]:setMask(1)
	end
	self.body = self.spiderbody.body
	self.shape = self.spiderbody.shape
	if self.r then 
		self.body:setAngle(self.r)
	end
end

function SpiderBoss:solidifyBacklegs()
	-- make the back legs impossible to move
	for i,v in ipairs(self.backlegs) do
		v[1].bodies[2]:setMass(0,0,500,0)
		local angle = v[2]:getLimits()
		v[2]:setLimits(angle-0.2,angle)
	end
end

function SpiderBoss:stab(unit,leg)
if not self.frontlegs[leg] then return end
	leg,joint,angle = unpack(self.frontlegs[leg])
	local angle2 = math.atan2(unit.y-self.y,unit.x-self.x)+self.body:getAngle()
	local direction = 1
	if angle2<angle then
		direction = -1
		angle2,angle = angle,angle2
	end
	print (angle,angle2)
	joint:setMaxMotorTorque(5000)
	joint:setMotorSpeed(4*direction)
	joint:setMotorEnabled(true)
	joint:setLimits(angle,angle2)
	leg:bend(0,-10)
	leg.state = 'grab'
end

function SpiderBoss:revertLeg(leg)
	if not self.frontlegs[leg] then return end
	leg,joint,angle = unpack(self.frontlegs[leg])
	joint:setLimits(angle-0.05,angle+0.05)
	leg:bend(1.5,2)
	leg.state = 'swipe'
end

function SpiderBoss:swipe(leg)
if not self.frontlegs[leg] then return end
	leg,joint,angle = unpack(self.frontlegs[leg])
	local lower,upper = joint:getLimits()
	
	joint:setMaxMotorTorque(5000)
	joint:setMotorEnabled(true)
	if leg.direction < 0 then
		joint:setLimits(0,1.58)
		joint:setMotorSpeed(4)
	else
		joint:setLimits(-1.58,0)
		joint:setMotorSpeed(-4)
	end
	leg:bend(0,-10)
	leg.state = 'swipe'
end

function SpiderBoss:drag(leg)
if not self.frontlegs[leg] then return end
	leg,joint,angle = unpack(self.frontlegs[leg])
	local lower,upper = joint:getLimits()
	
	joint:setMaxMotorTorque(5000)
	joint:setMotorEnabled(true)
	if leg.direction < 0 then
		joint:setLimits(0,1.58)
		joint:setMotorSpeed(4)
	else
		joint:setLimits(-1.58,0)
		joint:setMotorSpeed(-4)
	end
	leg:bend(2.7,10)
end

function SpiderBoss:update(dt)
	super.update(self,dt)
	self.x,self.y=self.spiderbody.body:getPosition()
end

function SpiderBoss:draw()
	for i,v in ipairs(self.frontlegs) do
		v[1]:_draw()
	end
	for i,v in ipairs(self.backlegs) do 
		v[1]:_draw()
	end
	self.spiderbody:_draw()
	self.spiderblade:_draw()
end

function SpiderBoss:enableAI(ai)
	self.ai = ai or AI.Spider(self,GetCharacter())
end

function SpiderBoss:getHP()
	local hp = self.hp
	for i,v in ipairs(self.frontlegs) do
		hp = hp + v[1].hp
	end
	return hp
end

function SpiderBoss:getHPPercent()
	return self:getHP()/15000
end

seekermissilelauncheffect_alt = ShootMissileEffect:new()
seekermissilelauncheffect_alt:addAction(function (unit,caster,skill)
	for _,r in ipairs{caster.body:getAngle()-1.57,caster.body:getAngle()+1.57} do
		local x,y = displacement(caster.x,caster.y,r,30)
		local missile = SeekerMissile:new(x,y,caster.controller)
		missile:setTarget(unit)
		map:addUnit(missile)
		missile.body:applyImpulse(math.cos(r)*100,math.sin(r)*100)
		missile:enableAI()
		missile.skills.explode.damage = 30
		missile.hp = 50
	end
end)


SeekerMissileLaunch_alt = ActiveSkill:subclass('SeekerMissileLaunch_alt')
function SeekerMissileLaunch_alt:initialize(unit)
	super.initialize(self)
	self.unit = unit
	self.effect = seekermissilelauncheffect_alt
	self.casttime = 3
end

function SeekerMissileLaunch_alt:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function SeekerMissileLaunch_alt:geteffectinfo()
	return GetOrderUnit(),self,self
end

SpiderSpiralEffect = UnitEffect:new()
SpiderSpiralEffect:addAction(function(unit,caster,skill)
	local shots = skill.shots
	function fire(timer)
		local cosx,sinx = math.cos(math.pi/shots*timer.count*2),math.sin(math.pi/shots*timer.count*2)
		PistolEffect:effect({cosx,sinx},caster,unit.skills.pistol)
	end
	local t = Timer:new(0.05,shots*3,fire,true)
	t.selfdestruct = true
end)

SpiderSpiral = ActiveSkill:subclass('SpiderSpiral')
function SpiderSpiral:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'SpiderSpiral'
	self.effecttime = -1
	self.effect = SpiderSpiralEffect
	self.cd = 2
	self.cdtime = 0
	self.shots = 25
	self.available = true
end

function SpiderSpiral:active()
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

SpiderPistol = Skill:subclass('SpiderPistol')
function SpiderPistol:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.bullettype = Bullet
	self.name = 'Pistol'
	self.effecttime = 0.1
	self.damage = 15
	self.effect = PistolEffect
	self.bulleteffect = BulletEffect
	self.bullettype = Bullet
end


LegDead = Object:subclass('LegDead')
function LegDead:initialize(x,y)
	self.x,self.y = x,y
	self.time = 3
	self.bodies = {}
	self.shape = {}
	self.dt = 0
end

function LegDead:update(dt)
	self.dt = self.dt + dt
	if self.dt> self.time then
		map:removeUnit(self)
	end
end

function LegDead:preremove()
	for k,v in pairs(self.shape) do
		v:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
	end
	self.preremoved = true
end

function LegDead:destroy()
	if self.preremoved then
		for k,v in pairs(self.shape) do
			v:destroy()
		end
		for k,v in pairs(self.bodies) do
			v:destroy()
		end
	else
	end
end

function LegDead:createBody(world)
	for i=1,20 do
		local x,y = self.x+math.random(-150,150),self.y+math.random(-150,150)
		local b = love.physics.newBody(world,x,y,5,5)
		local s = love.physics.newRectangleShape(b,0,0,32,32)
		b:setAngle(math.random()*math.pi)
		b:applyImpulse((x-self.x)/10,(y-self.y)/10)
		category,masks = unpack(typeinfo['dead'])
		s:setCategory(category)
		s:setMask(unpack(masks))
		table.insert(self.bodies,b)
		table.insert(self.shape,s)
	end
end

local udeadquad = love.graphics.newQuad(0,0,0,0,400,47)
local bdeadquad = love.graphics.newQuad(0,0,0,0,300,45)

function LegDead:draw()
	love.graphics.setColor(255,255,255,math.max(0,255*(1-self.dt/self.time)))
	for i=1,12 do
		local unit = self.bodies[i]
		udeadquad:setViewport(i*32,0,32,32)
		love.graphics.drawq(img.spiderfrontleg,udeadquad,unit:getX(),unit:getY(),unit:getAngle(),1,1,16,16)
	end
	for i=1,8 do
		local unit = self.bodies[i]
		udeadquad:setViewport(i*32,0,32,32)
		love.graphics.drawq(img.spiderbackleg,bdeadquad,unit:getX(),unit:getY(),unit:getAngle(),1,1,16,16)
	end
	love.graphics.setColor(255,255,255,255)
end