Animation = Object:subclass('Animation')
function Animation:initialize(image,w,h,interval,sx,sy,ox,oy)
	self.quad = {}
	if image then
		local rw = math.floor(image:getWidth()/w)
		local rh = math.floor(image:getHeight()/h)
		for j=0,rh-1 do
			for i = 0,rw-1 do
				table.insert(self.quad,love.graphics.newQuad(i*w,j*h,w-2,h-2,image:getWidth(),image:getHeight()))
			end
		end
		self.sx,self.sy = sx,sy
		self.ox,self.oy = ox,oy
		self.interval = interval
		self.dt = 0
		self.index = 1
		self.image = image
	end
end

function Animation:reset()
	self.index = 1
	self.dt = 0
end

function Animation:update(dt)
	self.dt = self.dt + dt
	if self.dt > self.interval then
		self.index = self.index + 1
		self.dt = self.dt - self.interval
		if self.index > #self.quad then
			self.index = 1
			return true
		end
	end
end

function Animation:draw(x,y,r)
	love.graphics.drawq(self.image,self.quad[self.index],x,y,r,self.sx,self.sy,self.ox,self.oy)
end

function Animation:subSequence(start,finish)
	local anim = Animation:new()
	for i=start,finish do
		table.insert(anim.quad,self.quad[i])
	end
	anim.sx,anim.sy = self.sx,self.sy
	anim.ox,anim.oy = self.ox,self.oy
	anim.interval = self.interval
	anim.dt = 0
	anim.image = self.image
	anim.index = 1
	return anim
end

animation = {}
animation.explosion = Animation:new(love.graphics.newImage('assets/explosion.png'),96,96,0.03,1.5,1.5,48,48)

ExplosionActor = Object:subclass('ExplosionActor')
function ExplosionActor:initialize(x,y)
	self.x,self.y = x,y
	self.r = math.random(math.pi*2)
	self.anim = animation.explosion:subSequence(1,15)
end

function ExplosionActor:update(dt)
	if self.anim:update(dt) then
		map:removeUpdatable(self)
	end
end

function ExplosionActor:draw()
	self.anim:draw(self.x,self.y,self.r)
end

function CreateExplosion(x,y)
	map:addUpdatable(ExplosionActor:new(x,y))
end

