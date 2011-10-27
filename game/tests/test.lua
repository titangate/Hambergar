function test()
	require 'scenes.whistler.station'
	local gs = require 'scenes.gamesystem'
	mainmenu:onClose()
	pushsystem(loadingscreen)
	loadingscreen.finished = function ()
		SetGameSystem(gs)
		GetGameSystem():load()
		GetGameSystem():runMap(KingEdStation,'opening')
		pushsystem(GetGameSystem())
	end
end
