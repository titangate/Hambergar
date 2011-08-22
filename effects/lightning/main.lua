require 'MiddleClass'
function math.clamp(x,lower,upper)
	return math.min(math.max(x,lower),upper)
end

local filesTable = love.filesystem.enumerate('lightning')
local lightningimage = {}
for i,v in ipairs(filesTable) do
	local file = 'lightning/'..v
	print (file)
	if love.filesystem.isFile(file) then
		table.insert(lightningimage,love.graphics.newImage(file))
	end
end
LightningImpact=Object:subclass('LightningImpact')
function LightningImpact:initialize(branch,scale,cycle,life,color,freq)
	self.branch = {}
	self.freq = freq or 1
	self.scale = scale or 1
--	self.branchlocation = {}
	for i=1,branch do
		table.insert(self.branch,lightningimage[math.random(#lightningimage)])
		local angle =math.pi/branch*2/i
--		table.insert(self.branchlocation,{math.cos(angle),math.sin(angle)})
	end
	self.dt=0
	self.cycle = cycle
	self.life = life
	self.color = color or {255,255,255,255}
end

function LightningImpact:update(dt)
	self.dt = self.dt + dt
	if self.dt > self.cycle then
		self.dt = self.dt - self.cycle
		for i=1,3 do
		self.branch[math.random(#self.branch)]={lightningimage[math.random(#lightningimage)], math.random() < self.freq}
	end
	end
	self.life = self.life - dt
	self.color[4] = math.clamp(self.life*511,0,255)
	if self.life <= 0 then
		self:destroy()
	end
end

function LightningImpact:destroy()
end

function LightningImpact:draw(x,y)
	love.graphics.setColor(unpack(self.color))
	for i=1,#self.branch do
		if self.branch[i][2] then
			local angle =math.pi/#self.branch*2*i
			love.graphics.draw(self.branch[i][1],x,y,angle,self.scale,self.scale,self.branch[i][1]:getWidth(),0)
		end
	end
	love.graphics.setColor(255,255,255,255)
end
local filesTable = love.filesystem.enumerate('beam')
local beamimage = {}
for i,v in ipairs(filesTable) do
	local file = 'beam/'..v
	print (file)
	if love.filesystem.isFile(file) then
		local i = love.graphics.newImage(file)
		i:setWrap('repeat','repeat')
		table.insert(beamimage,i)
	end
end
Bolt = Object:subclass('Bolt')
function Bolt:initialize(cycle,life,color)
	self.beam = lightningimage[math.random(#lightningimage)]
	self.cycle = cycle
	self.life = life
--	self.quad = love.graphics.newQuad(0,0,self.beam:getWidth(),self.beam:getHeight(),self.beam:getWidth(),self.beam:getHeight())
	self.color = color or {255,255,255,255}
	self.dt = 0
end

function Bolt:draw(x1,y1,x2,y2)
	love.graphics.setColor(unpack(self.color))
	local length = math.sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))
	local sx = length/self.beam:getHeight()
--	self.quad:setViewport(self.life*1000,self.beam:getHeight(),length,self.beam:getHeight())
	love.graphics.draw(self.beam,x1,y1,3.9+math.atan2(y2-y1,x2-x1),sx,sx,self.beam:getWidth())
	love.graphics.setColor(255,255,255,255)
end

function Bolt:update(dt)
	self.dt = self.dt + dt
	self.life = self.life - dt
	self.color[4] = math.clamp(self.life*511,0,255)
	if self.dt > self.cycle then
		self.dt = self.dt - self.cycle
		self.beam=lightningimage[math.random(#lightningimage)]
	end
end


Beam = Object:subclass('Beam')
function Beam:initialize(cycle,life,color)
	self.beam = beamimage[math.random(#beamimage)]
	self.cycle = cycle
	self.life = life
	self.quad = love.graphics.newQuad(0,0,self.beam:getWidth(),self.beam:getHeight(),self.beam:getWidth(),self.beam:getHeight())
	self.color = color or {255,255,255,255}
	self.dt = 0
end

function Beam:draw(x1,y1,x2,y2)
	love.graphics.setColor(unpack(self.color))
	local length = math.sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))
	self.quad:setViewport(self.life*1000,self.beam:getHeight(),length,self.beam:getHeight())
	love.graphics.drawq(self.beam,self.quad,x1,y1,math.atan2(y2-y1,x2-x1),1,0.5,0,self.beam:getHeight()/2)
	love.graphics.setColor(255,255,255,255)
end

function Beam:update(dt)
	self.dt = self.dt + dt
	self.life = self.life - dt
	self.color[4] = math.clamp(self.life*511,0,255)
	if self.dt > self.cycle then
		self.dt = self.dt - self.cycle
		self.beam=beamimage[math.random(#beamimage)]
	end
end

li=LightningImpact:new(10,0.10,0.05,2,{255,0,0},0.3)
beam = Bolt:new(0.05,2,{255,0,0})
function love.load()
	love.graphics.setBackgroundColor(255,255,255,255)
end

function love.update(dt)
	li:update(dt)
	beam:update(dt)
end
gx,gy = 0,0
function love.draw()
	li:draw(gx,gy)
	beam:draw(400,300,gx,gy)
end

function love.mousepressed(x,y,b)
	beam = Bolt:new(5,2,{255,0,0})
	gx,gy=x,y
	li.life,beam.life = 1,1
end