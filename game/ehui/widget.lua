Widget = Object:subclass('Widget')
function Widget:initialize(x,y,w,h)
	self.x,self.y = x,y
	self.w,self.h = w,h
end

function Widget:getBoundingBox()
	return {
		x1 = self.x,
		y1 = self.y,
		x2 = self.x + self.w,
		y2 = self.y + self.h
	}
end

function Widget:inAABB(x,y)
	return x>self.x and y>self.y and x<self.x+self.w and y<self.y+self.h
end

function Widget:hover()
	self.hovering = true
end

function Widget:unhover()
	self.hovering = false
end

function Widget:getAboslutePosition()
	if self.parent then
		local x,y = self.parent:getAboslutePosition()
		return self.x+x,self.y+y
	else
		return self.x,self.y
	end
end

function Widget:mousepressed(x,y,b)
	if self.children then
		for k,v in ipairs(self.children) do
			v:mousepressed(x-self.x,y-self.y,b)
		end
	end
	if self.hovering and self.draggable and b=='l' then
		self:startDragging()
		if not self.dragging then
			self.dragOffsetX = x
			self.dragOffsetY = y
		end
		self.dragging = true
	end
end

function Widget:mousereleased(x,y,b)
	if self.children then
		for k,v in ipairs(self.children) do
			v:mousereleased(x-self.x,y-self.y,b)
		end
	end
	if self.hovering then
		if self.dragging and b=='l' then
			self:endDragging()
			self.dragging = nil
		end
	end
end

function Widget:addChild(child)
	if not self.children then
		self.children = {}
	end
	table.insert(self.children,child)
	child.parent = self
end

function Widget:removeChild(child)
	local removal = nil
	for i,v in ipairs(self.children) do
		if v==child then
			removal = i
		end
	end
	table.remove(self.children,removal)
	if self.children == {} then
		self.children = nil
	end
end

function Widget:update(dt,x,y)
	if self:inAABB(x,y) then
		if not self.hovering then
			self:hover()
		end
		UI.mouseover = self
	elseif self.hovering then
		self:unhover()
	end
	if self.children then
		for k,v in ipairs(self.children) do
			v:update(dt,x-self.x,y-self.y)
		end
	end
	if self.dragging then
		self.x = x - self.dragOffsetX
		self.y = y - self.dragOffsetY
	end
	if self.anim then
		local status = self.anim:update(dt)
		if status == 'finish' then
			self.anim = nil
		end
	end
		if self.actor then self.actor:update(dt) end
end

function Widget:clearChildren()
	self.children = nil
end

function Widget:layout(style)
	if not self.children then return end
	if style == 'horizontal' then
		local x = self.xMargin
		local y = self.yMargin
		local h = 0
		for i,v in ipairs(self.children) do
			if v.w+x > self.w then
				x = self.xMargin
				y = y+h+self.yMargin
				h = 0
			end
					h = math.max(h,v.h)
			v.x,v.y = x,y
			x = x + v.w + self.xMargin
		end
	elseif style == 'vertical' then
		local x = self.xMargin
		local y = self.yMargin
		local w = 0
		for i,v in ipairs(self.children) do
			if v.h+y > self.h then
				y = self.yMargin
				x = x+w+self.xMargin
				w = 0
			end
					w = math.max(w,v.w)
			v.x,v.y = x,y
			y = y + v.h + self.yMargin
		end
	end
end

function Widget:draw(x,y)
	if not self.hide then
		if self.anim then self.anim:apply() end
		if self.actor then self.actor:draw(x+self.x,y+self.y) end
		if self.children then
			love.graphics.push()
			love.graphics.translate(self.x,self.y)
			for k,v in ipairs(self.children) do
				v:draw(x,y)
			end
			love.graphics.pop()
		end
		if self.anim then self.anim:revert() end
	end
end

function Widget:setVisible(v)
	self.hide = not v
end

function Widget:setSlot(slot)
	self.slot = slot
end

function Widget:startDragging()
	self.dragx = self.x
	self.dragy = self.y
	UI.top = self
end
function Widget:endDragging()
	if not(self.slot and self.slot()) then
		self.x, self.y = self.dragx,self.dragy
		self.dragx,self.dragy = nil,nil
	else
		
		if self.put then self.put(self) end
	end
	UI.top = nil
end