--require ('objectlua')
--Object = objectlua.Object
require 'goo.MiddleClass'
require 'goo.MindState'
--[[
require ('libraries/camera.lua')
require ('libraries/scene.lua')
require ('libraries/unit.lua')
require 'libraries.animatedactor'
require ('libraries/skill.lua')
require ('libraries/skilleffect.lua')
require ('libraries/missile.lua')
require ('libraries/button.lua')
require ('libraries/particles.lua')
require ('libraries/buff.lua')
require ('libraries/ai.lua')
require ('libraries/hud.lua')
require ('abilities/init.lua')
require ('units/init.lua')
require ('libraries/timer.lua')
require ('libraries/system.lua')
require "libraries.uiitem"
require "libraries.item"
require "libraries.tilemap"
require "libraries.sound"
require 'scenes.init'
require "items.init"
require "libraries.tutorial"
require "libraries.conversation"
require "editor.init"
require 'libraries.TEsound']]
goo=require "goo.goo"
anim = require "anim.anim"

require "libraries.mainmenu"
require 'libraries.controller'
require 'libraries.TEsound'
screen = {
	width = love.graphics.getWidth(),
	height = love.graphics.getHeight(),
	halfwidth = love.graphics.getWidth()/2,
	halfheight = love.graphics.getHeight()/2,
}

playable = {
	width = screen.width,
	height = screen.height - 100,
	halfwidth = screen.width/2,
	halfheight = screen.height/2 - 50,
}

gamesystems = {}
function pushsystem(system)
	if gamesystems[#gamesystems] and gamesystems[#gamesystems].poped then gamesystems[#gamesystems]:poped() end
	table.insert(gamesystems,system)
	if system.pushed then system:pushed() end
	currentsystem = system
end

function popsystem()
	if currentsystem.poped then currentsystem:poped() end
	table.remove(gamesystems)
	currentsystem = gamesystems[#gamesystems]
	if currentsystem.pushed then currentsystem:pushed() end
end

function pause(state)
	pausing = state
end

function SetGameSystem(gs)
	assert(gs)
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

gameicon = love.graphics.newImage('gameicon.png')
function love.load()
	goo:load()
	f=love.graphics.newFont("awesome.ttf",20)
	love.graphics.setFont(f)
	love.graphics.setIcon(gameicon)
	pushsystem(MainMenu)
--	UI.load()
	mainmenu = require "mainmenu.mainmenu"
	mainmenu:birth()
	smallfont = fonts.smallfont--love.graphics.newFont("awesome.ttf",12)
	bigfont = fonts.bigfont--love.graphics.newFont("awesome.ttf",25)
	if love.joystick.isOpen(0) then
		controller = XBOX360Controller:new(0)
	end
end

function revertFont()
	love.graphics.setFont(f)
end

function love.keypressed(k,unicode)
	if currentsystem.keypressed then currentsystem:keypressed(k) end
	goo:keypressed(k,unicode)
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
	if pausing then return end
	controller:update(dt)
	currentsystem:update(dt)
	goo:update(dt)
	anim:update(dt)
	TEsound.cleanup()
end

function love.draw()
	revertFont()
	love.graphics.setColor(255,255,255,255)
	currentsystem:draw()
end

