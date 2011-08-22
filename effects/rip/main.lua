require ('objectlua.init.lua')
Object=objectlua.Object
Pulse = Object:subclass('Pulse')
circle = love.graphics.newImage('circle.png')
function Pulse:initialize(x,y)
	local pulse = love.graphics.newImage("rip.png")
	local p = love.graphics.newParticleSystem(pulse, 1000)
	p:setEmissionRate(100)
	p:setSpeed(100, 200)
	p:setGravity(0)
	p:setSize(0.5, 0.25)
--	p:setColor(255, 122, 122, 255, 122, 122, 255, 0)
	p:setPosition(400, 300)
	p:setLifetime(0.5)
	p:setParticleLife(0.5)
	p:setDirection(0)
	p:setSpread(360)
	p:setRadialAcceleration(-500)
--	p:setTangentialAcceleration(1500)
	p:stop()
	self.system=p
	self.dt = 0
	self.time = 1
end

x,y=300,300
function getPosition(dt)
--	x,y=100*dt+x,y
	return love.mouse.getPosition()
end

function Pulse:update(dt)
	self.system:setPosition(getPosition(dt))
	self.dt = self.dt+dt
	if self.dt>self.time then
		self.dt = self.dt-self.time
	end
	self.system:start()
	self.system:update(dt)
end

function Pulse:draw()
	love.graphics.draw(self.system)
	local scale = self.dt/self.time
	local x,y = getPosition()
	love.graphics.draw(circle,x,y,0,0.2,0.2,128,128)
end

function love.load()
	p = Pulse:new(400,300)
end

function love.update(dt)
	p:update(dt)
end

function love.draw()
	p:draw()
end