b_Tornadod = Buff:subclass('b_Tornadod')
TornadoEffect = UnitEffect:new()
TornadoEffect:addAction(function(point,caster,skill)
	local chain = caster.chain
	local chain1,chain2 = unpack(caster.subchains)
	chain:setAngle(4.189)
	chain1:setAngle(0)
	chain2:setAngle(2.094)
	chain:tornado(12)
	chain1:tornado(12)
	chain2:tornado(12)
	local length = skill.length
	Timer(0.05,length+20,function(timer)
		if timer.count > length+15 then
			chain:setLength(length+25-timer.count)
			chain1:setLength(length+25-timer.count)
			chain2:setLength(length+25-timer.count)
		elseif timer.count <=5 then
			chain:setLength(timer.count+3)
			chain1:setLength(timer.count+3)
			chain2:setLength(timer.count+3)
		end
	end,true,true)
	Timer(2,1,function()
		caster.chain:revert()
		chain1:revert()
		chain2:revert()
	end,true,true)
	
end)

Tornado = ActiveSkill:subclass('Tornado')
function Tornado:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Tornado'
	self.groupname = 'Chain'
	self.effecttime = -1
	self.effect = TornadoEffect
	self.cd = 1
	self.cdtime = 0
	self.shots = 5
	self.available = true
	self:setLevel(level)
	self.damage = 200
	self.length = 10
	self.hiteffect = Tornadohiteffect
end

function Tornado:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	self.unit:playAnimation('attack',1)
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function Tornado:getPanelData()
	return{
		title = 'Tornado',
		type = 'ACTIVE',
		attributes = {
			{text = 'Tornado your chain and deal damage.'},
		}
	}
end

function Tornado:geteffectinfo()
	return self.unit,self.unit,self
end

function Tornado:stop()
	self.time = 0
end

function Tornado:setLevel(lvl)
	self.level = lvl
end
