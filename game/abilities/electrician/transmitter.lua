
b_Ionicform = Buff:subclass('b_Ionicform')
function b_Ionicform:initialize(point,caster,skill)
	self.point = point
	self.skill = skill
end

function b_Ionicform:start(unit)
	self.trail = BoltTrail:new(unit)
	unit.movementspeedbuffpercent = unit.movementspeedbuffpercent + self.skill.movementspeedbuffpercent
	self.beam = Beam:new({x=unit.x,y=unit.y},unit,1,100,{255,255,255})
	map:addUpdatable(self.trail)
	map:addUpdatable(self.beam)
	unit.shape:setSensor(true)
end

function b_Ionicform:stop(unit)
	unit.state = 'slide'
	unit.movementspeedbuffpercent = unit.movementspeedbuffpercent - self.skill.movementspeedbuffpercent
	unit.body:setLinearVelocity(0,0)
	unit.shape:setSensor(false)
	self.trail.dt = 99
	self.beam.life = 0.5
end

function b_Ionicform:buff(unit,dt)
	unit.direction = self.point;
	unit.state = 'move';
	self.beam.x2,self.beam.y2 = unit.x,unit.y
	unit.mp = unit.mp-dt*self.skill.manacost
	if unit.mp<200 then
		unit:stop()
	end
end

IonicformEffect = ShootMissileEffect:new()
IonicformEffect:addAction(function(point,caster,skill)
	local buff = b_Ionicform:new(point,caster,skill)
	caster:addBuff(buff,99)
	skill.buff = buff
end)

Ionicform = Skill:subclass('Ionicform')
function Ionicform:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Ionicform'
	self.effecttime = 9999
	self.effect = IonicformEffect
	self:setLevel(level)
	self.movementspeedbuffpercent = 10
	self.maxlevel = 3
	self.manacost = 30
end

function Ionicform:getPanelData()
	return{
		title = 'Ionicform',
		type = 'PRIMARY WEAPON',
		attributes = {
			{text = "Purely awesome weapon."},
			{text = 'Firerate (per second)',data = function()return  string.format('%.1f',1/self.casttime) end},
			{text = 'Damage',data = function()return  self.damage end},
		}
	}
end

function Ionicform:startChannel()
	if self.unit.mp<200 then return end
	self.effect:effect(self:getorderinfo())
	self.unit:playAnimation('ionicform',1,true)
end

function Ionicform:endChannel()
	print 'end'
	if self.buff then
		for k,v in pairs(self.unit.buffs) do
			print (k,v,'before')
		end
		self.unit:removeBuff(self.buff)
		for k,v in pairs(self.unit.buffs) do
			print (k,v,'after')
		end
	end
	self.unit:resetAnimation()
	self.buff = nil
end

function Ionicform:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function Ionicform:stop()
	self.time = 0
end

function Ionicform:setLevel(lvl)
	self.casttime = 0.7/(1+lvl*0.2) -- inversely proportional
	self.level = lvl
end
