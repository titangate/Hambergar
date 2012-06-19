MindRipfieldEffect = CircleAoEEffect:new(100)
MindRipfieldEffect:addAction(function (area,caster,skill)
	if caster:getMP()<skill.manacost then return end
	caster.mp = caster.mp-20
	local actor = MindRipFieldActor:new(area.x,area.y)
	map:addUpdatable(actor)
	actor.x,actor.y=area.x,area.y
	local units = map:findUnitsInArea(area)
	for k,v in pairs(units) do
		if v:isKindOf(Unit) then
			v:addBuff(b_Stun:new(100,nil),1)
			v:damage('Mind',caster:getDamageDealing(skill.damage,'Mind'),caster)
		end
	end
end)

MindRipfield = Skill:subclass('MindRipfield')

function MindRipfield:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'MindRipfield'
	self.effecttime = 0.05
	self.casttime = 1
	self.effect = MindRipfieldEffect
	self:setLevel(level)
	self.manacost = 20
	self.damage = 50
end

function MindRipfield:stop()
	self.time = 0
end

function MindRipfield:setLevel(lvl)
	self.level = lvl
	self.damage = 50*lvl
end

function MindRipfield:startChannel()
	super.startChannel(self)
	self.point = GetOrderPoint()
end

function MindRipfield:geteffectinfo()
	return self.point,self.unit,self
end

function MindRipfield:getPanelData()
	return{
		title = LocalizedString'Mind Rip Field',
		type = LocalizedString'Active Channel',
		attributes = {
			{text = LocalizedString"Creates a vortex of concentrated mind power, damage and stun enemies caught."},
			{text = LocalizedString"Damage",data = function() return self.damage end}
		}
	}
end
MindRipFieldActor = Object:subclass('MindRipFieldActor')
function MindRipFieldActor:initialize(x,y)
	self.x,self.y=x,y
	local p = love.graphics.newParticleSystem(requireImage'assets/rip.png', 1000)
	p:setEmissionRate(options.particlerate*500)
	p:setSpeed(300, 400)
	p:setGravity(0)
	p:setSizes(1, 0.5)
	p:setColors(255, 122, 122, 255, 122, 122, 255, 0)
	p:setPosition(self.x,self.y)
	p:setLifetime(0.5)
	p:setParticleLife(0.5)
	p:setDirection(0)
	p:setSpread(360)
	p:setRadialAcceleration(-500)
	p:setTangentialAcceleration(1500)
	p:stop()
	self.system=p
	self.dt = 0
	self.time = 1
	self.visible = true
	x,y = map.camera:transform(x,y)
	x,y = x/screen.w+0.5,1-(y+300)/screen.w
	filtermanager:setFilterArguments('Shockwave',{center = {x,y}})
	
	filtermanager.filter.Shockwave:reset()
end


function MindRipFieldActor:reset()
	self.dt = 0
	self.visible = true
end

function MindRipFieldActor:update(dt)
	self.dt = self.dt+dt
	if self.dt>self.time then
		self.system:update(dt)
		if self.dt>self.time+1 then
			self.visible = false
			map:removeUpdatable(self)
		end
	else
		self.system:setPosition(self.x,self.y)
		self.system:start()
		self.system:update(dt)
	end
end

function MindRipFieldActor:draw()
	if not self.visible then return end
	love.graphics.draw(self.system,0,0)
	local scale = self.dt/self.time
	love.graphics.setColor(255,255*(1-scale),255*(1-scale),255*(1-scale))
	love.graphics.draw(requireImage'assets/ripcircle.png',self.x,self.y,0,scale*2,scale*2,128,128)
	love.graphics.setColor(255,255,255,255)
	filtermanager:requestFilter('Shockwave')
end

MindDrainActor=Object:subclass('MindDrainActor')
function MindDrainActor:initialize(unit,x,y)
	self.unit = unit
	self.x,self.y=x,y
	local p = love.graphics.newParticleSystem(img.pulse,1000)
	p:setEmissionRate(options.particlerate*20)
	p:setSpeed(0, 0)
	p:setGravity(0)
	p:setSizes(0.4,0.4)
	p:setColors(83, 168, 255, 255, 255, 255, 255, 0)
	p:setPosition(400, 300)
	p:setLifetime(1)
	p:setParticleLife(1)
	p:stop()
	self.system=p
	map:addUpdatable(self)
end


function MindDrainActor:update(dt)
	local x,y=self.unit.x-self.x,self.unit.y-self.y
	x,y=normalize(x,y)
	self.x,self.y=self.x+x*dt*100,self.y+y*dt*100
	if math.abs((self.x-self.unit.x)*(self.y-self.unit.y))<100 then
		map:removeUpdatable(self)
	end
	self.system:setPosition(self.x,self.y)
	self.system:start()
	self.system:update(dt)
end

function MindDrainActor:draw()
	love.graphics.draw(self.system)
end

MindListener = StatefulObject:subclass('MindListener')
function MindListener:handle(event)
	if event.type == 'death' and event.killer == GetCharacter() then
		event.killer.mp = event.killer.mp + event.killer.skills.mind.manaregen
		local a = MindDrainActor:new(event.killer,event.unit.x,event.unit.y)
	end
end
local MindListenerDWS = MindListener:addState('DWS')
function MindListenerDWS:handle(event)
	if event.type == 'death' and event.killer == GetCharacter() then
		event.killer.hp = event.killer.hp + event.killer.skills.mind.manaregen
		local a = MindDrainActor:new(event.killer,event.unit.x,event.unit.y)
		a.system:setColors(255, 168, 83,255,255,255,255,255)
	end
end
local nothing = MindListener:addState('nothing')
function nothing:handle() end

b_Mind = Buff:subclass('b_Mind')
function b_Mind:initialize(MPRegen)
	self.MPRegen = MPRegen
end
function b_Mind:start(unit)
	unit.MPRegen = unit.MPRegen + self.MPRegen
end
function b_Mind:stop(unit)
	unit.MPRegen = unit.MPRegen - self.MPRegen
end


Mind = Skill:subclass('Mind')
function Mind:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Mind'
	self:setLevel(level)
end

function Mind:setLevel(lvl)
	self.level = self.level or 0
	if self.unit:hasBuff(b_Mind) then
		self.unit:removeBuff(b_Mind)
	end
	self.unit:addBuff(b_Mind(5*lvl),true)
--	self.unit.MPRegen = self.unit.MPRegen + 5*(lvl-self.level)
	self.level = lvl
	if lvl == 2 then
		if self.unit.skills.mindripfield then
			return {self.unit.skills.mindripfield}
		end
	elseif lvl == 4 then
		if self.unit.skills.invis then
			return {self.unit.skills.invis}
		end
	elseif lvl == 6 then
		if self.unit.skills.mysteriousqi then
			return {self.unit.skills.mysteriousqi}
		end
	end
end

function Mind:getEnabled()
	local enabled = {}
	if self.level>=2 then
		table.insert(enabled,self.unit.skills.mindripfield)
		if self.level>=4 then
			table.insert(enabled,self.unit.skills.invis)
			if self.level>=6 then
				table.insert(enabled,self.unit.skills.mysteriousqi)
			end
		end
	end
	return enabled
end

function Mind:getPanelData()
	return{
		title = LocalizedString'MIND POWER',
		type = LocalizedString'Passive',
		attributes = {
			{text = LocalizedString"Assassin's source of power. Everytime assassin kills an enemy, he drains the victim's neural energy and supply it as his own."},
			{text = LocalizedString'Energy Regen',image = icontable.mind,data = function()return 5*self.level end}
		}
	}
end

local MindDWS = Mind:addState('DWS')
function MindDWS:enterState()
--	assassinkilllistener:gotoState('DWS')
end

function MindDWS:exitState()
--	assassinkilllistener:gotoState()
end

b_Qi = Buff:subclass('b_Qi')
function b_Qi:initialize(evade)
	self.evade = evade
	self.genre = 'buff'
	self.icon = requireImage'assets/icon/innerair.png'
end

function b_Qi:start(unit)
	local t = 1 - unit.evade
	t = t * (1-self.evade)
	unit.evade = getdodgerate(unit.evade,self.evade)
end

function b_Qi:stop(unit)
	unit.evade = getdodgerate(unit.evade,-self.evade)
end

function b_Qi:getPanelData()
	return {
		title = LocalizedString'Mysterious Qi',
		type = LocalizedString'Buff',
		attributes = {
			{text = LocalizedString'Temperarily increase evade chance.'}}
	}
end

MysteriousQi = Skill:subclass'MysteriousQi'
function MysteriousQi:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self:setLevel(level)
	self.chance = 1
	self.time = 3
end


function MysteriousQi:setLevel(lvl)
	self.level = lvl or 0
	self.evade = 0.1 + lvl * 0.1
end

function MysteriousQi:getPanelData()
	return{
		title = LocalizedString'MYSTERIOUS QI',
		type = LocalizedString'Passive',
		attributes = {
			{text = LocalizedString"An inner power aligning breath, movement, and awareness for exercise, healing, and meditation."},
			{text = LocalizedString"Temperarily increase evade chance after executing a critical hit."},
			{text = LocalizedString'Duration',data = self.time },
			{text = LocalizedString'Evade',data = string.format("%.1f",self.evade*100).."%" },
		}
	}
end