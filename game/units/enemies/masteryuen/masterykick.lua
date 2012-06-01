
KickMissile = Missile:subclass('KickMissile')
function KickMissile:draw()
	if self.dt < 0.3 then
		love.graphics.setColor(255,160,40,self.dt/0.3*255)
	elseif self.dt > 0.7 then
		love.graphics.setColor(255,255,255,(1-self.dt)/0.3*255)
	else
		love.graphics.setColor(255,160,40)
	end
--	love.graphics.setColor(255,255,255)
	love.graphics.circle('fill',self.x,self.y,self.body:getAngle(),100)
	love.graphics.draw(myimg.missile.dragonmissile,self.x,self.y,self.body:getAngle(),1,1,200,100)
	love.graphics.setColor(255,255,255)
end
function KickMissile:add(unit,coll)
	if (self.controller=='playerMissile' and unit.controller=='enemy') or (self.controller == 'enemyMissile' and unit.controller=='player') then
		if not unit.bht[self] then
			if self.effect then self.effect:effect(unit,self,self.skill) end
			unit.bht[self] = true
			self.body:setLinearVelocity(0,0)
			self.body:setAngularVelocity(0,0)
			self.dt = 0.3
			self.add = function() end
		end
	end
end

function KickMissile:createBody(world)
	self.body = love.physics.newBody(world,self.x,self.y,'dynamic')
	self.shape = love.physics.newRectangleShape(80,30)
	self.fixture = love.physics.newFixture(self.body,self.shape)
	if self.controller then
		category,masks = unpack(typeinfo[self.controller])
		self.fixture:setCategory(category)
		self.fixture:setDensity(self.mass/5)
		
		self.fixture:setMask(unpack(masks))
	end
	self.body:resetMassData()
	self.body:setLinearVelocity(self.dx*self.vi,self.dy*self.vi)
	self.body:setBullet(true)
	self.body:setAngle(math.atan2(self.dy,self.dx))
	self.fixture:setUserData(self)
end


KickP1MEffect = UnitEffect:new()
KickP1MEffect:addAction(function (unit,caster,skill)
	unit:damage('Bullet',caster.unit:getDamageDealing(skill.damage,'Bullet'),caster.unit)
	unit:addBuff(b_Stun(100),3)
end)

KickP1Effect = ShootMissileEffect:new()
KickP1Effect:addAction(function(point,caster,skill)
	local Missile = KickMissile:new(1,skill.bulletmass,skill.range/1,caster.x,caster.y,unpack(point))
	Missile.controller = caster.controller..'Missile'
	Missile.effect = KickP1MEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
	TEsound.play({'sound/sword1.wav','sound/sword2.wav','sound/sword3.wav'})
end)

KickP1 = Skill:subclass'KickP1'
function KickP1:initialize(unit)
	super.initialize(self)
	self.unit = unit
	self.name = 'Kick'
	self.effecttime = 0.02
	self.casttime = 1
	self.damage = 50
	self.bulletmass = 1
	self.range = 1*400
	self.effect = KickP1Effect
end

function KickP1:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end


requireImage('assets/electrician/lightningball.png','KickP2')
KickP2Unit = Missile:subclass('KickP2Unit')

function KickP2Unit:preremove()
	super.preremove(self)
	self.skill.bulleteffect:effect({self.x,self.y},self.unit,self.skill)
	local ip = LightningImpact:new(self,30,0.25,0.05,1,{255,255,255},1)
	map:addUpdatable(ip)
end

function KickP2Unit:update(dt)
	super.update(self,dt)
	if self.dt>1 then
		self.body:setLinearVelocity(0,0)
	end
end

function KickP2Unit:draw()
	love.graphics.draw(img.KickP2,self.x,self.y,math.random(),1,1,32,32)
end

CrackEffect = ShootMissileEffect:new()
CrackEffect:addAction(function(point,caster,skill)
	local sx,sy = point[1]-caster.x,point[2]-caster.y
	local v = math.sqrt(sx*sx+sy*sy)
	sx,sy=normalize(sx,sy)
	local Missile = KickP2Unit:new(1,1,v,caster.x,caster.y,sx,sy)
	local ip = LightningImpact:new(Missile,30,0.1,0.05,4,{255,255,255},0.3)
	map:addUpdatable(ip)
	Missile.controller = caster.controller..'Missile'
	Missile.effect = CrackDamageEffect
	Missile.skill = skill
	Missile.unit = caster
	map:addUnit(Missile)
end)

CrackDamageEffect = CircleAoEEffect(200)
CrackDamageEffect:addAction(function (area,caster,skill)
	local units = map:findUnitsInArea(area)
	for k,v in pairs(units) do
		if v:isKindOf(Unit) then
			local impact = skill.impact
			local x,y=normalize(v.x-area.x,v.y-area.y)
			x,y=x*impact,y*impact
			if v.body and not v.immuneimpact then
				v.body:applyLinearImpulse(x,y)
			end
			v:damage('Electric',skill.damage,caster)
		end
	end
	TEsound.play('sound/thunderclap.wav')
end)

KickP2 = ActiveSkill:subclass('KickP2')
function KickP2:initialize(unit)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.bullettype = BoltMissile
	self.name = 'KickP2'
	self.effecttime = 0.1
	self.damage = 200
	self.effect = CrackEffect
	self.bulleteffect = CrackDamageEffect
	self.manacost = 20
	self.cd=1
	self.cdtime = 0
	self.impact = 300
end

function KickP2:active()
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

function KickP2:geteffectinfo()
	return GetOrderPoint(),self.unit,self
end


SevenSidedStrikeActor = Object:subclass'SevenSidedStrikeActor'
function SevenSidedStrikeActor:initialize(b,cha,r)
	self.unit = b
	self.cha = cha
	self.r = r or math.random()*math.pi*2
	self.sx,self.sy = -math.cos(self.r)*300+b.x,-math.sin(self.r)*300+b.y
	self.x,self.y = 0,0
	self.dt = 0
	map.anim:easy(self,'x',self.sx,self.unit.x,0.25,'quadInOut')
	map.anim:easy(self,'y',self.sy,self.unit.y,0.25,'quadInOut')
	map:addUpdatable(UnitTrail(self,'goldensparkle',0.4,0.1))
end

function SevenSidedStrikeActor:update(dt)
	self.dt = self.dt + dt
	if self.dt> 0.5 then
		map:removeUpdatable(self)
	end
end

function SevenSidedStrikeActor:draw()
	love.graphics.setColor(255,255,255,255*self.dt*4)
	love.graphics.draw(self.cha,self.x,self.y,self.r,1,1,self.cha:getWidth()/2,self.cha:getHeight()/2)
	love.graphics.setColor(255,255,255,255)
end

SevenSidedStrikeEffect = ShootMissileEffect:new()
SevenSidedStrikeEffect:addAction(function(point,caster,skill)
	local buff = b_Dash(point,caster,skill)
	caster:addBuff(buff,1)
	Timer:new(1,1,function()caster.add=nil end,true,true)
	function caster:add(b,coll)
		if b:isKindOf(Unit) and b.controller ~= self.controller then
			caster:removeBuff(buff)
			--caster.ai = nil
			caster:stop()
			caster.state = 'slide'
			caster.body:setLinearVelocity(0,0)
			caster.add = nil
			local count = 1
			Timer:new(0.2,7,function(timer)
				if b.invisible or (not b.body) then
					timer.count = 1
				end
				local angle = math.random()*math.pi*2
				local x,y = math.cos(angle)*30,math.sin(angle)*30
				caster.body:setPosition(b.x-x,b.y-y)
				caster.x,caster.y = b.x-x,b.y-y
--				caster.skills.kickp1.effect:effect({normalize(x,y)},caster,caster.skills.kickp1)
				caster:skilleffect(caster.skills.melee)
				self:setAngle(angle)
				if timer.count <= 1 then
		--			caster.skills.melee.casttime = oricasttime
				end
				map:addUpdatable(SevenSidedStrikeActor(b,myimg.shades[tostring(timer.count%5+1)],angle))
			end)
		end
	end
end)

SevenSidedStrike = ActiveSkill:subclass('SevenSidedStrike')
function SevenSidedStrike:initialize(unit)
	super.initialize(self)
	self.unit = unit
	self.name = 'SevenSidedStrike'
	self.effect = SevenSidedStrikeEffect
	self.cd = 8
	self.cdtime = 0
	self.available = true
	self.movementspeedbuffpercent = 12
	self.manacost = 30
end

function SevenSidedStrike:stop()
	self.time = 0
end

function SevenSidedStrike:active()
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

function SevenSidedStrike:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end
