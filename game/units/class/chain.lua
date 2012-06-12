ChainSegment = Object:subclass('ChainSegment')
requireImage('assets/swift/link.png','link')
requireImage('assets/swift/linkend.png','linkend')
img.link:setWrap('repeat','repeat')
local linkquad = love.graphics.newQuad(0,0,20,10,20,10)
local chainstyle = {
	default = {
		update = function(self,dt)
			if self.isend then
				self.delegate.p:update(dt)
				self.delegate.p:setPosition(self.x,self.y)
			end
		end,
		draw = function (self)
			if self.isend then
				love.graphics.draw(img.linkend,self.x,self.y,self.r,1,1,10,5)
				love.graphics.draw(self.delegate.p)
			else
				love.graphics.draw(img.link,self.x,self.y,self.r,1,1,10,5)
			end
		end,
		update_blur = function(self,dt)
			self.dt = self.dt + dt
		end,
		draw_blur = function(self)
			if self.isend then
				love.graphics.draw(self.delegate.p)
			end
			linkquad:setViewport(self.dt*240,0,20,10)
			love.graphics.drawq(img.link,linkquad,self.x,self.y,self.r,1,1,10,5)
		end,
	}
}
function ChainSegment:initialize(delegate,chainindex,isend)
	assert(delegate)
	self.delegate = delegate
	self.chainindex = chainindex
	self.isend = isend
	self.dt = 0
	self.x,self.y,self.r = 0,0,0
end

function ChainSegment:add(b,coll)
	self.delegate.segmentCollide(b,coll,self)
end

function ChainSegment:createBody(world,x,y,r,prev,cat,mask)
	assert(world)
	assert(prev)
	self.body = love.physics.newBody(world,x,y,0.1,0.1)
	self.shape = love.physics.newRectangleShape(self.body,0,0,10,5)
	self.body:setAngle(r)
	self.updatedata = true
	self.shape:setCategory(cat) -- it behaves like one
	self.shape:setMask(unpack(mask))
	-- connect with previous segment/unit
	self.prev = prev
	self.joint = love.physics.newRevoluteJoint(self.prev.body,self.body,self.prev.body:getPosition())
	self.shape:setSensor(true)
	self.joint:setLimitsEnabled(true)
	self.joint:setLimits(-0.1,0.1)
end

function ChainSegment:join()
	self.body:setMass(0,0,0.1,0.1)
end

function ChainSegment:brk()
	self.body:setMass(0,0,0.001,0.001)
end

function ChainSegment:update(dt)
	if self.updatedata then
		self.shape:setData(self)
		self.updatedata = nil
	end
	self.x,self.y = self.body:getPosition()
	self.r = self.body:getAngle()
	self.delegate.style.update(self,dt)
end

function ChainSegment:update_blur(dt)
	if self.updatedata then
		self.shape:setData(self)
		self.updatedata = nil
	end
	self.x,self.y = self.body:getPosition()
	self.r = self.body:getAngle()
	self.delegate.style.update_blur(self,dt)
end

function ChainSegment:draw()
	self.delegate.style.draw(self)
	--love.graphics.draw(img.link,self.x,self.y,self.r,1,1,10,5)
end

function ChainSegment:setSensor(sensor)
	self.shape:setSensor(sensor)
end

function ChainSegment:draw_blur()
	self.delegate.style.draw_blur(self)
end

function ChainSegment:preremove()
	self.shape:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
    self.preremoved = true
end

function ChainSegment:destroy()
	if self.preremoved then
        if self.shape then self.shape:destroy() end
        if self.body then self.body:destroy() end
		self.shape = nil
		self.body = nil
    end
end

Chain = Object:subclass('Chain')
function Chain:initialize(unit,maxsegment,length)
	assert(unit)
	maxsegment = maxsegment or 20
	length = length or maxsegment
	self.unit = unit
	self.segs = {}
	for i=1,maxsegment do
		local seg = ChainSegment(self,i,i==maxsegment)
		self.segs[i] = seg
	end
	self:setStyle('default')
	local p = love.graphics.newParticleSystem(img.pulse,1000)
	p:setEmissionRate(options.particlerate*200)
	p:setSpeed(0, 0)
	p:setGravity(0)
	p:setSize(0.2,0.1)
	p:setColor(0, 0, 0, 255, 0, 0, 0, 0)
	p:setPosition(400, 300)
	p:setLifetime(3600)
	p:setParticleLife(1)
	p:start()
	self.p = p
	self.chainmask = {cc.player,cc.playermissile,cc.enemymissile}
	self.cat = cc.playermissile
--	self.blur = true
end

function Chain:setChainMask(mask,cat)
	self.chainmask = mask
	self.cat = cat
--	self:setLength(self.length)
end

function Chain:setStyle(style)
	self.style = chainstyle[style]
end

function Chain:createBody(world)
	assert(world)
	local x,y = self.unit.x,self.unit.y
	local prev = self.unit
	assert(prev)
	for i,seg in ipairs(self.segs) do
		-- chains start off with angle 0 (pointing right)
		x = x + 20
		seg:createBody(world,x,y,0,prev,self.cat,self.chainmask)
		prev = seg
	end
	self:setLength(#self.segs)
end

function Chain:preremove()
	for i,v in ipairs(self.segs) do
		v:preremove()
	end
end

function Chain:destroy()
	for i,v in ipairs(self.segs) do
		v:destroy()
	end
end

function Chain:update(dt)
	if self.blur then
		for i,seg in ipairs(self.segs) do
			seg:update_blur(dt)
		end
	else
		for i,seg in ipairs(self.segs) do
			seg:update(dt)
		end
	end
	if self.attachjoint then
		local seg = self.segs[self.length]
		self.attachjoint:setTarget(seg.x,seg.y)
	end
end

function Chain:segmentCollide()
end

function Chain:draw()
	if self.blur then
		for i=1,self.length do
			self.segs[i]:draw_blur()
		end
	else
		for i=1,self.length do
			self.segs[i]:draw()
		end
	end
end

function Chain:swipe(angle,range,speed)
	local joint = self.segs[1].joint
	joint:setLimitsEnabled(true)
	joint:setLimits(angle-range/2,angle+range/2)
	joint:setMotorEnabled(true)
	joint:setMotorSpeed(speed)
	joint:setMaxMotorTorque(5000)
	local r
	if speed>0 then
		r = angle-range/2
	else
		r = angle+range/2
	end
	self:setAngle(angle)
end

function Chain:revert()
	local joint = self.segs[1].joint
	joint:setLimitsEnabled(false)
	joint:setMotorEnabled(false)
	self:setCollisionCallback()
end

function Chain:tornado(speed)
	local joint = self.segs[1].joint
	joint:setLimitsEnabled(false)
	joint:setMotorEnabled(true)
	joint:setMotorSpeed(speed)
	joint:setMaxMotorTorque(5000)
end

function Chain:setAngle(angle)
	local sx,sy = 20*math.cos(angle),20*math.sin(angle)
	for i,seg in ipairs(self.segs) do
		seg.body:setLinearVelocity(0,0)
		seg.body:setAngularVelocity(0)
		seg.body:setPosition(sx*i+self.unit.x,sy*i+self.unit.y)
		seg.body:setAngle(angle)
	end
end

function Chain:stab(angle)
	local joint = self.segs[1].joint
	joint:setLimitsEnabled(true)
	joint:setMotorEnabled(false)
	joint:setLimits(angle-0.05,angle+0.05)
	self:setAngle(angle)
end

function Chain:setCollisionCallback(add)
	self.segmentCollide = add or function()end
end

function Chain:setLength(length)
	assert(length<=#self.segs)
	assert(length>0)
	self.length = length
	for i=1,length do
		local seg = self.segs[i]
		seg.shape:setMask(unpack(self.chainmask))
		seg.isend = nil
		seg:join()
	end
	for i=length+1,#self.segs do
		local seg = self.segs[i]
		seg.shape:setMask(unpack(cc.all))
		seg.isend = nil
		seg:brk()
	end
	self.segs[self.length].isend = true
end

function Chain:setSensor(...)
	for i,v in ipairs(self.segs) do
		v:setSensor(...)
	end
end

function Chain:attach(b)
	assert(b.body)
	self.attachment = b
	local seg = self.segs[self.length]
	self.attachjoint = love.physics.newMouseJoint(b.body,seg.x,seg.y)
end

function Chain:unattach()
	assert(self.attachment)
	local b = self.attachment
	self.attachjoint:destroy()
	self.attachjoint = nil
	self.attachment = nil
end