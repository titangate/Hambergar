
local conv = {
	meditation = function(trig,cp)
		cine_wait(2)
		cp:playConversation'From unreal lead me to the real.'
		cine_wait(5)
		cp:playConversation'From darkness lead me to the light.'
		cine_wait(5)
		cp:playConversation'From death lead me to immortality.'
		cine_wait(5)
		cp:playConversation()
		cp:setChoiceTime(0)
	end,
}

return function(self)
	local c = require 'cutscene.waterfall.meditation'
	local cp = CutscenePlayer(c)
	pushsystem(cp)
	local t = Trigger:new(conv.meditation)
	t:run(cp)
	local choices1 = {
		'SAVE',
		'CHARACTER',
		'LEAVE'
	}
	local c = choices1
	
	cp:setChoiceTime(2)
	cp.onFinish = function(self)
		cp:setChoice(c)
		n = cp:getChoice()
		if n == 'SAVE' then
			-- TODO
		elseif n == 'CHARACTER' then	
			GetCharacter().manager.tree.learning = true
			GetCharacter().manager:start()
			print (GetCharacter().manager.tree.learning)
--			GetGameSystem().bottompanel.count=0
			pushsystem(GetCharacter().manager)
		elseif n == 'LEAVE' then
			popsystem()
		end
	end
end