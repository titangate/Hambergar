require 'astar'
function normalize(x,y)
	local mag = math.sqrt(x*x+y*y)
	if mag == 0 then
		return 0,0,0
	else
		return x/mag,y/mag,mag
	end
end

function distancebetweensq(a,b)
	return (b.x-a.x)^2+(b.y-a.y)^2
end

StealthSystem = Object:subclass'StealthSyste'
function StealthSystem:initialize()
	self.ai = {}
	self.suspicioustime = 5
	self.lastseen = nil
	self.investigate = nil
	self.astar = AStar(self)
end

-- Set the path finding map
function StealthSystem:setMap(map)
	self.map = map
	self.regions = {}
	local tw,th = self.map.tileWidth,self.map.tileHeight
	local w,h = self.map.width,self.map.height
	local layer = self.map.tl["Path"]
	for i=1,w do
		table.insert(self.regions,{})
		for j=1,h do
			local layer = self.map.tl["Path"]
			table.insert(self.regions[i],{
				x = i,
				y = j,
				tile = self.map.tiles[layer.tileData[i][j]],
			})
		end
	end
end
-- Set what unit every enemy is targeting
function StealthSystem:setTarget(unit)
	self.unit = unit
end
-- Whenever a new AI is created with this system, this function is to be called
function StealthSystem:addAI(ai)
	assert(ai)
	table.insert(self.ai,ai)
end
-- Whenever an AI spot their target, the last seen position of the target is to be 
-- updated with this method
function StealthSystem:updateLastseen(region)
	assert(region)
	self.lastseen = region
end
-- Just an update function
function StealthSystem:update(dt)
end
-- Use this function to create distraction. This function is responsible of creating 
-- ditraction-->investigation behavior
function StealthSystem:disrupt(region,level)
	level = level or 0
	self.investigate = region
end
-- When a unit finishes investigation, they are expected to wander around the last seen
-- position. This function returns such region given the target region
function StealthSystem:getWanderRegion(r)
end
-- If an investigation unit is requested, this function will find the best possible unit and
-- returns it. 
function StealthSystem:getAvailableUnit()
end
-- Receives coordinates, returns tile
function StealthSystem:getTile(x,y)
	assert(self.map)
	local w,h = self.map.tileWidth,self.map.tileHeight
	local layer = self.map.tl["Path"]
	local nx,ny = math.floor(x/w)+1,math.floor(y/h)+1
	return self.map.tiles[layer.tileData[ny][nx]],nx,ny
end
-- convert coordinate into (stored) region data
function StealthSystem:getRegion(x,y)
	assert(self.map)
	local w,h = self.map.tileWidth,self.map.tileHeight
	local layer = self.map.tl["Path"]
	local nx,ny = math.floor(x/w)+1,math.floor(y/h)+1
	return self.regions[nx][ny]
end
-- pathfinding with A*
function StealthSystem:getNode(location)
	local x,y = location.x,location.y
	local w,h = self.map.tileWidth,self.map.tileHeight
	local layer = self.map.tl["Path"]
	if x > w or x < 1 then
		return
	end
	if y > h or y < 1 then
		return
	end
	if self.regions[x][y].tile.properties.obstacle then
		return
	end
	return Node(location,10,location.y*h+location.x)
end
function StealthSystem:getAdjacentNodes(curnode,dest)
	local result = {}
	local cl = curnode.location
	local dl = dest
	local n = false
	n = self:_handleNode(cl.x + 1, cl.y, curnode, dl.x, dl.y)
	if n then
	  table.insert(result, n)
	end

	n = self:_handleNode(cl.x - 1, cl.y, curnode, dl.x, dl.y)
	if n then
	  table.insert(result, n)
	end

	n = self:_handleNode(cl.x, cl.y + 1, curnode, dl.x, dl.y)
	if n then
	  table.insert(result, n)
	end

	n = self:_handleNode(cl.x, cl.y - 1, curnode, dl.x, dl.y)
	if n then
	  table.insert(result, n)
	end
	return result
end
function StealthSystem:locationsAreEqual(a,b)
	return a.x == b.x and a.y == b.y
end
function StealthSystem:_handleNode(x,y,fromnode,destx,desty)
	-- Fetch a Node for the given location and set its parameters
	local loc = {
	    x = x,
	    y = y
	  }

	  local n = self:getNode(loc)
	  if n ~= nil then
	    local dx = math.max(x, destx) - math.min(x, destx)
	    local dy = math.max(y, desty) - math.min(y, desty)
	    local emCost = dx + dy

	    n.mCost = n.mCost + fromnode.mCost
	    n.score = n.mCost + emCost
	    n.parent = fromnode

	    return n
	  end

	  return nil
end
function StealthSystem:getPath(origin,target)
	assert(origin)
	assert(target)
	local path = self.astar:findPath(target, origin) -- backwards, in order to make the list poppable from the back
	if not path then return nil end
	local result = {target}
	for i,v in pairs(path:getNodes()) do
		print (v.location.x,v.location.y)
		table.insert(result,self.regions[v.location.y][v.location.x])
	end
	return result
end

function StealthSystem:checkTileState(x,y)
	local w,h = self.map.tileWidth,self.map.tileHeight
	if debugc.drawraycast then
		addDrawCommand(function()
			love.graphics.setColor(0,0,255,100)
			love.graphics.rectangle('fill',x*w-w,y*h-h,w,h)
			love.graphics.setColor(255,255,255)
		end)
	end
	return self.regions[x][y].tile.properties.obstacle
end

-- Return a bool, indicates if unit a can see b
function StealthSystem:see(a,b)
	if true then return true end
	a,b = self:getRegion(a.x,a.y),self:getRegion(b.x,b.y)
	-- bresenham's line algorithm
	local x0,y0,x1,y1 = a.x,a.y,b.x,b.y
	local steep = math.abs(y1-y0)>math.abs(x1-x0)
	if steep then
		x0,y0 = y0,x0
		x1,y1 = y1,x1
	end
	if x0>x1 then
		x0,x1 = x1,x0
		y0,y1 = y1,y0
	end
	local dx = x1-x0
	local dy = math.abs(y1-y0)
	local err = dx/2
	local ystep
	local y = y0
	if y0<y1 then ystep = 1 else ystep = -1 end
	for x=x0,x1 do
		if steep then
			if self:checkTileState(y,x) then return false end
		else
			if self:checkTileState(x,y) then return false end
		end
		err = err - dy
		if err < 0 then
			y = y + ystep
			err = err + dx
		end
	end
	return true
end

GeneralAI = StatefulObject:subclass'GeneralAI'
function GeneralAI:initialize(system)
	super.initialize(self)
	self.sys = system
	self.sys:addAI(self)
end
function GeneralAI:process(unit,dt)
end
-- Is to be called when ever the unit changes direction.
function GeneralAI:orderMoveTo(unit,region)
	if self.targetregion ~= region then
		self.targetregion = region
		self.path = self.sys:getPath(unit:getRegion(),region)
	end
	if not self.path or #self.path<1 then
		unit.vx,unit.vy = 0,0
		self.targetregion = nil
		return
	end
	if distancebetweensq(unit:getRegion(),self.path[#self.path])<=2 then
		table.remove(self.path)
	else
		local t = self.path[#self.path]
		local w,h = self.sys.map.tileWidth,self.sys.map.tileHeight
		unit.vx,unit.vy = normalize(t.x*w-unit.x,t.y*h-unit.y)
		unit.vx,unit.vy = unit.vx*100,unit.vy*100
	end
end
-- Is to be called when ever the unit changes target.
function GeneralAI:orderAttack(unit,target)
end

StealthAI = GeneralAI:subclass'StealthAI'
function StealthAI:initialize(system)
	super.initialize(self,system)
end

function StealthAI:getRegion(unit)
	return self.sys:getRegion(unit.x,unit.y)
end

function StealthAI:process(unit,dt)
	if self.sys.unit then
		if self.sys:see(unit,self.sys.unit) then
			self:gotoState'suspicious'
			self.sys:updateLastseen(self.sys:getRegion(self.sys.unit.x,self.sys.unit.y))
		end
	end
	super.process(self,unit,dt)
end

-- Accepting a list. The unit will start to walk around the route given. 
-- Will add other arguments in the future
function StealthAI:setPatrolPath(path)
	self.patrolpath = path
end

function StealthAI:investigate(area)
	self.targetarea = area
	self:gotoState'investigate'
end

function StealthAI:suspicious(time)
	self:gotoState'suspicious'
end

function StealthAI:alarm(time)
	self:gotoState'alarm'
end



local investigate = StealthAI:addState'investigate'
function investigate:process(unit,dt)
	if self.sys.unit then
		if self.sys:see(unit,self.sys.unit) then
		self.sys:updateLastseen(self.sys:getRegion(self.sys.unit.x,self.sys.unit.y))
			self:gotoState'suspicious'
		elseif unit:getRegion() == self.sys.investigate then
			self:popState()
		else
			self:orderMoveTo(unit,self.sys.investigate)
		end
	end
	unit:setIndicator'Investigate'
	GeneralAI.process(self,unit,dt)
	
end

local suspicious = StealthAI:addState'suspicious'
function suspicious:process(unit,dt)
	if self.sys.unit then
		if self.sys:see(unit,self.sys.unit) then
		self.sys:updateLastseen(self.sys:getRegion(self.sys.unit.x,self.sys.unit.y))
			self:pushState'alarm'
		else
			self.time = self.time - dt
			if self.time <= 0 then
				self:popState()
				return
			end
			if not self.target or unit:getRegion() == self.target then
				self.target = self.sys:getWanderRegion()
				self:orderMoveTo(unit,self.target)
			end
			
		end
	else
		self:popState()
	end
	
	unit:setIndicator'Suspicious'
	GeneralAI.process(self,unit,dt)
end

function suspicious:enterState()
	self.time = self.sys.suspicioustime
end

function suspicious:continuedState()
	suspicious.enterState(self)
end

function suspicious:pushedState()
	suspicious.enterState(self)
end

local alarm = StealthAI:addState'alarm'
function alarm:pushedState()
	alarm.enterState(self,alarm)
end
function alarm:enterState()
	
end
function alarm:process(unit,dt)
	if self.sys.unit and self.sys.lastseen then
		if self.sys:see(unit,self.sys.unit) then
			self:orderAttack(unit,self.sys.unit)
			self.sys:updateLastseen(self.sys:getRegion(self.sys.unit.x,self.sys.unit.y))
			self:orderMoveTo(unit,self.sys.lastseen)
		elseif unit:getRegion() == self.sys.lastseen then
			self:popState()
		else
			self:orderMoveTo(unit,self.sys.lastseen)
		end
	else
		self:popState()
	end
	unit:setIndicator'Alarm'
	GeneralAI.process(self,unit,dt)
end