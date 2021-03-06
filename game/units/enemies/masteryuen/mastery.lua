
MasterYuenAura = Object:subclass'MasterYuenAura'
function MasterYuenAura:initialize(unit)
	self.unit = unit
	self.bullet = {}
end
function MasterYuenAura:add(b,coll)
--	if type(b)=='function' then print (b) end
	if self.unit.immuebullet and b:isKindOf(Missile) then
		if self.unit:isEnemyOf(b) then
			map:changeOwner(b,'enemyMissile')
			local vx,vy = b.body:getLinearVelocity()
			
			if self.unit.immuebullet == 'reflect' then
				b.body:setLinearVelocity(0,0)
				local category,masks = unpack(typeinfo.enemyMissile)
				b.fixture:setCategory(category)
				b.fixture:setMask(unpack(masks))
				self:captureBullet(b)
			else
				b.body:setLinearVelocity(vx*0.03,vy*0.03)
			end
		end
	end
end

function MasterYuenAura:captureBullet(bullet)
	bullet.time = 1000
	table.insert(self.bullet,{
		bullet = bullet,
		angle = anglebetween(self.unit,bullet)
	})
end

function MasterYuenAura:update(dt)
	for i,v in ipairs(self.bullet) do
		v.angle = v.angle + dt * 3
		local x,y = self.unit.x + math.cos(v.angle) * 160,self.unit.y + math.sin(v.angle) * 160
		v.bullet.body:setPosition(x,y)
		v.bullet.body:setAngle(v.angle)
	end
end

function MasterYuenAura:releaseBullet()
	for i,v in ipairs(self.bullet) do
		local angle = anglebetween(v.bullet,GetCharacter())
		v.bullet.body:setAngle(angle)
		v.bullet.body:setLinearVelocity(math.cos(angle)*500,math.sin(angle)*500)
	end
	self.bullet = {}
end

MasterYuen = Unit:subclass'MasterYuen'

function MasterYuen:initialize(x,y)
	super.initialize(self,x,y,16,10)
	self.actor = MasterYuenActor()
	self.x,self.y = x,y
	self.hp,self.maxhp = 40000,40000
	self.HPRegen = 0
--	self.actor:playAnimation('crane',1,true)
--	self.actor:setEffect'glow'
	self.aura = MasterYuenAura(self)
	self.mantra = MantraActor()
	
	self.skills = {
		-- phase 1
		fistp1 = FistP1(self),
		kickp1 = KickP1(self),
		cranep1 = CraneP1(self),
		fistp2 = FistP2(self),
		kickp2 = KickP2(self),
		cranep2 = CraneP2(self),
		
		fistp3 = FistP3(self),
		kickp3 = SevenSidedStrike(self),
		
	}
		self.time = 0
	self:setImmunity(true)
	
	self.displaymaxhp = self.maxhp
	self.preventdeath = true
end

function MasterYuen:update(dt)
	super.update(self,dt)
	self.actor:update(dt)
	self.time = self.time + dt
	self.mantra:update(dt)
	self.aura:update(dt)
end

function MasterYuen:createBody(world)
	super.createBody(self,world)
	local aurashape = love.physics.newCircleShape(160)
	self.aurafixture = love.physics.newFixture(self.body,aurashape)
	self.aurafixture:setSensor(true)
	self.aurafixture:setDensity(0)
	self.aurafixture:setUserData(self.aura)
	self.aurafixture:setCategory(cc.enemy)
	self.aurafixture:setMask(unpack(typeinfo.enemy[2]))
	self.body:resetMassData()
	
end

function MasterYuen:setImmunity(state)
	self.immuebullet = state
	self.mantra:setState(state)
	if not state then
		self.aura:releaseBullet()
	end
end

function MasterYuen:draw()
	if self.immuebullet then
		self.actor:draw(self.x,self.y,self.body:getAngle(),self.time)
	else
		self.actor:draw(self.x,self.y,self.body:getAngle())
	end
	self:drawBuff()
	self.mantra:draw(self.x,self.y)
end

function MasterYuen:dashStrike(action,distance,pause)
	--self.actor:setEffect'glow'
	self.actor:playAnimation(action,1,false)
	map:addUpdatable(UnitTrail(self,'goldensparkle',2,0.5))
	Timer(pause,1,function()
		if action == 'fist' then 
			TEsound.play'sound/shout3.mp3'
			self.skills.fistp1.effect:effect({math.cos(self.body:getAngle()),math.sin(self.body:getAngle())},self,self.skills.fistp1) 
			elseif action == 'kick' then 
				TEsound.play'sound/shout2.mp3'
				self.skills.kickp1.effect:effect({math.cos(self.body:getAngle()),math.sin(self.body:getAngle())},self,self.skills.kickp1)
			elseif action == 'crane' then 
					TEsound.play'sound/shout1.mp3'
				self.skills.cranep1.effect:effect({math.cos(self.body:getAngle()),math.sin(self.body:getAngle())},self,self.skills.cranep1)
		end
		self.actor:setEffect()
		local r = self.body:getAngle()
		local cosr,sinr = math.cos(r),math.sin(r)
		assert(self.body)
		self.body:applyLinearImpulse(cosr*distance,sinr*distance)
	end)
end


function MasterYuen:dashStrikep2(action,distance,pause)
	--self.actor:setEffect'glow'
	self.actor:playAnimation(action,1,false)
	map:addUpdatable(UnitTrail(self,'goldensparkle',2,0.5))
	if action == 'fist' then 
		--self.ai:pause(true)
		Timer(pause,3,function(timer)
			self:face(GetCharacter())
			TEsound.play'sound/shout3.mp3'
			self.skills.fistp2.effect:effect({math.cos(self.body:getAngle()),math.sin(self.body:getAngle())},self,self.skills.fistp1)
			
			self.actor:setEffect()
			local r = self.body:getAngle()
			local cosr,sinr = math.cos(r),math.sin(r)
			assert(self.body)
			self.body:applyLinearImpulse(cosr*distance,sinr*distance)
			if timer.count == 3 then
			--	self.ai:pause(false)
			end
		end)
	elseif action == 'kick' then
			TEsound.play'sound/shout2.mp3'
		Timer(pause,1,function()
			self:face(GetCharacter())
			self.skills.kickp2.effect:effect({GetCharacter():getPosition()},self,self.skills.kickp2)
			self.actor:setEffect()
		end)
	elseif action == 'crane' then 	
			TEsound.play'sound/eagle.wav'
		Timer(pause,1,function()
			self:face(GetCharacter())
			self.skills.cranep2.effect:effect(GetCharacter(),self,self.skills.cranep2)
			self.actor:setEffect()
		end)
	end
end


function MasterYuen:dashStrikep3(action,distance,pause)
	self.actor:playAnimation(action,1,false)
	map:addUpdatable(UnitTrail(self,'goldensparkle',2,0.5))
	Timer(pause,1,function()
		if action == 'fist' then 
				TEsound.play'sound/shout3.mp3'
				self.skills.fistp3.effect:effect({GetCharacter():getPosition()},self,self.skills.fistp3) 
			elseif action == 'kick' then 
				TEsound.play'sound/shout2.mp3'
				self.skills.kickp3.effect:effect({math.cos(self.body:getAngle()),math.sin(self.body:getAngle())},self,self.skills.kickp3)
			elseif action == 'crane' then 
				TEsound.play'sound/shout1.mp3'
				map:addUpdatable(CraneCircleP3(GetCharacter(),my))
				--self.skills.cranep3.effect:effect({math.cos(self.body:getAngle()),math.sin(self.body:getAngle())},self,self.skills.cranep3)
		end
		self.actor:setEffect()
		local r = self.body:getAngle()
		local cosr,sinr = math.cos(r),math.sin(r)
		assert(self.body)
		self.body:applyLinearImpulse(cosr*distance,sinr*distance)
	end)
end


function MasterYuen:pray()
	Trigger(function()
		self.actor:playAnimation('pray')
		wait(0.5)
--		self.actor:setEffect'invis'
		TEsound.play{'sound/masteryuenchant/iwillreturn.mp3','sound/masteryuenchant/cycle.mp3'}
		wait(0.5)
		self.body:setPosition(0,0)
		self:addBuff(b_pray(1000),3)
		self.actor:setEffect()
	end):run()
end

function MasterYuen:prayp2()
	for i=1,3 do
		local r = math.pi*2/3*i
		local img  = MasterYuenImage(math.cos(r)*100,math.sin(r)*100)
		img.controller = 'enemy'
		map:addUnit(img)
		img:enableAI()
	end
	self:pray()
end


function MasterYuen:entermantra()
	Trigger(function()
		self.actor:playAnimation('pray')
		wait(0.5)
		self.actor:setEffect'invis'
		wait(0.5)
		self.body:setPosition(0,0)
		self.actor:setEffect()
		map:enterMantra()
		wait(3)
	end):run()
end


function MasterYuen:add(b,coll)
	if self:isEnemyOf(b) then
	end
end

function MasterYuen:enableAI()
	local approach = ProAI_Walkto(self,GetCharacter(),200)
	local fist1 = ProAI_Exec(self,function()
	local c = math.random(3)
		self:setImmunity(false)
		if c==1 then
			self:dashStrike('crane',2000,0.5)
		elseif c==2 then
			self:dashStrike('kick',2000,0.5)
		else
			self:dashStrike('fist',2500,0.5)
		end
	end)
	local reset = ProAI_Exec(self,function() self.actor:reset() end)
	local wait = ProAI_Wait(self,4)
	local restoreimmue = ProAI_Exec(self,function() 
		self:setImmunity(true)
	end)
	local praywait = ProAI_Wait(self,1.5)
	
	local pray = ProAI_Exec(self,function()
		self:pray()
	end)
	local prayswitch = ProAI_Exec(self,function(ai)
--		print (self:getHPPercent())
		if self:getHPPercent() < 0.6 then
			ai.next = self:phase2()
			return
		elseif self:getHPPercent() < 0.8 and math.random()< 0.5 then
			ai.next = praywait
		else
			ai.next = wait
		end
	end)
	approach.next = fist1
	fist1.next = prayswitch
	praywait.next = pray
	pray.next = wait
	wait.next = reset
	reset.next = restoreimmue
	restoreimmue.next = approach
	self.ai = approach
end

function MasterYuen:phase2()
	local approach = ProAI_Walkto(self,GetCharacter(),200)
	local fist1 = ProAI_Exec(self,function()
	local c = math.random(3)
		self:setImmunity(false)
		if c==1 then
			self:dashStrikep2('crane',2000,0.2)
		elseif c==2 then
			self:dashStrikep2('kick',2000,0.2)
		else
			self:dashStrikep2('fist',2500,1)
		end
	end)
	local reset = ProAI_Exec(self,function() self.actor:reset() end)
	local wait = ProAI_Wait(self,4)
	local restoreimmue = ProAI_Exec(self,function() 
		self.mantra.level = 2
		self:setImmunity'reflect'
	end)
	local praywait = ProAI_Wait(self,1.5)
	
	local pray = ProAI_Exec(self,function()
		self:prayp2()
	end)
	local prayswitch = ProAI_Exec(self,function(ai)
		if self:getHPPercent() < 0.2 then
			ai.next = self:phase3()
		elseif math.random()< 0.5 then
			ai.next = praywait
		else
			ai.next = wait
		end
	end)
	approach.next = fist1
	fist1.next = prayswitch
	praywait.next = pray
	pray.next = wait
	wait.next = reset
	reset.next = restoreimmue
	restoreimmue.next = approach
	return approach
	--self.ai = approach
end

function MasterYuen:getHPPercent()
	return self.hp/self.displaymaxhp
end

function MasterYuen:phase3()
	self:entermantra()
	self.hp = self.maxhp
	self:setImmunity()
	self.accumulatedmg = 0
--	self.movementspeedbuffpercent = self.movementspeedbuffpercent + 1
	local approach = ProAI_Walkto(self,GetCharacter(),200)
	local fist1 = ProAI_Exec(self,function()
	local c = math.random(3)
--		self:setImmunity(false)
		if c==1 then
			self:dashStrikep3('crane',2000,0.5)
		elseif c==2 then
			self:dashStrikep3('kick',2000,0.5)
		else
			self:dashStrikep3('fist',2500,0.5)
		end
	end)
	local reset = ProAI_Exec(self,function() self.actor:reset() end)
	local wait = ProAI_Wait(self,4)
	local restoreimmue = ProAI_Exec(self,function() 
--		self:setImmunity(true)
	end)
	
	approach.next = fist1
	fist1.next = wait
	wait.next = reset
	reset.next = restoreimmue
	restoreimmue.next = approach
	local failing = ProAI_Exec(self,function()
		self.fail = true
		self.actor:playAnimation'kneel'
		map:exitMantra()
		
		TEsound.play'sound/groan.mp3'
		self:stop()
	end)
	local failingwait = ProAI_Wait(self,10)
	local restore 
	restore = ProAI_Exec(self,function()
		self:entermantra()
		self.accumulatedmg = 0
		self.fail = false
		if self:getHPPercent()<=0.15 then
			restore.next = self:phase4()
		end
	end)
	failing.next = failingwait
	failingwait.next = restore
	restore.next = wait
	self.failing = failing
	self.maxallowdmg = self.maxhp / 5
	self.damage = function(self,...)
		local dmg = Unit.damage(self,...)
		if self.fail then
			self.maxhp = self.maxhp - dmg
		else
			self.accumulatedmg = self.accumulatedmg + dmg
			if self.accumulatedmg > self.maxallowdmg then
				self.ai = failing
			end
		end
	end
	return wait
end

function MasterYuen:phase4()
	self.actor:setEffect'invis'
	self.actor:playAnimation'pray'
	local b = GetCharacter()
	Trigger(function()
	
		wait(0.5)
		map.camera = FollowerCamera(GetCharacter())
		GetCharacter():addBuff(b_Stun(),-1)
		Timer(0.35,10,function()
			local cx,cy = GetCharacter():getPosition()
			local x,y = displacement(0,0,math.random()*math.pi*2,1200)
			local a = FireChainActor(cx-x,cy-y,x,y,2)
			map:addUpdatable(a)
			Timer(5,1,function()map:removeUpdatable(a)end)
		end)
		wait(1)
		Timer:new(0.15,20,function(timer)
			if b.invisible or (not b.body) then
				timer.count = 1
			end
			local angle = math.random()*math.pi*2
			local x,y = math.cos(angle)*30,math.sin(angle)*30
--			caster.body:setPosition(b.x-x,b.y-y)
--			caster.x,caster.y = b.x-x,b.y-y
--				caster.skills.kickp1.effect:effect({normalize(x,y)},caster,caster.skills.kickp1)
--			caster:skilleffect(caster.skills.melee)
			self:setAngle(angle)
			if timer.count <= 1 then
	--			caster.skills.melee.casttime = oricasttime
			end
			map:addUpdatable(SevenSidedStrikeActor(b,myimg.shades[tostring(timer.count%5+1)],angle))
		end)
	end):run()
	map:finish()
	return ProAI_Wait(self,3600)
end

function MasterYuen:rise()
	local failing = ProAI_Exec(self,function()
		self.fail = true
		self.actor:playAnimation'kneel'
		map:exitMantra()
		self:stop()
	end)
	self:setImmunity(false)
	local approach = ProAI_Walkto(self,GetCharacter(),200)
	local fist1 = ProAI_Exec(self,function()
	local c = math.random(3)
		
		if c==1 then
			self:dashStrikep2('crane',2000,0.2)
		elseif c==2 then
			self:dashStrikep2('kick',2000,0.2)
		else
			self:dashStrikep2('fist',2500,1)
		end
	end)
	local reset = ProAI_Exec(self,function() self.actor:reset() end)
	local wait = ProAI_Wait(self,4)
	local restoreimmue = ProAI_Exec(self,function() 
--		self.mantra.level = 2
--		self:setImmunity'reflect'
	end)
	local praywait = ProAI_Wait(self,1.5)
	
	local pray = ProAI_Exec(self,function()
--		self:prayp2()
	end)
	local prayswitch = ProAI_Exec(self,function(ai)
		if self:getHPPercent() < 0.2 then
			ai.next = failing
		elseif math.random()< 0.5 then
			ai.next = praywait
		else
			ai.next = wait
		end
	end)
	
	approach.next = fist1
	fist1.next = prayswitch
	praywait.next = pray
	pray.next = wait
	wait.next = reset
	reset.next = restoreimmue
	restoreimmue.next = approach
	return approach
end