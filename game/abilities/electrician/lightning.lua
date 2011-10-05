
local filesTable = love.filesystem.enumerate('lightning')
local lightningimage = {}
for i,v in ipairs(filesTable) do
	local file = 'lightning/'..v
	if love.filesystem.isFile(file) then
		table.insert(lightningimage,love.graphics.newImage(file))
	end
end
LightningImpact=Object:subclass('LightningImpact')
function LightningImpact:initialize(pos,branch,scale,cycle,life,color,freq)
	self.pos=pos
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
	if self.pos then
		self.x,self.y=self.pos.x,self.pos.y
	end
	if self.dt > self.cycle then
		self.dt = self.dt - self.cycle
		for i=1,3 do
			self.branch[math.random(#self.branch)]={lightningimage[math.random(#lightningimage)], math.random() < self.freq}
		end
	end
	self.life = self.life - dt
	self.color[4] = math.clamp(self.life*511,0,255)
	if self.life <= 0 then
	map:removeUpdatable(self)
	end
end

function LightningImpact:destroy()
	map:removeUpdatable(self)
end

function LightningImpact:draw()
	local x,y = self.x,self.y
	love.graphics.setColor(unpack(self.color))
	for i=1,#self.branch do
		if self.branch[i][2] then
			local angle =math.pi/#self.branch*2*i
			love.graphics.draw(self.branch[i][1],x,y,angle,self.scale,self.scale,self.branch[i][1]:getWidth(),0)
		end
	end
	love.graphics.setColor(255,255,255,255)
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

function Bolt:draw()
	local x1,y1,x2,y2 = self.x1,self.y1,self.x2,self.y2
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
	if self.life <= 0 then
		map:removeUpdatable(self)
	end
	self.color[4] = math.clamp(self.life*511,0,255)
	if self.dt > self.cycle then
		self.dt = self.dt - self.cycle
		self.beam=lightningimage[math.random(#lightningimage)]
	end
end

local filesTable = love.filesystem.enumerate('beam')
local beamimage = {
	love.graphics.newImage('beam/l1.png'),
	love.graphics.newImage('beam/l2.png'),
	love.graphics.newImage('beam/l3.png'),
}
beamimage.drain=love.graphics.newImage('beam/drain.png')
for k,v in pairs(beamimage) do
	v:setWrap('repeat','clamp')
end
Beam = Object:subclass('Beam')
function Beam:initialize(p1,p2,cycle,life,color)
	self.beam = beamimage[math.random(#beamimage)]
	self.cycle = cycle
	self.life = life
	self.quad = love.graphics.newQuad(0,0,0,0,self.beam:getWidth(),self.beam:getHeight())
	self.color = color or {255,255,255,255}
	self.dt = 0
	self.p1,self.p2 = p1,p2
end

function Beam:draw()
	local x1,y1,x2,y2 = self.p1.x,self.p1.y,self.p2.x,self.p2.y
	love.graphics.setColor(unpack(self.color))
	local length = math.sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))
	self.quad:setViewport(self.life*1000,0,length,self.beam:getHeight())
	love.graphics.drawq(self.beam,self.quad,x1,y1,math.atan2(y2-y1,x2-x1),1,0.5,0,self.beam:getHeight()/2)
	love.graphics.setColor(255,255,255,255)
end

function Beam:update(dt)
	self.dt = self.dt + dt
	self.life = self.life - dt
	if self.life <= 0 then
	map:removeUpdatable(self)
	end
	self.color[4] = math.clamp(self.life*511,0,255)
	if self.dt > self.cycle then
		self.dt = self.dt - self.cycle
		self.beam=beamimage[math.random(#beamimage)]
	end
end

DrainBeam = Beam:subclass('DrainBeam')
function DrainBeam:initialize(p1,p2,life,color)
	super.initialize(self,p1,p2,nil,life,color)
	self.beam = beamimage.drain
end
function DrainBeam:update(dt)
	self.dt = self.dt+dt
	self.life = self.life-dt
	if self.life <= 0 then
		map:removeUpdatable(self)
	end
	self.color[4] = math.clamp(self.life*511,0,255)
end


beamimage.ray=love.graphics.newImage('beam/ray.png')
RayBeam = Beam:subclass('RayBeam')
function RayBeam:initialize(p1,p2,life,color)
	super.initialize(self,p1,p2,nil,life,color)
	self.beam = beamimage.ray
end
function RayBeam:update(dt)
	self.dt = self.dt+dt
	self.life = self.life-dt
	if self.life <= 0 then
		map:removeUpdatable(self)
	end
	self.color[4] = math.clamp(self.life*511,0,255)
end