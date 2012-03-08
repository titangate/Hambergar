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

function Unit:startCD(group,cd)
	self.cd[group]=cd
end

function Unit:getCD(group)
	return self.cd[group]
end

function Unit:initialize(x,y,rad,mass)
	super.initialize(self)
	self.x,self.y=x,y
	self.rad = rad
	self.mass = mass
	self.state = 'slide'
	self.order = 'stop'
	self.direction = {1,0}
	self.movingforce = self.mass*50
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
	self.critical = {}
	self.evade = {}
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
	self.invisible = false
	self.invulnerable = false
	self.immue = {}
	self.drops = {}
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
	if self.critical[type] then
		local chance,amplifier = unpack(self.criticalrate[type])
		if math.random()<chance then
			amount = amount * amplifier
			self:notifyListeners({type='critical',unit = self})
		end
	end
	return amount
end

function Unit:damage(type,amount,source)
	if self.evade[type] then
		if math.random()<self.dodgerate[type] then
			self:notifyListeners({type='dodge'})
			return
		end
	end
	if self.hp then
		if self.armor[type] then
			amount = math.max(1,amount-self.armor[type])
		end
		if self.damagereduction[type] then
			amount = amount * self.damagereduction[type]
		end
		self.hp = self.hp - amount
	end
	if self.hp <= 0 then self:kill(source) end
	self:notifyListeners({type='damage',damagetype=type,damage=amount,unit=self,source=source,})

end

function Unit:isEnemyOf(another)
	return (self.controller == 'player' and another.controller == 'enemy') or
	(self.controller == 'enemy' and another.controller == 'player')
end

function Unit:setAngle(angle)
	if self.body and not self.preremoved then
		self.body:setAngle(angle)
	end
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
	self.body = love.physics.newBody(world,self.x,self.y,self.mass,self.mass)
	self.shape = love.physics.newCircleShape(self.body,0,0,self.rad)
	if self.controller then
		category,masks = unpack(typeinfo[self.controller])
		self.shape:setCategory(category)
		self.shape:setMask(unpack(masks))
	end
--	self.shape:setData(self)
	self.updateShapeData = true -- a hack to fix the crash when set data in a coroutine
	if self.r then
		self.body:setAngle(self.r)
	end
end

function Unit:preremove()
	self.shape:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
    self.preremoved = true
end

function Unit:destroy()
    if self.preremoved then
        if self.shape then self.shape:destroy() end
        if self.body then self.body:destroy() end
		self.shape = nil
		self.body = nil
    end
end

function Unit:addBuff(buff,duration)
	self.buffs[buff] = duration
	if buff.start then buff:start(self) end
end

function Unit:removeBuff(buff)
	for v,_ in pairs(self.buffs) do
		if v.class == buff then
			self:removeBuff(v)
			return
		end
	end
	self.buffs[buff] = nil
	if buff.stop then buff:stop(self) end
end

function Unit:hasBuff(c)
	for v,_ in pairs(self.buffs) do
		if v.class == c then
			return true
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
	if self.updateShapeData then
		self.shape:setData(self)
		self.updateShapeData = nil
	end
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
		if k.buff then
			k:buff(self,dt)
		end
		if type(v)=='number' and v>=0 then
			self.buffs[k] = v-dt
			if self.buffs[k]<=0 then
				self.buffs[k]=nil
				if k.stop then k:stop(self) end
			end
		end
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
--	love.graphics.circle('fill',self.x,self.y,self.rad,32)
	self:drawBuff()
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

AnimatedUnit = Unit:subclass('AnimatedUnit')

function AnimatedUnit:playAnimation(anim,speed,loop,interupt)
	if self.animation[anim] then
		if self.animation[anim] == self.anim and interupt then return end
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

function Character:setWeaponSkill(skill)
	print (skill)
	self.skills.weaponskill = self.skills.weaponskill or FireWeapon(self)
	self.skills.weaponskill:setSkill(skill)
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

function Character:save()
	
	if self.inventory then
		self.inventory:setEquipmentActive(false)
		print ('disabled')
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

Probe = Object:subclass('Probe')
function Probe:initialize(unit,start,direction,r)
	self.unit = unit
	self.start = start
	self.direction = direction
	self.controller = 'playerMissile'
	self.life = 0.3
	self.r = r or 64
end

function Probe:createBody(world)
	local x,y = self.start.x,self.start.y
--	assert(math.abs(x)<map.w/2)
--	assert(math.abs(y)<map.h/2)
	self.body = love.physics.newBody(world,x,y,0.0001,1)
	self.shape = love.physics.newCircleShape(self.body,0,0,self.r)
	self.body:setBullet(true)
	self.shape:setSensor(true)
	self.shape:setCategory(15)
	self.shape:setMask(cc.playermissile,cc.enemymissile,cc.player)
	--[[
	if self.controller then
		local category,masks = unpack(typeinfo[self.controller])
		self.shape:setCategory(category)
		self.shape:setMask(unpack(masks))
	end]]
	x,y = unpack(self.direction)
	x,y = normalize(x,y)
	self.body:setLinearVelocity(x*2000,y*2000)
	self.shape:setData(self)
end

function Probe:update(dt)
	self.life = self.life - dt
	if self.life<= 0 then
		self.add = nil
		self.offline = true
		map:removeUnit(self)
	end
end

function Probe:preremove()
	self.shape:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
    self.preremoved = true
end
function Probe:destroy()
    if self.preremoved then
        if self.shape then self.shape:destroy() end
        if self.body then self.body:destroy() end
		self.shape = nil
		self.body = nil
    end
end

--[[
function Probe:draw()
	love.graphics.circle('fill',self.body:getX(),self.body:getY(),16,10)
end
]]

function Probe:add(b)
	if not b:isKindOf(Unit) or b==GetCharacter() or self.offline then return end
	self.add = nil
	self.unit:lock(b)
	self.offline = true
	map:removeUnit(self)
--	end
end


function Character:update(dt)
	super.update(self,dt)
	self.probedt = self.probedt - dt
	if self.probedt <= 0 then
		self.probedt = self.probetime
		local probe = Probe:new(controller,self,controller:GetRawOrderDirection())
		map:addUnit(probe)
	end
end

function Character:load(save)
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

local npc = Character:addState'npc'
function npc:update(dt)
	Unit.update(self,dt)
end

function Unit:getOffenceTarget()
	if self.controller=='enemy' or self.controller=='enemyMissile' then
		return GetCharacter()
	end
end
