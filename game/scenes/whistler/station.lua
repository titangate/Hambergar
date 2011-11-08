preload('assassin','commonenemies','tibet','vancouver','stealth')
KingEdStation = PathMap:subclass('KingEdStation')
requireImage('assets/whistler/trail.png','trail')
img.trail:setWrap('repeat','clamp')
local traily
local trailquad = love.graphics.newQuad(0,0,1024,52,12,52)
local kingedbg={
	x = 0,
	dt = 0,
}
function kingedbg:update(dt)
	
	self.dt = self.dt + dt
--	print (self.dtfunc)
	if self.dtfunc then
		self.x = self.x - self.dtfunc(self.dt,dt)
	else
--		self.x = self.x - 1000*dt
	end
	if self.x < -5000 then
		self.x = 5000
	end
end
function kingedbg:draw()
	love.graphics.push()
	love.graphics.translate(-map.w/2,-map.h/2)
	self.m:draw()
	love.graphics.pop()
--	love.graphics.drawq(img.trail,trailquad,0,traily,0)
--	love.graphics.drawq(img.trail,trailquad,1024,traily,0)
--	love.graphics.drawq(img.trail,trailquad,-1024,traily,0)
--	love.graphics.drawq(img.trail,trailquad,2048,traily,0)
--	love.graphics.drawq(img.trail,trailquad,-2048,traily,0)
	
	love.graphics.push()
		love.graphics.translate(kingedbg.x,0)
		love.graphics.translate(-map.train.w/2,-map.train.h/2)
		map.train.background.m:draw()
	love.graphics.pop()
end

local stationcount = 0

function KingEdStation:initialize()
	local w = 4096
	local h = w
	self.w,self.h=w,h
	super.initialize(self,w,h)
	local m = self:loadTiled'station.tmx'
	
	kingedbg.m = m
	self.background = kingedbg
	self.savedata = {
--		map = 'scenes.whistler.station',
	}
	assert (utilitybox)
	traily = map.waypoints.trail[2]
	stationcount = stationcount + 1
	assert(stationcount<2)
end

function KingEdStation:load()
	
end


function KingEdStation:loadCheckpoint(checkpoint)
	if checkpoint == 'opening' then
		self:checkpoint1_load()
	end
end

function KingEdStation:checkpoint1_load()
	local x,y = unpack(map.waypoints.chr)
	local leon = Assassin:new(x,y,32,10)
	leon.direction = {0,-1}
	leon.controller = 'player'
--	leon.HPRegen = 1000
	SetCharacter(leon)
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
	assert(self.train)
end

function KingEdStation:checkpoint1_enter()
	local leon = GetCharacter()
--	leon.direction = {0,-1}
	leon.controller = 'player'
--	leon.HPRegen = 1000
	SetCharacter(leon)
	leon:gotoState'stealth'
--	map:addUnit(leon)
	map.camera = FollowerCamera:new(leon,{
		x1 = -self.w/2+screen.halfwidth,
		y1 = -self.h/2+screen.halfheight,
		x2 = self.w/2-screen.halfwidth,
		y2 = self.h/2-screen.halfheight
	})
--	GetGameSystem().bottompanel:fillPanel(GetCharacter():getSkillpanelData())
--	GetGameSystem().bottompanel:setPos(screen.halfwidth-512,screen.height - 140)
	self:checkpoint1_loaded()
end

function KingEdStation:checkpoint1_loaded()
	local x,y = unpack(map.waypoints.guard1)
	local i = IALMachineGunner(x,y,'enemy')
	i.ai = StealthNormal(i,GetCharacter(),i.skills.gun,100)
	local x,y = unpack(map.waypoints.guard2)
	local i2 = IALMachineGunner(x,y,'enemy')
	i2.ai = StealthNormal(i2,GetCharacter(),i2.skills.gun,100)
	map:addUnit(i)
	map:addUnit(i2)
	i:setAngle(-math.pi/2)
	i2:setAngle(-math.pi/2)
	i:addBuff(b_StealthMeter(),-1)
	--GetGameSystem().bossbar = AssassinHPBar:new(function()return i.ai.alertlevel/aiconstant.alarm end,screen.halfwidth-400,screen.height-100,800)
	local x,y = unpack(map.waypoints.guard3)
	local guard3 = IALMachineGunner(x,y,'enemy')
	local patrolai = Sequence()
	patrolai:push(OrderStop())
	patrolai:push(OrderWait(10))
	patrolai:push(OrderMoveTo(unpack(map.waypoints.guard3)))
	patrolai:push(OrderMoveTo(unpack(map.waypoints.guard3patrol1)))
	patrolai:push(OrderMoveTo(unpack(map.waypoints.guard3patrol2)))
	patrolai:push(OrderMoveTo(unpack(map.waypoints.guard3patrol3)))
	patrolai:push(OrderStop())
	patrolai:push(OrderWait(10))
	
	patrolai:push(OrderMoveTo(unpack(map.waypoints.guard3patrol3)))
	patrolai:push(OrderMoveTo(unpack(map.waypoints.guard3patrol2)))
	patrolai:push(OrderMoveTo(unpack(map.waypoints.guard3patrol1)))
	patrolai:push(OrderMoveTo(unpack(map.waypoints.guard3)))
	patrolai.loop = true
	guard3.ai = StealthNormal(guard3,GetCharacter(),guard3.skills.gun,100)
	guard3.ai.patrolai = patrolai
	guard3:addBuff(b_StealthMeter(),-1)
	map:addUnit(guard3)
	local x,y = unpack(map.waypoints.g1)
	local g1 = IALShotgunner(x,y,'enemy')
	g1.ai = StealthNormal(g1,GetCharacter(),g1.skills.gun,100)
	map:addUnit(g1)
	local x,y = unpack(map.waypoints.g2)
	local g2 = IALShotgunner(x,y,'enemy')
	g2.ai = StealthNormal(g2,GetCharacter(),g2.skills.gun,100)
	map:addUnit(g2)
	
	local x,y = unpack(map.waypoints.captain1)
	local captain = IALSwordsman(x,y,'enemy')
	local patrolai = Sequence()
	patrolai:push(OrderStop())
	patrolai:push(OrderWait(10))
	patrolai:push(OrderMoveTo(unpack(map.waypoints.captain1)))
	patrolai:push(OrderStop())
	patrolai:push(OrderWait(10))
	patrolai:push(OrderMoveTo(unpack(map.waypoints.captain2)))
	patrolai.loop = true
	captain.ai = StealthNormal(captain,GetCharacter(),captain.skills.melee,100)
	captain.ai.patrolai = patrolai
	captain:addBuff(b_StealthMeter(),-1)
	table.insert(captain.drops,StationKeycard())
	map:addUnit(captain)
	
	self.exitTrigger = Trigger(function(self,event)
		if (event.index == 'BuildingEntrance' or event.index == 'OfficeEntrance') and event.unit == GetCharacter() then
			StealthSystem.lethalAttract()
		end
	end)
	self.exitTrigger:registerEventType('add')
	GetCharacter().skills.weaponskill:gotoState'interact'
	
	function utilitybox:interact(unit)
		g1.ai:setSuspicious(self)
		g2.ai:setSuspicious(self)
	end
	
	self.exitTrigger = Trigger(function(self,event)
		if event.index == 'exit' and event.unit == GetCharacter() then
			print 'exiting'
			map.update = map.exitToTrain
		end
	end)
		self.exitTrigger:registerEventType'add'
		self:startTrain()
end

function KingEdStation:enterFromTrain()
	self:startTrain()
	self.exitTrigger:registerEventType'add'
end


function KingEdStation:exitToTrain()
	self.exitTrigger:destroy()	
	self.update = nil
	self:removeUnit(GetCharacter())
	self:update(0.016)
	map = self.train
	map:addUnit(GetCharacter())
	map:enterFromStation()
end

function KingEdStation:startTrain()
	kingedbg.dtfunc = function(time,dt)
		return 100*(time)*dt
	end
	kingedbg.x = 0
	kingedbg.dt = 0
	Timer(10,1,function()kingedbg.dtfunc = nil end)
	self.running = true
	self.docking = nil
end

function KingEdStation:stopTrain()
	kingedbg.x = 5000
	kingedbg.dtfunc = function(time,dt)
		return 100*(10-time)*dt
	end
	kingedbg.dt = 0
	Timer(10,1,function()kingedbg.dtfunc = nil end)
	self.running = nil
	self.docking = true
end


function KingEdStation:destroy()
	self.exitTrigger:destroy()
	
end

return KingEdStation()
