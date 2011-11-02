preload('assassin','commonenemies','tibet','vancouver','stealth','electrician')
KingEdTrain = Map:subclass'KingEdTrain'
local kingedbg={}
function kingedbg:update(dt)
end
function kingedbg:draw()
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
	kingedbg.m = m
	self.background = kingedbg
	self.savedata = {
		map = 'scenes.whistler.station',
	}
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
	map:addUnit(Paddle(0,0))
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
		if (event.index == 'BuildingEntrance' or event.index == 'OfficeEntrance') and event.unit == GetCharacter() then
			StealthSystem.lethalAttract()
		end
	end)
--	self.exitTrigger:registerEventType('add')
	GetCharacter().skills.weaponskill:gotoState'interact'
end

function KingEdTrain:destroy()
	self.exitTrigger:destroy()
end

return KingEdTrain()