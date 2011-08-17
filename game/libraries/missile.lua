Missile = Object:subclass('Missile')
function Missile:initialize(time,mass,vi,x,y,dx,dy,size)
	self.time,self.vi=time,vi
	self.x,self.y=x,y
	self.dx,self.dy = dx,dy
	self.dt = 0
	self.mass = mass or 5
	self.size = size or 10
end

function Missile:createBody(world)
	self.body = love.physics.newBody(world,self.x,self.y,self.mass,self.mass)
	self.shape = love.physics.newCircleShape(self.body,0,0,self.size)
	self.body:setLinearVelocity(self.dx*self.vi,self.dy*self.vi)
	self.body:setBullet(true)
	self.body:setAngle(math.atan2(self.dy,self.dx))
	if self.controller then
		local category,masks = unpack(typeinfo[self.controller])
		self.shape:setCategory(category)
		self.shape:setMask(unpack(masks))
	end	
	self.shape:setData(self)
end
function Missile:preremove()
	self.shape:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
    self.preremoved = true
end
function Missile:destroy()
    if self.preremoved then
        if self.shape then self.shape:destroy() end
        if self.body then self.body:destroy() end
		self.shape = nil
		self.body = nil
    end
end

function Missile:update(dt)
	self.dt = self.dt + dt
	self.x,self.y = self.body:getPosition()
	if self.dt> self.time then
		map:removeUnit(self)
	end
end

function Missile:draw()
	love.graphics.circle('line',self.x,self.y,5)
end
