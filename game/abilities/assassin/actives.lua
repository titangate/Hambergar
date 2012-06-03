StimEffect = UnitEffect:new()
StimEffect:addAction(function (unit,caster,skill)
	unit:addBuff(b_Stim:new(skill.movementspeedbuffpercent,skill.movementspeedbuffpercent),skill.stimtime)
end)

Stim = ActiveSkill:subclass('Stim')
function Stim:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Stim'
	self.effecttime = -1
	self.effect = StimEffect
	self.cd = 8
	self.cdtime = 0
	self.stimtime = 5
	self.available = true
	self:setLevel(level)
end

function Stim:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	if self.unit:getHPPercent()<0.2 then
		return false,'Not enough HP'
	end
	
	super.active(self)
	self.unit:damage('Cost',self.unit:getMaxHP()*0.2)
	self.effect:effect(self:getorderinfo())
	return true
end

function Stim:getPanelData()
	return{
		title = 'STIM',
		type = 'ACTIVE',
		attributes = {
			{text = 'Use vitality power to strength assassin for a short period of time. Lose 20% of Maximum HP to initiate. Cannot initiate if your HP if below 20%.'},
			{text = 'Movement Speed',data = function() return string.format('+%.1f',self.movementspeedbuffpercent*100) end},
			{text = 'Skill Speed',data = function() return string.format('+%.1f',self.spellspeedbuffpercent*100) end},
		}
	}
end

function Stim:geteffectinfo()
	return self.unit,self.unit,self
end

function Stim:stop()
	self.time = 0
end

function Stim:setLevel(lvl)
	self.movementspeedbuffpercent = 0.5*lvl -- inversely proportional
	self.spellspeedbuffpercent = 0.5*lvl
	self.level = lvl
end

RoundaboutShotEffect = UnitEffect:new()
RoundaboutShotEffect:addAction(function(unit,caster,skill)
	local shots = skill.shots
	function fire(timer)
		local cosx,sinx = math.cos(math.pi/shots*timer.count*2),math.sin(math.pi/shots*timer.count*2)
		PistolEffect:effect({cosx,sinx},caster,unit.skills.pistol)
	end
	local t = Timer:new(0.05,shots,fire,true)
	t.selfdestruct = true
end)

RoundaboutShot = ActiveSkill:subclass('RoundboutShot')
function RoundaboutShot:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'RoundaboutShot'
	self.effecttime = -1
	self.effect = RoundaboutShotEffect
	self.cd = 2
	self.cdtime = 0
	self.shots = 5
	self.available = true
	self:setLevel(level)
	self.manacost = 50
end

function RoundaboutShot:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	
	if self.unit:getMP()<self.manacost then
		return false,'Not enough MP'
	end
	self.unit.mp = self.unit.mp - self.manacost
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end


function RoundaboutShot:getPanelData()
	return{
		title = 'SPRIAL',
		type = 'ACTIVE',
		attributes = {
			{text = 'Use your mindpower to create a powerful roundabout shot at all direction. The shot inherent your pistol upgrades.'},
			{text = 'Shots',data = function()return self.shots end},
			{text = 'Mindpower cost',data = function()return self.manacost end,image = icontable.mind}
		}
	}
end

function RoundaboutShot:geteffectinfo()
	return self.unit,self.unit,self
end

function RoundaboutShot:stop()
	self.time = 0
end

function RoundaboutShot:setLevel(lvl)
	self.shots = 5+lvl*3
	self.level = lvl
end

RoundaboutShotDWSEffect = UnitEffect:new()
RoundaboutShotDWSEffect:addAction(function(unit,caster,skill)
	local shots = skill.shots
	function fire(timer)
		local cosx,sinx = math.cos(math.pi/shots*timer.count*2),math.sin(math.pi/shots*timer.count*2)
		PistolEffect:effect({cosx,sinx},caster,unit.skills.pistol)
	end
	local t = Timer:new(0.05,shots*3,fire,true)
	t.selfdestruct = true
end)

RoundaboutShotDWS = RoundaboutShot:addState('DWS')
function RoundaboutShotDWS:enterState()
	self.originaleffect = self.effect
	self.effect = RoundaboutShotDWSEffect
end
function RoundaboutShotDWS:exitState()
	self.effect = self.originaleffect
end


DashEffect = ShootMissileEffect:new()
DashEffect:addAction(function(point,caster,skill)
	caster:addBuff(b_Dash:new(point,caster,skill),0.5)
end)
Dash = ActiveSkill:subclass('Dash')
function Dash:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Dash'
	self.effecttime = -1
	self.effect = DashEffect
	self.cd = 2
	self.cdtime = 0
	self.shots = 5
	self.available = true
	self:setLevel(level)
	self.manacost = 50
	self.movementspeedbuffpercent = 3
end

function Dash:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	
	if self.unit:getMP()<self.manacost then
		return false,'Not enough MP'
	end
	self.unit.mp = self.unit.mp - self.manacost
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function Dash:getPanelData()
	return{
		title = 'DASH',
		type = 'ACTIVE',
		attributes = {
			{text = 'Dash for a short distance to avoid incoming attack.'},
		}
	}
end

function Dash:geteffectinfo()
	return GetCharacter().direction,self.unit,self
end

function Dash:stop()
	self.time = 0
end

function Dash:setLevel(lvl)
	self.level = lvl
	if lvl == 2 then
		if self.unit.skills.roundaboutshot then
			return {self.unit.skills.roundaboutshot}
		end
	elseif lvl == 4 then
		if self.unit.skills.stim then
			return {self.unit.skills.stim}
		end
	elseif lvl == 6 then
		if self.unit.skill.invis then
			return {self.unit.skills.invis}
		end
	end
end

b_DashDWS = b_Dash:subclass('b_DashDWS')
function b_DashDWS:stop(unit)
	super.stop(self,unit)
	local area = {type = 'circle',
	range = 200,
	x=unit.x,
	y=unit.y}
	local actor = MindRipFieldActor:new(unit.x,unit.y)
	map:addUnit(actor)
	actor.x,actor.y=area.x,area.y
	local units = map:findUnitsInArea(area)
	for k,v in pairs(units) do
		if v:isKindOf(Unit) and v~=unit then
			v:damage('Mind',unit:getDamageDealing(50,'Mind'),unit)
		end
	end
end


DashDWSEffect = ShootMissileEffect:new()
DashDWSEffect:addAction(function(point,caster,skill)
	caster:addBuff(b_DashDWS:new(point,caster,skill),0.5)
end)
local DashDWS = Dash:addState('DWS')
function DashDWS:enterState()
	self.originaleffect = self.effect
	self.effect = DashDWSEffect
end

function DashDWS:exitState()
	self.effect = self.originaleffect
end

b_Invis = Buff:subclass('b_Invis')
function b_Invis:initialize(...)
	super.initialize(self,...)
	
	
	self.icon = requireImage('assets/icon/invis.png',icontable)
	self.genre = 'buff'
end
function b_Invis:start(unit)
	unit.invisible = true
	self.inviscancellistener = {}
	self.inviscancellistener.handle=function (listener,event)
		if event.type == 'active' or (event.type == 'channel' and event.skill) then
			unit:removeBuff(self)
		end
	end
	unit:stop()
	gamelistener:register(self.inviscancellistener)
end

function b_Invis:stop(unit)
	unit.invisible = false
	gamelistener:unregister(self.inviscancellistener)
end


function b_Invis:getPanelData()
	return {
		title = 'Invisibility',
		type = 'Buff',
		attributes = {
			{text = "You have vanished from enemys' sights."}}
	}
end

InvisEffect = UnitEffect:new()
InvisEffect:addAction(function (unit,caster,skill)
	caster:addBuff(b_Invis:new(),skill.invistime)
end)
Invis = ActiveSkill:subclass('Invis')
function Invis:initialize(unit,level)	
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Invis'
	self.effecttime = -1
	self.effect = InvisEffect
	self.cd = 30
	self.cdtime = 0
	self.available = true
	self:setLevel(level)
	self.manacost = 50
end

function Invis:geteffectinfo()
	return self.unit,self.unit,self
end

function Invis:setLevel(lvl)
	self.level = lvl
	self.invistime = lvl*5
end


function Invis:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	if self.unit:getMP()<self.manacost then
		return false,'Not enough MP'
	end
	self.unit.mp = self.unit.mp - self.manacost
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end


function Invis:getPanelData()
	return{
		title = 'INVISIBILITY',
		type = 'ACTIVE',
		attributes = {
			{text = 'Use mindpower to generate a spiritual mist, hallucinate enemies and grant yourself invisibility. Using any skill or item will cancel your invisibility. The first strike you fire with invisibility will be a garanteed critical strike'},
			{text = 'Duration',data = function()return self.invistime end}
		}
	}
end
