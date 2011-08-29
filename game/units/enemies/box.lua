Box = Unit:subclass('Box')
requireImage('box.png','boxpic')
deadquad = love.graphics.newQuad(0,0,32,8,32,32)
function Box:initialize(x,y,controller)
	super.initialize(self,x,y,16,100)
	self.hp = 100
	self.controller = controller
	self.state = 'slide'
end

function Box:damage(type,amount,source)
	super.damage(self,type,amount,source)
end

function Box:draw()
	love.graphics.draw(img.boxpic,self.x,self.y,self.body:getAngle(),1,1,16,16)
	self:drawBuff()
end

function Box:kill(killer)
	super.kill(self,killer)
--	map:removeUnit(self)
	map:addUnit(BoxDead:new(self.x,self.y))
end

BoxDead = Object:subclass('BoxDead')
function BoxDead:initialize(x,y)
	self.x,self.y = x,y
	self.time = 3
	self.bodies = {}
	self.shape = {}
	self.dt = 0
end

function BoxDead:update(dt)
	self.dt = self.dt + dt
	if self.dt> self.time then
		map:removeUnit(self)
	end
end

function BoxDead:preremove()
	for k,v in pairs(self.shape) do
		v:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
	end
	self.preremoved = true
end

function BoxDead:destroy()
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

function BoxDead:createBody(world)
	for i=1,4 do
		local x,y = self.x+math.random(-30,30),self.y+math.random(-30,30)
		local b = love.physics.newBody(world,x,y,5,5)
		local s = love.physics.newRectangleShape(b,0,0,32,8)
		b:setAngle(math.random()*math.pi)
		b:applyImpulse((x-self.x)/10,(y-self.y)/10)
		category,masks = unpack(typeinfo['dead'])
		s:setCategory(category)
		s:setMask(unpack(masks))
		table.insert(self.bodies,b)
		table.insert(self.shape,s)
	end
end

function BoxDead:draw()
	love.graphics.setColor(255,255,255,math.max(0,255*(1-self.dt/self.time)))
	for k,unit in ipairs(self.bodies) do
		love.graphics.drawq(img.boxpic,deadquad,unit:getX(),unit:getY(),unit:getAngle(),1,1,16,4)
	end
	love.graphics.setColor(255,255,255,255)
end