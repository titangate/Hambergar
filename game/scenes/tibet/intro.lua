

local DrawMainmenu = AnimationGoal:subclass('DrawMainmenu')
function DrawMainmenu:update(dt)
	MainMenu:update(dt,true)
	return super.update(self,dt)
end
function DrawMainmenu:draw()
	MainMenu:draw()
end

local drawintroflow = AnimationGoal:new(48)
drawintroflow.flows = {}
drawintroflow.spawntime = 0
local p = love.graphics.newParticleSystem(part1, 1000)
p:setPosition(0,0)
p:setEmissionRate(50)
p:setGravity(0,0)
p:setSpeed(-50,50)
p:setSize(1, 1)
p:setColor(125, 125, 125, 125, 125, 125, 125, 0)
p:setLifetime(1)
p:setParticleLife(2)
p:setDirection(0)
p:setSpread(360)
p:setTangentialAcceleration(0)
p:setRadialAcceleration(0)
p:stop()
drawintroflow.system = p
drawintroflow.x = 0
drawintroflow.cloudtime = 0
function drawintroflow:spawnflow(x,y)
table.insert(drawintroflow.flows,{x,y})
end

function drawintroflow:update(dt)
	
	local removal = nil
	self.time = self.time + dt
	self.cloudtime = self.time*200
	if self.time >= self.totaltime then
		return STATE_SUCCESS,dt
	end
end

function drawintroflow:draw()
		love.graphics.setColor(255,255,255,100)
	love.graphics.drawq(cloud,cloudquad,self.cloudtime*0.9,0,120,4,4,2000,2000)
	love.graphics.drawq(cloud,cloudquad,self.cloudtime*0.6,-792,0,3,3,2000,2000)
	love.graphics.drawq(cloud,cloudquad,self.cloudtime*0.4,552,0,2,2,2000,2000)
	love.graphics.setColor(255,255,255,255)	
end

DrawIntroText = AnimationGoal:subclass('DrawIntroText')
function DrawIntroText:initialize(time,string)
	super.initialize(self,time)
	self.z = 10
	self.string = string
	x,y = love.graphics.getWidth(),love.graphics.getHeight()/2
	local p = love.graphics.newParticleSystem(part1, 1000)
	p:setPosition(x,y)
	p:setEmissionRate(50)
	p:setGravity(0,0)
	p:setSpeed(-50,50)
	p:setSize(3, 1)
	p:setColor(255, 255, 255, 255, 255, 255, 255, 0)
	p:setLifetime(1)
	p:setParticleLife(2)
	p:setDirection(0)
	p:setSpread(360)
	p:setTangentialAcceleration(0)
	p:setRadialAcceleration(0)
	p:stop()
	self.system = p
	self.x,self.y = x,y
end

function DrawIntroText:update(dt)
	
	self.x = self.x - dt*300
	local p = self.system
	p:setPosition(self.x,self.y)
	p:start()
	p:update(dt)
	return super.update(self,dt)
end

function DrawIntroText:draw()
	love.graphics.draw(self.system)
	if self.time < 3 then love.graphics.setScissor(self.x,0,love.graphics.getWidth(),love.graphics.getHeight()) end
	love.graphics.setColor(255,255,255,math.min(255,(self.totaltime - self.time)*255))
	love.graphics.setFont(bigfont)
	love.graphics.printf(self.string,love.graphics.getWidth()/8,love.graphics.getHeight()/2-50,love.graphics.getWidth()*0.75,'center')
	revertFont()
	love.graphics.setColor(255,255,255,255)
	love.graphics.setScissor()
end

initializescene = AnimationGoal:new(10)
--map.camera = Camera:new(-GetCharacter().x+love.graphics.getWidth()/2,-GetCharacter().y+love.graphics.getHeight()/2)
--local camera = map.camera
function initializescene:update(dt)
	self.time = self.time + dt
	if self.time >= self.totaltime then
		popsystem()
		require 'scenes.tibet.tibet1'
		local gs = require 'scenes.tibet.tibetgamesystem'
		require 'scenes.tibet.intro'
		mainmenu:onClose()
		SetGameSystem(gs)
		GetGameSystem():load()
		GetGameSystem():runMap(Tibet1,'opening')
		pushsystem(GetGameSystem())
		return STATE_SUCCESS,dt
	end
	return STATE_ACTIVE
end
function initializescene:draw()
	local percent = self.time/self.totaltime*0.5+0.5
--	camera.r = percent*math.pi*2
	camera.sx,camera.sy = percent,percent
	map:draw()
	camera:revert()
end

function playWindsound()
	windloop = love.audio.newSource('sound/windloop.ogg','static')
	windloop:setLooping(true)
	love.audio.play(windloop)
end

function playyansile()
	yansile = love.audio.newSource('music/yansile.ogg','stream')
	yansile:setVolume(0.4)
	love.audio.play(yansile)
end

tibetintro = CutSceneSequence:new()
tibetintro:push(FadeOut:new('fadeout',nil,{255,255,255},2),0)
tibetintro:push(DrawMainmenu:new(2),0)
tibetintro:push(ExecFunction:new(function() love.graphics.setBackgroundColor(70,129,200,255) end),2)
tibetintro:push(FadeOut:new('fadein',nil,{255,255,255},2),2)
tibetintro:push(drawintroflow,2)
tibetintro:push(ExecFunction:new(playWindsound),4)
tibetintro:push(DrawIntroText:new(7,"THE YEAR IS 2022. THE WORLD IS ON THE EDGE OF COLLAPSE."),7)
tibetintro:push(ExecFunction:new(playyansile),11)
tibetintro:push(DrawIntroText:new(7,"SHOTLY AFTER THE ASSASSINATION OF THE US PRESIDENT, THE NOTORIOUS IAL - INTERNATIONAL ASSASSINS' LEAGUE, CLAIMED THEIR RESPONSIBILITY OF HIS DEATH."),13)
--tibetintro:push(DrawIntroText:new(4,"HACKED BY TOM KIM"),19)
tibetintro:push(DrawIntroText:new(14,"wtf. anyways. THE US SOON LEARNED THAT THE IAL HQ IS LOCATED IN TIBET. THE CHINESE GOVERNMENT REFUSED TO LET THE US ARMY ENTER ITS TERRITORY. BOTH COUNTRIES HAVE THREATED TO USE NUCLEAR WEAPONS."),19)
tibetintro:push(DrawIntroText:new(12,"YET, THERE'S SOMEONE WHO DOESN'T NEED THE PERMISSION OF NEITHER GOVERNMENT TO DEAL WITH THE IAL HIMSELF. RIVER, ONE OF THE MOST DILIGENT FORMER MEMBER OF THE LEAGUE, CAME TO THE HOLY STAIRS TO SEEK VENGENCE FROM HIS MASTER."),32)
tibetintro:push(FadeOut:new('fadeout',nil,{255,255,255},2),46)
tibetintro:push(initializescene,48)
tibetintro:push(DrawIntroText:new(10,"JUNE 2022, SACRED STAIRS, TIBET"),48)
tibetintro:push(FadeOut:new('fadein',nil,{255,255,255},5),48)