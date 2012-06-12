
--local vancouver = require 'scenes.vancouver.vancouver'
require 'cutscene.cutscene'
preload('assassin','commonenemies','tibet','vancouver','kingofdragons')

local Waterfallbg={}
function Waterfallbg:update(dt)
end

requireImage('assets/vancouver/waterfall.png','waterfall')
function Waterfallbg:draw()
	love.graphics.draw(img.waterfall,0,300,0,2,2,300,150)
	love.graphics.push()
	love.graphics.translate(-600,-600)
	self.m:draw()
	love.graphics.pop()
end

Waterfall = Map:subclass'Waterfall'
function Waterfall:initialize()
	local w = 1200
	local h = w
	self.w,self.h=w,h
	super.initialize(self,w,h)
	local m = self:loadTiled'meditation.tmx'
	Waterfallbg.m = m
	self.background = Waterfallbg
end

function Waterfall:destroy()
	self.exitTrigger:destroy()
end

function Waterfall:draw()
	dragongate.predraw()
	super.draw(self)
end

function Waterfall:opening_load()
	local leon = Assassin:new(10,10,32,10)
	leon.direction = {0,-1}
	leon.controller = 'player'
	map:addUnit(leon)
	SetCharacter(leon)
	map.camera = FollowerCamera:new(leon,{
		x1 = -600+screen.halfwidth,
		y1 = -600+screen.halfheight,
		x2 = 600-screen.halfwidth,
		y2 = 600-screen.halfheight
	})
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
	leon2.interact = require 'scenes.vancouver.swift-visit-1'
end

function Waterfall:enter_load(character)
	character = character or GetCharacter()
	assert(character)
	character.x,character.y = 0,-200
	map:addUnit(character)
	map.camera = FollowerCamera:new(character,{
		x1 = -600+screen.halfwidth,
		y1 = -600+screen.halfheight,
		x2 = 600-screen.halfwidth,
		y2 = 600-screen.halfheight
	})
	self:enter_loaded()
end

function Waterfall:enter_loaded()
	if GetCharacter().class == Assassin then
		self:wake_loaded()
	else
		local leon2 = KingOfDragons()--GetGameSystem():loadobj 'Assassin'
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

function Waterfall:wake_load()
	local leon2 = KingOfDragons()--GetGameSystem():loadobj 'Assassin'
	leon2.x,leon2.y = 0,0
	leon2.direction = {0,-1}
	leon2.controller = 'player'
	map:addUnit(leon2)
	SetCharacter(leon2)
	self:wake_loaded()
	map.camera = FollowerCamera:new(leon2,{
		x1 = -600+screen.halfwidth,
		y1 = -600+screen.halfheight,
		x2 = 600-screen.halfwidth,
		y2 = 600-screen.halfheight
	})
	leon2.inventory:addItem(Theravada(100,100))
	leon2.inventory:addItem(Cloak(100,100))
end

function Waterfall:wake_loaded()
	self:addUnit(Mat(0,150,60,5))
	
	self.exitTrigger = Trigger(function(self,event)
		if event.index == 'exit' and event.unit == GetCharacter() then
			pushsystem(vancouver)
			vancouver:zoomOutCity'vancouver'
		end
	end)
	self.exitTrigger:registerEventType('add')
	local u = IALSwordsman(0,0,'enemy')
	u:enableAI()
end

function Waterfall:load(x,y,c)
	self:wake_load()
end

function scenetest()
	local u = HealthPotion(100,0)
	map:addUnit(u)
	u = EnergyPotion(0,100)
	map:addUnit(u)
	u = Catalyst(100,100)
	map:addUnit(u)
	u = MistyCloud(-100,100)
	map:addUnit(u)
	u = TrollPotion(-100,-100)
	map:addUnit(u)
	u = FinalRadiance(100,-100)
	map:addUnit(u)
	u = TempestWeapon(-300,0)
	map:addUnit(u)
	u = CVolcanoWeapon(-200,0)
	map:addUnit(u)
	u = MournWeapon(-100,0)
	map:addUnit(u)
	u = IALSwordsman(0,-300,'enemy')
	map:addUnit(u)
end