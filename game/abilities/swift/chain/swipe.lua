
b_Swiped = Buff:subclass('b_Swiped')
SwipeEffect = ShootMissileEffect:new()
local direction = 6
SwipeEffect:addAction(function(point,caster,skill)
	local chain = caster.chain
	caster.chain:setLength(4)
	chain:swipe(math.atan2(point[2],point[1]),1.5,direction)
	
	direction = direction *-1
	caster.chain:setLength(10)
	Timer(0.05,20,function(timer)
		if timer.count <=5 then
			caster.chain:setLength(timer.count+3)
		end
	end,true,true)
	Timer(1,1,function()
		caster.chain:revert()
	end,true,true)
	
	chain:setCollisionCallback(
	function(b,coll,segment)
		if b:isKindOf(Unit) and b:isEnemyOf(caster) then
			if not b:hasBuff(b_Swiped) then -- create buff
				
				TEsound.play({'sound/sword1.wav','sound/sword2.wav','sound/sword3.wav'})
				if skill.hiteffect then skill.hiteffect:effect(b,caster,skill) end
				b:addBuff(b_Swiped(),0.5)
			end
		end
	end
	)
end)
swipehiteffect = UnitEffect()
swipehiteffect:addAction(function(target,unit,skill)
	target:damage('Bullet',skill.damage,unit)
end)
Swipe = ActiveSkill:subclass('Swipe')
function Swipe:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Swipe'
	self.groupname = 'Chain'
	self.effecttime = -1
	self.effect = SwipeEffect
	self.cd = 1
	self.cdtime = 0
	self.shots = 5
	self.available = true
	self:setLevel(level)
	self.damage = 200
	self.hiteffect = swipehiteffect
end

function Swipe:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	self.unit:playAnimation('attack',1)
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function Swipe:getPanelData()
	return{
		title = 'Swipe',
		type = 'ACTIVE',
		attributes = {
			{text = 'Swipe your chain and deal damage.'},
		}
	}
end

function Swipe:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function Swipe:stop()
	self.time = 0
end

function Swipe:setLevel(lvl)
	self.level = lvl
end
