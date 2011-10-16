-------------------------------------------------------------
------ PROGRESS BAR.
-------------------------------------------------------------
goo.progressbar = class('goo progressbar', goo.object)
function goo.progressbar:initialize( parent )
	super.initialize(self,parent)
	self.current_progress 	= 0
	self.max_progress 		= 100
	self.max_width			= 100
	self.scale				= 100
	self.cw					= self.w
	self:setRange()
end
function goo.progressbar:draw()
	love.graphics.setColor( unpack(self.style.backgroundColor) )
	love.graphics.rectangle( self.style.fillMode, 0,0, self.max_width, self.h )
	love.graphics.setColor( unpack(self.style.foregroundColor) )
	love.graphics.rectangle( self.style.fillMode, 0,0, self.cw, self.h )
	love.graphics.setColor( 255,255,255,255 )
end
function goo.progressbar:setProgress( progress )
	self.current_progress = progress
	self.cw = self.current_progress/self.range
	if self.onChange then self:onChange() end
end
function goo.progressbar:setPercentage( percentage )
	local percentage = percentage or 0
	self.cw = self.max_width * (percentage/100)
	if self.onChange then self:onChange() end
end
function goo.progressbar:setRange( min, max )
	local min = min or 0
	local max = max or 100
	self.range = (max-min)
	return self.range
end
function goo.progressbar:setSize( w, h )
	super.setSize( self, w, h )
	self.max_width = w
	self.scale = self.range / w
end
function goo.progressbar:updateSize( w, h )
	local w = w or self.w or 0
	local h = h or self.h or 20
	self.w = w
	self.h = h
end
function goo.progressbar:mousepressed(x,y,button)
	super.mousepressed(self,x,y,button)
end
function goo.progressbar:incrementProgress()
	self.current_progress = self.current_progress + 1
	self:updateSize( (self.current_progress / self.range) * self.max_width )
end
function goo.progressbar:getProgress()
	return self.current_progress
end
function goo.progressbar:getPercentage()
	return (self.cw/self.max_width)*100
end
function goo.progressbar:update(dt)
	super.update(self,dt)
	if love.mouse.isDown('l') and self.hoverState then
		local x,y = self:getAbsolutePos()
		local nx,ny = love.mouse.getPosition()
		self:setPercentage((nx-x)/self.max_width*100)
	end
end

return goo.progressbar