Button = Object:subclass('Button')
function Button:initialize(group,x,y,w,h)
	self.group = group
	self.x,self.y,self.w,self.h=x,y,w,h
	self.hover = false
	self.pressing = false
	self.rpressing = false
end

function Button:update(dt)
	local x,y = love.mouse.getPosition()
	if x>self.x and x<self.x+self.w and y>self.y and y<self.y+self.h then
		if not self.hover and self.mouseOn then
			self:mouseOn()
		end
		self.hover = true
	else
		if self.hover and self.mouseOff then
			self:mouseOff()
		end
		self.hover = false
	end
	if self.dragging then
		self.hover = true
	end
	if love.mouse.isDown('l') then
		if self.hover then
			if not self.pressing then self:pressed() end
			self.pressing = true
		end
	else
		if self.pressing then
			self:released()
			if self.hover and self.click then self:click() end
		end
		self.pressing = false
	end
	if love.mouse.isDown('r') then
		if self.hover then
			if not self.pressingr then self:rightPressed() end
			self.pressingr = true
		end
	else
		if self.pressingr  then
			self:rightReleased()
			if self.hover and self.rightClick then self:rightClick() end
		end
		self.pressingr = false
	end
end

function Button:pressed()
end

function Button:released()
end

function Button:rightPressed()
	print ('rightPressed')
end

function Button:rightReleased()
	print ('rightReleased')
end

function Button:rightClick()
	print ('rightClick')
end