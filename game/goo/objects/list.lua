-- menu
goo.list = class('goo list', goo.object)

function goo.list:initialize(parent)
	super.initialize(self,parent)
	self.dragState = false
	self.draggable = false
	self.items = {}
--	self.highlight = 1
end
function goo.list:setSkin()
end
function goo.list:update(dt)
	super.update(self,dt)
end
function goo.list:draw( x, y )
	super.draw(self)
	if self.highlight then
			local item = self.items[self.highlight]
			if item then
			love.graphics.setColor(255,255,255)
			love.graphics.rectangle('line',item.x,item.y,item.w,item.h)
		end
	end
end
local responds = {
	LSU = 1,
	LSD = 1,
	w = 1,
	s = 1,
}
local responds2 = {
	LSL = 1,
	LSR = 1,
	a = 1,
	d = 1,
}
function goo.list:focus()
	local x,y = self.highlighted:getAbsolutePos()
	love.mouse.setPosition(x+50,y+24)
	self.hoverState = true
end
function goo.list:keypressed(k)
	if self.hoverState then
		if responds[k] then
			local x,y = controller:GetWalkDirection()
			local newlockon = self:direct(self.highlighted,{x,y},function(obj)
				return true -- and newlockon:isKindOf(goo.itembutton) -- not obj:isKindOf(goo.imagelabel)
			end)
			if newlockon then
				local x,y = newlockon:getAbsolutePos()
				love.mouse.setPosition(x+24,y+24)
				self.highlighted = newlockon	
			end
		end
		if k=='return' then
			local x,y = love.mouse.getPosition()
			love.mousepressed(x,y,'r')
		end
	end
end
function goo.list:getDirectItem(direction)
end

function goo.list:mousepressed(x,y,menuitem)
	super.mousepressed(self,x,y,menuitem)
	if self.hoverState then
		
		-- Move to top.
		if self.z < #self.parent.children then
			self:removeFromParent()
			self:addToParent( self.parent )
		end
	end
end
function goo.list:setPos( x, y )
	super.setPos(self, x, y)
	self:updateBounds()
end
function goo.list:setSize( w, h )
	super.setSize(self, w, h)
	self:updateBounds()
end
function goo.list:clear()
	for k,v in pairs(self.items) do
		v:destroy()
	end
	self.items = {}
	self.h=0
end
function goo.list:reposition()
	for k,v in pairs(self.items) do
		v:setPos(item.x,self.h)
		self.itemh = self.itemh + v.h + self.style.vertSpacing
	end
end
function goo.list:addItem(item,key)
	key = key or #self.items
	self.items[key+1]=item
	item:setPos(item.x,self.h)
	self:setSize(self.w,self.h + item.h + self.style.vertSpacing)
	self.highlighted = item
end
function goo.list:enterHover()
end
function goo.list:removeItem(key)
	local i = self.items[key]
	i:destroy()
	self.items[key]=nil
	self:setSize(self.h - i.h - self.style.vertSpacing)
end
function goo.list:mousepressed(x,y,k)
	if k=='wd' then
		self:setPos(self.x,math.min(math.max(self.y-10,self.parent.h-self.h),0)) -- restrain within container
	elseif k=='wu' then
		self:setPos(self.x,math.min(math.max(self.y+10,self.parent.h-self.h),0))
	end
end

function goo.list:scrollTo(key)
	self:setPos(self.x,math.min(math.max(self.items[key].y,self.parent.h-self.h),0))
end
return goo.list
