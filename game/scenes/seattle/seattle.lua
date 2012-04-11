require 'scenes.seattle.seattlebackground'
preload('electrician','commonenemies','seattle')
Seattle = Map:subclass('Seattle')
function Seattle:initialize()
	local w = 4096
	local h = w
	self.w,self.h=w,h
	super.initialize(self,w,h)
	self.background = SeattleBackground()
	
	local m = self:loadTiled'seattle.tmx'
	self.background.m = m
end

function Seattle:destroy()
end

function Seattle:load()
	local leon2 = GetGameSystem():loadobj 'Electrician'
	leon2.x,leon2.y = 0,0
	leon2.direction = {0,-1}
	leon2.controller = 'player'
	map:addUnit(leon2)
	SetCharacter(leon2)
	self:wake_loaded()
	map.camera = FollowerCamera:new(leon2,{
		x1 = -self.w/2+screen.halfwidth,
		y1 = -self.w/2+screen.halfheight,
		x2 = self.h/2-screen.halfwidth,
		y2 = self.h/2-screen.halfheight
	})
	local h = Tank()
	h.controller = 'enemy'
	map:addUnit(h)
	h:enableAI()
end

function Seattle:enter_loaded()
end

function Seattle:wake_loaded()
	
end