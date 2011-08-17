require ('objectlua.init.lua')
Object=objectlua.Object
Pulse = Object:subclass('Pulse')
function Pulse:initialize(x,y)
	local pulse = love.graphics.newImage("pulse.png")
	local p = love.graphics.newParticleSystem(pulse, 1000)
	p:setEmissionRate(200)
	p:setSpeed(0, 0)
	p:setGravity(0)
	p:setSize(0.1, 0.1)
	p:setColor(255, 255, 255, 255, 255, 255, 255, 0)
	p:setPosition(400, 300)
	p:setLifetime(1)
	p:setParticleLife(1)
--	p:setDirection(0)
--	p:setSpread(360)
--	p:setRadialAcceleration(-2000)
--	p:setTangentialAcceleration(1000)
	p:stop()
	self.system=p
end

x,y=0,300
function getPosition(dt)
	x,y=100*dt+x,y
	return x,y
end

function Pulse:update(dt)
	self.system:setPosition(getPosition(dt))
	self.system:start()
	self.system:update(dt)
end

function Pulse:draw()
	love.graphics.draw(self.system,0,0)
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