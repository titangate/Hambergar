-- BUTTON
goo.flag = class('goo flag', goo.button)
goo.flag.image = {}
function goo.flag:initialize( parent )
	super.initialize(self,parent)
	self.text = "button"
	self.borderStyle = 'line'
	self.backgroundColor = {0,0,0,255}
	self.borderColor = {255,255,255}
	self.textColor = {255,255,255}
	self.spacing = 5
	self.border = true
	self.background = true
end

function goo.flag:setSkin()
	goo.flag.image.star = love.graphics.newImage( goo.skin..'flag.png' )
	goo.flag.image.flash = love.graphics.newImage( goo.skin..'flash.png' )
end

function goo.flag:draw()
	love.graphics.draw(goo.flag.image.star,0,0,0,1,1,32,32)
	self:setColor( self.textColor )
	love.graphics.setFont( self.style.textFont )
	local fontW, fontH = self.style.textFont:getWidth(self.text or ''), self.style.textFont:getHeight()
	local ypos = 0
	local xpos = ((self.w - fontW)/2)
	love.graphics.print( self.text, xpos, ypos )
end
function goo.flag:enterHover()
end
function goo.flag:exitHover()
end
function goo.flag:mousepressed(x,y,button)
	if self.onClick then self:onClick(button) end
	self:updateBounds( 'children', self.updateBounds )
end
function goo.flag:setText( text )
	self.text = text or ''
end
return goo.flag