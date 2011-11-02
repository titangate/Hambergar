preload('assassin','commonenemies','tibet','vancouver','stealth')
KingEdStation = PathMap:subclass('KingEdStation')

local kingedbg={}
function kingedbg:update(dt)
end
function kingedbg:draw()
	love.graphics.push()
	love.graphics.translate(-map.w/2,-map.h/2)
	self.m:draw()
	love.graphics.pop()
end
function KingEdStation:initialize()
	local w = 4096
	local h = w
	self.w,self.h=w,h
	super.initialize(self,w,h)
	local m = self:loadTiled'station.tmx'
	kingedbg.m = m
	self.background = kingedbg
	self.savedata = {
		map = 'scenes.whistler.station',
	}
end
function KingEdStation:update(dt)
	super.update(self,dt)
end
function KingEdStation:draw()
	super.draw(self)
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
	function scenetest()
		i2.ai:setSuspicious({
			x = GetCharacter().x,
			y = GetCharacter().y,
			region = GetCharacter().region
		})
	end
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
end

function KingEdStation:destroy()
	self.exitTrigger:destroy()
end

return KingEdStation()
