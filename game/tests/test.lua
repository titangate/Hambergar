function test()
	require 'scenes.whistler.dreamSequence'
	local gs = require 'scenes.gamesystem'
	mainmenu:onClose()
	pushsystem(loadingscreen)
	loadingscreen.finished = function ()
		SetGameSystem(gs)
		GetGameSystem():load()
		GetGameSystem():runMap(DreamMaze,'opening')
		pushsystem(GetGameSystem())
	end
end
