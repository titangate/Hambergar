
local conv = {
	opening = function(trig,cp)
		cp:playConversation("I've waited you long enough.","Hans")
		cine_wait(4)
		cp:playConversation("Hans? Why are you in my way?","River")
		cine_wait(4)
		cp:playConversation("I pledged my sword to Master Yuen and I am here to stop you.","Hans")
		cine_wait(6)
		cp:playConversation("Move, I don't want to kill you.","River")
		cine_wait(4)
		cp:playConversation("Every one of us is but a slave to karma, River. May your guns be blessed.","Hans")
		cine_wait(5)
		cp:playConversation("Amitabha.","River",3)
		cine_wait(6)
		popsystem()
	end,
}

return function(self)
	local c = require 'cutscene.tibet.hans'
	local cp = CutscenePlayer(c)
	pushsystem(cp)
	local t = Trigger:new(conv.opening)
	t:run(cp)
	local choices1 = {
		'LILY',
		'COMPASS',
		'RUNE',
	}
	local choices2 = {
		'LEAVE',
		'COMPASS',
		'RUNE',
	}
	cp:setChoiceTime(30)
	cp.onFinish = function(self)
		
	end
end