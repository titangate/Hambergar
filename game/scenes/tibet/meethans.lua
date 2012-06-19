
local conv = {
	opening = function(trig,cp)
		cp:playConversation(LocalizedString"I've waited you long enough.",LocalizedString"Hans")
		cine_wait(4)
		cp:playConversation(LocalizedString"Hans? Why are you in my way?",LocalizedString"River")
		cine_wait(4)
		cp:playConversation(LocalizedString"I pledged my sword to Master Yuen and I am here to stop you.",LocalizedString"Hans")
		cine_wait(6)
		cp:playConversation(LocalizedString"Move, I don't want to kill you.",LocalizedString"River")
		cine_wait(4)
		cp:playConversation(LocalizedString"Every one of us is but a slave to karma, River. May your guns be blessed.",LocalizedString"Hans")
		cine_wait(5)
		cp:playConversation(LocalizedString"Amitabha.",LocalizedString"River",3)
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