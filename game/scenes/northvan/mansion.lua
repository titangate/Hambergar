
require 'cutscene.cutscene'
preload('assassin','commonenemies','tibet','masteryuen')

local Mansionbg={}
function Mansionbg:update(dt)
end

requireImage('assets/vancouver/waterfall.png','waterfall')
function Mansionbg:draw()
--	love.graphics.draw(img.waterfall,0,300,0,2,2,300,150)
	love.graphics.push()
	love.graphics.translate(-720,-1024)
	self.m:draw()
	love.graphics.pop()
end

local mantrabg = {
	time = 0,
}
function mantrabg:update(dt)
	self.time = self.time + dt
end

requireImage'assets/northvan/hellup.png'
requireImage'assets/northvan/eye.png'
requireImage'assets/northvan/hellspinarm.png'
requireImage'assets/northvan/mantra1.png'
requireImage'assets/northvan/mantra2.png'
requireImage'assets/northvan/mantra3.png'
function mantrabg:draw()
	love.graphics.push()
--	love.graphics.scale(0.5)
	if self.time > 3 then
		love.graphics.setColor(0,0,0)
	else
		love.graphics.push()
		love.graphics.scale(1-self.time/3)
		Mansionbg:draw()
		love.graphics.setColor(0,0,0,self.time*255/3)
		love.graphics.pop()
	end
	love.graphics.draw(img.dot,0,0,0,100000,100000,0.5,0.5)
	love.graphics.setColor(255,255,255,math.min(255,self.time*255/3))
	love.graphics.draw(img.hellspinarm,0,0,self.time,2,2,256,256)
	love.graphics.draw(img.hellspinarm,0,0,-self.time,2,2,256,256)
	love.graphics.draw(img.hellup,0,0,self.time/3,2,2,256,256)
	love.graphics.draw(img.eye,0,0,0,0.5,0.5,1164/2,588/2)
	
	love.graphics.draw(img.mantra1,0,0,self.time,2,2,256,256)
	love.graphics.draw(img.mantra2,0,0,-self.time,2,2,256,256)
	love.graphics.draw(img.mantra3,0,0,self.time,2,2,256,256)
	love.graphics.pop()
end

Mansion = Map:subclass'Mansion'
function Mansion:initialize()
	local w = 1440
	local h = 2048
	self.w,self.h=w,h
	super.initialize(self,w,h)
	local m = self:loadTiled'mansion.tmx'
	assert(m)
	Mansionbg.m = m
	self.background = Mansionbg
end

function Mansion:destroy()
	self.exitTrigger:destroy()
end

function Mansion:opening_load()
	local leon = Assassin:new(10,10,32,10)
	leon.direction = {0,-1}
	leon.controller = 'player'
	map:addUnit(leon)
	SetCharacter(leon)
	controller:setLockAvailability(true)
	GetCharacter().skills.weaponskill:gotoState'interact'
	local inv = GetCharacter().inventory
	inv:addItem(FiveSlash())
	inv:addItem(PeacockFeather:new())
	inv:addItem(BigHealthPotion:new())
	local leon2 = Assassin(100,10,32,10)
	leon2.direction = {0,-1}
	leon2:gotoState'npc'
	leon2.controller = 'player'
	map:addUnit(leon2)
	self:loadDefaultCamera(leon2)
	leon2.interact = require 'scenes.vancouver.swift-visit-1'
	
	
end

function Mansion:enter_load(character)
	character = character or GetCharacter()
	assert(character)
	character.x,character.y = 0,-200
	map:addUnit(character)
	self:enter_loaded()
	self:loadDefaultCamera(character)
end

function Mansion:enterMantra()
	self.background = mantrabg
end

function Mansion:enter_loaded()
	if GetCharacter().class == Assassin then
		self:wake_loaded()
	else
		local leon2 = GetGameSystem():loadobj 'Assassin'
		leon2.x,leon2.y = 0,0
		leon2.direction = {0,-1}
		leon2.controller = 'player'
		leon2:gotoState'npc'
		map:addUnit(leon2)
		leon2.interact = require 'scenes.vancouver.swift-visit-1'
	end
	self:addUnit(Mat(0,150,60,5))
	
	self.exitTrigger = Trigger(function(self,event)
		if event.index == 'exit' and event.unit == GetCharacter() then
			pushsystem(vancouver)
			vancouver:zoomOutCity'vancouver'
		end
	end)
	self.exitTrigger:registerEventType('add')
	
end

function Mansion:wake_load()
	local leon2 = GetGameSystem():loadobj 'Assassin'
	leon2.x,leon2.y = 200,0
	leon2.direction = {0,-1}
	leon2.controller = 'player'
	map:addUnit(leon2)
	SetCharacter(leon2)
	self:wake_loaded()
	self:loadDefaultCamera(leon2)
end

function Mansion:wake_loaded()
	my=MasterYuen()
	my.controller = 'enemy'
	map:addUnit(my)
end

function Mansion:load(x,y,c)
	self:wake_load()
end

function testimg()
	local img  = MasterYuenImage(-300,-300)
	img.controller = 'enemy'
	map:addUnit(img)
	img:enableAI()
end

function scenetest()
--	testimg()
--	map.camera = ContainerCamera:new(200,nil,my,GetCharacter())
	GetGameSystem().bossbar = AssassinHPBar:new(function()return my:getHPPercent() end,screen.halfwidth-400,screen.height-100,800)
	local self = my

	map:addUpdatable(CraneCircleP3(GetCharacter(),my))
--	self.skills.fistp3.effect:effect({math.cos(self.body:getAngle()),math.sin(self.body:getAngle())},self,self.skills.fistp1)
	--my:enableAI()
--	my.ai = my:phase2()
--	my:phase3()
--	my.mantra.level = 2
--	my:setImmunity'reflect'
--	local target,hans = GetCharacter(),my
--	my.skills.kickp3.effect:effect({normalize(target.x-hans.x,target.y-hans.y)},hans,hans.skills.kickp3)
	--my:face(GetCharacter())
	--[[
	local c = math.random(3)
	if c==1 then
	my:dashStrike('crane',2000,0.3)
elseif c==2 then
	my:dashStrike('kick',2000,0.25)
else
	my:dashStrike('fist',2500,0.5)
end]]
--	GetCharacter():dash(100,100)

end
