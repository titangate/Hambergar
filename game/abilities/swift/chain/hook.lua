b_Hooking = Buff:subclass('b_Hooking')

function b_Hooking:initialize(priority,actor)
	self.dt = 0
	self.time = 0.05
	self.chainlength = 3
end

function b_Hooking:buff(unit,dt)
	local skill = self.skill
	self.dt = self.dt + dt
	if self.dt>self.time then
		self.dt = self.dt - self.time
		self.chainlength = self.chainlength + 1
		if self.chainlength > skill.length then
			unit:removeBuff(self)
			Timer:new(0.05,skill.length-3,function(timer)
				unit.chain:setLength(3+timer.count)
			end,true,true)
		else
			unit.chain:setLength(self.chainlength)
		end
	end
 	unit.state = 'slide'
	unit.allowskill = false
end

HookEffect = ShootMissileEffect:new()
HookEffect:addAction(function(point,caster,skill)
	local chain = caster.chain
	chain:setLength(3)
	chain:stab(math.atan2(point[2],point[1]))
	local maxlength = skill.length
	local buff = b_Hooking()
	buff.skill = skill
	buff.caster = caster
	chain:setCollisionCallback(
	function(b,coll,segment)
		if b:isKindOf(Unit) and b:isEnemyOf(caster) then
			if not b:hasBuff(b_Hooked) then
				TEsound.play({'sound/sword1.wav','sound/sword2.wav','sound/sword3.wav'})
				if skill.hiteffect then skill.hiteffect:effect(b,caster,skill) end
				caster:removeBuff(buff)
				chain:setCollisionCallback()
			end
		end
	end)
	caster:addBuff(buff,1)
end)

b_Hooked = b_Stun:subclass('b_Hooked')
function b_Hooked:stop(unit)
	if unit.shape then
		assert(self.mask)
		unit.shape:setMask(unpack(self.mask))
		if self.add ~= false then
			unit.add = self.add
		end
	end
	unit.state = 'slide'
	self.caster.chain:unattach()
end

function b_Hooked:buff(unit,dt)
	unit.state = 'auto'
	unit.allowskill = false
end

function b_Hooked:start(unit)
	if unit.shape then
		self.mask = {unit.shape:getMask()}
		unit.shape:setMask(cc.playermissile,cc.enemymissile,cc.player)
		if unit.add then
			self.add = unit.add
		else
			self.add = false
		end
		assert(self.caster)
		local c = self.caster
		function unit.add(unit,b,coll)
			if b:isKindOf(Unit) and b:isEnemyOf(c) then
				b:damage('Bullet',self.skill.smashdamage,self.caster)
				TEsound.play({'sound/thunderclap.wav'})
			end
		end
	end
end

hookhiteffect = UnitEffect()
hookhiteffect:addAction(function(unit,caster,skill)
	-- the hooked unit --> hooked mode
	-- possible move:
	-- keep the unit at the end of the chain
	-- drag close w/ stab
	-- (disarm)
	local buff = b_Hooked()
	buff.caster = caster
	buff.skill = skill
	unit:addBuff(buff,10)
	caster.chain:attach(unit)
	
end)

Hook = ActiveSkill:subclass('Hook')
function Hook:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Hook'
	self.groupname = 'Chain'
	self.hiteffect = hookhiteffect
	self.effecttime = -1
	self.effect = HookEffect
	self.cd = 5
	self.cdtime = 0
	self.shots = 5
	self.available = true
	self.length = 20
	self.smashdamage = 10
	self:setLevel(level)
end

function Hook:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	self.unit:playAnimation('attack',1)
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function Hook:getPanelData()
	return{
		title = 'Hook',
		type = 'ACTIVE',
		attributes = {
			{text = 'Hook your enemy.'},
		}
	}
end

function Hook:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function Hook:stop()
	self.time = 0
end

function Hook:setLevel(lvl)
	self.level = lvl
end
