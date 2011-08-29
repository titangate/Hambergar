
quads = {
	topleft = love.graphics.newQuad(0,0,10,10,40,40),
	topright = love.graphics.newQuad(30,0,10,10,40,40),
	botleft = love.graphics.newQuad(0,30,10,10,40,40),
	botright = love.graphics.newQuad(30,30,10,10,40,40),
	top = love.graphics.newQuad(10,0,1,10,40,40),
	bot = love.graphics.newQuad(10,30,1,10,40,40),
	left = love.graphics.newQuad(0,10,10,1,40,40),
	right = love.graphics.newQuad(30,10,10,1,40,40),
	mid = love.graphics.newQuad(10,10,1,1,40,40)
}


goo.ehpanel = class('eh panel', goo.object)
goo.ehpanel.image = {}

function goo.ehpanel:initialize(parent)
	super.initialize(self,parent)
	self.title = "title"
	self.dragState = false
	self.draggable = false
end

function goo.ehpanel:update(dt)
	super.update(self,dt)
	if self.dragState and self.draggable then
		self.x = love.mouse.getX() - self.dragOffsetX
		self.y = love.mouse.getY() - self.dragOffsetY
		--self:updateBounds()
	end
	if self.closetime then
		self.closetime = self.closetime - dt
		if self.closetime <= 0 then
			self:destroy()
		end
	end
end
function goo.ehpanel:drawbox(x,y)
	self:setColor( self.style.backgroundColor )
	love.graphics.drawq(attritubebackground,quads.topleft,x-10,y-10)
	love.graphics.drawq(attritubebackground,quads.topright,x+self.w,y-10)
	love.graphics.drawq(attritubebackground,quads.botleft,x-10,y+self.h)
	love.graphics.drawq(attritubebackground,quads.botright,x+self.w,y+self.h)
	love.graphics.drawq(attritubebackground,quads.top,x,y-10,0,self.w,1)
	love.graphics.drawq(attritubebackground,quads.bot,x,y+self.h,0,self.w,1)
	love.graphics.drawq(attritubebackground,quads.left,x-10,y,0,1,self.h)
	love.graphics.drawq(attritubebackground,quads.right,x+self.w,y,0,1,self.h)
	love.graphics.drawq(attritubebackground,quads.mid,x,y,0,self.w,self.h)
end
function goo.ehpanel:draw()
	super.draw(self)
--	love.graphics.setColor(self.style.backgroundColor)
	self:drawbox(0,-35)
	love.graphics.setFont( self.style.titleFont )
	love.graphics.printf( self.title, 0,-35 ,self.w,'center')
end
function goo.ehpanel:mousepressed(x,y,button)
	super.mousepressed(self,x,y,button)
	if self.hoverState then
		-- Move to top.
		if self.z < #self.parent.children then
			self:removeFromParent()
			self:addToParent( self.parent )
		end
	end
end
function goo.ehpanel:mousereleased(x,y,button)
end
function goo.ehpanel:setTitle( title )
	self.title = title
end
function goo.ehpanel:setPos( x, y )
	super.setPos(self, x, y)
	self:updateBounds()
end
function goo.ehpanel:setSize( w, h )
	super.setSize(self, w, h)
	self:updateBounds()
end
function goo.ehpanel:setDraggable( draggable )
	self.draggable = draggable
end
return goo.ehpanel