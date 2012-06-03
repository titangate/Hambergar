--require ('objectlua')
--Object = objectlua.Object
require 'MiddleClass'
require 'MindState'


fonts = {}
fonts.default24 = love.graphics.newFont(24)
fonts.oldsans12 = love.graphics.newFont(  'oldsansblack.ttf', 12)
fonts.oldsans20 = love.graphics.newFont('oldsansblack.ttf', 20)
fonts.oldsans24 = love.graphics.newFont('oldsansblack.ttf', 24)
fonts.oldsans32 = love.graphics.newFont('oldsansblack.ttf', 32)
fonts.bigfont = love.graphics.newFont("awesome.ttf",25)
fonts.midfont = love.graphics.newFont("awesome.ttf",19)
fonts.smallfont = love.graphics.newFont("awesome.ttf",13)
require 'libraries.system'
require "libraries.mainmenu"
require 'libraries.controller'
require 'libraries.TEsound'
require ('libraries.camera')
require ('libraries/scene')
require ('libraries/unit')
require 'libraries.animatedactor'
require ('libraries/buff')
require ('libraries/ai')
require "libraries.tutorial"
require ('libraries/skill')
require ('libraries/skilleffect')
require ('libraries/missile')
require ('libraries/button')
require ('libraries/particles')
require ('libraries/hud')
require ('abilities/init')
require ('units/init')
require ('libraries/timer')
require "libraries.uiitem"
require "libraries.item"
require 'libraries.weapon'
require "libraries.tilemap"
require "libraries.sound"
require 'scenes.init'
require "items.init"
require "libraries.conversation"
require "libraries.filter"
require "libraries.filtermanager"
--require "editor.init"
require 'libraries.TEsound'
--require 'libraries.stealth'
goo=require "goo.goo"
anim = require "anim.anim"
Blureffect = require 'libraries.blur'
Lighteffect = require 'libraries.vl'
require 'units.init'
require 'cutscene.cutscene'
require 'sampleshader'

local gametimers = {}
screen = {
	width = love.graphics.getWidth(),
	height = love.graphics.getHeight(),
	halfwidth = love.graphics.getWidth()/2,
	halfheight = love.graphics.getHeight()/2,
	w = love.graphics.getWidth(),
	h = love.graphics.getHeight(),
}

playable = {
	width = screen.width,
	height = screen.height - 100,
	halfwidth = screen.width/2,
	halfheight = screen.height/2 - 50,
}

options = {
	aimassist = true,
	usecontroller = false, -- unimplemented
	blureffect = true, -- unimplemented
}

-- This stores conversation data.
storydata = {
	daysbeforeinvasion = 1,
	swift = {
		
	},
}

function DBGTABLE(t)
	print ('Contents for t',t)
	for k,v in pairs(t) do
		print (k,v)
	end
end

debugmessages = {}
function DBGMSG(msg,time)
	time = time or 0
	debugmessages[msg] = time
end
function DBGMSG2(time,msg)
	time = time or 1
	debugmessages[msg] = time
end
local p=print
function print(...)
	p(...)
end
gamesystems = {}
function pushsystem(system)
	if gamesystems[#gamesystems] and gamesystems[#gamesystems].poped then gamesystems[#gamesystems]:poped() end
	table.insert(gamesystems,system)
	if system.pushed then system:pushed() end
	currentsystem = system
	SetGameSystem(system)
end

function popsystem()
	if currentsystem.poped then currentsystem:poped() end
	table.remove(gamesystems)
	currentsystem = gamesystems[#gamesystems]
	if currentsystem.pushed then currentsystem:pushed() end
	SetGameSystem(currentsystem)
end

function pause(state)
	pausing = state
end

function SetGameSystem(gs)
	gamesystem = gs
end

function GetGameSystem()
	return gamesystem
end
--[[
steptime = 1/60
function love.run()
	love.load(arg)
	local dt = 0
	while true do
		love.timer.step()
		dt = love.timer.getDelta()
		love.update(steptime)
		-- Render
		love.graphics.clear()
		love.draw()
		-- Process events
		for e,a,b,c in love.event.poll() do
			if e == "q" then
				if not love.quit or not love.quit() then
					love.audio.stop()
					return
				end
			end
			love.handlers[e](a,b,c)
		end
--		love.timer.sleep()
		print (dt)
		if dt<steptime then love.timer.sleep(steptime-dt) end	-- fixed FPS
		love.graphics.present()
	end
end]]

requireImage( 'gameicon.png','gameicon' )
function love.load()
	goo:load()
	f=love.graphics.newFont("awesome.ttf",20)
	love.graphics.setFont(f)
	love.graphics.setIcon(img.gameicon)
	pushsystem(MainMenu)
--	UI.load()
	mainmenu = require "mainmenu.mainmenu"
	mainmenu:birth()
	smallfont = fonts.smallfont--love.graphics.newFont("awesome.ttf",12)
	bigfont = fonts.bigfont--love.graphics.newFont("awesome.ttf",25)
	if love.joystick.isOpen(0) then
--		controller = XBOX360Controller:new(0)
	end
	
	filtermanager = FilterManager()
	
	filtermanager:loadFilters('filters/')
	filtermanager:setFilterArguments('Shockwave',{center = {0.5,0.3}})
	filtermanager:setFilterArguments('Blackhole',{center = {0.5,0.6},radius = 0.2})
	
	hazenormal = love.graphics.newImage'heathaze.png'
	hazenormal:setWrap('repeat','repeat')
	gbmask = love.graphics.newImage'oval.png'
	
	filtermanager:setFilterArguments('Heathaze',{normal = hazenormal})
	filtermanager:setFilterArguments('Gaussianblur',{mask = gbmask})
end

function revertFont()
	love.graphics.setFont(f)
end

effects = {}
function love.keypressed(k,unicode)
	
	if currentsystem.keypressed then currentsystem:keypressed(k) end
	goo:keypressed(k,unicode)
	k = tonumber(k)
	if k then
		na = filtermanager.filterindex[k]
		filtermanager:reset()
		effects[na] = not effects[na]
		DBGMSG(na.." is "..tostring(effects[na]),1)
	end
end

function love.keyreleased(k,unicode)
	if currentsystem.keyreleased then currentsystem:keyreleased(k) end
	goo:keyreleased(k,unicode)
end

function love.mousepressed(x,y,k)
	if currentsystem.mousepressed then currentsystem:mousepressed(x,y,k) end
	goo:mousepressed(x,y,k)
	goo:keypressed(k..'b',-1)
end

function love.mousereleased(x,y,k)
	if currentsystem.mousereleased then currentsystem:mousereleased(x,y,k) end
	goo:mousereleased(x,y,k)
	goo:keyreleased(k..'b',-1)
end

function love.update(dt)
	for v,active in pairs(effects) do
		if active then
			filtermanager:requestFilter(v)
		end
	end
	
	for msg,time in pairs(debugmessages) do
		
		if time < 0 then
			debugmessages[msg] = nil
		else
			
			debugmessages[msg] = time - dt
		end
	end
	filtermanager:update(dt)
	if pausing then return end
	controller:update(dt)
	currentsystem:update(dt)
	goo:update(dt)
	anim:update(dt)
	TEsound.cleanup()
end

--local blurbuffer = love.graphics.newFramebuffer()
function love.draw()
	love.graphics.setColor(255,255,255)
	revertFont()
	
--	local d = function()
		currentsystem:draw()
--	end
--	filtermanager:draw(d)
	local height = 10
	for msg,time in pairs(debugmessages) do
		love.graphics.print(msg,10,height)
		height = height + 15
	end
	love.graphics.setColor(255,255,255,255)
	love.graphics.setFont(fonts.oldsans24)
	love.graphics.print(love.timer.getFPS(),screen.width-100,30)
end



