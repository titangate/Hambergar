
Assassin = Character:subclass('Assassin')
function Assassin:initialize(x,y)
	super.initialize(self,x,y,16,10)
	self.hp = 500
	self.maxhp = 500
	self.mp = 500
	self.maxmp = 500
	self.skills = {
		pistoldwsalt = PistolDWSAlt:new(self,1),
		pistol = Pistol:new(self,1),
		stunbullet = StunBullet:new(self,-1),
		explosivebullet = ExplosiveBullet:new(self,-1),
		momentumbullet = AbsoluteMomentum:new(self,-1),
		stim = Stim:new(self,-1),
		roundaboutshot = RoundaboutShot:new(self,-1),
		dash = Dash:new(self,1),
		mindripfield = MindRipfield:new(self,1),
		mind = Mind:new(self,1),
		invis = Invis:new(self,1),
		snipe = Snipe:new(self,1),
		dws = DWS:new(self,0),
	}
	self:setWeaponSkill()
	self.spirit = 10
	self.manager = AssassinPanelManager:new(self)
end

function Assassin:getSkin()
	return 'default'
end

function Assassin:damage(...)
	super.damage(self,...)
	local b = BloodTrail:new(self)
	map:addUpdatable(b)
end

function Assassin:getSkillpanelData()
	return {
		buttons = {
			{skill = self.skills.dash,hotkey='b',face=character[self.skills.dash.name]},
			{skill = self.skills.roundaboutshot,hotkey='r',face=character[self.skills.roundaboutshot.name]},
			{skill = self.skills.stim,hotkey='e',face=character[self.skills.stim.name]},
			{skill = self.skills.mindripfield,hotkey='f',face=character[self.skills.mindripfield.name]},
			{skill = self.skills.weaponskill,hotkey='lb',face=character[self.skills.pistol.name]},
			{skill = self.skills.invis,hotkey='v',face=character[self.skills.invis.name]},
			{skill = self.skills.snipe,hotkey='g',face=character[self.skills.pistol.name]},
			{skill = self.skills.dws,hotkey='z',face=character.divide},
		}
	}
end

requireImage('assets/assassin/assassinpose copy.png','assassinpose')
function Assassin:draw()
	if self.invisible then
		love.graphics.setColor(255,255,255,100)
	end
	local facing = GetOrderDirection()
	facing = math.atan2(facing[2],facing[1])
	love.graphics.draw(img.assassinpose,self.x,self.y,facing,1,1,20,32)
	local weapon = self.inventory:getEquip('weapon')
	if weapon then
		weapon:drawBody(self.x,self.y,facing)
	end
	self:drawBuff()
	love.graphics.setColor(255,255,255,255)
end

local DWSAssassin = Assassin:addState('DWS')
function DWSAssassin:enterState()
	for k,v in pairs(self.skills) do
		if v.states.DWS then
			v:gotoState('DWS')
		end
	end
	if not self.particles then
		self.particles = {}
		local p = love.graphics.newParticleSystem(img.part1, 1000)
		p:setEmissionRate(200)
		p:setSpeed(30, 40)
		p:setSize(0.25, 0.5)
		p:setColor(220, 105, 20, 255, 194, 30, 18, 0)
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
		p:setEmissionRate(200)
		p:setSpeed(30, 40)
		p:setSize(0.25, 0.5)
		p:setColor(20, 105, 220, 255, 18, 30, 194, 0)
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
		p:setEmissionRate(200)
		p:setSpeed(30, 40)
		p:setSize(0.25, 0.5)
		p:setColor(220, 220, 20, 255, 194, 194, 18, 0)
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

function DWSAssassin:switchChannelSkill(skill)
	skill = skill or self.skills.pistoldwsalt
	Assassin.switchChannelSkill(self,skill)
end

function DWSAssassin:morphEnd()
	self:gotoState()
end