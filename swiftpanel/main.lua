require 'MiddleClass'

love.graphics.setColor(255,252,160)

wheelpic = love.graphics.newImage'wheel.png'
Wheel = Object:subclass'Wheel'
function Wheel:initialize(x,y,world)
	self.body = love.physics.newBody(world,x,y)
	self.shape = love.physics.newCircleShape(self.body,0,0,128)
end

local wheelratio = 255/96
function Wheel:draw(r)
	local x,y = self.body:getPosition()
--	love.graphics.circle('fill',x,y,128)
	love.graphics.draw(wheelpic,x,y,r,wheelratio,wheelratio,48,48)
end
SwiftPanel = Object:subclass'SwiftPanel'
function SwiftPanel:initialize()
	local world = love.physics.newWorld(-2000,-2000,2000,2000)
	world:setMeter(512)
	world:setGravity(0,5120)
	self.world = world
	
	-- The wheels
	self.wheel1 = Wheel(128,128,world)
	
	self.wheel2 = Wheel(0,0,world)
	self.wheelangle = 0

	-- The Particles
	self.shapes = {}
	self.bodies = {}
end

function SwiftPanel:createSparkle()
	local body = love.physics.newBody(self.world,128,0,1)
	local shape = love.physics.newCircleShape(body,0,0,4)
	table.insert(self.shapes,shape)
	table.insert(self.bodies,body)
	body:applyImpulse(6,math.random()*10)
end

function SwiftPanel:update(dt)
	self.world:update(dt)
	if self.d_shapes then
		for i,v in ipairs(self.d_shapes) do
			v:destroy()
		end
		for i,v in ipairs(self.d_bodies) do
			v:destroy()
		end
		self.d_shapes = nil
		self.d_bodies = nil
	end
	if self.activetime > 0 then
		self.activetime = self.activetime - dt
		if self.activetime > 2 then
			self:createSparkle()
			self:createSparkle()
		end
		if self.activetime < 0 then
			for i,v in ipairs(self.shapes) do
				v:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
			end
			self.d_bodies = self.bodies
			self.d_shapes = self.shapes
			self.bodies = {}
			self.shapes = {}
		end
	else
		
	end
	self.wheelangle = self.wheelangle + (self.activetime * 5 + 1) *dt
end

function SwiftPanel:activateWheel(time)
	self.activetime = time
end

function SwiftPanel:draw()
love.graphics.setColor(255,255,255)
	self.wheel1:draw(self.wheelangle)
	self.wheel2:draw(self.wheelangle)
	love.graphics.setColor(166,202,255)
--	love.graphics.setColor(255,252,160)
	for i,v in ipairs(self.bodies) do
		local x,y = v:getPosition()
		love.graphics.circle('fill',x,y,4)
	end
end

sp = SwiftPanel()
sp:activateWheel(5)

function love.draw()
	love.graphics.translate(100,100)
	love.graphics.scale(0.5)
	sp:draw()
end

function love.update(dt)
	sp:update(dt/2)
end

function love.keypressed()
	sp:activateWheel(5)
end