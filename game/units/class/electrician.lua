
animation.electrician = Animation:new(love.graphics.newImage('assets/electrician/electrician.png'),200,200,0.08,1,1,12,100)
animation.weaponbolt = Animation:new(love.graphics.newImage('assets/electrician/weaponbolt.png'),200,200,0.08,1,1,12,100)
animation.weaponsword = Animation:new(love.graphics.newImage('assets/electrician/weaponsword.png'),200,200,0.08,1,1,27,100,15,0)

Electrician = Character:subclass('Electrician')

files = love.filesystem.enumerate('assets/electrician/icon')
electricianicon = {}
for i,v in ipairs(files) do
	if love.filesystem.isFile('assets/electrician/icon/'..v) then
		local f = v:gmatch("(%w+).(%w+)")
		local file,ext=f()
		if ext=='png' then
			electricianicon[file] = love.graphics.newImage('assets/electrician/icon/'..v)
		end
	end
end

function Electrician:initialize(x,y)
	super.initialize(self,x,y,16,10)
	self.hp = 500
	self.maxhp = 500
	self.mp = 500
	self.maxmp = 500
	self.skills = {
		battery = Battery:new(self,1),
		lightningbolt = LightningBolt:new(self,1),
		ionicform = Ionicform:new(self,3),
		lightningchain = LightningChain:new(self,1),
		drain = Drain:new(self,1),
		cpu = CPU:new(self,1)
	}
	self.animation = {
		stand = animation.electrician:subSequence(1,4),
		attack = animation.electrician:subSequence(5,10),
		active = animation.electrician:subSequence(18,21),
		ionicform = {reset=function()end,update=function()end,draw=function(self,x,y,r) love.graphics.draw(pulse,x,y,0,2,2,16,16) end},
	}
	self.weapons = {
		stand = animation.weaponsword:subSequence(1,4),
		attack = animation.weaponsword:subSequence(5,10),
		active = animation.weaponsword:subSequence(18,21),
		ionicform = {reset=function()end,update=function()end,draw=function()end},
	}
	self.spirit = 10
	self.manager = ElectricianPanelManager:new(self)
	self:resetAnimation()
end

function Electrician:damage(...)
	super.damage(self,...)
	local b = BloodTrail:new(self)
	map:addUpdatable(b)
end

function Electrician:getSkillpanelData()
	return {
		buttons = {
			{skill = self.skills.lightningbolt,hotkey='lb',face=electricianicon.bolt},
			{skill = self.skills.ionicform,hotkey='rb',face=electricianicon.ionicform},
			{skill = self.skills.lightningchain,hotkey='g',face=electricianicon.lightningchain},
			{skill = self.skills.drain,hotkey='q',face=electricianicon.drain},
		}
	}
end

function Electrician:playAnimation(anim,speed,loop)
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
	if self.weapons[anim] then
		if #(self.weapons[anim]) > 0 then
			self.weapon = self.weapons[anim][math.random(#self.weapons[anim])]
		else
			self.weapon = self.weapons[anim]
		end
		self.weapon:reset()
	end
end


function Electrician:resetAnimation()
	self.animspeed = 1
	self.anim = self.animation.stand
	self.weapon = self.weapons.stand
	self.animloop = true
end

function Electrician:update(dt)
	super.update(self,dt)
	if self.anim then
		
		if self.anim:update(dt*self.animspeed) and not self.animloop then
			self:resetAnimation()
		end
	end
	if self.weapon then
		self.weapon:update(dt*self.animspeed)
	end
end

function Electrician:draw()
	if self.invisible then
		love.graphics.setColor(255,255,255,100)
	end
	local facing = GetOrderDirection()
	facing = math.atan2(facing[2],facing[1])
	if self.weapon then
		self.weapon:draw(self.x,self.y,facing)
	end
	if self.anim then
		self.anim:draw(self.x,self.y,facing)
	end
	self:drawBuff()
	love.graphics.setColor(255,255,255,255)
	if self.lockunit then
		love.graphics.circle('fill',self.lockunit.x,self.lockunit.y,64)
	end
end