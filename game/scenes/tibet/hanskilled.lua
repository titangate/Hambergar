
local conv = {
	ending = function(trig,cp)
		cine_wait(4)
		cp:playConversation"Not yet... I'm not finished!!!"
		cine_wait(15)
		cp:playConversation"So there I was, drifting among rocks and death."
		cine_wait(5)
		cp:playConversation"When I finally regained my consciousness, I realized disappointely, I did not die, nor did Master Yuen. In fact, I've never seen him on Tibet mountain."
		cine_wait(8)
		cp:playConversation"That is, when I saw him again as I made my way to the harber..."
		cine_wait(8)
		cp:playConversation("You useless pawn.",5,"Master Yuen")
		cine_wait(15)
		cp:playConversation("There stands my master. I came to him all the way here, but I am not at my best condition.",8,"River")
		cine_wait(5)
		cp:playConversation("But, I don't seem to have a choice",5,"River")
		cine_wait(10)
		cp:setChoiceTime(0)
	end,
}

return function(npc)
	local c = require 'cutscene.tibet.hanskilled'
	local cp = CutscenePlayer(c)
	pushsystem(cp)
--	cp:playConversation(t,true)
	local t = Trigger(conv.ending)
	t:run(cp)

	cp.onFinish = function(self)
		popsystem()
	end
end