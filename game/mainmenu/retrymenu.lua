local height = 200
local pausemenu = goo.menu:new()
pausemenu:setPos( screen.halfwidth, 50 )
pausemenu:setSize( screen.halfwidth, screen.height )
pausemenu:setScale(2,2)
pausemenu.birth = function(self)
	anim:easy( self, 'opacity', 0, 255, 1, 'quadInOut')
	anim:easy( self, 'xscale', 3, 1, 1, 'quadInOut')
	anim:easy( self, 'yscale', 3, 1, 1, 'quadInOut')
end
pausemenu.onClose = function(self)
	self.closetime = 0.5
	anim:easy( pausemenu, 'opacity', 255, 0, 1, 'quadInOut')
	anim:easy( pausemenu, 'xscale', 1, 3, 1, 'quadInOut')
	anim:easy( pausemenu, 'yscale', 1, 3, 1, 'quadInOut')
end
local b_continue = goo.menuitem:new( pausemenu )
b_continue:setPos( 10, height )
b_continue:setText( LocalizedString'Restart From Last Checkpoint' )
b_continue:sizeToText()
b_continue.onClick = function(self,button)
	GetGameSystem():popState()
	GetGameSystem():prepareToContinue('checkpoint')
	GetGameSystem():continue('checkpoint')
	pausemenu:onClose()
end
height = height + 50
local b_quit = goo.menuitem:new( pausemenu )
b_quit:setPos( 10, height )
b_quit:setText( LocalizedString'Quit to Main Menu' )
b_quit:sizeToText()
b_quit.onClick = function(self,button)
	GetGameSystem():popState()
	popsystem()
	love.graphics.reset()
	PlayTutorial()
	pushsystem(MainMenu)
	mainmenu = love.filesystem.load("mainmenu/mainmenu.lua")()
	mainmenu:birth()
	pausemenu:onClose()
end
height = height + 50

pausemenu:highlightitem(b_continue)
return pausemenu