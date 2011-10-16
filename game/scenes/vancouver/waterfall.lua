require 'scenes.vancouver.vancouver'
require 'cutscene.cutscene'
preload('assassin','swift','commonenemies','tibet','vancouver')

local conv = {
	greet = {
		[3] = {'What do you seek?',5},
		[12] = {"So, I was told you were the infamous Compass Assassin River.",8}
	},
	story = {
		[0] = {'Why did you end up joining us?',5},
		[6] = {"Because they took the sole reason i lived for, and Now I'm making them pay.",8},
	},
}

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
end

function Waterfall:opening_load()
	local leon = Assassin:new(10,10,32,10)
	leon.direction = {0,-1}
	leon.controller = 'player'
	map:addUnit(leon)
	SetCharacter(leon)
	map.camera = FollowerCamera:new(leon)
	controller:setLockAvailability(true)
	GetCharacter().skills.weaponskill:gotoState'interact'
	
	local leon2 = Assassin(100,10,32,10)
	leon2.direction = {0,-1}
	leon2:gotoState'npc'
	map:addUnit(leon2)
	leon2.interact = function(self)
		GetCharacter():gotoState'npc'
		SetCharacter(leon2)
		GetGameSystem().bottompanel:fillPanel(GetCharacter():getSkillpanelData())
		GetGameSystem().bottompanel:setPos(screen.halfwidth-512,screen.height - 150)
		GetCharacter().skills.weaponskill:gotoState'interact'
		leon2:gotoState()
		map.camera = FollowerCamera(leon2)
		local c = require 'cutscene.swift-assassin-visit1.cutscene'
		local c_talk = require 'cutscene.swift-assassin-visit1.rivertalking'
		local cp = CutscenePlayer(c)
		cp:playConversation(conv.greet)
		local choices = {
			'STORY',
			'MEDITATION',
			'SWITCH'
		}
		cp.onFinish = function(self)
			cp:setChoice(choices)
			n = cp:getChoice()
			if n == 1 then
				cp:play(c_talk)
				cp:playConversation(conv.story)
			end
		end
		pushsystem(cp)
	end
end

function Waterfall:enter_load(character)
	assert(character)
	character.x,character.y = 0,-200
	map:addUnit(character)
	map.camera = FollowerCamera:new(character)
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
		leon2.interact = function(self)
			GetCharacter():gotoState'npc'
			SetCharacter(leon2)
			GetCharacter().skills.weaponskill:gotoState'interact'
			leon2:gotoState()
			map.camera = FollowerCamera(leon2)
		end
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