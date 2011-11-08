
local conv = {
	opening = function(trig,cp)
		cine_wait(2)
		cp:playConversation'Is that.. you.. Lily?'
		cine_wait(3)
		cp:playConversation"Don't you recognize me anymore?"
		cine_wait(3.5)
		cp:playConversation"This is not possible... I clearly remember... you..."
		cine_wait(4)
		cp:playConversation"You left me die in the hand of Compass. You have not forgotten it."
		cine_wait(4)
		cp:playConversation"No.. hear me explain..."
		cine_wait(3)
		cp:playConversation"I know what you are seeking. Stop lying to yourself, Leon."
		cine_wait(4)
		cp:playConversation()
		cp:setChoiceTime(0)
	end,
	leon = function(trig,cp)
		cp:playConversation"You're right. Whatever I tried to do, nothing is resolved since your death. I've lost everything, my one true love, my identity."
		cine_wait(8)
		cp:playConversation"Then what are you fighting for?"
		cine_wait(4)
		cp:playConversation()
		cp:setChoiceTime(0)
	end,

	defence = function(trig,cp)
		cp:playConversation'I need to stop Compass. They will destroy everything if I fail.'
		cine_wait(5)
		cp:playConversation"What about me? Do you love them over me?"
		cine_wait(7)
		cp:playConversation()
		cp:setChoiceTime(0)
	end,

	vengence = function(trig,cp)
		cp:playConversation'They will pay for your blood.'
		cine_wait(4)
		cp:playConversation"Will that bring me back from death?"
		cine_wait(5)
		cp:playConversation()
		cp:setChoiceTime(0)
	end,

	train = function(trig,cp)
		cp:playConversation'Why are we.. here?'
		cine_wait(4)
		cp:playConversation"This is the place we first met, remember?"
		cine_wait(5)
		cp:playConversation"But... Why? What is your purpose here?"
		cine_wait(4)
		cp:playConversation"Same reason as you."
		cine_wait(4)
		cp:playConversation()
		cp:setChoiceTime(0)
	end,

	lily = function(trig,cp)
		cp:playConversation"Do you know how much I miss you?"
		cine_wait(4)
		cp:playConversation"Come and find me. (chuckles)"
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
		'LEON',
		'TRAIN',
		'LILY'
	}
	local choices2 = {
		'DEFENCE',
		'VENGENCE'
	}
	local c = choices1
	
	cp:setChoiceTime(1000)
	cp.onFinish = function(self)
		cp:setChoice(c)
		n = cp:getChoice()
		if n == 'LEON' then
			local t = Trigger:new(conv.leon)
			t:run(cp)
			c = choices2
			cp:setChoiceTime(1000)
		elseif n == 'DEFENCE' then	
			local t = Trigger:new(conv.defence)
			t:run(cp)
			c = choices1
			cp:setChoiceTime(1000)
		elseif n == 'VENGENCE' then
			local t = Trigger:new(conv.vengence)
			t:run(cp)
			c = choices1
			cp:setChoiceTime(1000)
		elseif n == 'TRAIN' then
			local t = Trigger:new(conv.train)
			t:run(cp)
			cp:setChoiceTime(1000)
		elseif n == 'LILY' then
			local t = Trigger:new(conv.lily)
			t:run(cp)
			cp:setChoiceTime(1000)
		end
	end
end