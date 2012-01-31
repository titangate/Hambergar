StealthUnit = Object:subclass'StealthUnit'
function StealthUnit:initialize(x,y)
	self.x,self.y = x,y
	self.vx,self.vy = 0,0
	self.visioncorn = math.pi/3
end
function StealthUnit:update(dt)
	self.state = nil
	if self.ai then
		self.ai:process(self,dt)
	end
	self.x,self.y = self.x+self.vx*dt,self.y+self.vy*dt
end

function StealthUnit:setIndicator(state)
	self.state = state
end
function StealthUnit:draw()
	love.graphics.circle('fill',self.x,self.y,16,30)
	if self.state then
		love.graphics.print(self.state,self.x,self.y)
	end
end

function StealthUnit:getPosition()
	return self.x,self.y
end

function StealthUnit:getRegion()
	return self.ai:getRegion(self)
end