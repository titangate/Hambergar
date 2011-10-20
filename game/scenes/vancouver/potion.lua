
local conv = {
	assassin_greet = function(trig,cp)
		cine_wait(2)
		cp:playConversation('Hello, River.')
		cine_wait(2)
		cp:playConversation'You know my name?'
		cine_wait(3)
		cp:playConversation"Who could've not recognize the murderer of Kevin Luo?"
		cine_wait(5)
		cp:playConversation"That name again. Should not have taken that contract."
		cine_wait(5)
		cp:playConversation"And you should not have join Compass for some blood money."
		cine_wait(5)
		cp:playConversation"I kill for a promise of life."
		cine_wait(5)
		cp:playConversation"One life versus a hundred lives of other people?"
		cine_wait(5)
		cp:playConversation"You don't judge me. What do you do?"
		cine_wait(4)
		cp:playConversation"I am a chemist, making potions that could prove to be my salvation."
		cine_wait(5)
		cp:playConversation()
		cp:setChoiceTime(0)
	end,
	assassin_story = function(trig,cp)
		cp:playConversation"So What made you here?"
		cine_wait(5)
		cp:playConversation"Wind."
		cine_wait(2)
		cp:playConversation"I mean seriously."
		cine_wait(3)
		cp:playConversation"I am. Korea was nuked. I was lucky enough to escape to a boat before all that happen."
		cine_wait(4.5)
		cp:playConversation"Wind favoured us, however the supply didn't. We had to draw to decide who gets to live."
		cine_wait(4.5)
		cp:playConversation"By the time the boat reaches the shore of Vancouver, I'm the only one left."
		cine_wait(4)
		cp:playConversation"That was.. familiar."
		cine_wait(3.5)
		cp:playConversation()
		cp:setChoiceTime(0)
	end,
}

return function(npc)
	local c = require 'cutscene.granvilleisland.potion'
	local cp = CutscenePlayer(c)
	pushsystem(cp)
--	cp:playConversation(t,true)
	if not storydata.assassin_potion_greet then
		storydata.assassin_potion_greet = true
		local t = Trigger:new(conv.assassin_greet)
		t:run(cp)
		cp:setChoiceTime(1000)
	else
		cp:setChoiceTime(2)
	end
	
	local choices1 = {
		'STORY',
		'POTION',
		'LEAVE'
	}
	local c = choices1
	cp.onFinish = function(self)
		cp:setChoice(c)
		n = cp:getChoice()
		if n == 'STORY' then
			local t = Trigger:new(conv.assassin_story)
			t:run(cp)
			cp:setChoiceTime(1000)
		elseif n == 'POTION' then	
			pushsystem(ShopPanel(GetCharacter(),npc))
		elseif n == 'LEAVE' then
			popsystem()
		end
	end
end