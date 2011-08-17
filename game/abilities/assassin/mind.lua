MindRipfieldEffect = CircleAoEEffect:new(100)
MindRipfieldEffect:addAction(function (area,caster,skill)
	if caster:getMP()<skill.manacost then return end
	caster.mp = caster.mp-20
	local actor = MindRipFieldActor:new(area.x,area.y)
	map:addUnit(actor)
	actor.x,actor.y=area.x,area.y
	local units = map:findUnitsInArea(area)
	for k,v in pairs(units) do
		if v:isKindOf(Unit) then
			v:addBuff(b_Stun:new(100,nil),1)
			v:damage('mind',caster:getDamageDealing(50,'mind'),caster)
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
end

function MindRipfield:stop()
	self.time = 0
end

function MindRipfield:setLevel(lvl)
	self.level = lvl
end

function MindRipfield:startChannel()
	super.startChannel(self)
	self.point = GetOrderPoint()
end

function MindRipfield:geteffectinfo()
	return self.point,self.unit,self
end

rip = love.graphics.newImage('assets/rip.png')
ripcircle = love.graphics.newImage('assets/ripcircle.png')
MindRipFieldActor = Object:subclass('MindRipFieldActor')
function MindRipFieldActor:initialize(x,y)
	self.x,self.y=x,y
	local p = love.graphics.newParticleSystem(rip, 1000)
	p:setEmissionRate(500)
	p:setSpeed(300, 400)
	p:setGravity(0)
	p:setSize(1, 0.5)
	p:setColor(255, 122, 122, 255, 122, 122, 255, 0)
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
			map:removeUnit(self)
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
	love.graphics.draw(ripcircle,self.x,self.y,0,scale*2,scale*2,128,128)
	love.graphics.setColor(255,255,255,255)
end

MindDrainActor=Object:subclass('MindDrainActor')
function MindDrainActor:initialize(unit,x,y)
	self.unit = unit
	self.x,self.y=x,y
	local p = love.graphics.newParticleSystem(pulse,1000)
	p:setEmissionRate(20)
	p:setSpeed(0, 0)
	p:setGravity(0)
	p:setSize(0.4,0.4)
	p:setColor(83, 168, 255, 255, 255, 255, 255, 0)
	p:setPosition(400, 300)
	p:setLifetime(1)
	p:setParticleLife(1)
	p:stop()
	self.system=p
	map:addUnit(self)
end


function MindDrainActor:update(dt)
	local x,y=self.unit.x-self.x,self.unit.y-self.y
	x,y=normalize(x,y)
	self.x,self.y=self.x+x*dt*100,self.y+y*dt*100
	if math.abs((self.x-self.unit.x)*(self.y-self.unit.y))<100 then
		map:removeUnit(self)
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
		a.system:setColor(255, 168, 83,255,255,255,255,255)
	end
end

assassinkilllistener = MindListener:new()
gamelistener:register(assassinkilllistener)

Mind = Skill:subclass('Mind')
function Mind:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Mind'
	self:setLevel(level)
end

function Mind:setLevel(lvl)
	self.manaregen = 25*lvl
	self.level = lvl
end

function Mind:getPanelData()
	return{
		title = 'MIND POWER',
		type = 'ACTIVE',
		attributes = {
			{text = "Assassin's source of power. Everytime assassin kills an enemy, he drains the victim's neural energy and supply it as his own."},
			{text = 'Regen per kill',image = icontable.mind,data = function()return self.manaregen end}
		}
	}
end

local MindDWS = Mind:addState('DWS')
function MindDWS:enterState()
	assassinkilllistener:gotoState('DWS')
end

function MindDWS:exitState()
	assassinkilllistener:gotoState()
end