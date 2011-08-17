Effect = Object:subclass('Effect')
function Effect:initialize(skill)
	self.skill = skill
	self.actions = {}
end
function Effect:addAction(action)
	table.insert(self.actions,action)
end
function Effect:removeAction(index)
	table.remove(self.actions,index)
end

UnitEffect = Effect:subclass('UnitEffect')

function UnitEffect:effect(unit,caster,skill)
	for k,v in pairs(self.actions) do
		v(unit,caster,skill)
	end
end

MissileEffect = Effect:subclass('MissileEffect')
ShootMissileEffect = MissileEffect:subclass('ShootMissileEffect')

function ShootMissileEffect:effect(point,caster,skill)
	for k,v in pairs(self.actions) do
		v(point,caster,skill)
	end
end

AoEEffect = Effect:subclass('AoEEffect')
function AoEEffect:effect(point,caster,skill)
	for k,v in pairs(self.actions) do
		v(self:getArea(point),caster,skill)
	end
end

CircleAoEEffect = AoEEffect:subclass('CircleAoEEffect')
function CircleAoEEffect:initialize(range)
	super.initialize(self)
	self.range = range
end

function CircleAoEEffect:getArea(point)
	return {type = 'circle',
	range = self.range,
	x=point[1],
	y=point[2]}
end