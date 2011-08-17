-- MENU ITEM
goo.menuitem = class('goo menuitem', goo.object)
function goo.menuitem:initialize( parent )
	super.initialize(self,parent)
	self.text = "menuitem"
	self.borderStyle = 'line'
	self.backgroundColor = {0,0,0,255}
	self.borderColor = {255,255,255,255}
	self.textColor = {255,255,255,255}
end
function goo.menuitem:draw()
--	self:setColor( self.textColor )
	love.graphics.setFont( self.style.textFont )
	local fontW, fontH = self.style.textFont:getWidth(self.text or ''), self.style.textFont:getHeight()
--	local ypos = ((self.h - (fontH*2))/2)
--	local xpos = ((self.w - fontW)/2)
	love.graphics.print( self.text, 0, 0 )
end
function goo.menuitem:enterHover()
	--anim:easy( self.parent.highlight, 'y', self.parent.highlight.y, self.y, 0.3, 'quadInOut')
	self.parent:highlightitem(self)
end
function goo.menuitem:exitHover()
end
function goo.menuitem:mousepressed(x,y,menuitem)
	if self.onClick then self:onClick(menuitem) end
	self:updateBounds( 'children', self.updateBounds )
end
function goo.menuitem:setText( text )
	self.text = text or ''
end
function goo.menuitem:sizeToText( padding )
	local padding = padding or 5
	local _font = self.style.textFont or love.graphics.getFont()
	self.w = _font:getWidth(self.text or '') + (padding*2)
	self.h = _font:getHeight()  + (padding*2)
	self:updateBounds()
end
goo.menuitem:getterSetter('border')
goo.menuitem:getterSetter('background')

return goo.menuitem