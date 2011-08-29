local height = screen.halfheight-100
local mainmenu = goo.menu:new()
mainmenu:setPos( screen.halfwidth, 50 )
mainmenu:setSize( screen.halfwidth, screen.height )
mainmenu:setScale(2,2)
mainmenu.birth = function(self)
	anim:easy( self, 'opacity', 0, 255, 1, 'quadInOut')
	anim:easy( self, 'xscale', 3, 1, 1, 'quadInOut')
	anim:easy( self, 'yscale', 3, 1, 1, 'quadInOut')
	MainMenu:refreshWithImage(gameicon)
end
mainmenu.onClose = function(self)
	self.closetime = 0.5
	anim:easy( mainmenu, 'opacity', 255, 0, 1, 'quadInOut')
	anim:easy( mainmenu, 'xscale', 1, 3, 1, 'quadInOut')
	anim:easy( mainmenu, 'yscale', 1, 3, 1, 'quadInOut')
end
local b_continue = nil
if love.filesystem.exists('lastsave.sav') then
	b_continue = goo.menuitem:new( mainmenu )
	b_continue:setPos( 10, height )
	b_continue:setText( 'Continue' )
	b_continue:sizeToText()
	b_continue.onClick = function(self,button)
	local save = table.load(love.filesystem.read('lastsave.sav'))
	local gs = loadstring(save.gamesystem)()
	SetGameSystem(gs)
	gs:load()
	gs:continueFromSave(save)
	pushsystem(gs)
	mainmenu:onClose()
	end
end

height = height + 50
local b_startgame = goo.menuitem:new( mainmenu )
b_startgame:setPos( 10, height )
b_startgame:setText( 'Start Game' )
b_startgame:sizeToText()
b_startgame.onClick = function( self, button )
	require 'scenes.tibet.tibet1'
	local gs = require 'scenes.tibet.tibetgamesystem'
	require 'scenes.tibet.intro'
	mainmenu:onClose()
	SetGameSystem(gs)
	GetGameSystem():load()
	GetGameSystem():runMap(Tibet1,'opening')
	pushsystem(GetGameSystem())
end
height = height + 50

local b_grid = goo.menuitem:new( mainmenu )
b_grid:setPos( 10, height )
b_grid:setText( 'GRID' )
b_grid:sizeToText()
b_grid.onClick = function( self, button )
	require 'scenes.grid.grid'
	local gs = require 'scenes.grid.gridgamesystem'
	mainmenu:onClose()
	SetGameSystem(gs)
	GetGameSystem():load()
	GetGameSystem():runMap(Grid,'opening')
	pushsystem(GetGameSystem())
end
height = height + 50

local b_option = goo.menuitem:new( mainmenu )
b_option:setPos( 10, height )
b_option:setText( 'Options' )
b_option:sizeToText()
b_option.onClick = function(self,button)
	anim:easy( mainmenu, 'opacity', 255, 0, 1, 'quadInOut')
	anim:easy( mainmenu, 'xscale', 1, 0.3, 1, 'quadInOut')
	anim:easy( mainmenu, 'yscale', 1, 0.3, 1, 'quadInOut')
	mainmenu.closetime = 0.5
	option = love.filesystem.load('mainmenu/option.lua')()
	option:birth()
end
	height = height + 50
local b_editor = goo.menuitem:new ( mainmenu)
b_editor:setPos(10,height)
b_editor:setText('Editor')
b_editor:sizeToText()
b_editor.onClick = function(self,button)
	mainmenu.closetime = 0.1
	pushsystem(TileEditor)
end
	height = height + 50
local b_quit = goo.menuitem:new( mainmenu )
b_quit:setPos( 10, height )
b_quit:setText( "Quit Game" )
b_quit:sizeToText()
b_quit.onClick = function (self,button)
	love.event.push('q')
end
height = height + 50
if love.filesystem.exists('lastsave.sav') then
	mainmenu:highlightitem(b_continue)
else
	mainmenu:highlightitem(b_startgame)
end
return mainmenu
