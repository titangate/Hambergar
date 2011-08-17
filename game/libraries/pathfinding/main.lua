local index = require ('libraries.pathfinding.index')

AIMap = Object:subclass('AIMap')

function AIMap:initialize(w,h,meter)
	meter = meter or 40
	self.meter = meter
	self.w,self.h = w,h
	self.terrain = index()
end

function AIMap:draw()
	for x,y in self.terrain:keys() do
		if self.terrain[{x,y}] then love.graphics.rectangle('fill',x*30,y*30,30,30) end
	end
end

function heuristic_cost_estimate(start,goal)
	return math.abs(goal[1]-start[1])+math.abs(goal[2]-start[2])
end

-- The neibournode shift. the 3rd item of the table is the distance to the original node.
local shifts = {
--	{-1,-1,1.4},
	{0,-1,1},
--	{1,-1,1.4},
	{-1,0,1},
	{1,0,1},
--	{-1,1,1.4},
	{0,1,1},
--	{1,1,1.4}
}


function AIMap:get_neighbor_nodes(t)
	return coroutine.wrap(function (node)
		for k,v in pairs(shifts) do
			local t = {v[1]+node[1],v[2]+node[2]}
			if not self.terrain[t] then -- if the node is passable
				coroutine.yield(t,v[3])
			end
		end
	end), t
end

function AIMap:astar(start,goal)
	start={self:scaleDown(unpack(start))}
	goal={self:scaleDown(unpack(goal))}
	local closedset = index()
	local openset = index()
	openset[start] = 1
	local camefrom = index()
	
	local gscore = index()
	local hscore = index()
	local fscore = index()
	gscore[start] = 0
	hscore[start] = heuristic_cost_estimate(start,goal)
	fscore[start] = hscore[start]
	
	while openset ~= {} do
		local f,x = nil,nil
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
		for y,dis in self:get_neighbor_nodes(x) do
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
		table.insert(path,{map.aimap:scaleUp(unpack(currentnode))})
		currentnode = camefrom[currentnode]
	end
	return path
end


function AIMap:setMeter(m)
	self.meter = m
end

function AIMap:scaleDown_(t,i)
	if t[i]~=nil then
		return math.floor(t[i]/self.meter),self:scaleDown_(t,i+1)
	end
end

function AIMap:scaleDown(...)
	return self:scaleDown_(arg,1)
end

function AIMap:scaleUp_(t,i)
	if t[i]~=nil then
		return (t[i]+0.5)*self.meter,self:scaleUp_(t,i+1)
	end
end
function AIMap:scaleUp(...)
	return self:scaleUp_(arg,1)
end

function AIMap:setBlock(x,y,b)
	self.terrain[{self:scaleDown(x,y)}]=b
end

function AIMap:getBlock(x,y)
	return self.terrain[{self:scaleDown(x,y)}]
end
