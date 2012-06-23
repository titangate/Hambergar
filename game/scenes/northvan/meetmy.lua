
local conv = {
	revive = function(trig,m)
	end,
}

return function(self)
	local c = require 'cutscene.waterfall.meditation'
	local cp = CutscenePlayer(c)
	pushsystem(cp)
	cp:setChoiceTime(1000)
	local t = Trigger:new(conv.revive)
	t:run(cp)
	cp.onFinish = function(self)
		popsystem()
	end
end