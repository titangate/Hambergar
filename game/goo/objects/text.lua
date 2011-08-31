-- STATIC TEXT
goo.text = class('goo static text', goo.object)
function goo.text:initialize( parent )
	super.initialize(self,parent)
	self.text = "no text"
--	self.align = "left"
end
function goo.text:setAlignMode(mode)
	self.align = mode
end
function goo.text:draw(x,y)
	super.draw(self)
	x,y = x or 0,y or 0
	love.graphics.setColor( unpack(self.color) )
	if self.align then
		love.graphics.printf( self.text, x, y,self.w,self.align )
	else
		love.graphics.printf(self.text,x,y)
	end
end
function goo.text:setText( text )
	self.text = text or ""
--	self:textToSize
end
function goo.text:getText()
	return self.text
end


function goo.text:textToSize()
	local _font = love.graphics.getFont()
	self.w = _font:getWidth(self.text)
	self.h = math.max(imageh,_font:getHeight())
end

return goo.text