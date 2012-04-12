TankMachineGun = MachineGun:subclass('IALMachineGun')
function TankMachineGun:initialize(unit)
	super.initialize(self,unit)
	self.damage = 30
	self.casttime = 0.25
end

requireImage('assets/assassin/bullet.png','bullet')
RocketMissileMissile = Missile:subclass('RocketMissileMissile')
function RocketMissileMissile:draw()
	love.graphics.setColor(255,169,142,255)
	love.graphics.draw(img.bullet,self.x,self.y,self.body:getAngle(),2,2,16,16)
	love.graphics.setColor(255,255,255,255)
end

function RocketMissileMissile:createBody(...)
	super.createBody(self,...)
	self.shape:setCategory(cc.enemy)
	
end

function RocketMissileMissile:add(unit,coll)
	if (self.controller=='playerMissile' and unit.controller=='enemy') or 
		(self.controller == 'enemyMissile' and unit.controller=='player') then
		if not unit.bht[self] then
			if self.effect then self.effect:effect(unit,self,self.skill) end
			unit.bht[self] = true
			self.draw = function() end
			self.persist = function() end
		end
	end
	if (not unit:isKindOf(Probe)) and ((self.controller=='playerMissile' and unit.controller=='enemyMissile') or
		(self.controller == 'enemyMissile' and unit.controller=='playerMissile')) then
			self:kill()
			unit:kill()
	end
end

RocketMissileEffect = ShootMissileEffect:new()
RocketMissileEffect:addAction(function(point,caster,skill)
	Timer(0.5,3,function ()
		local Missile = RocketMissileMissile:new(5,0.2,200,caster.x,caster.y,point[1],point[2],25)
		Missile.controller = caster.controller..'Missile'
		Missile.effect = BulletEffect
		Missile.skill = skill
		Missile.unit = caster
		map:addUnit(Missile)
	end
	)
end)

RocketMissile = ActiveSkill:subclass('RocketMissile')
function RocketMissile:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'RocketMissile'
	self.effecttime = -1
	self.effect = RocketMissileEffect
	self.cd = 2
	self.cdtime = 0
	self.damage = 300
	self.available = true
	self.manacost = 50
end

function RocketMissile:active()
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

function RocketMissile:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end


Tank = Unit:subclass('Tank')
function Tank:initialize(x,y,controller)
	super.initialize(self,x,y,48,10)
	self.controller = controller
	self.hp = 500
	self.maxhp = 500
	self.mp = 500
	self.maxmp = 500
	self.skills = {
		gun = TankMachineGun(self),
		missile = RocketMissile(self),
	}
	self.dt = 0
end



function Tank:enableAI(ai)
	if ai then self.ai = ai
	else
		ai = Parallel()
		local target = self:getOffenceTarget()
		--ai:push(AI.ApproachAndAttack(self,target,self.skills.gun,300,400))
		local firemissile = Sequence()
		firemissile.loop = true
		firemissile:push(OrderWait(4))
		firemissile:push(OrderActiveSkill:new(self.skills.missile,
			function() 
				return {normalize(target.x-self.x,target.y-self.y)},
				self,self.skills.missile 
			end))
		ai:push(firemissile)
		self.ai = ai
	end
end

function Tank:update(dt)
	super.update(self,dt)
end


