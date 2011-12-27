local ox,oy = 32,32
LightpuzzleUnit = Unit:subclass'LightpuzzleUnit'
function LightpuzzleUnit:initialize(...)
	super.initialize(self,...)
--	assert(map.l)
end

function LightpuzzleUnit:setLighterObject(obj)
	assert(self.map.l)
	assert(obj)
	self.map.l:addLighterObject(obj)
	self.l = obj
	obj.owner = self
end

function LightpuzzleUnit:update(dt)
	super.update(self,dt)
	self.l.x,self.l.y = self.body:getPosition()
	self.l.direction = self.body:getAngle()
end

UFilter = LightpuzzleUnit:subclass'UFilter'
function UFilter:initialize(x,y,controller)
	super.initialize(self,x,y,32,10)
	self.hp = 100
	self.maxhp = 100
	self.controller = controller
end
function UFilter:createBody(...)
	super.createBody(self,...)
	self:setLighterObject(Filter(self.x,self.y,{255,0,0}))
end
function UFilter:damage(type,amount,source)
end

function UFilter:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(img.guardian,self.x,self.y,self.body:getAngle(),1,1,ox,oy)
end

ULightSource = LightpuzzleUnit:subclass'ULightSource'
function ULightSource:initialize(x,y,controller)
	super.initialize(self,x,y,32,10)
	self.hp = 100
	self.maxhp = 100
	self.controller = controller
end
function ULightSource:createBody(...)
	super.createBody(self,...)
	self:setLighterObject(LightSource(self.x,self.y,{0,0,255},self.r))
end

function ULightSource:damage(type,amount,source)
end

function ULightSource:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(img.guardian,self.x,self.y,self.body:getAngle(),1,1,ox,oy)
end


ULightSensor = LightpuzzleUnit:subclass'ULightSensor'
function ULightSensor:initialize(x,y,controller)
	super.initialize(self,x,y,32,10)
	self.hp = 100
	self.maxhp = 100
	self.controller = controller
end
function ULightSensor:createBody(...)
	super.createBody(self,...)
	self:setLighterObject(LighterObject(self.x,self.y))
end
function ULightSensor:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(img.guardian,self.x,self.y,self.body:getAngle(),1,1,ox,oy)
end



UPortal = LightpuzzleUnit:subclass'UPortal'
function UPortal:initialize(x,y,controller)
	super.initialize(self,x,y,32,10)
	self.hp = 100
	self.maxhp = 100
	self.controller = controller
end
function UPortal:createBody(...)
	super.createBody(self,...)
	self:setLighterObject(Portal(self.x,self.y,self.body:getAngle()))
end
function UPortal:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(img.guardian,self.x,self.y,self.body:getAngle(),1,1,ox,oy)
end

UObstacle = LightpuzzleUnit:subclass'UObstacle'
function UObstacle:initialize(x,y,controller)
	super.initialize(self,x,y,32,10)
	self.hp = 100
	self.maxhp = 100
	self.controller = controller
end
function UObstacle:createBody(...)
	super.createBody(self,...)
	self:setLighterObject(Obstacle(self.x,self.y,10))
end

function UObstacle:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(img.guardian,self.x,self.y,self.body:getAngle(),1,1,ox,oy)
end


UMirror = LightpuzzleUnit:subclass'UMirror'
function UMirror:initialize(x,y,controller)
	super.initialize(self,x,y,32,10)
	self.hp = 100
	self.maxhp = 100
	self.controller = controller
end
function UMirror:createBody(...)
	super.createBody(self,...)
	self:setLighterObject(Mirror(self.x,self.y,self.body:getAngle()))
end
function UMirror:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(img.guardian,self.x,self.y,self.body:getAngle(),1,1,ox,oy)
end
