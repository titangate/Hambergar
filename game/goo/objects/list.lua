-- menu
goo.list = class('goo list', goo.object)

function goo.list:initialize(parent)
	super.initialize(self,parent)
	self.dragState = false
	self.draggable = false
	self.items = {}
end
function goo.list:setSkin()
end
function goo.list:update(dt)
	super.update(self,dt)
end
function goo.list:draw( x, y )
	super.draw(self)
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
	self.items[key]=item
	item:setPos(item.x,self.h)
	self:setSize(self.w,self.h + item.h + self.style.vertSpacing)
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
return goo.list
