
local conv = {
	greet = function(trig,cp)
		cine_wait(3)
		cp:playConversation('What do you seek?',3)
		cine_wait(5)
		cp:playConversation("So, I was told you were the infamous Compass Assassin River.",8)
		cine_wait(5)
		
		cp:setChoiceTime(0)
	end,
	story = function(trig,cp)
		cp:playConversation('Why did you end up joining us?',4)
		cine_wait(4)
		cp:playConversation("Because they took the sole reason i lived for, and Now I'm making them pay.",5)
		cine_wait(5)
		cp:playConversation('Your sole reason to live for?',5)
		cine_wait(3)
		cp:setChoiceTime(0)
	end,
	insist = function(trig,cp)
		cp:playConversation('Tell me about it.',4)
		cine_wait(4)
		cp:playConversation("I am not ready to tell anyone about it yet.",5)
		cine_wait(5)
		cp:setChoiceTime(0)
	end,
	meditation = function(trig,cp)
		cp:playConversation('Why are you meditating?',4)
		cine_wait(4)
		cp:playConversation("I used to meditate for a better understanding for this universe, but now I just want to recover sooner. We have a war ahead of us.",8)
		cine_wait(8)
		cp:playConversation("Perhaps I should leave you be then.",3)
		cine_wait(3.5)
		cp:setChoiceTime(0)
		cp:playConversation("Amitabha.",3)
	end,
}

return function(self)
	local c = require 'cutscene.waterfall.swift-visit1'
	local c_talk = require 'cutscene.waterfall.rivertalking'
	local cp = CutscenePlayer(c)
	pushsystem(cp)
	local t = Trigger:new(conv.greet)
	t:run(cp)
	local choices1 = {
		'STORY',
		'MEDITATION',
		'SWITCH',
		'LEAVE'
	}
	local choices2 = {
		'INSIST',
		'MEDITATION',
		'SWITCH',
		'LEAVE'
	}
	local choices3 = {
		'MEDITATION',
		'SWITCH',
		'LEAVE'
	}
	local c = choices1
	
	cp:setChoiceTime(20)
	cp.onFinish = function(self)
		cp:setChoice(c)
		n = cp:getChoice()
		if n == 'STORY' then
			cp:play(c_talk)
			c = choices2
				local t = Trigger:new(conv.story)
				t:run(cp)
			cp:setChoiceTime(20)
		elseif n == 'INSIST' then
			cp:play(c_talk)
			c = choices3
				local t = Trigger:new(conv.insist)
				t:run(cp)
			cp:setChoiceTime(10)
			
		elseif n == 'MEDITATION' then
			cp:play(c_talk)
				local t = Trigger:new(conv.meditation)
				t:run(cp)
			cp:setChoiceTime(25)
		elseif n == 'LEAVE' then
			popsystem()
		elseif n == 'SWITCH' then
			GetCharacter():gotoState'npc'
			SetCharacter(leon2)
			GetGameSystem().bottompanel:fillPanel(GetCharacter():getSkillpanelData())
			GetGameSystem().bottompanel:setPos(screen.halfwidth-512,screen.height - 150)
			GetCharacter().skills.weaponskill:gotoState'interact'
			leon2:gotoState()
			map.camera = FollowerCamera(leon2)
			popsystem()
		end
	end
end