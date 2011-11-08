
animation.skeletonsword = Animation(love.graphics.newImage('assets/dungeon/skeletonsword.png'),99,86,0.04,1,1,12,46)

SkeletonSwordsman = AnimatedUnit:subclass('SkeletonSwordsman')
function SkeletonSwordsman:initialize(x,y,controller)
	super.initialize(self,x,y,16,10)
	self.controller = controller
	self.hp = 500
	self.maxhp = 500
	self.mp = 500
	self.maxmp = 500
	self.skills = {
		melee = IALSwordsmanMelee:new(self),
		tornado = SkeletonTornado(self),
	}
	self.animation = {
		stand = animation.skeletonsword:subSequence(1,1),
		attack = animation.skeletonsword:subSequence(2,7),
		spin = animation.skeletonsword:subSequence(6,6)
	}
	self:resetAnimation()
	self.speedlimit = self.speedlimit * 2
end

function SkeletonSwordsman:skilleffect(skill)
	if skill then
		self:playAnimation('attack',0.4,false)
	end
end

function SkeletonSwordsman:enableAI(ai)
	local t = self:getOffenceTarget()
	local t2 = self
	local normalattack = Sequence:new()
--	normalattack:push(OrderWait(3))
	normalattack:push(OrderMoveTowardsRange:new(t,80))
	
	normalattack:push(OrderStop())
	normalattack:push(OrderChannelSkill:new(self.skills.melee,function()t2:setAngle(math.atan2(t.y-t2.y,t.x-t2.x))return {normalize(t.x-t2.x,t.y-t2.y)},t2,self.skills.melee end))
	normalattack:push(OrderWait(0.5))
	normalattack:push(OrderStop())
	
	
	local tornadoseq = Sequence:new()
	tornadoseq:push(OrderWait(3))
	tornadoseq:push(OrderMoveTowardsRange:new(t,400))
--	tornadoseq:push(OrderStop())
	tornadoseq:push(OrderActiveSkill:new(self.skills.tornado,function() return self,self,t2.skills.tornado end))
--	normalattack:push(OrderWaitUntil:new(function()return getdistance(t,t2)>firerange or t.invisible end))
	tornadoseq:push(OrderMoveTowardsRange:new(t,50))
	tornadoseq:push(OrderStop())
	
	local demoselector = Selector:new()
	demoselector:push(function ()
		if math.random()>0.5 then
			return tornadoseq
		else
			return tornadoseq
		end
	end)
	local AIDemo = Sequence:new()
	AIDemo:push(demoselector)
	AIDemo.loop = true
	self.ai = AIDemo
end

local tornado = SkeletonSwordsman:addState'tornado'
function tornado:enterState()
	self.cr = 0
	self:playAnimation('tornado',1,true)
end

function tornado:exitState()
	self:resetAnimation()
end

function tornado:update(dt)
	SkeletonSwordsman.update(self,dt)
	self.cr = self.cr + dt * 20
	self.body:setAngle(self.cr)
end

b_SkeletonTornado = Buff:subclass('b_SkeletonTornado')

function b_SkeletonTornado:stop(unit)
--	unit:morphEnd()
	unit:gotoState()
	unit:stop()
end
function b_SkeletonTornado:buff(unit,dt)
	local units = map:findUnitsInArea({
		type = 'circle',
		range = 80,
		x=unit.x,
		y=unit.y
	})
	for k,v in pairs(units) do
		if v:isKindOf(Unit) then
			v:addBuff(b_Stun:new(100,nil),dt)
			v:damage('Bullet',unit:getDamageDealing(50*dt,'Bullet'),unit)
		end
	end
end
function b_SkeletonTornado:start(unit)
	unit:gotoState'tornado'
end

SkeletonTornadoEffect = UnitEffect:new()
SkeletonTornadoEffect:addAction(function (unit,caster,skill)
	unit:addBuff(b_SkeletonTornado(),3)
end)

SkeletonTornado = ActiveSkill:subclass('SkeletonTornado')
function SkeletonTornado:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Skeleton Tornado'
	self.effecttime = -1
	self.effect = SkeletonTornadoEffect
	self.cd = 2
	self.cdtime = 0
	self.SkeletonTornadotime = 45
	self.available = true
	self:setLevel(level)
end

function SkeletonTornado:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	if self.unit:getMPPercent()<1 then
		return false,'Not enough MP'
	end
	
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function SkeletonTornado:geteffectinfo()
	return self.unit,self.unit,self
end

function SkeletonTornado:setLevel(lvl)
	self.level = lvl
end

