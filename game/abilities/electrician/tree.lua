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
	self.battery:setSkill(unit.skills.battery,batteryimg)
	self.battery.chip = pcb.battery
	
	-- Drain
	self.drain = goo.learnbutton:new(self.container)
	self.drain:setPos(pcb.drain.x*scale,pcb.drain.y*scale)
	self.drain:setSize(pcb.drain.w*scale,pcb.drain.h*scale)
	
	self.drain:setSkill(unit.skills.drain,pulse)
	self.drain.chip = pcb.drain
	-- CPU
	self.cpu = goo.learnbutton:new(self.container)
	self.cpu:setPos(pcb.cpu.x*scale,pcb.cpu.y*scale)
	self.cpu:setSize(pcb.cpu.w*scale,pcb.cpu.h*scale)
	
	self.cpu:setSkill(unit.skills.cpu,pulse)
	self.cpu.chip = pcb.cpu
	
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
						v.maxlevel = v.maxlevel+1
					else
						v:setLevel(skill:getSublevel(skill,skill.level+1))
					end
				end
			end
		end
	end
end


