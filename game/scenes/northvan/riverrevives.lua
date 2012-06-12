
local conv = {
	revive = function(trig,cp)
		cine_wait(5)
		cp:playConversation("Maybe I should pray for you. But you are too weak. You deserve to rot in Avicii.",8,"Master Yuen")
		cine_wait(15)
		cp:playConversation('Where am I....',4,"River")
		cine_wait(10)
		cp:playConversation("You are the only person who can answer this.",5,"Lily")
		cine_wait(8)
		cp:playConversation('Am I on... the train?',4,"River")
		cine_wait(5)
		cp:playConversation("Mhmm.",2,"Lily")
		cine_wait(3)
		cp:playConversation('Am I dead?',3,"River")
		cine_wait(4)
		cp:playConversation("It is your choice. You can die, and hope the gods are gracious enough to offer you a place among the high heavens.",8,"Lily")
		cine_wait(9)
		cp:playConversation("But You don not want that, will you?",4,"River")
		cine_wait(4)
		cp:playConversation("No, YOU do not want that. You are a warrior still.",4,"Lily")
		cine_wait(6)
		cp:playConversation('To complete the cycle',4,"River")
		cine_wait(10)
		playConversation("Let me finish you.",4,"Master Yuen")
		cine_wait(10)
		playConversation("What.. By that is holy...",4,"Master Yuen")
		cine_wait(7)
		cp:playConversation()
		cp:setChoiceTime(0)
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