
files = love.filesystem.enumerate('assets/electrician/icon')
for i,v in ipairs(files) do
	if love.filesystem.isFile('assets/electrician/icon/'..v) then
		local f = v:gmatch("(%w+).(%w+)")
		local file,ext=f()
		if ext=='png' then
			requireImage('assets/electrician/icon/'..v,file,icontable)
		end
	end
end
ElectricianAbiTree = Object:subclass('ElectricianAbiTree')
local pcb=require 'abilities.electrician.pcb'
local scale = 15
function ElectricianAbiTree:initialize(unit)
	self.unit = unit
	self.container = goo.object:new()
	-- Battery
	self.battery = goo.learnbutton:new(self.container)
	self.battery:setPos(pcb.battery.x*scale,pcb.battery.y*scale)
	self.battery:setSize(pcb.battery.w*scale,pcb.battery.h*scale)
	-- TODO: FOR REAL
	self.battery:setSkill(unit.skills.battery,img.batteryimg)
	self.battery.chip = pcb.battery
	
	-- Drain
	self.drain = goo.learnbutton:new(self.container)
	self.drain:setPos(pcb.drain.x*scale,pcb.drain.y*scale)
	self.drain:setSize(pcb.drain.w*scale,pcb.drain.h*scale)
	
	self.drain:setSkill(unit.skills.drain,img.pulse)
	self.drain.chip = pcb.drain
	-- CPU
	self.cpu = goo.learnbutton:new(self.container)
	self.cpu:setPos(pcb.cpu.x*scale,pcb.cpu.y*scale)
	self.cpu:setSize(pcb.cpu.w*scale,pcb.cpu.h*scale)
	
	self.cpu:setSkill(unit.skills.cpu,img.cpu)
	self.cpu.chip = pcb.cpu
	-- Lightning bolt
	
	self.lightningbolt = goo.learnbutton:new(self.container)
	self.lightningbolt:setPos(pcb.cpu1.x*scale,pcb.cpu1.y*scale)
	self.lightningbolt:setSize(pcb.cpu1.w*scale,pcb.cpu1.h*scale)
	
	self.lightningbolt:setSkill(unit.skills.lightningbolt,icontable.bolt)
	self.lightningbolt.chip = pcb.cpu1
	
	-- Lightning Chain
	
	self.lightningchain = goo.learnbutton:new(self.container)
	self.lightningchain:setPos(pcb.cpu2.x*scale,pcb.cpu2.y*scale)
	self.lightningchain:setSize(pcb.cpu2.w*scale,pcb.cpu2.h*scale)
	
	self.lightningchain:setSkill(unit.skills.lightningchain,icontable.lightningchain)
	self.lightningchain.chip = pcb.cpu2
	
	-- Lightning Ball
	
	self.lightningball = goo.learnbutton:new(self.container)
	self.lightningball:setPos(pcb.cpu3.x*scale,pcb.cpu3.y*scale)
	self.lightningball:setSize(pcb.cpu3.w*scale,pcb.cpu3.h*scale)
	
	self.lightningball:setSkill(unit.skills.lightningball,icontable.lightningball)
	self.lightningball.chip = pcb.cpu3
	
	local p = love.graphics.newParticleSystem(img.pulse,1024)
	print ((pcb.battery.x+pcb.battery.w/2)*scale,(pcb.battery.y+pcb.battery.h/2)*scale,'battery')
	p:setEmissionRate(100)
	p:setSpeed(200, 100)
	p:setColor(255, 255, 255, 255, 58, 128, 255, 0)
	p:setSize(0.5, 0.25)
	p:setLifetime(1)
	p:setParticleLife(1)
	p:setDirection(0)
	p:setSpread(1)
	p:setRadialAcceleration(-200)
	p:setTangentialAcceleration(-250)
	self.batterpos=p
	
	local p = love.graphics.newParticleSystem(img.pulse,1024)
	print ((pcb.battery.x+pcb.battery.w/2)*scale,(pcb.battery.y+pcb.battery.h/2)*scale,'battery')
	p:setEmissionRate(100)
	p:setSpeed(200, 100)
--	p:setGravity(0)	
	p:setColor(255, 0, 255, 255, 32, 32, 255, 0)
	p:setSize(0.5, 0.25)
	p:setLifetime(1)
--	p:setGravity(1000)
	p:setParticleLife(1)
	p:setDirection(0)
	p:setSpread(1)
	p:setRadialAcceleration(-200)
	p:setTangentialAcceleration(-250)
	self.batterneg=p
	
	self.container.panel1 = goo.itempanel:new(self.container)
	self.container.panel1:setPos(600,50)
	self.container.panel1:setSize(300,10)
	self.container.panel1:setVisible(false)
	self.container:setVisible(false)
	self.container.panel1:setFollowerPanel(true)
	self.container.learn = function(skill,button) self:learn(skill,button) end
end

function ElectricianAbiTree:update(dt)
	pcb:update(dt)
	self.batterpos:start()
	self.batterpos:update(dt)
	self.batterneg:start()
	self.batterneg:update(dt)
end

function ElectricianAbiTree:draw()
	pcb:draw()
	goo:draw()
	love.graphics.setScissor(pcb.battery.x*scale,pcb.battery.y*scale,pcb.battery.w*scale,pcb.battery.h*scale)
	love.graphics.draw(self.batterpos,(pcb.battery.x+pcb.battery.w/2)*scale,(pcb.battery.y+pcb.battery.h/2)*scale)
	love.graphics.draw(self.batterneg,(pcb.battery.x+pcb.battery.w/2)*scale,(pcb.battery.y+pcb.battery.h/2)*scale,math.pi)
	love.graphics.setScissor()
end

function ElectricianAbiTree:learn(skill,button)
	-- TODO
	local x,y=math.floor(button.x/scale),button.y%scale
	local c = button.chip
	if c then
		c:activate()
	end
	if self.unit.spirit>=1 then
		if skill.level<skill.maxlevel and skill.isHub then
			for k,v in ipairs(skill:setLevel(skill.level+1))do
				if v then
					if v.isHub then
						v.maxlevel = skill:getSublevel(v)
					else
						v:setLevel(skill:getSublevel(v))
					end
				end
			end
		end
	end
end


