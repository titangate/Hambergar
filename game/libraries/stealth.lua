require 'libraries.pathfinding.pathmap'
aiconstant = {
	suspicious = 2,
	alarm = 20,
	alarmtime = 10,
}

StealthSystem = {
	units = {}
}

function StealthSystem.getAlertIndex(unit)
	if unit == GetCharacter() then
		local a
		if unit.region then
			if unit.outfit then
				a = unit.region.alert[unit.outfit.name]
			else
				a = unit.region.alert.Assassin
			end
		end
		a = a or 0.5
		return a+unit.alertlevel
	end
end

function StealthSystem.getPatrolArea(lastseen)
	local connected = {}
	for v,_ in pairs(map.map[lastseen.region]) do
		table.insert(connected,v)
	end
	return connected[math.random(#connected)]
end

function StealthSystem.lethalAttract(unit)
	for i,v in ipairs(StealthSystem.units) do
		v.ai.passive = true
		if v.ai:getCurrentState() ~= StealthSuspicious then
			v.ai:setSuspicious(unit)
		end
	end
end

function StealthSystem.alarm()
	for i,v in ipairs(StealthSystem.units) do
		v.ai:gotoState'alarm'
	end
end

DProbe = Probe:subclass'DProbe'
function DProbe:initialize(...)
	super.initialize(self,...)
	self.life = 0.3
end

function DProbe:add(b,coll)
	if self.offline then return end
	self.unit:hit(b)
--	self.offline = true
end

--[[
function DProbe:draw()
	love.graphics.circle('fill',self.body:getX(),self.body:getY(),self.r,10)
end]]


function DProbe:createBody(world)
	local x,y = self.start.x,self.start.y
	self.body = love.physics.newBody(world,x,y,0.0001,1)
	self.shape = love.physics.newCircleShape(self.body,0,0,self.r)
	self.body:setBullet(true)
	self.shape:setCategory(15)
	self.shape:setMask(cc.playermissile,cc.enemymissile,cc.enemy,15)
	x,y = unpack(self.direction)
	x,y = normalize(x,y)
	self.body:setLinearVelocity(x*2000,y*2000)
	self.shape:setData(self)
end

OrderMoveToClear = AtomicGoal:subclass('OrderMoveToClear')
function OrderMoveToClear:initialize(owner,unit,range)
	assert(unit)
	self.start = owner
	self.unit = unit
	self.range = range
	self.time = 0
	self.clear = false
	super.initialize(self,x,y)
end

function OrderMoveToClear:process(dt,owner)
	if self.start.ai.alertlevel>aiconstant.alarmtime-0.2 then
		return STATE_SUCCESS,dt
	end
	owner.direction = map:getDirection(owner,self.unit)
	owner.state = 'move'
--	owner:setAngle(math.atan2(dy,dx))
	return STATE_ACTIVE,dt
end


OrderMoveToRegion = AtomicGoal:subclass('OrderMoveToRegion')
function OrderMoveToRegion:initialize(owner,target,range)
	assert(owner)
	self.start = owner
	self.target = target
	self.range = range
	self.time = 0
	self.clear = false
	super.initialize(self,x,y)
end

function OrderMoveToRegion:process(dt,owner)
	if getdistance(owner,self.target)<100 then
		return STATE_SUCCESS,dt
	end
	owner.direction = map:getDirection(owner,self.target)
	owner.state = 'move'
--	owner:setAngle(math.atan2(dy,dx))
	return STATE_ACTIVE,dt
end

OrderSearch = AtomicGoal:subclass'OrderSearch'
function OrderSearch:initialize(owner,region)
--	assert(region)
	self.start = owner
--	self.target = target
	self.region = region
--	self:reset()
	super.initialize(self)
end

function OrderSearch:revert()
	local connected = {}
	local r = map.regions -- basegraph[self.region]
	self.patrolregion = r[math.random(#r)]
	print(self.patrolregion.name,'is being patrolled')
	self.target = {
		x = self.patrolregion.x,
		y = self.patrolregion.y,
		region = self.patrolregion
	}
end

function OrderSearch:process(dt,owner)
	if getdistance(owner,self.target)<100 then
		return STATE_SUCCESS,dt
	end
	local origin = owner
	owner.direction = map:getDirection(owner,self.target)
--	print (unpack(owner.direction))
	owner.state = 'move'
	return STATE_ACTIVE,dt
end

b_StealthMeter = Buff:subclass'b_StealthMeter'
function b_StealthMeter:initialize(...)
	super.initialize(self,...)
end

function b_StealthMeter:draw(unit)
	local v = unit.ai.alertlevel
	local color,maxlevel
	if unit.ai:getCurrentState() and unit.ai:getCurrentState().class==StealthSuspicious then
		color = {0,255,0}
		maxlevel = aiconstant.alarm
	elseif unit.ai:getCurrentState() and unit.ai:getCurrentState().class==StealthAlarm then
		maxlevel = aiconstant.alarmtime
		color = {255,0,0}
	else
		maxlevel = aiconstant.suspicious
		color = {0,0,255}
	end
	drawAwarenessLevel(unit.x,unit.y,v,maxlevel,color)
end

StealthNormal = StatefulObject:subclass'StealthNormal'
function StealthNormal:initialize(t2,t,attackskill,range)
	super.initialize(self)
	self.unit = t2
	self.target = t
	self.alertlevel = 0
	self.visionrange = 1.1
	self.dt = 0
	self.detectrate = 0.05
	self.subai = Sequence:new()
	self.subai:push(OrderMoveToClear:new(t2,t,range))
	self.subai:push(OrderStop:new())
	self.subai:push(OrderChannelSkill:new(attackskill,function()t2:setAngle(math.atan2(t.y-t2.y,t.x-t2.x))return {normalize(t.x-t2.x,t.y-t2.y)},t2,attackskill end))
	self.subai:push(OrderWaitUntil:new(function()return self.alertlevel<aiconstant.alarmtime-0.2 or t.invisible end))
	self.subai:push(OrderStop:new())
	self.subai.loop = true
	table.insert(StealthSystem.units,self.unit)
end

function StealthNormal:fireDetector()
	local r = self.unit:getAngle()
	assert(r)
	local fireangle = math.random()*self.visionrange-self.visionrange/2+r
	local detector = DProbe(self,self.unit,{math.cos(fireangle),math.sin(fireangle)},16)
	map:addUnit(detector)
end

function StealthNormal:hit(unit)
	if unit == self.target then
		self.alertlevel = self.alertlevel + StealthSystem.getAlertIndex(unit)
		self.lastseen = {
			x = unit.x,
			y = unit.y,
			region = unit.region,
		}
	end
end

function StealthNormal:process(dt,owner)
	if self.paused then return STATE_ACTIVE,dt end
	self.dt = self.dt + dt
	if self.dt > self.detectrate then
		self.dt = self.dt - self.detectrate
		self:fireDetector()
	end
	if self.alertlevel >= aiconstant.suspicious then
		
		self:setSuspicious(self.target)
	end
	self.alertlevel = math.max(0,self.alertlevel - dt)
	if self.patrolai then
		return self.patrolai:process(dt,owner)
	else
		return STATE_ACTIVE,dt
	end
end

function StealthNormal:setSuspicious(target)
	self.checking = target
	self.passive = not target
--	self.alertlevel = self.alertlevel + 15
	self:gotoState()
	self:gotoState'suspicious'
end


function StealthNormal:pause()
	self.paused = true
end

function StealthNormal:resume()
	self.paused = nil
end


StealthSuspicious = StealthNormal:addState'suspicious'
function StealthSuspicious:process(dt)
	
	if self.paused then return STATE_ACTIVE,dt end
	self.dt = self.dt + dt
	if self.dt > self.detectrate then
		self.dt = self.dt - self.detectrate
		self:fireDetector()
	end
	if self.alertlevel >= aiconstant.alarm then
		StealthSystem.alarm()
	end
	if self.alertlevel <= 0 then
		self.checking = nil
--		assert(false)
		self:gotoState()
	end
	
	self.alertlevel = math.max(0,self.alertlevel - dt)
	if self.suspiciousai then
		return self.suspiciousai:process(dt,self.unit)
	else
		return STATE_ACTIVE,dt
	end
end

function StealthSuspicious:fireDetector()
	local dx,dy = self.target.x-self.unit.x,self.target.y-self.unit.y
	local detector = DProbe(self,self.unit,{normalize(dx,dy)},16)
	map:addUnit(detector)
end

function StealthSuspicious:enterState()
	self.alertlevel = 15
	if self.passive then
		self.passive = nil
		self.suspiciousai = nil
		return
	end
	
	self.checking = self.checking or self.target
	self.suspiciousai = Sequence() -- TODO
	self.suspiciousai:push(OrderMoveToRegion(self.unit,self.checking))
	local patrolai = Sequence()
	patrolai:push(OrderSearch(self.unit,self.target.region))
	patrolai:push(OrderStop())
	patrolai:push(OrderWaitUntil(function()
		patrolai:revert()
		return true
	end))
	patrolai.loop = true
	patrolai:revert()
	self.suspiciousai:push(patrolai)
--	self.suspiciousai.loop = true
end

function StealthSuspicious:hit(unit)
	if unit == self.target then
		self.alertlevel = math.max(self.alertlevel,15)
		self.alertlevel = self.alertlevel + StealthSystem.getAlertIndex(unit)
		self.lastseen = {
			x = unit.x,
			y = unit.y,
			region = unit.region,
		}
	end
end

StealthAlarm = StealthNormal:addState'alarm'
function StealthAlarm:hit(unit)
	if unit == self.target then
		self.alertlevel = aiconstant.alarmtime
		StealthSystem.lastseen = unit
	end
end

function StealthAlarm:fireDetector()
	local dx,dy = self.target.x-self.unit.x,self.target.y-self.unit.y
	local detector = DProbe(self,self.unit,{normalize(dx,dy)},16)
	map:addUnit(detector)
end

function StealthAlarm:process(dt)
	if self.paused then return STATE_ACTIVE,dt end
	
	self.dt = self.dt + dt
	if self.dt > self.detectrate then
		self.dt = self.dt - self.detectrate
		self:fireDetector()
	end
	self.alertlevel = math.max(0,self.alertlevel - dt)
	if self.alertlevel <= 0 then
--		self.alertlevel = 15
		self:gotoState'suspicious'
		self.unit.state = 'slide'
		return STATE_ACTIVE,dt
	end
	return self.subai:process(dt,self.unit)
end
