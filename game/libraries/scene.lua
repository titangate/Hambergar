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
	terrain = 8,
	all = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16},
} -- collide category


typeinfo = {
	doodad = {2,{5,6}},
	player = {3,{3,5,7}},
	enemy = {4,{6,7}},
	playerMissile = {5,{3,5,6}},
	enemyMissile = {6,{6,4}},
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
	self.obstacles = {}
	controller:setLockAvailability(options.aimassist)
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
	if b:isKindOf(Unit) then
		self:notifyListeners({type='add',area=self,index=self.index,unit = b,coll=c})
	end
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

function Map:placeObstacle(x,y,w,h,b,name)
	local body = love.physics.newBody(self.world,x+w/2,y+h/2)
	local shape = love.physics.newRectangleShape(body,0,0,w,h)
	shape:setCategory(8)
	shape:setMask(5,6)
	if b then
		shape:setSensor(true)
		self.waypoints[b] = {x,y}
	end
	local mb = MapBlock:new(body,shape,b)
	if name then
		self.obstacles[name]=mb
	end
	shape:setData(mb)
	mb:registerListener(gamelistener)
end

function Map:setObstacleState(b,state)
	local obs = self.obstacles[b]
	assert(obs)
	mb.shape:setSensor(not state)
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
	--
	--
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
	if self.background then
		self.background:update(dt)
	end
	if not self.disableBlur then
		Blureffect.update(dt)
	end
	
end

function Map:draw()
	if not self.disableBlur then
		Blureffect.begin()
	end
	if self.camera then self.camera:apply() end
	if self.background then self.background:draw() end
	
	Lighteffect.begin(self.units)
	Lighteffect.finish()
--	if self.camera then self.camera:apply() end
	for unit,v in pairs(self.units) do
		if unit.draw then unit:draw() end
	end
	for unit,v in pairs(self.updatable) do
		if unit.draw then unit:draw() end
	end
	
--	if self.camera then self.camera:revert() end
	local x,y = unpack(GetOrderDirection())
	local px,py = unpack(GetOrderPoint())
	--[[
	if StealthSystem.lastseen then
		love.graphics.circle('fill',StealthSystem.lastseen.x,StealthSystem.lastseen.y,16)
	end]]
	love.graphics.draw(img.cursor,px,py,math.atan2(y,x),1,1,16,16)
	if self.camera then self.camera:revert() end
	if not self.disableBlur then
		Blureffect.finish()
	end
	local u = GetOrderUnit()
	if u then
		local x,y = u.x,u.y
		x,y = map.camera:transform(x,y)
		x,y = x+screen.halfwidth,y+screen.halfheight
		love.graphics.circle('line',x,y,16,30) -- TODO: make a better lock on Image
	end
	
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

function Map:loadUnitFromTileObject(obj)
	local w,h=self.w,self.h
	if loadstring('return '..obj.name)() then
		local object = loadstring('return '..obj.name..':new()')()
		assert(object)
		object.x,object.y=obj.x-w/2,obj.y-h/2
		if obj.properties.controller then
			object.controller = obj.properties.controller
		end
		object.r = obj.properties.angle or math.random(3.14)
		self:addUnit(object)
		if object.controller=='enemy' and object.enableAI then
			object:enableAI()
		end
		if obj.properties.id then
			_G[obj.properties.id]=object
		end
	end
end

function Map:loadTiled(tmx)
	local w,h=self.w,self.h
	local loader = require("AdvTiledLoader/Loader")
	loader.path = "maps/"
	local m = loader.load(tmx)
	m.useSpriteBatch=true
	m.drawObjects=false
	local oj = m.objectLayers
	for k,v in pairs(oj) do
		if v.name == 'obstacles' then
			for _,obj in pairs(v.objects) do
				self:placeObstacle(obj.x-w/2,obj.y-h/2,obj.width,obj.height)
			end
		elseif v.name == 'areas' then
			for _,obj in pairs(v.objects) do
				self:placeObstacle(obj.x-w/2,obj.y-h/2,obj.width,obj.height,obj.name)
			end
		elseif v.name == 'objects' then
			for _,obj in pairs(v.objects) do
				if obj.properties.phrase then
					local p = obj.properties.phrase
					unitdict[p] = unitdict[p] or {}
					table.insert(unitdict[p],obj)
				else
					self:loadUnitFromTileObject(obj,w,h)
				end
			end
		end
	end
	self.tiled = m
	return m
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
