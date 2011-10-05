SolarStormEffect = CircleAoEEffect:new(100)

SolarStormEffect:addAction(function (area,caster,skill)
	if caster:getMP()<skill.manacost then return end
	caster.mp = caster.mp - 30
	local units = map:findUnitsInArea(area)
	for k,v in pairs(units) do
		if v:isKindOf(Unit) and not v:isKindOf(SolarStormUnit) then
			v:damage('Electric',caster:getDamageDealing(80,'Electric'),caster)
			print ('damaging',v)
		end
	end
end)

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
	self.manacost = 30
end

function SolarStorm:stop()
	self.time = 0
end

function SolarStorm:setLevel(lvl)
	self.level = lvl
end

function SolarStorm:startChannel()
	Blureffect.blur('motion',{},0,20)
--	Blureffect.blur('zoom',{},0,2.3)
	super.startChannel(self)
	self.sunit = SolarStormUnit:new(unpack(GetOrderPoint()))
	map:addUnit(self.sunit)
	
	map:addUpdatable(impact)
end

function SolarStorm:endChannel()
	self.sunit.hp = 1
end

function SolarStorm:geteffectinfo()
	return {self.sunit.x,self.sunit.y},self.unit,self
end

function AI.SolarStorm(target)
	local seq = Sequence()
	seq:push(OrderMoveTowardsRange(target,50))
	seq:push(OrderWait(0.1))
	seq.loop = true
	return seq
end

requireImage('assets/electrician/solarstorm.png','solarstorm')
requireImage('assets/electrician/solarstormbolt.png','solarstormbolt')
SolarStormUnit = Unit:subclass('SolarStormUnit')
function SolarStormUnit:initialize(x,y)
	super.initialize(self,x,y,16,10)
	self.HPRegen = -2
	self.maxhp = 20
	self.hp = 20
end

function SolarStormUnit:createBody(...)
	super.createBody(self,...)
	self.shape:setMask(1,2,3,4,5,6,7,9,10,11,12,13,14,15,16) -- except terrain
	self.impact = LightningImpact(self,12,0.5,0.05,100,{0,0,0},0.4)
	map:addUpdatable(self.impact)
	-- Mouse
	self.mousetarget = { update = function()
			local x,y = unpack(GetOrderPoint())
			self.mousetarget.x=x
			self.mousetarget.y=y
		end
	}
	self.mousetarget.update()
	self.ai = AI.SolarStorm(self.mousetarget)
end

function SolarStormUnit:update(dt)
	super.update(self,dt)
	self.mousetarget.update()
	if self.hp <= 0 then
		self:kill(self)
	end
end

function SolarStormUnit:kill(...)
	super.kill(self,...)
	self.impact.life = 1
end

function SolarStormUnit:draw()
	local alpha = math.clamp(self.hp*255,0,255)
	love.graphics.setColor(255,255,255,alpha)
	local r = self.hp - math.floor(self.hp)
	local r2 = self.hp/3
	r2 = r2- math.floor(r2)
	r = r*math.pi*2
		local x,y = self.x,self.y
	for i=1,3 do
		for j=1,4 do
			love.graphics.draw(img.solarstorm,x,y,r+j*math.pi*0.5+i*math.pi*0.33,i*0.3+0.4) -- forming a span
		end
		love.graphics.draw(img.solarstormbolt,x,y,r2*math.pi*2+i*math.pi*2/3,2)
	end
	love.graphics.setColor(255,255,255)
end
