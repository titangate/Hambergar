animation.swift = Animation:new(love.graphics.newImage('assets/electrician/electrician.png'),200,200,0.08,1,1,12,100)
Swift = Character:subclass('Swift')

function Swift:initialize(x,y)
	super.initialize(self,x,y,16,10)
	self.hp = 500
	self.maxhp = 500
	self.mp = 500
	self.maxmp = 500
	self.skills = {
		swipe = Swipe(self,1),
		hook = Hook(self,1),
		tornado = Tornado(self,1),
		drag = Drag(self,1),
		hellofspikes = HellOfSpikes(self,1),
	}
	self.animation = {
		stand = animation.swift:subSequence(1,4),
		attack = animation.swift:subSequence(5,10),
		active = animation.swift:subSequence(18,21),
	}
	self.spirit = 10
--	self.manager = SwiftPanelManager:new(self)
	self:resetAnimation()
	self.chain = Chain(self)
	self.subchains = {
		Chain(self),
		Chain(self),
	}
	self.blureffect = Blureffect
	self:setWeaponSkill()
end


function Swift:getSkin()
	return 'swift'
end

function Swift:damage(...)
	super.damage(self,...)
	local b = BloodTrail:new(self)
	map:addUpdatable(b)
end

function Swift:getSkillpanelData()
	return {
		buttons = {
			{skill = self.skills.swipe,hotkey='lb',face=icontable.swipe},
			{skill = self.skills.hook,hotkey='r',face=icontable.swipe},
			{skill = self.skills.tornado,hotkey='q',face=icontable.swipe},
			{skill = self.skills.drag,hotkey='b',face=icontable.swipe},
			{skill = self.skills.hellofspikes,hotkey='x',face=icontable.swipe},
		}
	}
end

function Swift:createBody(world)
	super.createBody(self,world)
	self.body:setAngle(0)
	self.body:setFixedRotation(true)
	self.chain:createBody(world)
	self.subchains[1]:createBody(world)
	self.subchains[2]:createBody(world)
end

function Swift:playAnimation(anim,speed,loop)
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
	if self.weapons and self.weapons[anim] then
		if #(self.weapons[anim]) > 0 then
			self.weapon = self.weapons[anim][math.random(#self.weapons[anim])]
		else
			self.weapon = self.weapons[anim]
		end
		self.weapon:reset()
	end
end


function Swift:resetAnimation()
	self.animspeed = 1
	self.anim = self.animation.stand
	self.animloop = true
end

function Swift:update(dt)
	super.update(self,dt)
	if self.anim then
		
		if self.anim:update(dt*self.animspeed) and not self.animloop then
			self:resetAnimation()
		end
	end
	if self.weapon then
		self.weapon:update(dt*self.animspeed)
	end
	self.chain:update(dt)
	self.subchains[1]:update(dt)
	self.subchains[2]:update(dt)
	local facing = GetOrderDirection()
	facing = math.atan2(facing[2],facing[1])
	self.r = facing
	self.body:setAngle(0)
--	Blureffect.update(dt)
end

function Swift:draw()
	
--	Blureffect.begin()
	self.chain:draw()
	self.subchains[1]:draw()
	self.subchains[2]:draw()
	if self.invisible then
		love.graphics.setColor(255,255,255,100)
	end
	if self.weapon then
		self.weapon:draw(self.x,self.y,self.r)
	end
	if self.anim then
		self.anim:draw(self.x,self.y,self.r)
	end
	self:drawBuff()
	
--	Blureffect.finish()
end