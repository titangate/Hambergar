DragEffect = UnitEffect:new()
DragEffect:addAction(function(unit,caster,skill)
	skill.movementspeedbuffpercent = getdistance(unit,caster)/50
	local buff = b_Dash:new({normalize(unit.x-caster.x,unit.y-caster.y)},caster,skill)
	caster:addBuff(buff,1)
	unit:removeBuff(b_Hooked)
	Timer:new(0.05,caster.chain.length-3,function(timer)
		caster.chain:setLength(3+timer.count)
	end,true,true)
end)
Drag = ActiveSkill:subclass('Drag')
function Drag:initialize(unit,level)
	super.initialize(self)
	self.unit = unit
	self.name = 'Drag'
	self.effect = DragEffect
	self.cd = 8
	self.cdtime = 0
	self.available = true
	self.movementspeedbuffpercent = 5
	self.manacost = 30
	self:setLevel(level)
end

function Drag:stop()
	self.time = 0
end

function Drag:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	
	if self.unit:getMP()<self.manacost then
		return false,'Not enough MP'
	end
	if not self.unit.chain.attachment then
		return false,'Not Hooked'
	end
	self.unit.mp = self.unit.mp - self.manacost
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function Drag:geteffectinfo()
	return self.unit.chain.attachment,self.unit,self
end


function Drag:setLevel(lvl)
	self.level = lvl
end