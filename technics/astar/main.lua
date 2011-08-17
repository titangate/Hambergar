local index = require ('index')

Map = {}
Map.__index = Map

function Map.create(w,h)
	local self = {}
	setmetatable(self,Map)
	self.w,self.h = w,h
	self.terrain = index()
	return self
end

function Map:draw()
	for x,y in map.terrain:keys() do
		if map.terrain[{x,y}] then love.graphics.rectangle('fill',x*30,y*30,30,30) end
	end
end

function heuristic_cost_estimate(start,goal)
	return math.abs(goal[1]-start[1])+math.abs(goal[2]-start[2])
end

-- The neibournode shift. the 3rd item of the table is the distance to the original node.
shifts = {
	{-1,-1,1.4},
	{0,-1,1},
	{1,-1,1.4},
	{-1,0,1},
	{1,0,1},
	{-1,1,1.4},
	{0,1,1},
	{1,1,1.4}
}

function get_neighbor_nodes_it(node)
	for k,v in pairs(shifts) do
		local t = {v[1]+node[1],v[2]+node[2]}
		if not map.terrain[t] then -- if the node is passable
			coroutine.yield(t,v[3])
		end
	end
end
function get_neighbor_nodes(t)
	return coroutine.wrap(get_neighbor_nodes_it), t
end

function astar(start,goal)
	closedset = index()
	openset = index()
	openset[start] = 1
	camefrom = index()
	
	gscore = index()
	hscore = index()
	fscore = index()
	gscore[start] = 0
	hscore[start] = heuristic_cost_estimate(start,goal)
	fscore[start] = hscore[start]
	
	while openset ~= {} do
		f = nil
		for cx,cy in openset:keys() do
			v = {cx,cy}
			if f==nil then f,x = fscore[v],v end
			if f>fscore[v] then
				f,x = fscore[v],v
			end
		end
		if x[1]==goal[1] and x[2]==goal[2] then
			return reconstruct_path(camefrom,camefrom[goal])
		end
		openset[x] = nil
		closedset[x] = 1
		for y,dis in get_neighbor_nodes(x) do
			if not closedset[y] then
				tentative_g_score = gscore[x] + dis
				if not openset[y] then
					openset[y] = 1
					tentative_is_better = true
				elseif tentative_g_score < gscore[y] then
					tentative_is_better = true
				else
					tentative_is_better = false
				end
				if tentative_is_better then
					camefrom[y] = x
					gscore[y] = tentative_g_score
					hscore[y] = heuristic_cost_estimate(y,goal)
					fscore[y] = gscore[y] + hscore [y]
				end
			end
		end
	end
	return false
end


function reconstruct_path(camefrom,currentnode)
	local path = {}
	while camefrom[currentnode] do
		table.insert(path,currentnode)
		currentnode = camefrom[currentnode]
	end
	return path
end

map = Map.create(10,10)
map.terrain[{4,5}] = true
map.terrain[{4,6}] = true
map.terrain[{4,7}] = true
function findcoord(x,y)
	return math.floor(x/30),math.floor(y/30)
end
function love.mousepressed(x,y,b)
	x,y = findcoord(x,y)
	point = {x,y}
	if point == start or point == goal then return end
	map.terrain[point] = not map.terrain[point]
end

function love.keypressed(k)
	local x,y = findcoord(love.mouse.getPosition())
	if k=='g' then
		start = {x,y}
	elseif k == 't' then
		goal = {x,y}
	elseif k == 's' then
		for i=1,1 do path = astar(goal,start) end
	end
end

function love.draw()
	love.graphics.setColor(255,80,80,255)
	if start then love.graphics.rectangle('fill',start[1]*30,start[2]*30,30,30) end
	love.graphics.setColor(80,80,255,255)
	if goal then love.graphics.rectangle('fill',goal[1]*30,goal[2]*30,30,30) end
	love.graphics.setColor(80,255,80,255)
	if path then
		for k,v in pairs(path) do
			love.graphics.circle('fill',v[1]*30+15,v[2]*30+15,15,30)
		end
	end
	map:draw()
end