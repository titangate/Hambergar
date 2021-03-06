Unit = class('Unit',StatefulObject)
bufftable = {}
bufftable.__mode = 'k'
function Unit:switchChannelSkill(skill)
	if self.skill ~= skill then
		if self.skill then 
			self.skill:endChannel() 
		end
		if skill then
			skill:startChannel() 
		end
	end
	self.skill = skill
	self:notifyListeners({type='channel',skill = skill})
end

function Unit:missileSpawnPoint()
	return self.x,self.y
end

function Unit:startCD(group,cd)
	self.cd[group]=cd
end

function Unit:resetCD()
	self.cd = {}
end

function Unit:getCD(group)
	return self.cd[group]
end

function Unit:initialize(x,y,rad,mass)
	super.initialize(self)
	x,y = x or 0,y or 0
	self.x,self.y=x,y
	self.rad = rad
	self.mass = mass
	self.state = 'slide'
	self.order = 'stop'
	self.direction = {1,0}
	self.movingforce = self.mass*200
	self.speedlimit = 20000
	self.buffs={}
	self.maxhp=100
	self.hp=100
	self.HPRegen = 0
	self.maxmp=100
	self.mp=100
	self.MPRegen = 0
	self.armor = {}
	self.damagereduction = {}
	self.damagebuff = {}
	self.damageamplify = {}
	self.critical = {2,0}
	self.evade = 0
	self.allowmovement = true
	self.allowskill = true
	self.allowmelee = true
	self.allowactive = true
	self.movementspeedbuff = 0
	self.movementspeedbuffpercent = 1
	self.spellspeedbuffpercent = 1
	self.timescale = 1
	self.controllable = true
	self.bht = {}
	self.cd = {}
--	self.invisible = false
--	self.invulnerable = false
	self.immue = {}
	self.drops = {}
--	self.preventdeath = {}
	setmetatable(self.bht,bufftable)
end

function Unit:drop()
	local i = table.remove(self.drops)
	while i do
		i.x,i.y = self.x,self.y
		map:addUnit(i)
		i = table.remove(self.drops)
	end
end

function Unit:getDamageDealing(amount,type)
	if self.damagebuff[type] then
		amount = amount + self.damagebuff[type]
	end
	if self.damageamplify[type] then
		amount = amount * self.damageamplify[type]
	end
	if self.critical then
		local amplifier,chance = unpack(self.critical)
		local r = math.random()
		if r<chance then
--			amount = amount * amplifier
			
--			print ('critical hit')
			return {amount,amount*amplifier}
		end
	end
	return amount
end

function Unit:damage(t,amount,source)
	if self.invulerable then return end
	if self.evade and source~=self then
		if math.random()<self.evade then
			self:notifyListeners({type='evade',unit = self,source = source})
			return
		end
	end
	local crit
	if type(amount)=='table'  then
		if source==self then
			amount = amount[1]
		else
			amount,crit = unpack(amount)
		end
	end
	if self.hp then
		if self.armor[t] then
			amount = math.max(1,amount-self.armor[t])
		end
		if self.damagereduction[t] then
			amount = amount * self.damagereduction[t]
		end
		self.hp = self.hp - amount
	end
	if self.hp <= 0 and not self.preventdeath then 
		self:kill(source) 
	else
		self.hp = math.max(self.hp,1)
	end
	self:notifyListeners({type='damage',damagetype=t,damage=amount,unit=self,source=source,})
	if crit then
		self:notifyListeners({type='crit',
		unit = source,
		damage = crit,
		target = self,})
	end
	return amount
end

function Unit:isEnemyOf(another)
return (self.controller == 'player' and another.controller == 'enemy') or
(self.controller == 'enemy' and another.controller == 'player') or
(self.controller == 'player' and another.controller == 'enemyMissile') or
(self.controller == 'enemy' and another.controller == 'playerMissile') 
end

function Unit:setAngle(angle)
	if self.body and not self.preremoved then
		self.body:setAngle(angle)
	end
end

function Unit:setPosition(x,y)
	
	if self.body and not self.preremoved then
		self.body:setPosition(x,y)
	end
	self.x,self.y = x,y
end

function Unit:getAngle()
	if self.body and not self.preremoved then
		return self.body:getAngle()
	end
end

function Unit:kill(killer)
	if self.isDead then
		return
	end
	map:removeUnit(self)
	CreateExplosion(self.x,self.y)
	self:notifyListeners({type='death',killer = killer,unit=self})
	self.isDead = true
	self:drop()
end

function Unit:getHP()
	if self.hp then return self.hp end
	return 1000
end


function Unit:getMaxHP()
	if self.maxhp then return self.maxhp end
	return 1000
end

function Unit:getHPPercent()
	if self.hp and self.maxhp then return self.hp/self.maxhp end
	return 1
end
function Unit:getMP()
	if self.mp then return self.mp end
	return 1000
end

function Unit:getMaxMP()
	if self.maxmp then return self.maxmp end
	return 1000
end

function Unit:getMPPercent()
	if self.mp and self.maxmp then return self.mp/self.maxmp end
	return 1
end

function Unit:createBody(world)
	local t = 'dynamic'
	if self.mass <= 0 then t = 'static' end
	self.body = love.physics.newBody(world,self.x,self.y,t)
	self.shape = love.physics.newCircleShape(self.rad)
	self.fixture = love.physics.newFixture(self.body,self.shape)
	if self.controller then
		category,masks = unpack(typeinfo[self.controller])
		self.fixture:setCategory(category)
		self.fixture:setMask(unpack(masks))
		self.fixture:setDensity(self.mass/2)
	end
	self.updateShapeData = true -- a hack to fix the crash when set data in a coroutine
	if self.r then
		self.body:setAngle(self.r)
	end
end

function Unit:preremove()
	self.fixture:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
	
    self.preremoved = true
end

function Unit:destroy()
    if self.preremoved then
--        if self.shape then self.shape:destroy() end
        if self.fixture then self.fixture:destroy() end
        if self.body then self.body:destroy() end
		self.shape = nil
		self.fixture = nil
		self.body = nil
    end
end

function Unit:addBuff(buff,duration)
	local v = self:hasBuff(buff.class)
	if v then
		self.buffs[v] = math.max(self.buffs[v],duration)
		return
	end
	self.buffs[buff] = duration
	if buff.start then buff:start(self) end
end

function Unit:removeBuff(buff)
	if buff:isKindOf(Buff) then
		self:_removeBuff(buff)
		return
	end
	for v,_ in pairs(self.buffs) do
		if v.class == buff then
			self:_removeBuff(v)
			return
		end
	end
	
end

function Unit:_removeBuff(buff)
	self.buffs[buff] = nil
	if buff.stop then buff:stop(self) end
end

function Unit:hasBuff(c)
	for v,_ in pairs(self.buffs) do
		if v.class == c then
			return v
		end
	end
	return false
end

function Unit:setBuffActive(state)
	for k,v in pairs(self.buffs) do
		if state and k.start then
			k:start(self)
		elseif (not state) and k.stop then
			k:stop(self)
		end
	end
end

function Unit:update(dt)
	assert(self.body)
	if self.timescale then
		dt = dt * self.timescale
	end
	if self.updateShapeData then
		self.fixture:setUserData(self)
		self.updateShapeData = nil
	end
	if self.ai and not self.ai.paused then
		local status = self.ai:process(dt,self)
--		if status == STATE_FINISH then
--			self.ai = nil
--		end
	end
	self.allowmovement = true
	self.allowskill = true
	self.allowmelee = true
	self.controllable = true
	self.allowactive = true
	local erasebuff = {}
	for k,v in pairs(self.buffs) do
		if k.buff then
			k:buff(self,dt)
		end
		if type(v)=='number' and v>=0 then
			self.buffs[k] = v-dt
			if self.buffs[k]<=0 then
				table.insert(erasebuff,k)
				if k.stop then k:stop(self) end
			end
		end
	end
	for i,v in ipairs(erasebuff) do
		self.buffs[v] = nil
	end
	-- all the buff/debuffs
	local speedlimit = (self.speedlimit + self.movementspeedbuff) * self.movementspeedbuffpercent

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
			self.body:setAngularVelocity(0)
			local x,y = self.body:getLinearVelocity()
			if x*x+y*y < speedlimit then
				x,y = unpack(self.direction)
				x,y = x*self.movingforce*self.movementspeedbuffpercent,y*self.movingforce*self.movementspeedbuffpercent
				self.body:applyForce(x,y)
				self.body:setAngle(math.atan2(y,x))
			else
				self.body:setLinearVelocity(x*0.95,y*0.95)
			end
		end
		self.x,self.y=self.body:getPosition()
	end
	self.hp = math.min(self.hp + self.HPRegen*dt,self.maxhp)
	self.mp = math.min(self.mp + self.MPRegen*dt,self.maxmp)
end

function Unit:drawLight(x,y)
	if self.rad then
		local nx,ny = normalize(self.x-x,self.y-y)
		local x1,y1 = ny*self.rad/2,-nx*self.rad/2
		local x2,y2 = -x1,-y1
		x1,y1 = x1+self.x,y1+self.y
		x2,y2 = x2+self.x,y2+self.y
		love.graphics.polygon('fill',x1,y1,x2,y2,(x2-x)*1000,(y2-y)*1000,(x1-x)*1000,(y1-y)*1000)
	end
end

function Unit:stop()
	self.state = 'slide'
	self:switchChannelSkill(nil)
end

function Unit:face(x,y)
	if not y then
		x,y = x.x,x.y
	end
	self:setAngle(math.atan2(y-self.y,x-self.x))
end


function Unit:drawBuff()
	if not self.buffs then return end
	for k,v in pairs(self.buffs) do
		if k.draw then
			k:draw(self)
		end
	end
end

function Unit:skilleffect(skill)
end

function Unit:draw()
	love.graphics.circle('fill',self.x,self.y,self.rad,32)
	self:drawBuff()
end

-- Some additional function that makes abilities easier

function Unit:dash(x,y)
	assert(self.body)
	local vx = 2*500*(x-self.x)
	local vy = 2*500*(y-self.y)
	DBGMSG(vx,4)
	DBGMSG(vy,4)
	vx = vx^0.5
	vy = vy^0.5
	DBGMSG(vx,4)
	DBGMSG(vy,4)
	self.body:applyLinearImpulse(vx,vy)
end

function Unit:findUnitByType(type)
	local sources = map:findUnitsWithCondition(
		function(unit)
			return unit:isKindOf(type)
	end)
	if #sources>=1 then
		return sources[math.random(#sources)]
	end
end

function Unit:getPosition()
	return self.x,self.y
end

AnimatedUnit = Unit:subclass'AnimatedUnit'

function AnimatedUnit:playAnimation(anim,speed,loop,interrupt)
	if self.animation[anim] then
		if self.animation[anim] == self.anim and interrupt then return end
		if #(self.animation[anim]) > 0 then
			self.anim = self.animation[anim][math.random(#self.animation[anim])]
		else
			self.anim = self.animation[anim]
		end
		self.anim:reset()
		self.animspeed = speed
		self.animloop = loop
	end
end

function AnimatedUnit:resetAnimation()
	self.animspeed = 1
	self.anim = self.animation.stand
	self.animloop = true
end

function AnimatedUnit:update(dt)
	super.update(self,dt)
	if self.animation.move and self.state == 'move' and self.anim == self.animation.stand then
		self.animation.move:update(dt)
	elseif self.anim then
		if self.anim:update(dt*self.animspeed) and not self.animloop then
			self:resetAnimation()
		end
	end
end

function AnimatedUnit:draw()
	if self.animation.move and self.state == 'move' and self.anim == self.animation.stand then
		self.animation.move:draw(self.x,self.y,self.body:getAngle())
	elseif self.anim then
		self.anim:draw(self.x,self.y,self.body:getAngle())
	end
	self:drawBuff()
end

Character = Unit:subclass('Character')
function Character:initialize(x,y,rad,mass)
	super.initialize(self,x,y,rad,mass)
	self.probedt = 0
	self.probetime = 0.02
	self.animation = {}
	self.inventory = Inventory:new(self)
end

function Character:setWeaponSkill(skill,lvl)
	self.skills.weaponskill = skill or Skill()
	self.skills.weaponskill:setLevel(lvl or 0)
end

function Character:setUseItem(item)
	self.skills.useitem = self.skills.useitem or UseItem(item)
	self.skills.useitem:setItem(item)
	assert(self.skills.useitem)
end

function Character:pickUp(item,stack)
	return self.inventory:addItem(item,stack)
end

function table.copy(t)
  local t2 = {}
  for k,v in pairs(t) do
	if type(v)== 'table' then
    t2[k] = table.copy(v)
	else t2[k] = v
	end
  end
  return t2
end

function Character:reequip()
	if self.inventory then
		self.inventory:setEquipmentActive(false)
	end
	if self.inventory then
		self.inventory:setEquipmentActive(true)
	end
end

function Character:save()
	
	if self.inventory then
		self.inventory:setEquipmentActive(false)
	end
	--self.inventory:setEquipmentActive(false)
	self:setBuffActive(false)
	local save = {
		movingforce =self.movingforce ,
		speedlimit =self.speedlimit ,
		maxhp=self.maxhp,
		hp=self.hp,
		HPRegen =self.HPRegen ,
		maxmp=self.maxmp,
		mp=self.mp,
		MPRegen =self.MPRegen ,
		armor =self.armor ,
		damagereduction =self.damagereduction ,
		damagebuff =self.damagebuff ,
		damageamplify =self.damageamplify ,
		critical =self.critical,
		evade =self.evade,
		cd = self.cd,
		movementspeedbuff =self.movementspeedbuff,
		movementspeedbuffpercent =self.movementspeedbuffpercent,
		spellspeedbuffpercent =self.spellspeedbuffpercent,
		timescale =self.timescale,
		spirit = self.spirit,
		skills = {},
	}
	if self.inventory then
		save.inventory = self.inventory:save()
	end
	for k,v in pairs(self.skills) do
		if k~='weaponskill' then
			save.skills[k] = v.level
		end
	end
	local save = table.copy(save)
	if self.inventory then
		self.inventory:setEquipmentActive(true)
	end
	self:setBuffActive(true)
	return save
end

function Character:getManager()
	return self.manager
end

function Character:update(dt)
	super.update(self,dt)
	self.probedt = self.probedt - dt
	if self.probedt <= 0 then
	end
end

function Character:load(save)
	assert(save)
	self.buffs = {}
	if self.inventory then
		self.inventory:clear()
	end
	for k,v in pairs(save) do
		if k == 'skills' then
			for k2,v2 in pairs(v) do
				if self.skills[k2].setLevel then self.skills[k2]:setLevel(v2) end
			end
		elseif k ~= 'inventory' then
			self[k] = v
		end
	end
	if self.inventory then
		self.inventory:load(save.inventory)
	end
end

function Character:register()
end

function Character:unregister()
end

function Character:addBuff(buff,duration)
	super.addBuff(self,buff,duration)
	if buff.getPanelData and GetGameSystem().fillBuffPanel then
		GetGameSystem():fillBuffPanel(buff.genre,buff:getPanelData())
	end
end


function Character:drawBuff()
	if not self.buffs then return end
	for k,v in pairs(self.buffs) do
		if k.draw then
			k:draw(self)
			
		end
		if k.getPanelData then
			--GetGameSystem():indicateBuff(k)
		end
	end
end

local npc = Character:addState'npc'
function npc:update(dt)
	Unit.update(self,dt)
end

function Unit:getOffenceTarget()
	if self.controller=='enemy' or self.controller=='enemyMissile' then
		return GetCharacter()
	end
end
