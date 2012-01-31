function extractMin(t,condition)
	if #t == 0 then
		return
	end
	if #t == 1 then
		return table.remove(t,id)
	end
	local n,id = condition(t[1]),1
	for i=2,#t do
		local c = condition(t[i])
		if c < n then
			n,id = c,i
		end
	end
	return table.remove(t,id)
end

function normalize(x,y)
	local d = math.sqrt(x*x+y*y)
	if d == 0 then
		return 0,0,0
	else
		return x/d,y/d,d
	end
end

function distanceBetween(a,b)
	local dx,dy = a.x-b.x,a.y-b.y
	return math.sqrt(dx*dx+dy*dy)
end

local img = {
	ray = love.graphics.newImage'ray.png',
	dot = love.graphics.newImage'dot.png',s
}
Lighter = Object:subclass'Lighter'
function Lighter:initialize()
	self.obj = {}
end

function Lighter:update(dt)
	self.beam = {}
	for v,_ in pairs(self.obj) do
		v:update(dt)
	end
	local count = 1
	while count <= #self.beam do
		self.beam[count]:process()
		count = count + 1
	end
end

function Lighter:draw()
	for _,v in pairs(self.beam) do
		v:draw()
	end
	for v,_ in pairs(self.obj) do
		v:draw()
	end
end

function Lighter:addLighterObject(o)
	assert(o:isKindOf(LighterObject))
	self.obj[o]=true
	o.parent = self
end

function Lighter:removeLighterObject(o)
	self.obj[o] = nil
	o.parent = nil
end

function Lighter:addBeam(b)
	table.insert(self.beam,b)
end

function Lighter:reset()
	self.obj = {}
end

function Lighter:setDelegate(delegate)
	self.delegate = delegate
end

LightBeam = Object:subclass'LightBeam'
function LightBeam:initialize(x,y,color,direction,source)
	self.x,self.y = x,y
	self.color = color
	self.direction = direction
	self.length = 99999
	self.source = source
end

function LightBeam:casted(beam)
	return false
end

function LightBeam:process()
	local obj = {}
	local dx,dy = math.cos(self.direction),math.sin(self.direction)
	for v,_ in pairs(self.parent.obj) do
		if v~=self and v~=self.source then
			local s = true
			local r = v.radius or 10
			local d = (v.x-self.x)/dx
			local x,y,d = normalize(v.x-self.x,v.y-self.y)
			r = r/d
			local nx,ny = dx-x,dy-y
			if nx*nx+ny*ny < r*r then -- ray cast
				table.insert(obj,v)
			end
		end
	end
	while #obj>0 do
		local o = extractMin(obj,function(t)
			local dx,dy = t.x-self.x,t.y-self.y
			return dx*dx+dy*dy
		end)
		gamelistener:notify{
			type = 'lightcast',
			object = o,
			beam = self,
		}
		if o:casted(self) then
			self.length = distanceBetween(o,self)
			return
		end
	end
end

function LightBeam:draw()
	love.graphics.setColor(self.color)
	love.graphics.draw(img.ray,self.x,self.y,self.direction,self.length,1,0,17.5)
	love.graphics.setColor(255,255,255)
end

LighterObject = Object:subclass'LighterObject'
function LighterObject:initialize(x,y,r)
	self.x,self.y,self.r = x,y,r or 10
end
function LighterObject:update(dt)
end

function LighterObject:draw()
end

function LighterObject:draw_debug()
end

LightSource = LighterObject:subclass'LightSource'
function LightSource:initialize(x,y,color,direction)
	self.x,self.y = x,y
	self.color = color
	self.direction = direction
end

function LightSource:setColor(color)
end

function LightSource:setPosition(x,y)
end

function LightSource:casted(beam)
	return false
end

function LightSource:update(dt)
	local l = LightBeam(self.x,self.y,self.color,self.direction,self)
	l.parent = self.parent
	self.parent:addBeam(l)
end

GlobalLightSource = LighterObject:subclass'GlobalLightSource'
function GlobalLightSource:initialize(x,y,color)
	self.x,self.y,self.color = x,y,color
end

Filter = LighterObject:subclass'Filter'
function Filter:initialize(x,y,color)
	self.x,self.y,self.color = x,y,color
end

function Filter:casted(beam)
	local newc = {}
	for i=1,#beam.color do
		local c = self.color[i] or 255
		newc[i] = math.min(255,beam.color[i]+c)
	end
	local l = LightBeam(self.x,self.y,newc,beam.direction,self)
	l.parent = self.parent
	self.parent:addBeam(l)
	return true
end

function Filter:draw()
	love.graphics.setColor(self.color)
	love.graphics.circle('fill',self.x,self.y,16,10)
	love.graphics.setColor(255,255,255)
end

Obstacle = LighterObject:subclass'Obstacle'
function Obstacle:initialize(x,y,r)
	self.x,self.y,self.r = x,y,r
	self.enable = true
end

function Obstacle:enable(state)
	self.enable = state
end

function Obstacle:casted(beam)
	return self.enable
end

Mirror = LighterObject:subclass'Mirror'
function Mirror:initialize(x,y,direction)
	self.x,self.y,self.direction = x,y,direction
end

function Mirror:casted(beam)
	local dir = self.direction*2+math.pi-beam.direction
	local l = LightBeam(self.x,self.y,beam.color,dir,self)
	l.parent = self.parent
	self.parent:addBeam(l)
	return true
end

function Mirror:draw()
	love.graphics.draw(img.dot,self.x,self.y,self.direction+math.pi/2,30,5,0.5,0.5)
end

Portal = LighterObject:subclass'Portal'
function Portal:initialize(x,y,direction)
	self.x,self.y,self.direction = x,y,direction
	self.color = {255,0,0}
end

function Portal:link(b)
	self.portal = b
	b.portal = self
	self.color = {255,0,0}
	b.color = {0,0,255}
end

function Portal:casted(beam)
	if self.portal then
		local l = LightBeam(self.portal.x,self.portal.y,beam.color,beam.direction-self.direction+self.portal.direction,self.portal)
		l.parent = self.parent
		self.parent:addBeam(l)
		return true
	else
		return false
	end
end

function Portal:draw()
	love.graphics.setColor(self.color)
	love.graphics.draw(img.dot,self.x,self.y,self.direction+math.pi/2,30,5,0.5,0.5)
	love.graphics.setColor(255,255,255)
end