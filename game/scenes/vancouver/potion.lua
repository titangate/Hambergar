
local conv = {
	assassin_greet = {
		{'Hello, River.',2},
		{'You know my name?',2},
		{"Who could've not recognize the murderer of Stephen Harper?",5},
		{"That name again. Should not have taken that contract.",5},
		{"And you should not have join Compass for some blood money.",5},
		{"I did not join Compass for money. I joined for an exchange for a life.",5},
		{"Exchange with what? A hundred lives of other people?",5},
		{"You don't judge me. What do you do?",4},
		{"I am a chemist, making potions that could prove to be my salvation.",5},
	},
}

return function(self)
	local c = require 'cutscene.granvilleisland.potion'
	local cp = CutscenePlayer(c)
	print (c)
	cp:playConversation(conv.greet,true)
	local choices1 = {
		'STORY',
		'POTION',
		'LEAVE'
	}
	local c = choices1
	
	cp:setChoiceTime(2)
	cp.onFinish = function(self)
		cp:setChoice(c)
		n = cp:getChoice()
		if n == 'STORY' then
			
		elseif n == 'POTION' then	
		
		elseif n == 'LEAVE' then
			popsystem()
		end
	end
	pushsystem(cp)
end