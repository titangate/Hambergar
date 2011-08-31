-- menu
goo.menu = class('goo menu', goo.object)
goo.menu.image = {}

function goo.menu:initialize(parent)
	super.initialize(self,parent)
	self.dragState = false
	self.draggable = false
	self.highlight = goo.image:new(self)
	self.highlight:setImage(self.highlightimage)
	self.opentime = 0.5
end
function goo.menu:setSkin()
	self.highlightimage = (love.graphics.newImage(goo.skin..'highlight.png'))
end
function goo.menu:update(dt)
	super.update(self,dt)
	if self.opentime then
		self.opentime = self.opentime - dt
		if self.opentime <= 0 then
			self.opentime = nil
		end
	end
	if self.closetime then
		self.closetime = self.closetime - dt
		if self.closetime <= 0 then
			if self.onDestroy then
				self:onDestroy()
			end
			self:destroy()
		end
	end
end
function goo.menu:draw( x, y )
	super.draw(self)
end
function goo.menu:mousepressed(x,y,menuitem)
	super.mousepressed(self,x,y,menuitem)
	if self.hoverState then
		
		-- Move to top.
		if self.z < #self.parent.children then
			self:removeFromParent()
			self:addToParent( self.parent )
		end
	end
end
function goo.menu:highlightitem(item)
	anim:easy(self.highlight,'y',self.highlight.y,item.y-5,0.3,'linear')
	self.highlighted = item
end
function goo.menu:mousereleased(x,y,menuitem)
end
function goo.menu:setPos( x, y )
	super.setPos(self, x, y)
	self:updateBounds()
end
function goo.menu:setSize( w, h )
	super.setSize(self, w, h)
	self:updateBounds()
end
function goo.menu:setDraggable( draggable )
	self.draggable = draggable
end
function goo.menu:updateBounds()
	local x, y = self:getAbsolutePos()
	self.bounds.x1 = x 
	self.bounds.y1 = y 
	self.bounds.x2 = x + self.w 
	self.bounds.y2 = y + self.h 
end
local commandshifts = {
	up={0,-1},
	down={0,1}
}
function goo.menu:keypressed(k)
	if self.opentime then return end
	if k=='LSU' or k=='LSD' then
		print ('suppose')
		local x,y = controller:GetWalkDirection()
		local newlockon = self:direct(self.highlighted,{x,y},function(obj)
		return obj:isKindOf(goo.menuitem)
		end)
		if newlockon then
			self:highlightitem(newlockon)
		end
	end
	if commandshifts[k] then
		local newlockon = self:direct(self.highlighted,commandshifts[k],function(obj)
		return obj:isKindOf(goo.menuitem)
		end)
		if newlockon then
			self:highlightitem(newlockon)
		end
	end
	--[[
	if k == 'down' or k=='LSD' then
		for k,v in ipairs(self.children) do
			if v==self.highlighted then
				while self.children[k+1] and not self.children[k+1]:isKindOf(goo.menuitem) do
					k = k+1
				end
				if self.children[k+1] then
					self:highlightitem(self.children[k+1])
				end
				return
			end
		end
	elseif k=='up' or k=='LSU' then
		for k,v in ipairs(self.children) do
			if v==self.highlighted then
				while self.children[k-1] and not self.children[k-1]:isKindOf(goo.menuitem) do
					k = k-1
				end
				if self.children[k-1] then
					self:highlightitem(self.children[k-1])
				end
				return
			end
		end
	]]
	print (k,'is pressed in menu')
	if k=='return' then
		print (self.highlighted.text,'onclicked')
		self.highlighted:onClick(self.highlighted)
	end
end

return goo.menu
