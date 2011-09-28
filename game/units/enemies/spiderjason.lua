SpiderLeg = Unit:subclass('SpiderLeg')

function SpiderLeg:initialize(x,y,r)
	super.initialize(self,x,y,40,40)
	self.direction = -1
	self.r = r
end

function SpiderLeg:createBody(world)
	self.r = self.r or 0
	local x,y = self.x-150*math.cos(self.r),self.y-150*math.sin(self.r)
	local ulbody = love.physics.newBody(world,x,y,20,20)
	local ulshape = love.physics.newRectangleShape(ulbody,0,0,300,30,0)
	ulbody:setAngle(self.r)
	local x,y = self.x+250*math.cos(self.r),self.y+250*math.sin(self.r)
	local blbody = love.physics.newBody(world,x,y,20,20)
	local blshape = love.physics.newRectangleShape(blbody,0,0,500,30,0)
	blbody:setAngle(self.r)
	local legjoint = love.physics.newRevoluteJoint(ulbody,blbody,self.x,self.y)
	ulshape:setData(self)
	blshape:setData(self)
	legjoint:setLimitsEnabled(true)
	legjoint:setLimits(-0.3,0.3)
	ulshape:setMask(cc.enemy)
	blshape:setMask(cc.enemy)
	ulshape:setCategory(cc.enemy)
	blshape:setCategory(cc.enemy)
	self.bodies = {ulbody,blbody}
	self.shapes = {blshape,ulshape}
	self.joint = legjoint
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

requireImage('dot.png','dot')
function SpiderLeg:draw()
	local x,y = self.bodies[1]:getPosition()
	local r = self.bodies[1]:getAngle()
	love.graphics.draw(img.dot,x,y,r,300,30,0.5,0.5)
	love.graphics.setColor(255,0,0)
	local x,y = self.bodies[2]:getPosition()
	local r = self.bodies[2]:getAngle()
	love.graphics.draw(img.dot,x,y,r,500,30,0.5,0.5)
	love.graphics.setColor(255,255,255)
end

SpiderBlade = Unit:subclass('SpiderBlade')
	
function SpiderBlade:initialize(x,y)
	super.initialize(self,x,y,40,40)
end

function SpiderBlade:createBody(world)
	local bladecount = 12
	local anglemulti = math.pi*2/12
	self.body = love.physics.newBody(world,self.x,self.y,10,10)
	self.shapes = {}
	for i=1,bladecount do
		local shape = love.physics.newRectangleShape(self.body,120*math.cos(anglemulti*i),120*math.sin(anglemulti*i),40,10,anglemulti*i)
		shape:setData(self)
		shape:setCategory(3)
		shape:setMask(cc.enemy)
		table.insert(self.shapes,shape)
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

function SpiderBlade:draw()
	local bladecount = 12
	local anglemulti = math.pi*2/12
	local x,y = self.body:getPosition()
	local r = self.body:getAngle()
	for i=1,bladecount do
		love.graphics.draw(img.dot,x+120*math.cos(anglemulti*i+r),y+120*math.sin(anglemulti*i+r),r+anglemulti*i,40,10,0.5,0.5)
	end
end

SpiderBody = Unit:subclass('SpiderBody')

function SpiderBody:initialize(x,y)
	super.initialize(self,x,y,40,40)
end

function SpiderBody:createBody(world)
	self.body = love.physics.newBody(world,self.x,self.y,300,0)
	self.shape = love.physics.newCircleShape(self.body,0,0,120)
	self.shape:setData(self)
	self.shape:setCategory(cc.enemy)
end

--[[
function SpiderBody:update(dt)
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
]]

function SpiderBody:draw()
	local x,y = self.body:getPosition()
	local r = self.body:getAngle()
	love.graphics.draw(img.station,x,y,r,1,1,48,48)
end

SpiderBoss = Unit:subclass('SpiderBoss')
function SpiderBoss:initialize(x,y)
	super.initialize(self,x,y,40,100)
end

function SpiderBoss:createBody(world)
	self.spiderbody = SpiderBody:new(self.x,self.y)
	self.spiderblade = SpiderBlade:new(self.x,self.y)
	map:addUnit(self.spiderbody)
--	self.spiderbody.shape:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16) -- to prevent the collision when blade is added to the map
	map:addUnit(self.spiderblade)
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
		joint:setLimitsEnabled(true)
		print (angle,'is the limit angle')
		joint:setLimits(angle-0.05,angle+0.05)
		table.insert(self.backlegs,{leg,joint})
	end
	-- building front legs(AI controllable)
	
	for i,angle in ipairs{-math.pi/5,math.pi/5,-0.2,0.2} do -- create Two back legs
		local leg = SpiderLeg(self.x+300,self.y,0)
		map:addUnit(leg)
		d = d* -1
		leg.direction = d
		leg:bend(1.5,2)
		local joint = love.physics.newRevoluteJoint(self.spiderbody.body,leg.bodies[1],self.x,self.y)
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
	leg,joint,angle = unpack(self.frontlegs[leg])
	local angle2 = math.atan2(unit.y-self.y,unit.x-self.x)
	local direction = 1
	if angle2<angle then
		direction = -1
		angle2,angle = angle,angle2
	end
	joint:setMaxMotorTorque(5000)
	joint:setMotorSpeed(4*direction)
	joint:setMotorEnabled(true)
	joint:setLimits(angle,angle2+0.05)
	leg:bend(0,-10)
end

function SpiderBoss:revertLeg(leg)
	leg,joint,angle = unpack(self.frontlegs[leg])
	joint:setLimits(angle-0.05,angle+0.05)
	leg:bend(1.5,2)
end

function SpiderBoss:swipe(leg)
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
end

function SpiderBoss:drag(leg)
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
	love.graphics.setColor(0,0,255)
	love.graphics.circle('fill',self.x,self.y,100,30)
	love.graphics.circle('fill',GetCharacter().x,GetCharacter().y,30,30)
	love.graphics.setColor(255,255,255)
end