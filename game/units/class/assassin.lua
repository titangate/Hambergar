
Assassin = Character:subclass('Assassin')
function Assassin:initialize(x,y)
	super.initialize(self,x,y,16,10)
	self.hp = 500
	self.maxhp = 500
	self.mp = 500
	self.maxmp = 500
	self.skills = {
		pistoldwsalt = PistolDWSAlt(self,1),
		pistol = WeaponMastery(self,1),
		stunbullet = StunBullet:new(self,0),
		explosivebullet = ExplosiveBullet:new(self,0),
		momentumbullet = AbsoluteMomentum:new(self,0),
		stim = Stim:new(self,0),
		roundaboutshot = RoundaboutShot:new(self,0),
		dash = Dash:new(self,1),
		mindripfield = MindRipfield:new(self,1),
		mind = Mind:new(self,1),
		invis = Invis:new(self,1),
		snipe = Snipe:new(self,1),
		dws = DWS:new(self,1),
		takedown = Takedown(self,1),
		changeoutfit = ChangeOutfit(self,1),
		useitem = UseItem(self,0),
		mysteriousqi = MysteriousQi(self,1),
	}
	self:setWeaponSkill()
	self:setUseItem()
	self.spirit = 10
	self.manager = AssassinPanelManager(self)
	self.assassincritlistener = {
		eventtype = 'crit'
	}
	function self.assassincritlistener.handle(handler,event)
		if event.unit == self then
			if math.random()<self.skills.mysteriousqi.chance then
				self:addBuff(b_Qi(self.skills.mysteriousqi.evade),self.skills.mysteriousqi.time)
			end
		end
	end
end

function Assassin:load(...)
	super.load(self,...)
--	self.manager.tree:loadAvailableSkill()
end

function Assassin:getWeaponLevel()
	return self.skills.pistol:getLevel()
end

function Assassin:berserker(state)
	if state then
		self.beforeberserker = {
			stim = self.skills.stim.cd,
			snipe = self.skills.snipe.cd,
			roundaboutshot = self.skills.roundaboutshot.cd,
		}
		self.skills.stim.cd = 0
		self.skills.roundaboutshot.cd = 0
		self.skills.snipe.cd = 0
	else
		assert(self.beforeberserker)
		self.skills.stim.cd = self.beforeberserker.stim
		self.skills.roundaboutshot.cd = self.beforeberserker.roundaboutshot
		self.skills.snipe.cd = self.beforeberserker.snipe
	end
end

function Assassin:tome(state)
	if state then
		self.pusheen = self.skills.dws.cd
		self.skills.dws.cd = self.pusheen/2
	else
		assert(self.pusheen)
		self.skills.dws.cd = self.pusheen
		self.pusheen = nil
	end
end

function Assassin:beads(state)
	if state then
		self.beadsCD = self.skills.dash.cd
		self.beadsMP = self.skills.dash.manacost
		self.skills.dash.cd = self.beadsCD/2
		self.skills.dash.manacost = self.beadsMP/2
	else
		assert(self.beadsMP)
		assert(self.beadsCD)
		self.skills.dash.manacost = self.beadsMP
		self.skills.dash.cd = self.beadsCD
		self.beadsCD = nil
		self.beadsMP = nil
	end
end

function Assassin:lotus(hp,mp,buff,cd)
	if not hp then
		self.lotusOn = nil
	else
		self.lotusOn = {
			hp = hp,
			mp = mp,
			buff = buff,
			cd = cd,
		}
	end
		
end


function Assassin:kill(killer)
	if self.lotusOn and not self:hasBuff(b_Lotus) then
		self.hp = self.hp + self.lotusOn.hp*self.maxhp
		self.mp = self.mp + self.lotusOn.mp*self.maxmp
		self:addBuff(b_Lotus(),self.lotusOn.cd)
		return
	end
	super.kill(self,killer)
end

function Assassin:addBuff(buff,duration)
	if self.cloak and buff.genre == 'debuff' and type(duration) == 'number' then
		duration = duration/2
	end
	super.addBuff(self,buff,duration)
end

function Assassin:getSkin()
	return 'default'
end




-- please refer to abilities.assassin.mind


function Assassin:register()
	gamelistener:register(self.assassincritlistener)
--	assassinkilllistener:gotoState()
end

function Assassin:unregister()
	gamelistener:unregister(self.assassincritlistener)
end

function Assassin:damage(...)
	super.damage(self,...)
	local b = BloodTrail:new(self)
	map:addUpdatable(b)
end

function Assassin:getSkillpanelData()
	assert(self.skills.useitem)
	return {
		buttons = {
			{skill = self.skills.dash,hotkey=hotkeys.dash,face=requireImage'assets/icon/dash.png'},
			{skill = self.skills.roundaboutshot,hotkey=hotkeys.spiral,face=requireImage'assets/icon/spiral.png'},
			{skill = self.skills.stim,hotkey=hotkeys.stim,face=requireImage'assets/icon/stim.png'},
			{skill = self.skills.mindripfield,hotkey=hotkeys.mindripfield,face=requireImage'assets/icon/rip.png'},
			{skill = self.skills.weaponskill,hotkey=hotkeys.weaponskill,face=self.skills.weaponskill.icon},
			{skill = self.skills.invis,hotkey=hotkeys.invis,face=requireImage'assets/icon/invis.png'},
			{skill = self.skills.snipe,hotkey=hotkeys.snipe,face=requireImage'assets/icon/snipe.png'},
			{skill = self.skills.dws,hotkey=hotkeys.dws,face=requireImage'assets/icon/dws.png'},
			{skill = self.skills.useitem,hotkey=hotkeys.useitem,face=self.skills.useitem:getIcon()},
		}
	}
end

requireImage('assets/assassin/assassinpose copy.png','assassinpose')
function Assassin:draw()
	local facing = GetOrderDirection()
	facing = math.atan2(facing[2],facing[1])
	if self.invisible then
		love.graphics.setColor(255,255,255,100)
		filtermanager:requestFilter('Heathaze',function()
		
		love.graphics.draw(img.assassinpose,self.x,self.y,facing,1,1,20,32)
		end)
	end
	
	love.graphics.draw(img.assassinpose,self.x,self.y,facing,1,1,20,32)
	local weapon = self.inventory:getEquip('weapon')
	if weapon then
		weapon:drawBody(self.x,self.y,facing)
	end
	self:drawBuff()
	love.graphics.setColor(255,255,255,255)
end

local StealthAssassin = Assassin:addState'stealth'


function StealthAssassin:playAnimation(anim,speed,loop)
	if self.animation[anim] then
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

function StealthAssassin:resetAnimation()
	self.animspeed = 1
	self.anim = self.animation.stand
	self.animloop = true
end

function StealthAssassin:update(dt)
	Assassin.update(self,dt)
	local u = GetOrderUnit()
	if u and u.ai and u.ai.alertlevel == 0 and getdistance(self,u)<100 then
		self.takingdown = true
	else
		self.takingdown = false
	end
	if self.animation.move and self.state == 'move' and self.anim == self.animation.stand then
		self.animation.move:update(dt)
	elseif self.anim then
		if self.anim:update(dt*self.animspeed) and not self.animloop then
			self:resetAnimation()
		end
	end
end

function StealthAssassin:draw()
	local facing = GetOrderDirection()
	facing = math.atan2(facing[2],facing[1])
	if self.outfit then
		if self.animation.move and self.state == 'move' and self.anim == self.animation.stand then
			self.animation.move:draw(self.x,self.y,facing)
		elseif self.anim then
			self.anim:draw(self.x,self.y,facing)
		end
		self:drawBuff()
	else
		Assassin.draw(self)
	end
end

function StealthAssassin:getSkillpanelData()
	return {
		buttons = {
			{skill = self.skills.dash,hotkey='b',face=requireImage'assets/icon/dash.png'},
			{skill = self.skills.roundaboutshot,hotkey='r',face=character[self.skills.roundaboutshot.name]},
			{skill = self.skills.stim,hotkey='e',face=character[self.skills.stim.name]},
			{skill = self.skills.mindripfield,hotkey='f',face=character[self.skills.mindripfield.name]},
			{skill = self.skills.weaponskill,hotkey='lb',face=character[self.skills.pistol.name]},
			{skill = self.skills.invis,hotkey='v',face=character[self.skills.invis.name]},
			{skill = self.skills.snipe,hotkey='g',face=character[self.skills.pistol.name]},
			{skill = self.skills.takedown,hotkey='z',face=character.takedown},
			{skill = self.skills.changeoutfit,hotkey='r',face=character.change},
		}
	}
end

function StealthAssassin:enterState()
	if self==GetCharacter() then
		SetCharacter(self)
	end
	self.alertlevel = 0
end

local DWSAssassin = Assassin:addState('DWS')
function DWSAssassin:enterState()
	for k,v in pairs(self.skills) do
		if v.states.DWS then
			v:gotoState'DWS'
		end
	end
	if not self.particles then
		self.particles = {}
		local p = love.graphics.newParticleSystem(img.part1, 1000)
		p:setEmissionRate(options.particlerate*200)
		p:setSpeed(30, 40)
		p:setSizes(0.25, 0.5)
		p:setColors(220, 105, 20, 255, 194, 30, 18, 0)
		p:setPosition(400, 300)
		p:setLifetime(0.1)
		p:setParticleLife(0.2)
		p:setDirection(0)
		p:setSpread(360)
		p:setTangentialAcceleration(1000)
		p:setRadialAcceleration(0)
		p:stop()
		table.insert(self.particles, p)
		local p = love.graphics.newParticleSystem(img.part1, 1000)
		p:setEmissionRate(options.particlerate*200)
		p:setSpeed(30, 40)
		p:setSizes(0.25, 0.5)
		p:setColors(20, 105, 220, 255, 18, 30, 194, 0)
		p:setPosition(400, 300)
		p:setLifetime(0.1)
		p:setParticleLife(0.2)
		p:setDirection(0)
		p:setSpread(360)
		p:setTangentialAcceleration(1000)
		p:setRadialAcceleration(0)
		p:stop()
		table.insert(self.particles, p)
		local p = love.graphics.newParticleSystem(img.part1, 1000)
		p:setEmissionRate(options.particlerate*200)
		p:setSpeed(30, 40)
		p:setSizes(0.25, 0.5)
		p:setColors(220, 220, 20, 255, 194, 194, 18, 0)
		p:setPosition(400, 300)
		p:setLifetime(0.1)
		p:setParticleLife(0.2)
		p:setDirection(0)
		p:setSpread(360)
		p:setTangentialAcceleration(1000)
		p:setRadialAcceleration(0)
		p:stop()
		table.insert(self.particles, p)
	end
	self.dr = 0
end

function DWSAssassin:exitState()
	for k,v in pairs(self.skills) do
		if v.states.DWS then
			v:gotoState()
		end
	end
end
--[[
function DWSAssassin:update(dt)
	Assassin.update(self,dt)
	local x,y = self.x,self.y
	for k,v in ipairs(self.particles) do
		local cosr,sinr = math.cos(self.dr+k*2.09)*15,math.sin(self.dr+k*2.09)*15
		v:setPosition(self.x+cosr+sinr,self.y+cosr-sinr)
		v:start()
		v:update(dt)
	end
	self.dr = self.dr + 15*dt
end

function DWSAssassin:draw()
	Assassin.draw(self,dt)
	for k,v in ipairs(self.particles) do
		love.graphics.draw(v)
	end
end
]]
function DWSAssassin:switchChannelSkill(skill)
	skill = skill or self.skills.pistoldwsalt
	Assassin.switchChannelSkill(self,skill)
end

function DWSAssassin:morphEnd()
	self:gotoState()
end
