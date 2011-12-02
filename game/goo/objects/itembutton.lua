
goo.itembutton = class('goo itembutton', goo.object)
function goo.itembutton:initialize(parent)
	super.initialize(self,parent)
	self.dragState = false
	self.draggable = true
end

function goo.itembutton:setInventory(inv)
	self.inv = inv
end

function goo.itembutton:update(dt)
	super.update(self,dt)
end

function goo.itembutton:setItem(item)
	self.item = item
	if item and item.fixed then
		self:setDraggable(false)
	else
		self:setDraggable(true)
	end
end

function goo.itembutton:draw()
	love.graphics.draw(img.slotimg)
	if self.item then
		self.item:draw(32,32)
		love.graphics.setFont(self.style.titleFont)
		love.graphics.print(self.item.name,80,10)
		love.graphics.setFont(self.style.descriptionFont)
		love.graphics.print(self.item:getQuickInfo(),80,40)
	end
end

function goo.itembutton:mousepressed(x,y,button)
	super.mousepressed(self,x,y,button)
	-- Special case here for we want to inform the list to scroll
	if self.parent:isKindOf(goo.list) then
		self.parent:mousepressed(x,y,button)
	end
	
	if self.item then
		self.inv:interactItem(self.item,self.buttontype,button)
	end
end

function goo.itembutton:mousereleased(x,y,button)
	super.mousereleased(self,x,y,button)
end

function goo.itembutton:enterHover()
	if self.item then
		self.inv.updateInfoPanel(self.item)
		self.inv.hoverbutton = self
	end
end

function goo.itembutton:exitHover()
	if self.inv.hoverbutton == self then
		self.inv.updateInfoPanel()
		self.inv.hoverbutton = nil
	end
end

function goo.itembutton:setDraggable( draggable )
	self.draggable = draggable
end

return goo.itembutton
