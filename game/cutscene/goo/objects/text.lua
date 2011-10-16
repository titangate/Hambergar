-- STATIC TEXT
goo.text = class('goo static text', goo.object)
function goo.text:initialize( parent )
	super.initialize(self,parent)
	self.text = "no text"
end
function goo.text:draw(x,y)
	love.graphics.setColor( self.color )
	love.graphics.print( self.text,0,0 )
end
function goo.text:setText( text )
	self.text = text or ""
end
function goo.text:getText()
	return self.text
end

return goo.text