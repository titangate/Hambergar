function test()
	require 'scenes.whistler.train'
	local gs = require 'scenes.gamesystem'
	mainmenu:onClose()
	pushsystem(loadingscreen)
	loadingscreen.finished = function ()
		SetGameSystem(gs)
		GetGameSystem():load()
		GetGameSystem():runMap(KingEdTrain,'opening')
		pushsystem(GetGameSystem())
	end
end
