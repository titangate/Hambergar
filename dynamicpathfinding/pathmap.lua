local intersect = function(r1,r2)
	return math.abs(r1.x-r2.x)<=(r1.w+r2.w)/2 and math.abs(r1.y-r2.y)<=(r1.h+r2.h)/2
end
local cost = function(r1,r2)
	local dx,dy = r1.x-r2.x,r1.y-r2.y
	return dx*dx+dy*dy
end

function normalize(x,y)
	local length = (x*x+y*y)^0.5
	return x/length,y/length
end

local INF = 12346789
local regionmeta = {
	__index = function(t,k)
		local v = rawget(t,k)
		v = v or INF
		return v
	end
}

PathMap = Object:subclass'PathMap'
function PathMap:initialize()
	self.map = {}
	self.regions = {}
	self.next = {}
	self.joint = {}
end

function PathMap:insertRegion(r)
	self.map[r] = self.map[r] or {}--setmetatable({},regionmeta)
	self.next[r] = self.next[r] or {}
	self.joint[r] = self.joint[r] or {}
	self.map[r][r] = 0
	for i=1,#self.regions do
		local g = self.regions[i]
		if intersect(r,g) then
			self.map[r][g] = cost(r,g)
			self.map[g][r] = self.map[r][g]
			self.joint[g][r] = {x=(math.max(r.x-r.w/2,g.x-g.w/2)+math.min(r.x+r.w/2,g.x+g.w/2))/2,
				y=(math.max(r.y-r.h/2,g.y-g.h/2)+math.min(r.y+r.h/2,g.y+g.h/2))/2}
--			self.next[r][g] = g
--			self.next[g][r] = r
		end
	end
	table.insert(self.regions,r)
end

function PathMap:setRegionConnectivity(r1,r2,state)
	assert(self.map[r1])
	assert(self.map[r2])
	self.map[r1][r2] = state
	self.map[r2][r1] = state
end

function PathMap:buildMap()
	-- Floyd-Warshall
	for _,k in ipairs(self.regions) do
		for _,i in ipairs(self.regions) do
			for _,j in ipairs(self.regions) do
				self.map[i][k] = self.map[i][k] or INF
				self.map[k][j] = self.map[k][j] or INF
				self.map[i][j] = self.map[i][j] or INF
				if self.map[i][k] + self.map[k][j] < self.map[i][j] then
					self.map[i][j] = self.map[i][k] + self.map[k][j]
					self.next[i][j] = k
				end
			end
		end
	end
end

function PathMap:getPath(i,j)
	assert(i)
	assert(j)
	if self.map[i][j] >= INF then
		return false
	end
	local intermediate = self.next[i][j]
	if not intermediate then
		return {}
	else
		assert(intermediate)
		local h = self:getPath(i,intermediate)
		local t = self:getPath(intermediate,j)
		assert(h~=false)
		assert(t~=false)
		table.insert(h,intermediate)
		for i,v in ipairs(t) do
			table.insert(h,v)
		end
		return h
	end
end

function PathMap:printMap()
	for k1,v1 in pairs(self.next) do
		for k2,v2 in pairs(v1) do
			print (k1.name,k2.name,v2.name)
		end
	end
end

function PathMap:getDirection(origin,target)
	if origin.region == target.region then
		return {normalize(target.x-origin.x,target.y-origin.y)}
	else
		local intermediate = self.next[origin.region][target.region]
		local target = intermediate or target.region
		target = self.joint[origin.region][target] or target
		return {normalize(target.x-origin.x,target.y-origin.y)}
	end
	return {0,0}
end