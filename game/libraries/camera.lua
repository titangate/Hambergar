require 'anim.style'
Transformation = Object:subclass('CameraTransformation')
function Transformation:initialize(object,item,vi,vf,time,s,stylearg)
	self.object = object
	self.item = item
	self.vi = vi
	self.vf = vf
	self.time = time or 0
	self.dt = 0
	self.style = s or style.linear
	self.stylearg = stylearg or {}
	map:addUpdatable(self)
end
function Transformation:update(dt)
	self.dt = self.dt + dt
	if self.dt >= self.time then
--		self.object.modifier[self.item] = nil
		map:removeUpdatable(self)
	end
	self.object[self.item] = self.style(self.dt,self.vi,self.vf-self.vi,self.time,unpack(self.stylearg))
end
Camera = Object:subclass('Camera')

function Camera:initialize(x,y,sx,sy,r)
	x = x or 0
	y = y or 0
	sx = sx or 1
	sy = sy or 1
	r = r or 0
	self.ox = 0
	self.oy = 0
	self.x,self.y,self.sx,self.sy,self.r=x,y,sx,sy,r
	self.transformations = {}
end

function Camera:apply(z)
	love.graphics.push()
--	love.graphics.translate(self.x+playable.halfwidth,self.y+playable.halfheight)
	love.graphics.translate(self.x*self.sx,self.y*self.sy)
	love.graphics.scale(self.sx,self.sy)
	love.graphics.rotate(self.r)
	love.graphics.translate((self.ox+screen.halfwidth)/self.sx,(self.oy+screen.halfheight)/self.sy)
	for k,v in pairs(self.transformations) do
		v:apply()
	end
--	print (self.x,self.y)
--	love.graphics.translate(self.ox-playable.halfwidth,self.oy-playable.halfheight)
end

function Camera:transform(x,y)
	local cosr,sinr = math.cos(self.r),math.sin(self.r)
	x,y = x*cosr-y*sinr,x*sinr+y*cosr
	x,y = x*self.sx,y*self.sy
	x,y = x+self.x*self.sx,y+self.y*self.sy
	return x,y
end

function Camera:untransform(x,y)
	x,y = x-playable.halfwidth,y-playable.halfheight
	x,y = x/self.sx,y/self.sy
	x,y = x-self.x,y-self.y
	local cosr,sinr = math.cos(-self.r),math.sin(-self.r)
	x,y = x*cosr-y*sinr,x*sinr+y*cosr
	return x,y
end

function Camera:revert()
--	for k=#self.transformations,1,-1 do
--		self.transformations[k]:revert()
--	end
	love.graphics.pop()
end

function Camera:push(c)
	table.insert(self.transformations,c)
end

function Camera:pop()
	return table.remove(self.transformations)
end

function Camera:clear()
	self.transformations = {}
end

function Camera:pan(x,y,t)
	if not t then
		x,y,t = -x.x,-x.y,y
	end
	Transformation:new(self,'x',self.x,x,t)
	Transformation:new(self,'y',self.y,y,t)
end

function Camera:shake(degree,t)
	Transformation:new(self,'ox',math.random(degree),0,t,style.elastic)
	Transformation:new(self,'oy',math.random(degree),0,t,style.elastic)
end
-- Follower Camera

FollowerCamera = Camera:subclass('FollowerCamera')

function FollowerCamera:initialize(t,aabb)
	assert(t)
	super.initialize(self)
	self.t = t
	self.aabb = aabb or
	{
		x1 = -1000-playable.halfwidth,
		y1 = -1000-playable.halfheight,
		x2 = 1000-playable.halfwidth,
		y2 = 1000-playable.halfheight
	}
end

function FollowerCamera:apply(z)
	self.x,self.y=-self.t.x,-self.t.y
	if self.aabb then
		self.x = math.min(math.max(self.aabb.x1,self.x),self.aabb.x2)
		self.y = math.min(math.max(self.aabb.y1,self.y),self.aabb.y2)
	end
	super.apply(self,z)
end

ContainerCamera = Camera:subclass('ContainerCamera')
function ContainerCamera:initialize(range,aabb,...)
	super.initialize(self)
	self.range = range
	self.units = arg
	self.aabb = aabb or
	{
		x1 = -1000,
		y1 = -1000,
		x2 = 1000,
		y2 = 1000
	}
end

function ContainerCamera:apply(z) -- I honestly have no idea what this function is about. I pledge to rewrite this one day.
	local aabb = {x1 = 999999,
	y1=999999,
	x2=-999999,
	y2=-999999}
	for k,unit in ipairs(self.units) do
		aabb.x1 = math.min(unit.x-self.range,aabb.x1)
		aabb.y1 = math.min(unit.y-self.range,aabb.y1)
		aabb.x2 = math.max(unit.x+self.range,aabb.x2)
		aabb.y2 = math.max(unit.y+self.range,aabb.y2)
	end
	aabb.x1 = math.max(aabb.x1,self.aabb.x1)
	aabb.y1 = math.max(aabb.y1,self.aabb.y1)
	aabb.x2 = math.min(aabb.x2,self.aabb.x2)
	aabb.y2 = math.min(aabb.y2,self.aabb.y2)
	local scale = math.min(playable.height/(aabb.y2-aabb.y1), playable.width/(aabb.x2-aabb.x1))
	scale = math.min(1,scale)
	local sw,sh = playable.width,playable.height
	self.x,self.y=-(aabb.x1+aabb.x2)/2,-(aabb.y1+aabb.y2)/2
--	if self.aabb then
--	self.x = math.min(math.max(self.aabb.x1+sw,self.x),self.aabb.x2)
--	self.y = math.min(math.max(self.aabb.y1+sh,self.y),self.aabb.y2)
	self.x = (aabb.x1 + aabb.x2)/2
	self.y = (aabb.y1 + aabb.y2)/2
	self.sx,self.sy=scale,scale
--	self.sx,self.sy = 0.25,0.25
	super.apply(self,z)
end

function ContainerCamera:apply(z) -- I honestly have no idea what this function is about. I pledge to rewrite this one day.
	local aabb = {x1 = 999999,
	y1=999999,
	x2=-999999,
	y2=-999999}
	for k,unit in ipairs(self.units) do
		aabb.x1 = math.min(unit.x-self.range,aabb.x1)
		aabb.y1 = math.min(unit.y-self.range,aabb.y1)
		aabb.x2 = math.max(unit.x+self.range,aabb.x2)
		aabb.y2 = math.max(unit.y+self.range,aabb.y2)
	end
	aabb.x1 = math.max(aabb.x1,self.aabb.x1)
	aabb.y1 = math.max(aabb.y1,self.aabb.y1)
	aabb.x2 = math.min(aabb.x2,self.aabb.x2)
	aabb.y2 = math.min(aabb.y2,self.aabb.y2)
	local scale = math.min(playable.height/(aabb.y2-aabb.y1), playable.width/(aabb.x2-aabb.x1),1)
--	local sw,sh = playable.width,playable.height
	self.x,self.y=-(aabb.x1+aabb.x2)/2,-(aabb.y1+aabb.y2)/2
	self.sx,self.sy=scale,scale
--	self.sx,self.sy = 0.25,0.25
	super.apply(self,z)
end