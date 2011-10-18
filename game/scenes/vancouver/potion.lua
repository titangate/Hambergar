
local conv = {
	assassin_greet =function(trig,cp)
		wait(2)
		cp:playConversation('Hello, River.')
		wait(3)
		cp:playConversation'You know my name?'
		wait(3)
		cp:playConversation"Who could've not recognize the murderer of Kevin Luo?"
		wait(5)
		cp:playConversation"That name again. Should not have taken that contract."
		wait(5)
		cp:playConversation"And you should not have join Compass for some blood money."
		wait(5)
		cp:playConversation"Exchange with what? A hundred lives of other people?"
		wait(5)
		cp:playConversation"You don't judge me. What do you do?"
		wait(4)
		cp:playConversation"I am a chemist, making potions that could prove to be my salvation."
		wait(5)
		cp:PlayConversation()
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