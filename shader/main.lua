require 'MiddleClass'
require 'ShaderEffect'
require 'shader.shockwave'
function love.load()
	img = love.graphics.newImage('demo.png')
	s = ShockwaveEffect()
	s:setParameter{
		center = {0.5,0.5},
		shockParams = {10,0.8,0.1},
	}
end

function love.update(dt)
	s:update(dt)
end

function love.draw()
	s:predraw()
	love.graphics.draw(img)
end

function love.keypressed()
	s.time = 0
end