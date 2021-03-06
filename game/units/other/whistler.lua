EmergencyStop = Unit:subclass'EmergencyStop'
function EmergencyStop:initialize(x,y)
	super.initialize(self,x,y,16,48)
end


requireImage('assets/drainable/station.png','station')
--requireImage('assets/drainable/emergencystop.png','emergencystop')
function EmergencyStop:draw()
	love.graphics.draw(img.station,self.x,self.y,self.body:getAngle(),1,1,48,48)
end


Lily = Unit:subclass'Lily'
function Lily:initialize(x,y)
	super.initialize(self,x,y,16,10)
--	self.controller = 'player'
end

requireImage('assets/whistler/lily.png','lily')

function Lily:draw()
	love.graphics.draw(img.lily,self.x,self.y,0,1,1,20,32)
end

requireImage('assets/doodad/gate.png','gate')
GrandDoor = Unit:subclass'GrandDoor'
function GrandDoor:initialize(x,y,controller)
	super.initialize(self,x,y,100,0)
	self.hp = 5000
	self.controller = controller
	self.state = 'slide'
end
function GrandDoor:createBody(world)
	self.body = love.physics.newBody(world,self.x,self.y,self.mass,self.mass)
	self.shape = love.physics.newRectangleShape(self.body,0,0,128,32)
	if self.controller then
		category,masks = unpack(typeinfo[self.controller])
		self.shape:setCategory(category)
		self.shape:setMask(unpack(masks))
	end
	self.updateShapeData = true -- a hack to fix the crash when set data in a coroutine
	if self.r then
		self.body:setAngle(self.r)
	end
end

function GrandDoor:damage()
end

function GrandDoor:open()
	self:gotoState'open'
end

function GrandDoor:close()
	self:gotoState()
end

function GrandDoor:drawOpen()
	love.graphics.draw(img.gate,self.x,self.y,self.body:getAngle(),1,1,64,16)
	self:drawBuff()
end

function GrandDoor:draw()
	love.graphics.setColor(255,0,0,255)
	love.graphics.draw(img.gate,self.x,self.y,self.body:getAngle(),1,1,64,16)
	self:drawBuff()
	love.graphics.setColor(255,255,255)
end

local open = GrandDoor:addState'open'
function open:draw()
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(img.gate,self.x,self.y,self.body:getAngle(),1,1,64,16)
	self:drawBuff()
	love.graphics.setColor(255,255,255)
end

function open:enterState()
	self.shape:setSensor(true)
end

function open:exitState()
	self.shape:setSensor(false)
end

requireImage'assets/whistler/arcanecircle.png'
ArcaneCircle = Unit:subclass'ArcaneCircle'
function ArcaneCircle:initialize(x,y,controller)
	super.initialize(self,x,y,64,0)
	self.ignorelock = true
	self.controller = controller
end

function ArcaneCircle:createBody(world)
	super.createBody(self,world)
	self.shape:setSensor(true)
end

function ArcaneCircle:draw()
	love.graphics.draw(img.arcanecircle,self.x,self.y,self.body:getAngle(),1,1,64,64)
end

function ArcaneCircle:add(b,coll)
	if b==GetCharacter() then
		local i = b.inventory:getItemByType'Bomb'
		local stack = 0
		if not i then
			stack = 10
		elseif i.stack<=10 then
			stack = 10-i.stack
		end
		if stack > 0 then
			local bomb = Bomb()
			b:pickUp(bomb,stack)
		end
	end
end

RotateCircle = Unit:subclass'RotateCircle'
function RotateCircle:rotateDelta(da)
	self.dt = 1
	self.da = da
end

function RotateCircle:update(dt)
	if self.dt then
		self.dt = self.dt - dt
		if self.dt <= 0 then
			self.dt = nil
		end
		self.body:setAngle(self.body:getAngle()+self.da*dt)
	end
	
end

function RotateCircle:setAngle(r)
	super.setAngle(self,r)
end

function RotateCircle:preremove()
	self.preremoved = true
	for i,v in ipairs(self.shapes) do
		v:setMask(unpack(cc.all))
	end
end

function RotateCircle:destroy()
	if self.preremoved then
		for i,v in ipairs(self.shapes) do
			v:destroy()
		end
		self.body:destroy()
	end
end

InnerCircle = RotateCircle:subclass'InnerCircle'
function InnerCircle:initialize()
	super.initialize(self,x,y,64,0)
end

function InnerCircle:createBody(world)
	local b = love.physics.newBody(world,self.x,self.y)
	self.shapes = {}
	for i=-2,8 do
		local angle = math.pi*2/12*i
		local cosr,sinr = math.cos(angle),math.sin(angle)
		local s = love.physics.newRectangleShape(b,100*cosr,100*sinr,30,30,angle)
		table.insert(self.shapes,s)
	end
	self.body = b
	if self.r then
		self.body:setAngle(self.r)
	end
end

requireImage'assets/whistler/innercircle.png'
function InnerCircle:draw()
	love.graphics.draw(img.innercircle,self.x,self.y,self.body:getAngle(),1,1,256,256)
end


MiddleCircle = RotateCircle:subclass'MiddleCircle'
function MiddleCircle:initialize()
	super.initialize(self,x,y,64,0)
end

function MiddleCircle:createBody(world)
	local b = love.physics.newBody(world,self.x,self.y)
	self.shapes = {}
	for i=-2,8 do
		local angle = math.pi*2/12*i
		local cosr,sinr = math.cos(angle),math.sin(angle)
		local s = love.physics.newRectangleShape(b,160*cosr,160*sinr,50,80,angle)
		table.insert(self.shapes,s)
	end
	self.body = b
	if self.r then
		self.body:setAngle(self.r)
	end
end

requireImage'assets/whistler/middlecircle.png'
function MiddleCircle:draw()
	love.graphics.draw(img.middlecircle,self.x,self.y,self.body:getAngle(),1,1,256,256)
end


OuterCircle = RotateCircle:subclass'OuterCircle'
function OuterCircle:initialize()
	super.initialize(self,x,y,64,0)
end

function OuterCircle:createBody(world)
	local b = love.physics.newBody(world,self.x,self.y)
	self.shapes = {}
	for i=-1,7 do
		local angle = math.pi*2/12*i
		local cosr,sinr = math.cos(angle),math.sin(angle)
		local s = love.physics.newRectangleShape(b,220*cosr,220*sinr,50,150,angle)
		table.insert(self.shapes,s)
	end
	self.body = b
	if self.r then
		self.body:setAngle(self.r)
	end
end

requireImage'assets/whistler/outercircle.png'
function OuterCircle:draw()
	love.graphics.draw(img.outercircle,self.x,self.y,self.body:getAngle(),1,1,256,256)
	--[[
	for i=-1,7 do
		local angle = math.pi*2/12*i
		local cosr,sinr = math.cos(angle),math.sin(angle)
		love.graphics.draw(img.dot,self.x+220*cosr,220*sinr+self.y,angle,50,150,0.5,0.5)
	end]]
end



LightProbeMissile = Missile:subclass'LightProbeMissile'
function LightProbeMissile:initialize(...)
	super.initialize(self,...)
end
function LightProbeMissile:draw()
end
function LightProbeMissile:add(unit,coll)
	if unit.class == StarPlate then
		if not unit.bht[self] then
			self.add = nil
			if self.effect then self.effect:effect(unit,self,self.skill) end
			unit.bht[self] = true
			self.draw = function() end
			self.persist = function() end
		end
	end
end

LightProbeEffect = UnitEffect:new()
LightProbeEffect:addAction(function (unit,caster,skill)
	unit:damage('Light',caster.unit:getDamageDealing(skill.damage,'Light'),caster)
end)

LightProbe = Skill:subclass('LightProbe')
function LightProbe:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.bullettype = LightProbeMissile
	self.name = 'LightProbe'
	self.effecttime = 0.1
	self.casttime = 0.8
	self.damage = 50
	self.effect = SkeletonShootBoltEffect
	self.bulleteffect = LightProbeEffect
	self:setLevel(level)
	self.manacost = 20
end

function LightProbe:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function LightProbe:setLevel(lvl)
	self.level = lvl
end


requireImage'assets/whistler/guardian.png'
local ox,oy = img.guardian:getWidth()/2,img.guardian:getHeight()/2
GuardianPillar = Unit:subclass'GuardianPillar'
function GuardianPillar:initialize(x,y,controller)
	super.initialize(self,x,y,32,10)
	self.hp = 100
	self.maxhp = 100
	self.controller = controller
	self.color = {math.random(255),math.random(255),math.random(255),}
	self.skills = {gun = LightProbe(self)}
	self.skills.gun.color = self.color
end

function GuardianPillar:enableAI()
	
	local ai = Sequence()
	local emitlight = Sequence()
	emitlight:push(OrderChannelSkill(
	self.skills.gun,function()
		return {normalize(self.x-Lighteffect.source.x,self.y-Lighteffect.source.y)},self,self.skills.gun
	end))
	local selector = Selector()
	selector:push(function()
		if Lighteffect.isOn() then
			return emitlight
		else
			return OrderWait(3)
		end
	end)
	ai:push(selector)
--	self.ai = ai
end

function GuardianPillar:damage(type,amount,source)
end

requireImage'beam/whiteray.png'
function GuardianPillar:draw()
	if Lighteffect.isOn() then
--		local x,y = Lighteffect.source.x,Lighteffect.source.y
		local d = getdistance(self,Lighteffect.source)
		local a = anglebetween(self,Lighteffect.source)
		love.graphics.setColor(self.color[1],self.color[2],self.color[3],math.clamp(255-d/2,0,255))
		love.graphics.draw(img.whiteray,self.x,self.y,a,500-math.clamp(d,100,500),1,1,17.5,0)
	end
	love.graphics.setColor(255,255,255)
	love.graphics.draw(img.guardian,self.x,self.y,self.body:getAngle(),1,1,ox,oy)
end

animation.starplate=Animation(love.graphics.newImage'assets/dungeon/starplate.png',64,64,0.08,1,1,32,32)
StarPlate = AnimatedUnit:subclass'StarPlate'
function StarPlate:initialize(x,y,controller)
	super.initialize(self,x,y,32,0)
	self.ignorelock = true
	self.controller = controller
	self.animation = {
		stand = animation.starplate:subSequenceIndex(1),
		flash = animation.starplate:subSequence(1,2),
	}
	self.HPRegen = 50
	self:resetAnimation()
	self.color = {math.random(255),math.random(255),math.random(255),}
	self.hp,self.maxhp=10000,10000
end

function StarPlate:createBody(world)
	super.createBody(self,world)
	self.shape:setSensor(true)
end

function StarPlate:damage(type,amount,source)
	if type == 'Light' and source.unit.color == self.color then
		super.damage(self,type,amount,source)
		gamelistener:notify{
			type = 'lighted',
			unit = self,
			source = source
		}
	end
end

function StarPlate:update(dt)
	
	if self.hp<self.maxhp then
		self:playAnimation('flash',1,true,true)
		self.lighted = true
	else
		self:resetAnimation()
		self.lighted = nil
	end
	super.update(self,dt)
end

function StarPlate:draw()
	love.graphics.setColor(self.color)
	super.draw(self)
	love.graphics.setColor(255,255,255)
end


requireImage'assets/whistler/floorsymbol.png'
FloorSymbol = Unit:subclass'FloorSymbol'
function FloorSymbol:initialize(x,y,controller)
	super.initialize(self,x,y,64,0)
	self.ignorelock = true
	self.controller = controller
end

function FloorSymbol:createBody(world)
	super.createBody(self,world)
	self.shape:setSensor(true)
end

function FloorSymbol:draw()
	love.graphics.draw(img.floorsymbol,self.x,self.y,self.body:getAngle(),1,1,128,32)
end
