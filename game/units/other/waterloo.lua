Gate = Unit:subclass('Gate')
requireImage('assets/doodad/gate.png','gate')
local dq = love.graphics.newQuad(0,0,32,32,128,32)
function Gate:initialize(x,y,controller)
	super.initialize(self,x,y,100,0)
	self.hp = 5000
	self.controller = controller
	self.state = 'slide'
end

function Gate:createBody(world)
	self.body = love.physics.newBody(world,self.x,self.y,self.mass,self.mass)
	self.shape = love.physics.newRectangleShape(self.body,0,0,128,32)
	if self.controller then
		category,masks = unpack(typeinfo[self.controller])
		self.shape:setCategory(category)
		self.shape:setMask(unpack(masks))
	end
	self.shape:setData(self)
	if self.r then
		self.body:setAngle(self.r)
	end
end

function Gate:damage(type,amount,source)
	super.damage(self,type,amount,source)
end

function Gate:draw()
	love.graphics.draw(img.gate,self.x,self.y,self.body:getAngle(),1,1,64,16)
	self:drawBuff()
end

function Gate:kill(killer)
	super.kill(self,killer)
	map:addUnit(GateDead:new(self.x,self.y))
end

GateDead = Object:subclass('GateDead')
function GateDead:initialize(x,y)
	self.x,self.y = x,y
	self.time = 3
	self.bodies = {}
	self.shape = {}
	self.dt = 0
end

function GateDead:update(dt)
	self.dt = self.dt + dt
	if self.dt> self.time then
		map:removeUnit(self)
	end
end

function GateDead:preremove()
	for k,v in pairs(self.shape) do
		v:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
	end
	self.preremoved = true
end

function GateDead:destroy()
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

function GateDead:createBody(world)
	for i=1,4 do
		local x,y = self.x+math.random(-100,100),self.y+math.random(-30,30)
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

function GateDead:draw()
	love.graphics.setColor(255,255,255,math.max(0,255*(1-self.dt/self.time)))
	for k,unit in ipairs(self.bodies) do
		deadquad:setViewport(k*32,0,32,32)
		love.graphics.drawq(img.gate,dq,unit:getX(),unit:getY(),unit:getAngle(),1,1,16,16)
	end
	love.graphics.setColor(255,255,255,255)
end