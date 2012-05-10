
require 'cutscene.cutscene'
preload('assassin','commonenemies','tibet','masteryuen')

local Mansionbg={}
function Mansionbg:update(dt)
end

requireImage('assets/vancouver/waterfall.png','waterfall')
function Mansionbg:draw()
	love.graphics.draw(img.waterfall,0,300,0,2,2,300,150)
	love.graphics.push()
	love.graphics.translate(-600,-600)
	self.m:draw()
	love.graphics.pop()
end

Mansion = Map:subclass'Mansion'
function Mansion:initialize()
	local w = 1200
	local h = w
	self.w,self.h=w,h
	super.initialize(self,w,h)
	local m = self:loadTiled'meditation.tmx'
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

function Mansion:enter_load(character)
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
end

function Mansion:wake_loaded()
	my=MasterYuen()
	map:addUnit(my)
end

function Mansion:load(x,y,c)
	self:wake_load()
end


function scenetest()
	GetCharacter():dash(100,100)
end
