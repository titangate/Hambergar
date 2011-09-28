Map=Object:subclass('Map')

--[[
a list of type of unit and corresponding data
					CategoryID	Mask	Group
item				1			34567
doodad				2			56
player				3			1357
enemy				4			1467
player Missile		5			12357
enemy Missiles		6			12467
dead				7			13456
]]--

cc = {
	item = 1,
	doodad = 2,
	player = 3,
	enemy = 4,
	playermissile = 5,
	enemymissile = 6,
	dead = 7,
} -- collide category


typeinfo = {
	doodad = {2,{5,6}},
	player = {3,{3,5,7}},
	enemy = {4,{6,7}},
	playerMissile = {5,{5,6}},
	enemyMissile = {6,{6}},
	dead = {7,{5,6}},
	terrain = {8}
}

function Map:initialize(w,h)
	self.world = love.physics.newWorld(-w/2,-h/2,w/2,h/2)
	self.world:setCallbacks(add,nil,persist)
	self.units = {}
	self.destroys = {}
	self.updatable = {}
	self.waypoints = {}
--	self.aimap = AIMap:new(30,30,40)
	self:registerListener(gamelistener)
	self.count = {}
	self.blood = {}
end

MapBlock = Object:subclass('MapBlock')
function MapBlock:initialize(body,shape,index)
	self.body,self.shape,self.index = body,shape,index
end

function MapBlock:preremove()
	self.shape:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
end

function MapBlock:add(b,c)
--	print (b,c)
	self:notifyListeners({type='add',area=self,index=self.index,unit = b,coll=c})
end

function MapBlock:destroy()
	self.shape:destroy()
	self.body:destroy()
end

function Map:setBlock(x,y,b)
	if b then
		local body = love.physics.newBody(self.world,x,y)
		local shape = love.physics.newRectangleShape(body,0,0,40,40)
		shape:setCategory(8)
		shape:setMask(5,6)
		if b>0 then
			shape:setSensor(true)
			self.waypoints[b] = {x,y}
		end
		local mb = MapBlock:new(body,shape,b)
--		self.aimap:setBlock(x,y,mb)
		shape:setData(mb)
		mb:registerListener(gamelistener)
	else
	end	
end

function Map:placeObstacle(x,y,w,h,b)
	local body = love.physics.newBody(self.world,x+w/2,y+h/2)
	local shape = love.physics.newRectangleShape(body,0,0,w,h)
	shape:setCategory(8)
	shape:setMask(5,6)
	if b then
		shape:setSensor(true)
		self.waypoints[b] = {x,y}
	end
	local mb = MapBlock:new(body,shape,b)
	shape:setData(mb)
	mb:registerListener(gamelistener)
end

function Map:getBlock(x,y)
--	return self.aimap:getBlock(x,y)
end

function Map:findPath(start,goal)
--	return self.aimap:astar(start,goal)
end


function persist(a,b,c)
--	if map.units[a] and map.units[b] then
	if a and b then
		if a.persist then
			a:persist(b,c)
		end
		if b.persist then
			b:persist(a,c)
		end
	end
--	end
end


function add(a,b,c)
--	if map.units[a] and map.units[b] then
	if a and b then
		if a.add then
			a:add(b,c)
		end
		if b.add then
			b:add(a,c)
		end
	end
--	end
end

function Map:addUnit(...)
	for k,unit in ipairs(arg) do
		self.units[unit] = true
		if unit.createBody then unit:createBody(self.world) end
		unit:registerListener(gamelistener)
		local controller = unit.controller or 'default'
		self.count[controller] = self.count[controller] or 0
		self.count[controller] = self.count[controller] + 1
	end
end

function Map:addUpdatable(...)
	for k,unit in ipairs(arg) do
		self.updatable[unit] = true
	end
end

function Map:removeUpdatable(...)
	for k,unit in ipairs(arg) do
		self.updatable[unit] = nil
	end
end

function Map:removeUnit(...)
	for k,unit in ipairs(arg) do
		table.insert(self.destroys,unit)
		if unit.preremove then unit:preremove() end
		local controller = unit.controller or 'default'
		assert(self.count[controller])
		self.count[controller] = self.count[controller] - 1
	end
end

function Map:update(dt)
	if self.timescale then
		dt = self.timescale * dt
	end
	collides = {}
	self.world:update(dt)
	for k,v in pairs(self.destroys) do
		if v.destroy then v:destroy() end
		self.units[v] = nil
	end
	self.destroys = {}
	for unit,v in pairs(self.units) do
		if unit.update then unit:update(dt) end
	end
	for unit,v in pairs(self.updatable) do
		if unit.update then unit:update(dt) end
	end
end

function Map:draw()
		Blureffect.begin()
	if self.camera then self.camera:apply() end
	if self.background then self.background:draw() end
	for unit,v in pairs(self.units) do
		if unit.draw then unit:draw() end
	end
	for unit,v in pairs(self.updatable) do
		if unit.draw then unit:draw() end
	end
	local x,y = unpack(GetOrderDirection())
	local px,py = unpack(GetOrderPoint())
	love.graphics.draw(img.cursor,px,py,math.atan2(y,x),1,1,16,16)
	if self.camera then map.camera:revert() end
		Blureffect.finish()
end

function Map:findUnitsInArea(area)
	if area.type == 'circle' then
		return self:findUnitsWithCondition(
			function(unit) 
				return withincirclearea(unit,area.x,area.y,area.range)
		end)
	elseif area.type == 'fan' then
		return self:findUnitsWithCondition(
			function(unit) 
				return withinfanarea(unit,area.x,area.y,area.r,area.angle,area.range)
		end)
	end
end

function Map:findUnitsWithCondition(func)
	result = {}
	for unit,v in pairs(self.units) do
		if unit:isKindOf(Unit) and func(unit) then
			table.insert(result,unit)
		end
	end
	return result
end

function normalize(x,y)
	local n = math.sqrt(x*x+y*y)
	if n==0 then return 0,0 end
	return x/n,y/n
end

function withinrectanglearea(unit,x,y,w,h)
	return unit.x>=x and unit.x<=x+w and unit.y>=y and unit.y<=y+h
end

function withincirclearea(unit,x,y,r)
	return getdistance(unit,{x=x,y=y})<r
end

function withinfanarea(unit,x,y,r,angle,range)
	local angle2 = math.atan2(unit.y-y,unit.x-x)
	if angle<0 then
		angle = angle + math.pi*2
	end
	if angle2<0 then
		angle2 = angle2 + math.pi*2
	end
	return getdistance(unit,{x=x,y=y})<r and math.abs(angle2-angle)<range
end

function getdistance(a,b)
	x,y=a.x-b.x,a.y-b.y
	return math.sqrt(x*x+y*y)
end

function displacement(x,y,angle,dis)
	local cos,sin = math.cos(angle),math.sin(angle)
	return x+dis*cos,y+dis*sin
end