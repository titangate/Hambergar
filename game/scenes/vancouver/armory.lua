
--local vancouver = require 'scenes.vancouver.vancouver'
require 'cutscene.cutscene'


local Armorybg={}
function Armorybg:update(dt)
end

function Armorybg:draw()
	love.graphics.push()
	love.graphics.translate(-800,-800)
	self.m:draw()
	love.graphics.pop()
end

Armory = Map:subclass('Armory')
function Armory:initialize()
	local w = 1600
	local h = w
	self.w,self.h=w,h
	super.initialize(self,w,h)
	local m = self:loadTiled'armory.tmx'
	Armorybg.m = m
	self.background = Armorybg
--	self:addUnit(Brandon(0,-150,24,5))
	self.exitTrigger = Trigger(function(self,event)
		if event.index == 'exit' then
			pushsystem(vancouver)
			vancouver:zoomOutCity('vancouver')
		end
	end)
	self.exitTrigger:registerEventType('add')
end

function Armory:destroy()
	self.exitTrigger:destroy()
end

function Armory:enter_load(character)
	character = character or GetCharacter()
	assert(character)
	character.x,character.y = unpack(self.waypoints.spawningpoint)
	map:addUnit(character)
	map.camera = FollowerCamera:new(character,{
		x1 = -800+screen.halfwidth,
		y1 = -800+screen.halfheight,
		x2 = 800-screen.halfwidth,
		y2 = 800-screen.halfheight
	})
	self:enter_loaded()
end

function Armory:enter_loaded()
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

function Armory:wake_loaded()
	
end

function Armory:load(x,y,c)
	
end