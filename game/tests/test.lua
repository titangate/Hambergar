function test()
	require 'scenes.whistler.whistler'
	local gs = require 'scenes.gamesystem'
	mainmenu:onClose()
	pushsystem(loadingscreen)
	loadingscreen.finished = function ()
		SetGameSystem(gs)
		GetGameSystem():load()
		GetGameSystem():runMap(Whistler,'opening')
		pushsystem(GetGameSystem())
	end
end
