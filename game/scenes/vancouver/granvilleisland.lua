
--local vancouver = require 'scenes.vancouver.vancouver'
--require 'cutscene.cutscene'
--preload('assassin','swift','commonenemies','tibet','vancouver')

local GranvilleIslandbg={}
function GranvilleIslandbg:update(dt)
end

function GranvilleIslandbg:draw()
	love.graphics.push()
	love.graphics.translate(-640,-640)
	self.m:draw()
	love.graphics.pop()
end

GranvilleIsland = Map:subclass('GranvilleIsland')
function GranvilleIsland:initialize()
	local w = 1280
	local h = w
	self.w,self.h=w,h
	super.initialize(self,w,h)
	local m = self:loadTiled'granvilleisland.tmx'
	GranvilleIslandbg.m = m
	self.background = GranvilleIslandbg
	self:addUnit(PotionMaster(0,-150,24,5))
	self.exitTrigger = Trigger(function(self,event)
		if event.index == 'exit' then
			pushsystem(vancouver)
			vancouver:zoomOutCity('vancouver')
		end
	end)
	self.exitTrigger:registerEventType('add')
end

function GranvilleIsland:destroy()
	self.exitTrigger:destroy()
end

function GranvilleIsland:enter_load(character)
	character = character or GetCharacter()
	assert(character)
	character.x,character.y = 0,-200
	map:addUnit(character)
	map.camera = FollowerCamera:new(character,{
		x1 = -640+screen.halfwidth,
		y1 = -640+screen.halfheight,
		x2 = 640-screen.halfwidth,
		y2 = 640-screen.halfheight
	})
	self:enter_loaded()
end

function GranvilleIsland:enter_loaded()
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

function GranvilleIsland:wake_loaded()
	
end

function GranvilleIsland:load(x,y,c)
	
end