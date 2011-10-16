require 'MiddleClass'
require 'MindState'
goo = require 'goo.goo'
anim = require 'anim.anim'
style = require 'anim.style'
editor = require 'editor'

screen = {
	width = love.graphics.getWidth(),
	height = love.graphics.getHeight(),
	halfwidth = love.graphics.getWidth()/2,
	halfheight = love.graphics.getHeight()/2,
}

function editor.getScene()
	return c
end

function love.update(dt)
	goo:update(dt)
	anim:update(dt)
end

function love.load()
	goo:load()
	love.graphics.setBackgroundColor(255,255,255)
	editor.load()
	editor.selectObject(a)
	
end

function love.draw()
	love.graphics.setColor(255,255,255)
	love.graphics.push()
	c:draw()
	love.graphics.pop()
	love.graphics.setColor(0,0,0)
	love.graphics.print(c.frame,10,10)
	love.graphics.setColor(255,255,255)
	goo:draw()
end

f = 0

function love.keypressed( key, unicode )
	goo:keypressed( key, unicode )
end

function love.keyreleased( key, unicode )
	goo:keyreleased( key, unicode )
end

function love.mousepressed( x, y, button )
	goo:mousepressed( x, y, button )
end

function love.mousereleased( x, y, button )
	goo:mousereleased( x, y, button )
end
