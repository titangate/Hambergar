
b_DWS = Buff:subclass('b_DWS')
function b_DWS:initialize(...)
	super.initialize(self,...)
	
	self.icon = requireImage('assets/icon/dws.png',icontable)
	self.genre = 'buff'
end
function b_DWS:stop(unit,dt)
	unit:morphEnd()
	unit:stop()
end
function b_DWS:start(unit)
	unit:gotoState'DWS'
	unit:switchChannelSkill(GetCharacter().skills.pistoldwsalt)
end
function b_DWS:getPanelData()
	return {
		title = 'Divided We Stand',
		type = 'Buff',
		attributes = {
			{text = 'The power of your abilities has drastically increased.'}}
	}
end
DWSEffect = UnitEffect:new()
DWSEffect:addAction(function (unit,caster,skill)
	unit:addBuff(b_DWS:new(skill.movementspeedbuffpercent,skill.movementspeedbuffpercent),skill.DWStime)
	local dws = CutSceneSequence:new()
	map.timescale = 0.25
	local panel2 = goo.object:new()
	local divide = goo.image:new(panel2)
	divide:setPos(screen.width-200,screen.halfheight)
	divide:setImage(character.divide)
	local panel1 = goo.object:new()
	anim:easy(panel1,'x',-300,0,1,'quadInOut')
	anim:easy(panel2,'x',300,0,1,'quadInOut')
	local text = 'DIVIDED WE STAND'
	local x,y = 100,screen.halfheight-50
	for c in text:gmatch"." do
		dws:push(ExecFunction:new(function()
			local ib = goo.DWSText:new(panel1)
			ib:setText(c)
			ib:setPos(x,y)
			local textscale = 2
			x = x+ib.w*textscale
			local animsx = anim:new({
				table = ib,
				key = 'xscale',
				start = 5*textscale,
				finish = 2*textscale,
				time = 0.3,
				style = anim.style.linear}
			)
			local animsy = anim:new({
				table = ib,
				key = 'yscale',
				start = 5*textscale,
				finish = 2*textscale,
				time = 0.3,
				style = anim.style.linear}
			)
			local animg = anim.group:new(animsx,animsy)
			animg:play()
			local animwx = anim:new({
				table = ib,
				key = 'xscale',
				start = 2*textscale,
				finish = 1*textscale,
				time = 0.5,
				style = 'elastic'
			})
			local animwy = anim:new({
				table = ib,
				key = 'yscale',
				start = 2*textscale,
				finish = 1*textscale,
				time = 0.5,
				style = 'elastic'
			})
			local animw = anim.group:new(animwx,animwy)
			local animc = anim.chain:new(animg,animw)
			animc:play()
			TEsound.play('sound/thunderclap.wav')
		end),0)
		
		dws:wait(0.1)
	end	
		dws:wait(0.5)
	dws:push(ExecFunction:new(function()
	anim:easy(panel1,'x',0,screen.width,2,'quadInOut')
	anim:easy(panel2,'x',0,-screen.width,2,'quadInOut')
	map.timescale = 1
	end),0)
	dws:push(ExecFunction:new(function()
	panel1:destroy()
	panel2:destroy()
	end),2)
	map:playCutscene(dws)
end)

DWS = ActiveSkill:subclass('DWS')
function DWS:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Divided We Stand'
	self.effecttime = -1
	self.effect = DWSEffect
	self.cd = 180
	self.cdtime = 0
	self.DWStime = 45
	self.available = true
	self:setLevel(level)
end

function DWS:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	if self.unit:getMPPercent()<1 and (not self.unit.pusheen) then
		return false,'Not enough MP'
	end
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function DWS:getPanelData()
	return{
		title = 'Divided We Stand',
		type = 'Ultimate',
		attributes = {
			{text = "Assassin's ultimate. Can only be initiated with 100% of remaining energy."},
			{text = "Attack: you will automatically fire at three direction while not issuing attack command. When issuing attack command, you will continuously fire 3 time at given direction"},
			{text = "Dash: you will deal damage upon landing with Dash."},
			{text = "Spiral: you will fire 3 rounds of spiral."},
			{text = "Snipe: you will fire 3 sniper rounds."},
			{text = "Mind: you will gain HP instead of Mindpower when enemy is killed"}
		}
	}
end

function DWS:geteffectinfo()
	return self.unit,self.unit,self
end

function DWS:setLevel(lvl)
	self.movementspeedbuffpercent = 0.5*lvl -- inversely proportional
	self.spellspeedbuffpercent = 0.5*lvl
	self.level = lvl
end

