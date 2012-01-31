
local GOO_SKINPATH = 'goo/skins/electrician/'
requireImage(GOO_SKINPATH..'attritubebackground.png','attritubebackground')
requireImage(GOO_SKINPATH..'conversationbg.png','conversationbg')


requireImage(GOO_SKINPATH .. 'battery.png','batteryimg')
requireImage(GOO_SKINPATH .. 'cpu.png','cpu')

requireImage(GOO_SKINPATH..'electricianlevel.png','levelimg')
animation.electrician = Animation:new(love.graphics.newImage('assets/electrician/electrician.png'),200,200,0.08,1,1,12,100)
animation.weaponbolt = Animation:new(love.graphics.newImage('assets/electrician/weaponbolt.png'),200,200,0.08,1,1,12,100)
animation.weaponsword = Animation:new(love.graphics.newImage('assets/electrician/weaponsword.png'),200,200,0.08,1,1,27,100,15,0)
--[[
--requireImage(GOO_SKINPATH..'fuzz.png','fuzz')
local lowhealth = CutSceneSequence:new()
local panel2 = goo.object:new()
local fuzz = goo.image:new(panel2)
fuzz:setPos(0,-100)
fuzz:setImage(icontable.fuzz)
local panel1 = goo.object:new()
anim:easy(panel1,'y',-300,0,1,'quadInOut')
anim:easy(panel2,'x',300,0,1,'quadInOut')
local x,y = 100,screen.halfheight-50
for c in text:gmatch"." do
	lowhealth:push(ExecFunction:new(function()
		local ib = goo.image:new(panel1)
--		ib:setImage(img.)
		ib:setPos(x,y)
		local textscale = 2
		x = x+ib.w*textscale
		local animsx = anim:new({
			table = ib,
			key = 'xscale',
			start = 5*textscale,
			finish = 2*textscale,
			time = 0.3,
			style = anim.style.linear}
		)
		local animsy = anim:new({
			table = ib,
			key = 'yscale',
			start = 5*textscale,
			finish = 2*textscale,
			time = 0.3,
			style = anim.style.linear}
		)
		local animg = anim.group:new(animsx,animsy)
		animg:play()
		local animwx = anim:new({
			table = ib,
			key = 'xscale',
			start = 2*textscale,
			finish = 1*textscale,
			time = 0.5,
			style = 'elastic'
		})
		local animwy = anim:new({
			table = ib,
			key = 'yscale',
			start = 2*textscale,
			finish = 1*textscale,
			time = 0.5,
			style = 'elastic'
		})
		local animw = anim.group:new(animwx,animwy)
		local animc = anim.chain:new(animg,animw)
		animc:play()
		TEsound.play('sound/thunderclap.wav')
	end),0)
	
	lowhealth:wait(0.2)
end	
	lowhealth:wait(0.5)
lowhealth:push(ExecFunction:new(function()
anim:easy(panel1,'x',0,screen.width,2,'quadInOut')
anim:easy(panel2,'x',0,-screen.width,2,'quadInOut')
map.timescale = 1
end),0)
lowhealth:push(ExecFunction:new(function()
panel1:destroy()
panel2:destroy()
end),2)]]

Electrician = Character:subclass('Electrician')

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
		lightningchain = LightningChain:new(self,0),
		drain = Drain:new(self,1),
		lightningball = LightningBall:new(self,0),
		cpu = CPU:new(self,1),
		transmitter = Transmitter:new(self,1),
		icarus = Icarus:new(self,1),
		solarstorm = SolarStorm:new(self,1),
		ionicshield = IonicShield(self,1),
		ionicpool = IonicPool(self,1),
		illumination = Illumination(self,1),
		thorn = Thorn(self,1),
	}
	assert(self.skills.ionicshield)
	self.animation = {
		stand = animation.electrician:subSequence(1,4),
		attack = animation.electrician:subSequence(5,10),
		active = animation.electrician:subSequence(18,21),
		ionicform = {reset=function()end,update=function()end,draw=function(self,x,y,r) love.graphics.draw(img.pulse,x,y,0,2,2,16,16) end},
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
	self:setWeaponSkill()
	-- TODO: do what?
end

function Electrician:damage(t,amount,source)
	super.damage(self,t,amount,source)
	local b = BloodTrail:new(self)
	map:addUpdatable(b)
	if self.skills.thorn.level>0 then
		self.skills.thorn.effect:effect(source,self,self.skills.thorn)
	end
end


function Electrician:getSkin()
	return 'electrician'
end

function Electrician:getSkillpanelData()
	return {
		buttons = {
			{skill = self.skills.lightningbolt,hotkey='lb',face=icontable.bolt},
			{skill = self.skills.ionicform,hotkey='rb',face=icontable.ionicform},
			{skill = self.skills.lightningchain,hotkey='g',face=icontable.lightningchain},
			{skill = self.skills.drain,hotkey='q',face=icontable.drain},
			{skill = self.skills.lightningball,hotkey='e',face=icontable.lightningball},
			{skill = self.skills.icarus,hotkey='r',face=icontable.icarus},
			{skill = self.skills.solarstorm,hotkey='z',face=icontable.solarstorm},
			{skill = self.skills.ionicshield,hotkey='c',face=icontable.solarstorm},
			{skill = self.skills.illumination,hotkey='v',face=icontable.solarstorm},
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
