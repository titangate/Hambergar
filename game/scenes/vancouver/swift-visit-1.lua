
local conv = {
	greet = {
		[3] = {'What do you seek?',5},
		[12] = {"So, I was told you were the infamous Compass Assassin River.",8}
	},
	story = {
		[0] = {'Why did you end up joining us?',5},
		[6] = {"Because they took the sole reason i lived for, and Now I'm making them pay.",8},
		[16] = {'Your sole reason to live for?',5},
	},
	insist = {
		[0] = {"Tell me about it.",4},
		[5] = {"I am not ready to tell anyone about it yet.",5}
	},
	meditation = {
		[0] = {"Why are you meditating?",4},
		[5] = {"I used to meditate for a better understanding for this universe, but now I just want to recover sooner. We have a war ahead of us.",8},
		[15] = {"Perhaps I should leave you be then.",5},
		[21] = {"Amitabha.",3}
	}
}

return function(self)
	local c = require 'cutscene.waterfall.swift-visit1'
	local c_talk = require 'cutscene.waterfall.rivertalking'
	local cp = CutscenePlayer(c)
	cp:playConversation(conv.greet)
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
			cp:playConversation(conv.story)
			
			cp:setChoiceTime(20)
		elseif n == 'INSIST' then
			cp:play(c_talk)
			c = choices3
			cp:playConversation(conv.insist)
			
			cp:setChoiceTime(10)
			
		elseif n == 'MEDITATION' then
			cp:play(c_talk)
			cp:playConversation(conv.meditation)
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
	pushsystem(cp)
end