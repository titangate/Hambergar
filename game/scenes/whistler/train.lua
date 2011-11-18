local traily
preload('assassin','commonenemies','tibet','vancouver','stealth','whistler')
requireImage('assets/whistler/trail.png','trail')
img.trail:setWrap('repeat','clamp')
local trailquad = love.graphics.newQuad(0,0,1024,52,12,52)
KingEdTrain = Map:subclass'KingEdTrain'
local station
local trainbg={
	dt = 0,
}
local lightsource = {
	x = 5000,
	y = 0,
}

function trainbg:update(dt)
	self.dt = self.dt + dt
	if self.dtfunc then
		lightsource.x = lightsource.x - self.dtfunc(self.dt,dt)
	else
		lightsource.x = lightsource.x - 1000*dt
	end
	if lightsource.x < -5000 then
		lightsource.x = 5000
	end
	
end

function trainbg:draw()
	love.graphics.push()
	love.graphics.translate(-map.w/2,-map.h/2)
	self.m:draw()
	love.graphics.pop()
	trailquad:setViewport(-lightsource.x,0,1024,52)
	love.graphics.drawq(img.trail,trailquad,0,traily,0)
	love.graphics.drawq(img.trail,trailquad,1024,traily,0)
	love.graphics.drawq(img.trail,trailquad,-1024,traily,0)
	love.graphics.drawq(img.trail,trailquad,2048,traily,0)
	love.graphics.drawq(img.trail,trailquad,-2048,traily,0)
--	if stationt then
	if self.dtfunc then
		love.graphics.push()
			love.graphics.translate(lightsource.x,0)
			love.graphics.translate(-station.w/2,-station.h/2)
			station.background.m:draw()
		love.graphics.pop()
	end
--	end
end

function KingEdTrain:initialize()
	local w = 4096
	local h = 4096
	self.w,self.h=w,h
	super.initialize(self,w,h)
	local m = self:loadTiled'train.tmx'
	trainbg.m = m
	self.background = trainbg
	self.savedata = {
		map = 'scenes.whistler.station',
	}
	Lighteffect.lightOn(lightsource)
	function scenetest()
		if map.running then
			map:stopTrain()
		else
			map:startTrain()
		end
	end
	assert(emergencystop)
end

function KingEdTrain:update(dt)
	super.update(self,dt)
end

function KingEdTrain:loadCheckpoint(checkpoint)
	if checkpoint == 'opening' then
		self:checkpoint1_load()
	end
end

function KingEdTrain:load()
end

function KingEdTrain:checkpoint1_load()
	local x,y = unpack(map.waypoints.chr)
	local leon = Assassin:new(x,y,32,10)
	leon.direction = {0,-1}
	leon.controller = 'player'
	SetCharacter(leon)
	leon.HPRegen = 1000
	leon:gotoState'stealth'
	map:addUnit(leon)
--	map:addUnit(Paddle(0,0))
	map.camera = FollowerCamera:new(leon,{
		x1 = -self.w/2+screen.halfwidth,
		y1 = -self.h/2+screen.halfheight,
		x2 = self.w/2-screen.halfwidth,
		y2 = self.h/2-screen.halfheight
	})
	GetGameSystem().bottompanel:fillPanel(GetCharacter():getSkillpanelData())
	GetGameSystem().bottompanel:setPos(screen.halfwidth-512,screen.height - 140)
	self:checkpoint1_loaded()
end

function KingEdTrain:checkpoint1_enter()
	local x,y = unpack(map.waypoints.chr)
	leon = GetCharacter()
	leon.x,leon.y = x,y
--	SetCharacter(leon)
	leon:gotoState'stealth'
	map:addUnit(leon)
	map.camera = FollowerCamera:new(leon,{
		x1 = -self.w/2+screen.halfwidth,
		y1 = -self.h/2+screen.halfheight,
		x2 = self.w/2-screen.halfwidth,
		y2 = self.h/2-screen.halfheight
	})
	GetGameSystem().bottompanel:fillPanel(GetCharacter():getSkillpanelData())
	GetGameSystem().bottompanel:setPos(screen.halfwidth-512,screen.height - 140)
	self:checkpoint1_loaded()
end

function KingEdTrain:checkpoint1_loaded()
	
	traily = map.waypoints.trail[2]
	lightsource.y = traily
	self.exitTrigger = Trigger(function(self,event)
		if event.index == 'exit' and event.unit == GetCharacter() then
			map.update = map.exitToStation
		end
	end)
	self.exitTrigger:registerEventType'add'
	
	function emergencystop:interact(unit)
		if unit.inventory:hasItem'KEYCARD' then
			unit.inventory:removeItem'KEYCARD'
			map:finish()
		end
	end
	
	GetCharacter().skills.weaponskill:gotoState'interact'

	station = require 'scenes.whistler.station'
	station.train = self
	self.station = station
	function lily:interact(unit)
		map:removeUnit(lily)
		PlayMusic('music/dreamtheme.mp3')
		require 'scenes.whistler.lily'()
	end
	self:startTrain()
	
	anim:easy(GetGameSystem().fader,'opacity',255,0,1,'linear')
end

function KingEdTrain:startTrain()
	trainbg.dtfunc = function(time,dt)
		return 100*(time)*dt
	end
	trainbg.dt = 0
	lightsource.x = 0
	Timer(10,1,function()trainbg.dtfunc = nil end)
	self.running = true
	self.docking = nil
end

function KingEdTrain:stopTrain()
	lightsource.x = 5000
	trainbg.dtfunc = function(time,dt)
		return 100*(10-time)*dt
	end
	trainbg.dt = 0
	Timer(10,1,function()trainbg.dtfunc = function()return 0 end end)
	self.running = nil
	self.docking = true
end

function KingEdTrain:opening()
	require 'scenes.whistler.lily'()
end

function KingEdTrain:enterFromStation()
	self.exitTrigger:registerEventType'add'
	
	self:startTrain()
end

local stationloaded = false
function KingEdTrain:exitToStation()
	self:removeUnit(GetCharacter())
	self.update = nil
	self:update(0.016)
	self.exitTrigger:destroy()
	map = station
--	GetCharacter().y = GetCharacter().y - 700
	map:addUnit(GetCharacter())
--	map:startTrain()
	if stationloaded then
	map:enterFromTrain()
	else
		station:checkpoint1_enter()
		stationloaded = true
	end
end

function KingEdTrain:finish()
--	assert(false)
	map.camera:shake(100,0.5)
	require 'scenes.whistler.ending'()
end

function KingEdTrain:destroy()
	self.exitTrigger:destroy()
end

return KingEdTrain()