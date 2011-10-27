DProbe = Probe:subclass'DProbe'
function DProbe:add(b,coll)
	self.unit:hit(b)
	self.add = nil
end

function DProbe:draw()
	love.graphics.circle('fill',self.body:getX(),self.body:getY(),self.r,10)
end


function DProbe:createBody(world)
	local x,y = self.start.x,self.start.y
	self.body = love.physics.newBody(world,x,y,0.0001,1)
	self.shape = love.physics.newCircleShape(self.body,0,0,self.r)
	self.body:setBullet(true)
	self.shape:setCategory(cc.enemymissile)
	self.shape:setMask(cc.playermissile,cc.enemymissile,cc.enemy)
	x,y = unpack(self.direction)
	x,y = normalize(x,y)
	self.body:setLinearVelocity(x*2000,y*2000)
	self.shape:setData(self)
end

StealthNormal = Object:subclass'StealthNormal'
function StealthNormal:initialize(unit,target)
	self.unit = unit
	self.target = target
	self.spotvalue = 0
	self.alertlevel = 0
	self.visionrange = 1.1
	self.dt = 0
	self.detectrate = 0.05
end

function StealthNormal:fireDetector()
	local r = self.unit:getAngle()
	assert(r)
	local fireangle = math.random()*self.visionrange-self.visionrange/2
	local detector = DProbe(self,self.unit,{math.cos(fireangle),math.sin(fireangle)},16)
	map:addUnit(detector)
end

function StealthNormal:hit(unit)
	if unit == self.target then
		self.alertlevel = self.alertlevel + 0.1
	end
	print (self.alertlevel)
end

function StealthNormal:process(dt)
	self.dt = self.dt + dt
	if self.dt > self.detectrate then
		self.dt = self.dt - self.detectrate
		self:fireDetector()
	end
	self.alertlevel = self.alertlevel - dt
	return STATE_ACTIVE,dt
end
