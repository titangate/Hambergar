-- imagelabel LABEL OBJECT
goo.imagelabel = class('goo imagelabel', goo.object)
function goo.imagelabel:initialize( parent )
	super.initialize(self,parent)
	self.imagelabel = nil
	self.rotation = 0
	self.text = 'no text'
	self.align = 'left'
end
function goo.imagelabel:setImage( image )
	self.image = image
	self:textToSize()
end
function goo.imagelabel:getImage()
	return self.image
end
function goo.imagelabel:loadImage( imagename )
	self.image = love.graphics.newimage( imagename )
	self:textToSize()
end
function goo.imagelabel:setAlignMode(mode)
	self.align = mode
end
function goo.imagelabel:draw( x, y )
	super.draw(self)
	x,y = x or 0,y or 0
	self:setColor( self.style.imageTint )
	if self.image then
		love.graphics.draw( self.image, x, y, self.rotation )
	end
	local c = self.textcolor or self.style.textColor
	self:setColor( c )
	love.graphics.setFont(self.font or self.style.textFont)
	if self.image then
		love.graphics.printf( self.text, x+self.image:getWidth(), y,self.w,self.align)
	else
		love.graphics.printf(self.text,x,y,self.w,self.align)
	end
end

function goo.imagelabel:setText( text )
	self.text = text or ""
	self:textToSize()
end
function goo.imagelabel:getText()
	return self.text
end

function goo.imagelabel:setFont(font)
	self.font = font
end

function goo.imagelabel:textToSize()
	local imagew,imageh = 0,0
	if self.image then
		imagew,imageh = self.image:getWidth(),self.image:getHeight()
	end
	local _font = self.font or self.style.textFont or love.graphics.getFont()
	self.h = math.max(imageh,_font:getHeight()*select(2,_font:getWrap(self.text,self.w)))
end

return goo.imagelabel