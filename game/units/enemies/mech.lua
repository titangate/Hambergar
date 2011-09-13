animation.bluemech = Animation:new(love.graphics.newImage('assets/mech/bluemech.png'),77,76,0.08,1,1,38,38)
BlueMechShotgun = ThreewayShotgun:subclass('BlueMechShotgun')
function IALThreewayShotgun:initialize(unit)
	super.initialize(self,unit)
	self.damage = 50
end

BlueMech = AnimatedUnit:subclass('BlueMech')
function BlueMech:initialize(x,y,controller)
	super.initialize(self,x,y,38,30)
	self.controller = controller
	self.hp = 1000
	self.maxhp = 1000
	self.mp = 500
	self.maxmp = 500
	self.skills = {
		gun = ThreewayShotgun:new(self),
		missile = SeekerMissileLaunch(self),
		charge = Charge(self)
	}
	self.animation = {
		stand = animation.bluemech:subSequenceIndex(1),
		move = animation.bluemech:subSequence(1,12),
		attack = animation.bluemech:subSequenceIndex(1),
	}
	self:resetAnimation()
	self.speedlimit = self.speedlimit * 0.8
end

function BlueMech:enableAI(ai)
	local seq = Sequence:new()
	seq:push(OrderWait:new(1))
	seq:push(OrderMoveTowardsRange:new(GetCharacter(),500))
	seq:push(OrderActiveSkill:new(self.skills.charge,function() return {normalize(GetCharacter().x-self.x,GetCharacter().y-self.y)},self,self.skills.charge end))
	seq:push(OrderStop:new())
	seq:push(OrderWait:new(1))
	seq.loop = true
	self.ai = ai or seq
end

function BlueMech:skilleffect(skill)
	if skill then
		self:playAnimation('attack',0.4,false)
	end
end

seekermissilesuicideeffect = CircleAoEEffect:new(200)
seekermissilesuicideeffect:addAction(function (area,caster,skill)
	print ('wtf is going on')
	for k,v in pairs(area) do
		print (k,v)
	end
	local units = map:findUnitsInArea(area)
	for k,v in pairs(units) do
		if v:isKindOf(Unit) then
			local impact = skill.impact
			local x,y=normalize(v.x-area.x,v.y-area.y)
			x,y=x*impact,y*impact
			if v.body and not v.immuneimpact then
				v.body:applyImpulse(x,y)
			end
			v:damage('Bullet',skill.damage,caster)
		end
	end
	TEsound.play('sound/thunderclap.wav')
	caster:kill(caster)
end)

SeekerMissileSuicide = ActiveSkill:subclass('SeekerMissileSuicide')
function SeekerMissileSuicide:initialize(unit)
	super.initialize(self,unit)
	self.unit = unit
	self.effect = seekermissilesuicideeffect
	self.damage = 80
	self.impact = 50
end


function SeekerMissileSuicide:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function SeekerMissileSuicide:geteffectinfo()
	return {self.unit.x,self.unit.y},self.unit,self
end


animation.seekermissile = Animation:new(love.graphics.newImage('assets/insectoid/seeker.png'),47,48,0.08,1,1,24,24)
SeekerMissile = AnimatedUnit:subclass('SeekerMissile')
function SeekerMissile:initialize(x,y,controller)
	super.initialize(self,x,y,8,5)
	self.hp=200
	self.maxhp=200
	self.controller = controller
	self.skills = {
		explode = SeekerMissileSuicide:new(self),
	}
	self.animation = {
		stand = animation.seekermissile:subSequence(1,6)
	}
	self:resetAnimation()
end

function SeekerMissile:setTarget(t)
	self.target=t
	if not self.beam then
		self.beam = RayBeam:new(self,t,100,{255,0,0})
	end
	self.beam.p2=t
	map:addUpdatable(self.beam)
end

function SeekerMissile:kill(...)
	super.kill(self,...)
	self.beam.life=0
end

function SeekerMissile:enableAI(ai)
	local target = self.target
	danceseq=Sequence:new()
	danceseq:push(OrderMoveTowardsRange:new(target,50))
	danceseq:push(OrderActiveSkill:new(self.skills.explode,function() return {self.x,self.y},self,self.skills.explode end))
	danceseq:push(OrderWait:new(3))
	self.ai = ai or danceseq
end



seekermissilelauncheffect = ShootMissileEffect:new()
seekermissilelauncheffect:addAction(function (unit,caster,skill)
	local x,y = displacement(caster.x,caster.y,caster.body:getAngle(),30)
	print (x,y,'created')
	print (caster.controller)
	local missile = SeekerMissile:new(x,y,caster.controller)
	missile:setTarget(unit)
	map:addUnit(missile)
	missile:enableAI()
end)

SeekerMissileLaunch = ActiveSkill:subclass('SeekerMissileLaunch')
function SeekerMissileLaunch:initialize(unit)
	super.initialize(self)
	self.unit = unit
	for k,v in pairs(self) do
		print (k,v)
	end
	self.effect = seekermissilelauncheffect
end

function SeekerMissileLaunch:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function SeekerMissileLaunch:geteffectinfo()
	return GetOrderUnit(),self,self
end

ChargeEffect = ShootMissileEffect:new()
ChargeEffect:addAction(function(point,caster,skill)
	local buff = b_Dash:new(point,caster,skill)
	caster:addBuff(buff,1)
	caster:setAngle(math.atan2(point[2],point[1]))
	Timer:new(1,1,function()caster.add=nil end,true,true)
	function caster:add(b,coll)
		if b:isKindOf(Unit) and b.controller ~= self.controller then
			caster:removeBuff(buff)
			--caster.ai = nil
			caster:stop()
			caster.state = 'slide'
--			caster.body:setLinearVelocity(0,0)
			caster.add = nil
			b:damage('Bullet',skill.damage,caster)
		end
	end
end)

Charge = ActiveSkill:subclass('NineSwordDance')
function Charge:initialize(unit)
	super.initialize(self)
	self.unit = unit
	self.name = 'Charge'
	self.effect = ChargeEffect
	self.cd = 8
	self.cdtime = 0
	self.available = true
	self.movementspeedbuffpercent = 8
	self.manacost = 30
	self.damage = 100
end

function Charge:stop()
	self.time = 0
end

function Charge:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	
	if self.unit:getMP()<self.manacost then
		return false,'Not enough MP'
	end
	self.unit.mp = self.unit.mp - self.manacost
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function Charge:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

