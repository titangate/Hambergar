require 'libraries.scene'
require 'libraries.unit'
STATE_FAIL = 0
STATE_SUCCESS = 1
STATE_ACTIVE = 2
STATE_INACTIVE = 3
AI = {}
AtomicGoal = Object:subclass('AtomicGoal')
function AtomicGoal:process(dt,owner)
	return STATE_FAIL
end

function AtomicGoal:reset()
end

function AtomicGoal:destroy()
end

function AtomicGoal:revert()
end

OrderStop = AtomicGoal:subclass('OrderStop')
function OrderStop:process(dt,owner)
	owner.state = 'slide'
	owner:switchChannelSkill(nil)
	return STATE_SUCCESS
end

OrderMoveTo = AtomicGoal:subclass('MoveTo')
function OrderMoveTo:initialize(x,y)
	self.x,self.y=x,y
end

function OrderMoveTo:process(dt,owner)
	local dx,dy=self.x-owner.x,self.y-owner.y
	local distance=dx*dx+dy*dy
	if distance < 255 then
		return STATE_SUCCESS,dt
	end
	owner.direction = {normalize(dx,dy)}
	owner.state = 'move'
	return STATE_ACTIVE,dt
end

OrderMoveTowardsRange = AtomicGoal:subclass('OrderMoveTowardsRange')
function OrderMoveTowardsRange:initialize(target,range)
	self.target,self.range = target,range*range
end

function OrderMoveTowardsRange:process(dt,owner)
	if self.target.invisible then
		owner.state = 'slide'
		return STATE_FAIL,dt
	end
	local dx,dy=self.target.x-owner.x,self.target.y-owner.y
	local distance=dx*dx+dy*dy
	if distance < self.range then
		return STATE_SUCCESS,dt
	end
	owner.direction = {normalize(dx,dy)}
	owner.state = 'move'
	owner:setAngle(math.atan2(dy,dx))
	return STATE_ACTIVE,dt
end

OrderActiveSkill = AtomicGoal:subclass('OrderSkill')
function OrderActiveSkill:initialize(skill,func)
	self.skill,self.func=skill,func
	self.skill.getorderinfo = func
end

function OrderActiveSkill:process(dt,owner)
	if self.skill:active() then
		return STATE_SUCCESS,dt
	else
		return STATE_FAIL,dt
	end
end

OrderWaitUntil = AtomicGoal:subclass('OrderWaitUntil')
function OrderWaitUntil:initialize(condition)
	self.condition=condition
end

function OrderWaitUntil:process(dt,owner)
	if self.condition(dt,owner) then
		return STATE_SUCCESS,dt
	else
		return STATE_ACTIVE,dt
	end
end

OrderChannelSkill = AtomicGoal:subclass('OrderChannelSkill')
function OrderChannelSkill:initialize(skill,func)
	self.skill,self.func=skill,func
	self.skill.getorderinfo = func
end

function OrderChannelSkill:process(dt,owner)
	owner:switchChannelSkill(self.skill)
	return STATE_SUCCESS,dt
end

OrderWait = AtomicGoal:subclass('OrderWait')
function OrderWait:initialize(duration)
	self.duration=duration
	self.dt = 0
end

function OrderWait:process(dt,owner)
	self.dt = self.dt + dt
	
	if self.duration <= self.dt then
		return STATE_SUCCESS,self.duration - self.dt
	else
		return STATE_ACTIVE,dt
	end
end

function OrderWait:revert()
	self.dt = 0
end

Detector = Object:subclass('Clearance')
function Detector:initialize(start,unit,range,clear)
	self.unit = unit
	self.start = start
	self.range = range
	self.clear = clear
	self.exclude = true
end

function Detector:add(b,coll)
	self.clear(b)
end

function Detector:createBody(world)
	local x,y = self.start.x,self.start.y
	self.body = love.physics.newBody(world,x,y,1,1)
	self.shape = love.physics.newCircleShape(self.body,0,0,5)
--	self.shape:setSensor(true)
	self.body:setBullet(true)
	if self.controller then
		local category,masks = unpack(typeinfo[self.controller])
		self.shape:setCategory(category)
		self.shape:setMask(unpack(masks))
	end	
	x,y = self.unit.x-x,self.unit.y-y
	x,y = normalize(x,y)
	self.body:setLinearVelocity(x*1000,y*1000)
	self.shape:setData(self)
end

function Detector:preremove()
	self.shape:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
    self.preremoved = true
end

function Detector:destroy()
    if self.preremoved then
        self.shape:destroy()
        self.body:destroy()
		self.shape = nil
		self.body = nil
    end
end

function Detector:draw()
	love.graphics.circle('line',self.body:getX(),self.body:getY(),3)
end

OrderMoveToClear = OrderMoveTo:subclass('OrderMoveToClear')
function OrderMoveToClear:initialize(x,y,owner,unit,range)
	self.start = owner
	self.unit = unit
	self.range = range
	self.time = 0
	self.clear = false
	super.initialize(self,x,y)
end

function OrderMoveToClear:process(dt,owner)
	self.time = self.time + dt
	if self.time > self.range/2000 then
		if self.detector then map:removeUnit(self.detector) end
		self.detector = Detector:new(self.start,self.unit,self.range,function ()
			self.clear = true
			map:removeUnit(self.detector)
			self.detector = nil
		end)
		self.detector.controller = self.start.controller..'Missile'
		map:addUnit(self.detector)
		self.time = self.time - self.range/2000
	end
	if self.clear then
		return STATE_SUCCESS,dt
	end
	return super.process(self,dt,owner)
end

Sequence = Object:subclass('Sequence')
function Sequence:initialize()
	self.goals = {}
end

function Sequence:destroy()
	self:reset()
end

function Sequence:reset()
	if self.active ~= nil then
		self.goals[self.active]:reset()
		self.active = nil
	end
end

function Sequence:revert()
	for k,v in ipairs(self.goals) do
		v:revert()
	end
	if self.timelimit then
		self.dt = 0
	end
end

function Sequence:process(dt,owner)
	if #self.goals == 0 then
		return STATE_INACTIVE,0
	end
	-- activate if inactive
	if self.active == nil then
		self.active = 1
	end
	
	if self.timelimit then
		self.dt = self.dt+dt
		if self.timelimit<=self.dt then
			return STATE_FAIL,self.dt-self.timelimit
		end
	end
	-- process the active goal
	local status, used = self.goals[self.active]:process(dt,owner)
	
	-- the active goal has destroyed this sequence
	if self.active == nil then
		return completed,used
	end
	
	if status == STATE_ACTIVE then
		return STATE_ACTIVE, used
	elseif status == STATE_FAIL then
		-- the sequence has failed
		self.active = nil
		return STATE_FAIL, used
	elseif status == STATE_SUCCESS then
		-- move to the next goal
		self.active = self.active + 1
		if self.active > #self.goals then
			if self.loop ~= true then
				-- complete sequence
				self.active = nil
				return STATE_SUCCESS, used
			else
				self:revert()
				self.active = 1
			end
		end
	end
	--if dt == used then
	return STATE_ACTIVE, used
	--end
	--return self:process(dt-used,owner)
end

function Sequence:push(goal)
	assert(goal)
	table.insert(self.goals,goal)
end

function Sequence:clear()
	self:reset()
	while #self.goals > 0 do
		local last = table.remove(self.goals)
		last:destroy()
	end
end

SequencePathfinding = Sequence:subclass('SequencePathfinding')
function SequencePathfinding:initialize(start,goal)
	super.initialize(self)
	self.path = map:findPath(goal,start)
	for i,v in ipairs(self.path) do
		self:push(OrderMoveTo:new(unpack(v)))
	end
end


SequencePathfindingClear = SequencePathfinding:subclass('SequencePathfindingClear')
function SequencePathfindingClear:initialize(start,goal,range)
	super.initialize(self,{start.x,start.y},{goal.x,goal.y})
	self.start = start
	self.unit = goal
	self.range = range
	self.time = 0
	self.clearance = false
end

function SequencePathfinding:process(dt,owner)
	status,dt = super.process(self,dt,owner)
	if status == STATE_ACTIVE then
		self.time = self.time + dt
		if self.time > self.range/1000 then
			if self.detector then map:removeUnit(self.detector) end
			self.detector = Detector:new(self.start,self.unit,self.range,function (b,coll)
				if b==self.unit then self.clearance = true end
				map:removeUnit(self.detector)
				self.detector = nil
			end)
			self.detector.controller = self.start.controller..'Missile'
			map:addUnit(self.detector)
			self.time = self.time - self.range/1000
		end
		if self.clearance then
			return STATE_SUCCESS,dt
		end
	end
	return status,dt
end

Selector = Object:subclass('Selector')
function Selector:initialize()
end

function Selector:push(condition)
	self.condition = condition
end

function Selector:process(dt,owner)
	if not self.subgoal then
		self.subgoal = self.condition()
		if not self.subgoal then
			return STATE_FAIL,0
		end
		self.subgoal:revert()
	end
	local status,dt = self.subgoal:process(dt,owner)
	if status ~= STATE_ACTIVE then
		self.subgoal = nil
	end
	return status,dt
end

function Selector:revert()
end

Parallel = Object:subclass('Parallel')
function Parallel:initialize()
	self.subgoals = {}
end

function Parallel:push(goal)
	assert(goal)
	table.insert(self.subgoals,goal)
end

function Parallel:process(dt,owner)
	for i =1,#self.subgoals do
		local status,dt = self.subgoals[i]:process(dt,owner)
		if status == STATE_SUCCESS then
			table.remove(self.subgoals[i])
			i = i-1
		end
	end
	if #self.subgoals>0 then
		return STATE_ACTIVE,dt
	else
		return STATE_SUCCESS,dt
	end
end

function AI.ApproachAndAttack(t2,t,attackskill,range,firerange)
	AIDemo = Sequence:new()
	AIDemo:push(OrderMoveTowardsRange:new(t,range))
	AIDemo:push(OrderStop:new())
	AIDemo:push(OrderChannelSkill:new(attackskill,function()return {normalize(t.x-t2.x,t.y-t2.y)},t2,attackskill end))
	AIDemo:push(OrderWaitUntil:new(function()t2:setAngle(math.atan2(t.y-t2.y,t.x-t2.x))return getdistance(t,t2)>firerange or t.invisible end))
	AIDemo:push(OrderStop:new())
	AIDemo.loop = true
	return AIDemo
end
