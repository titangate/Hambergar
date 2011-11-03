
local coordinateshift = {
	x = 0,
	y = 0,
}
preload('assassin','commonenemies','tibet','vancouver','stealth','whistler')
KingEdTrain = Map:subclass'KingEdTrain'
local trainbg={}
local lightsource = {
	x = 0,
	y = 400,
}
function trainbg:update(dt)
	lightsource.x = lightsource.x - 1000*dt
	if lightsource.x < -2000 then
		lightsource.x = 6000
	end
end
function trainbg:draw()
	love.graphics.push()
	love.graphics.translate(-map.w/2,-map.h/2)
	self.m:draw()
	love.graphics.pop()
end
function KingEdTrain:initialize()
	local w = 3200
	local h = 1000
	self.w,self.h=w,h
	super.initialize(self,w,h)
	local m = self:loadTiled'train.tmx'
	trainbg.m = m
	self.background = trainbg
	self.savedata = {
		map = 'scenes.whistler.station',
	}
	Lighteffect.lightOn(lightsource)
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

function KingEdTrain:checkpoint1_loaded()
	
	self.exitTrigger = Trigger(function(self,event)
		if event.index == 'exit' and event.unit == GetCharacter() then
			map.update = map.exitToStation
		end
	end)
	map:addUnit(StationKeycard(-800,0))
	
	function emergencystop:interact(unit)
		if unit.inventory:hasItem'KEYCARD' then
			unit.inventory:removeItem'KEYCARD'
			map:finish()
		end
	end
	
	self.exitTrigger:registerEventType('add')
	GetCharacter().skills.weaponskill:gotoState'interact'
	
end

function KingEdTrain:startTrain()
	
end

function KingEdTrain:stopTrain()
end

function KingEdTrain:opening()
	require 'scenes.whistler.lily'()
end

function KingEdTrain:enterFromStation()
end

function KingEdTrain:exitToStation()
	self:removeUnit(GetCharacter())
	self.station = require 'scenes.whistler.station'
	map = self.station
	
	map:addUnit(GetCharacter())
	map:checkpoint1_enter()
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