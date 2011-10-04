SolarStormEffect = CircleAoEEffect:new(100)
--[[
SolarStormEffect:addAction(function (area,caster,skill)
	if caster:getMP()<skill.manacost then return end
	caster.mp = caster.mp-20
	local actor = MindRipFieldActor:new(area.x,area.y)
	map:addUpdatable(actor)
	actor.x,actor.y=area.x,area.y
	local units = map:findUnitsInArea(area)
	for k,v in pairs(units) do
		if v:isKindOf(Unit) then
			v:addBuff(b_Stun:new(100,nil),1)
			v:damage('mind',caster:getDamageDealing(50,'mind'),caster)
		end
	end
end)]]

SolarStorm = Skill:subclass('SolarStorm')

function SolarStorm:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'SolarStorm'
	self.effecttime = 0.05
	self.casttime = 1
	self.effect = SolarStormEffect
	self:setLevel(level)
	self.manacost = 20
end

function SolarStorm:stop()
	self.time = 0
end

function SolarStorm:setLevel(lvl)
	self.level = lvl
end

function SolarStorm:startChannel()
	super.startChannel(self)
	self.unit = SolarStormUnit:new(GetOrderPoint())
end

function SolarStorm:geteffectinfo()
	return self.point,self.unit,self
end

requireImage('assets/electrician/solarstorm.png','solarstorm')
SolarStormUnit = Unit:subclass('SolarStormUnit')
function SolarStormUnit:initialize(...)
	super.initialize(self,...)
	self.HPRegen = -5
	self.maxhp = 100
	self.hp = 100
end

function SolarStormUnit:createBody(...)
	super.createBody(self,...)
	self.shape:setMask(1,2,3,4,5,6,7,9,10,11,12,13,14,15,16) -- except terrain
end

function SolarStormUnit:draw()
	local r = self.hp - math.floor(self.hp)
	r = r*math.pi*2
	for i=1,3 do
		for j=1,4 do
			love.graphics.draw(img.solarstorm,self.x,self.y,r+j*math.pi*0.5+i*math.pi*0.33,i*0.3+0.4) -- forming a span
		end
	end
end
