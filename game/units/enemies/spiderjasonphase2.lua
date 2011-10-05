
SpiderChargeEffect = ShootMissileEffect:new()
SpiderChargeEffect:addAction(function(point,caster,skill)
	local buff = b_Dash:new(point,caster,skill)
	caster:addBuff(buff,1)
	caster:setAngle(math.atan2(point[2],point[1]))
	function caster:add(b,coll)
		if b:isKindOf(Unit) then
			local vx,vy = coll:getVelocity()
			if (vx*vx+vy*vy)>100000 then
				b:damage('Bullet',80,caster)
				TEsound.play('sound/thunderclap.wav')
				print ('damage dealt')
			end
		end
	end
	Timer:new(1,1,function()caster.add=nil end,true,true)
end)
SpiderCharge = ActiveSkill:subclass('SpiderCharge')
function SpiderCharge:initialize(unit)
	super.initialize(self)
	self.unit = unit
	self.name = 'SpiderCharge'
	self.effect = SpiderChargeEffect
	self.cd = 1
	self.cdtime = 0
	self.available = true
	self.movementspeedbuffpercent = 2
	self.manacost = 30
	self.damage = 100
end

function SpiderCharge:stop()
	self.time = 0
end

function SpiderCharge:active()
	print ('attempt to charge')
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function SpiderCharge:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function AI.SpiderPhase2(unit,target)
	local chargeseq = Sequence:new()
--	chargeseq:push(OrderWait:new(1))
	chargeseq:push(OrderActiveSkill:new(unit.skills.charge,function() return {normalize(GetCharacter().x-unit.x,GetCharacter().y-unit.y)},unit,unit.skills.charge end))
	chargeseq:push(OrderWait:new(5))
	chargeseq.loop = true
	return chargeseq
end

function jasonPhase2(unit)
	for i,v in ipairs(unit.backlegs) do
		v[2]:destroy()
		v[1]:kill(unit)
	end
	--[[
	unit.shape:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
	unit.body = love.physics.newBody(map.world,unit.x,unit.y,100,100)
	unit.shape = love.physics.newCircleShape(unit.body,0,0,100)
	unit.spiderbody.body = unit.body
	unit.spiderbody.shape = unit.shape]]
	local mass = unit.body:getMass()
	unit.body:setMass(0,0,mass,mass)
	unit.shape:setSensor(false)
	unit.shape:setData(unit)
	unit.shape:setRestitution(0.4)
	unit.shape:setMask(cc.enemy)
	unit.backlegs = {}
	unit.ai = AI.SpiderPhase2(unit,GetCharacter())
	unit.lostlegtrig:destroy()
	function unit:update(dt)
	if self.ai then
		local status = self.ai:process(dt,self)
		if status == STATE_FINISH then
			self.ai = nil
		end
	end
		self.allowmovement = true
		self.allowskill = true
		self.allowmelee = true
		self.controllable = true
		self.allowactive = true
		for k,v in pairs(self.buffs) do
		if type(v)=='number' and v>=0 then
			self.buffs[k] = v-dt
			if self.buffs[k]<=0 then
				self.buffs[k]=nil
				if k.stop then k:stop(self) end
			end
		end
			if k.buff then
				k:buff(self,dt)
			end
		end
		
		for k,v in pairs(self.cd) do
			if v>0 then 
				self.cd[k] = v-dt 
			else
				self.cd[k] = nil
			end
		end
		
		if self.skill and self.allowskill then
			self.skill:update(dt*self.spellspeedbuffpercent)
		end
		
		if self.body then
			if self.state == 'auto' then
			elseif self.state == 'stop' then
				self.body:setLinearVelocity(0,0)
				self.body:setAngularVelocity(0)
			elseif self.state == 'slide' then
				local x,y = self.body:getLinearVelocity()
				if x*x+y*y < 100 then
					self.body:setLinearVelocity(0,0)
					self.body:setAngularVelocity(0)
				else
					if x > 0 then x = x - 500*dt else x = x + 500*dt end
					if y > 0 then y = y - 500*dt else y = y + 500*dt end
					self.body:setLinearVelocity(x,y)
				end
			elseif self.state == 'move' and self.allowmovement then
				local x,y = self.body:getLinearVelocity()
--				if x*x+y*y < speedlimit then
					x,y = unpack(self.direction)
					x,y = x*self.movingforce*self.movementspeedbuffpercent,y*self.movingforce*self.movementspeedbuffpercent
					self.body:applyForce(x,y)
			end
			self.x,self.y=self.body:getPosition()
		end
		
		self.hp = math.min(self.hp + self.HPRegen*dt,self.maxhp)
		self.mp = math.min(self.mp + self.MPRegen*dt,self.maxmp)
	end
	unit.spiderbody.update = function()end
	station1.shape:setMask(cc.playermissile,cc.enemymissile)
	station2.shape:setMask(cc.playermissile,cc.enemymissile)
	station3.shape:setMask(cc.playermissile,cc.enemymissile)
	station4.shape:setMask(cc.playermissile,cc.enemymissile)
	local stationcount = 1
	local stationtrig = Trigger:new(function(trig,event)
		if event.unit:isKindOf(SpiderStation) then
			unit:damage('Bullet',1000,trig.unit)
			stationcount = stationcount - 1
			if stationcount == 0 then
				trig:destroy()
				unit.ai = nil
				local lawrence = GetCharacter()
				lawrence:switchChannelSkill(lawrence.skills.solarstorm)
				lawrence.skills.solarstorm.getorderinfo = function()
					return {unit.x,unit.y},unit,lawrence.skills.solarstorm
				end
				--jasonPhaseEnd(unit)
			end
		end
	end)
	stationtrig:registerEventType('death')
end

function jasonPhaseEnd(unit)
	unit.ai = nil
end