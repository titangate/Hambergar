 require 'scenes.vancouver.vancouver'
local vancouver = VancouverMap()
require 'cutscene.cutscene'
preload('assassin','swift','commonenemies','tibet','vancouver')


local Waterfallbg={}
function Waterfallbg:update(dt)
end

requireImage('assets/vancouver/waterfall.png','waterfall',vancouverbg)
function Waterfallbg:draw()
	love.graphics.draw(vancouverbg.waterfall,0,300,0,2,2,300,150)
	love.graphics.push()
	love.graphics.translate(-600,-600)
	self.m:draw()
	love.graphics.pop()
--	love.graphics.draw(vancouverbg.mat,0,150,0,1,1,64,64)
end

Waterfall = Map:subclass('Waterfall')
function Waterfall:initialize()
	local w = 1200
	local h = w
	self.w,self.h=w,h
	super.initialize(self,w,h)
	local m = self:loadTiled'meditation.tmx'
	Waterfallbg.m = m
	self.background = Waterfallbg
	self:addUnit(Mat(0,150,60,5))
	self:addUnit(PotionMaster(0,-150,60,5))
	self.exitTrigger = Trigger(function(self,event)
		if event.index == 'exit' then
			pushsystem(vancouver)
			vancouver:zoomOutCity('vancouver')
		end
	end)
	self.exitTrigger:registerEventType('add')
end

function Waterfall:destroy()
	self.exitTrigger:destroy()
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
	assert(character)
	character.x,character.y = 0,-200
	map:addUnit(character)
	map.camera = FollowerCamera:new(character,{
		x1 = -600+screen.halfwidth,
		y1 = -600+screen.halfheight,
		x2 = 600-screen.halfwidth,
		y2 = 600-screen.halfheight
	})
	sefl:enter_loaded()
end

function Waterfall:enter_loaded()
	if GetCharacter().class == Assassin then
		self:wake_loaded()
	else
		local leon2 = GetGameSystem():loadobj 'Assassin'
		leon2.x,leon2.y = 0,0
		leon2.direction = {0,-1}
		leon2.controller = 'player'
		leon2:gotoState'npc'
		map:addUnit(leon2)
--		if GetCharacter().class == Swift then
--			if story.daysbeforeinvasion == 1 then
				leon2.interact = require 'scenes.vancouver.swift-visit-1'
--			end
--		end
	end
end

function Waterfall:wake_load()
	local leon2 = GetGameSystem():loadobj 'Assassin'
	leon2.x,leon2.y = 0,0
	leon2.direction = {0,-1}
	leon2.controller = 'player'
	map:addUnit(leon2)
	SetCharacter(leon2)
	GetCharacter().skills.weaponskill:gotoState'interact'
	self:wake_loaded()
end

function Waterfall:wake_loaded()
	
end

function Waterfall:load(x,y,c)
	
end