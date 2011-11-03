
local conv = {
	opening = function(trig,cp)
		cine_wait(2)
		cp:playConversation'River? River? Are you there?'
		cine_wait(5)
		cp:playConversation"Arr. Yeah, I'm alright."
		cine_wait(5)
		cp:playConversation"I hope the trial wasn't too hard for you."
		cine_wait(5)
		cp:playConversation"Well... Warlock, I don't think I've found the rune."
		cine_wait(5)
		cp:playConversation"What? That's not possible! The prophet says... It should..."
		cine_wait(5)
		cp:playConversation"It's not here, I'm sorry. There's nothing I can do."
		cine_wait(5)
		cp:playConversation".... Fine, I guess I don't have any suggestions either. Now stay there, I've sent the choper to pick you up."
		cine_wait(7)
		cp:playConversation"Alright. -BEEP-"
		cine_wait(12)
		cp:playConversation("So it all ends up nothing, didn't it, Leon?",5)
		cine_wait(8)
		cp:playConversation"You... It's you again!"
		cine_wait(4)
		cp:playConversation"Calm down now, I know you have a lot to say."
		cine_wait(5)
		cp:playConversation"In fact I don't. I just want to rip your guts out."
		cine_wait(5)
		cp:playConversation"Not if you still wants to see her again, do you?"
		cine_wait(5)
		cp:playConversation"What??"
		cine_wait(4)
		cp:playConversation()
		cp:setChoiceTime(0)
	end,
	lily = function(trig,cp)
		cp:playConversation'What do you mean by... is she... alive?'
		cine_wait(5)
		cp:playConversation"I do not kill, not the innocents."
		cine_wait(5)
		cp:playConversation"I saw you killed her... There's no way. I dreamed of it everyday."
		cine_wait(5)
		cp:playConversation"She only fell into a coma. Do you really think I'd kill her? She has a bigger use alive than dead."
		cine_wait(7)
		cp:playConversation"You're a liar... show me the proof."
		cine_wait(5)
		cp:playConversation"You met her on Skytrain. She noticed you and asked for your number. Then she said, 'Your watch was an hour behind.'"
		cine_wait(7)
		cp:playConversation"On the day before, you assassinated Cambol Riad. You're too tired and you forgot about the time change."
		cine_wait(6)
		cp:playConversation"You're an asshole."
		cine_wait(4)
		cp:playConversation"If you ever want to see her, talk to me while meditating."
		cine_wait(4)
		cp:playConversation()
		cp:setChoiceTime(0)
	end,

	rune = function(trig,cp)
		cp:playConversation'Did you take the rune?'
		cine_wait(5)
		cp:playConversation"No. In fact, when i tried to search for it, turns out someone else has taken it already."
		cine_wait(7)
		cp:playConversation"Who do you think took it?"
		cine_wait(5)
		cp:playConversation"Well investigation isn't really my profession. Beside, I'm not on your side. Not yet."
		cine_wait(7)
		cp:playConversation()
		cp:setChoiceTime(0)
	end,

	compass = function(trig,cp)
		cp:playConversation'What is Compass up to?'
		cine_wait(4)
		cp:playConversation"To destroy Vancouver and implement the vision of His Grace."
		cine_wait(5)
		cp:playConversation"Whoever your king is, he must be mad and cruel, attempting to kill millions of innocents."
		cine_wait(5)
		cp:playConversation"God cherish innocents, there would be no better sacrifice."
		cine_wait(4)
		cp:playConversation()
		cp:setChoiceTime(0)
	end,

	leave = function(trig,cp)
		cp:playConversation"Before the chopper comes, I would like to give you something."
		cine_wait(4)
		cp:playConversation"What is it?"
		cine_wait(3)
		cp:playConversation"Remember they day you came to my temple? You told me you wish no longer wish to be a killer. You gave me this pistol, claiming there is too much blood on it that you wish it sealed."
		cine_wait(8)
		cp:playConversation"Now that you're a killer once more, I should give this thing back to you, as a token of honesty."
		cine_wait(5.5)
		cp:playConversation"Great, good old memories."
		cine_wait(3.5)
		cp:playConversation"Every one of us is but a slave to karma, Leon. Amitabha."
		cine_wait(4)
		cp:playConversation"Namu Amitabha."
		cine_wait(5)
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
		'LILY',
		'COMPASS',
		'RUNE',
	}
	local choices2 = {
		'LEAVE',
		'COMPASS',
		'RUNE',
	}
	local c = choices1
	
	cp:setChoiceTime(2)
	cp.onFinish = function(self)
		cp:setChoice(c)
		n = cp:getChoice()
		if n == 'LILY' then
			local t = Trigger:new(conv.lily)
			t:run(cp)
			c = choices2
		elseif n == 'RUNE' then	
			local t = Trigger:new(conv.rune)
			t:run(cp)
		elseif n == 'COMPASS' then
			local t = Trigger:new(conv.compass)
			t:run(cp)
		elseif n == 'LEAVE' then
			local t = Trigger:new(conv.leave)
			t:run(cp)
		end
	end
end