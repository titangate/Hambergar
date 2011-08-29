local option = goo.menu:new()
option:setPos( screen.halfwidth, 50 )
option:setSize( screen.halfwidth, screen.height )
option:setScale(2,2)
option.birth = function(self)
	anim:easy( self, 'opacity', 0, 255, 1, 'quadInOut')
	anim:easy( self, 'xscale', 3, 1, 1, 'quadInOut')
	anim:easy( self, 'yscale', 3, 1, 1, 'quadInOut')
	MainMenu:refreshWithImage(img.gameicon)
end
option.onClose = function(self)
	self.closetime = 0.5
	anim:easy( option, 'opacity', 255, 0, 1, 'quadInOut')
	anim:easy( option, 'xscale', 1, 3, 1, 'quadInOut')
	anim:easy( option, 'yscale', 1, 3, 1, 'quadInOut')
end
local b_back = goo.menuitem:new( option )
b_back:setPos( 10, 200 )
b_back:setText( 'Back' )
b_back:sizeToText()
b_back.onClick = function(self,button)
	anim:easy( option, 'opacity', 255, 0, 1, 'quadInOut')
	anim:easy( option, 'xscale', 1, 0.3, 1, 'quadInOut')
	anim:easy( option, 'yscale', 1, 0.3, 1, 'quadInOut')
	option.closetime = 0.5
	mainmenu = love.filesystem.load('mainmenu/mainmenu.lua')()
	mainmenu:birth()
end
option:highlightitem(b_back)
return option