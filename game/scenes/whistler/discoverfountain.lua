
local conv = {
	opening = function(trig,cp)
		cine_wait(5)
		print 'OHH'
		cp:playConversation"Warlock, I've found it."
		cine_wait(4)
		cp:playConversation"You did? Great. Now drink from it."
		cine_wait(4)
		cp:playConversation"I suppose this liquid is not going to kill me?"
		cine_wait(4)
		cp:playConversation"That's why I sent you for this quest. Swift and Lawrence will have little trouble with the monsters lurking in the dungeon, "
		cine_wait(6.5)
		cp:playConversation"but neither of them have what you possess -- An invicible mind."
		cine_wait(5)
		cp:playConversation"I merely exprienced too much. Now tell me, what's going to happen after I drink from this?"
		cine_wait(5)
		cp:playConversation"The Fountain of Dream does not reveal the same fact to every one, but the every vision is powerful enough to drive an ordinary person mad."
		cine_wait(6)
		cp:playConversation"... I'll talk to you in a bit."
		cine_wait(5)
		cp:playConversation()
		cp:setChoiceTime(0)
	end,
	drink = function(trig,cp)
		cp:playConversation"Let's see what those ancient jerks have for me."
		cine_wait(4)
		cp:playConversation()
		cine_wait(4)
		cp:playConversation()
		cp:setChoiceTime(0)
		popsystem()
		map:finish()
	end,

	leave = function(trig,cp)
		cp:playConversation"I want to look around. I don't feel ready, not just yet."
		cine_wait(5)
		cp:playConversation()
		cp:setChoiceTime(0)
		popsystem()
	end,

}

return function(self)
	local c = require 'cutscene.waterfall.meditation'
	local cp = CutscenePlayer(c)
	pushsystem(cp)
	local t = Trigger:new(conv.opening)
	t:run(cp)
	local choices1 = {
		'DRINK',
		'LEAVE',
	}
	local c = choices1
	cp:setChoiceTime(1000)
	cp.onFinish = function(self)
		cp:setChoice(c)
		n = cp:getChoice()
		if n == 'DRINK' then
			local t = Trigger:new(conv.drink)
			t:run(cp)
			cp:setChoiceTime(1000)
		elseif n == 'LEAVE' then	
			local t = Trigger:new(conv.leave)
			t:run(cp)
			c = choices1
			cp:setChoiceTime(1000)
		end
	end
end