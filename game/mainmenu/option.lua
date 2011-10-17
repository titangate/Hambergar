
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
height = 200
local b_back = goo.menuitem:new( option )
b_back:setPos( 10, height )
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

height = height + 50
local f_aimassist = function()
	if options.aimassist then
		return 'Disable aimassist'
	else
		return 'Enable aimassist'
	end
end

local b_aimassist = goo.menuitem:new( option )
b_aimassist:setPos( 10, height )
b_aimassist:setText( f_aimassist() )
b_aimassist:sizeToText()
b_aimassist.onClick = function(self,button)
	options.aimassist = not options.aimassist
	b_aimassist:setText( f_aimassist() )
end
option:highlightitem(b_aimassist)


height = height + 50
local f_blureffect = function()
	if options.blureffect then
		return 'Disable blur effect'
	else
		return 'Enable blur effect'
	end
end

local b_aimassist = goo.menuitem:new( option )
b_aimassist:setPos( 10, height )
b_aimassist:setText( f_blureffect() )
b_aimassist:sizeToText()
b_aimassist.onClick = function(self,button)
	options.blureffect = not options.blureffect
	b_aimassist:setText( f_blureffect() )
end
option:highlightitem(b_aimassist)
return option