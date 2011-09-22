-- menu
goo.listcontainer = class('goo list container', goo.object)

function goo.listcontainer:initialize(parent)
	super.initialize(self,parent)
	self.dragState = false
	self.draggable = false
	self.list = goo.list:new(self)
	self.list.childScissor = self
end

function goo.listcontainer:setSize(w,h)
	super.setSize(self,w,h)
	self.list:setSize(w,0)
end

function goo.listcontainer:update(dt)
	super.update(self,dt)
end

function goo.listcontainer:mousepressed(...)
	super.mousepressed(self,...)
end

function goo.listcontainer:draw()
	goo.drawBox(0,0,self.w,self.h)
	super.draw(self)
end

return goo.listcontainer
