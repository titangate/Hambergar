
local conv = {
	assassin_greet = function(trig,cp)
		cine_wait(2)
		cp:playConversation('Hello, River.')
		cine_wait(3)
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
}

return function(self)
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
			
		elseif n == 'POTION' then	
		
		elseif n == 'LEAVE' then
			popsystem()
		end
	end
end