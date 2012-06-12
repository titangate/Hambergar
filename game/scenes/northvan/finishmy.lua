
local conv = {
	revive = function(trig,cp)
		cine_wait(5)
		cp:playConversation("You... have grown... beyond me...",4,"Master Yuen")
		cine_wait(4)
		cp:playConversation('Is that your last words?',4,"River")
		cine_wait(4)
		cp:playConversation("Leon... Please... fulfill what I am failed...",6,"Master Yuen")
		cine_wait(6)
		cp:playConversation('How is that possible? You seek destruction of this world, but I seek its salvation.',7,"River")
		cine_wait(7)
		cp:playConversation("You will know... In time...",4,"Master Yuen")
		cine_wait(10)
		cp:playConversation("Compass has started its full scale invasion. With my power,I am ready to fight.",6,"River")
		cine_wait(6)
		cp:playConversation("But, I am too late.",4,"River")
		cine_wait(10)
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