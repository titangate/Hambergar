
local conv = {
	meditation = {
		[2] = {'From unreal lead me to the real.',5},
		[8] = {'From darkness lead me to the light.',5},
		[14] = {'From death lead me to immortality.',5},
	},
}

return function(self)
	local c = require 'cutscene.waterfall.meditation'
	local cp = CutscenePlayer(c)
	print (c)
	cp:playConversation(conv.meditation,true)
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
			GetGameSystem().bottompanel.count=0
			pushsystem(GetCharacter().manager)
		elseif n == 'LEAVE' then
			popsystem()
		end
	end
	pushsystem(cp)
end