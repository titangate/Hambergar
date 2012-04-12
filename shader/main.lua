require 'MiddleClass'
require 'ShaderEffect'
require 'shader.shockwave'
require 'shader.blackhole'
function love.load()
	img = love.graphics.newImage('demo.jpg')
	s = ShockwaveEffect()
	s:setParameter{
		center = {0.5,0.5},
		shockParams = {10,0.8,0.1},
	}
	bh = BlackholeEffect()
	bh:setParameter{
		center = {0.5,0.5},
		radius = 0.3,
	}
	zb = Zoom
	shaders = {s,bh,zb}
	id = 1
end

function love.update(dt)
	shaders[id]:update(dt)
end

function love.draw()
	shaders[id]:predraw()
	love.graphics.draw(img)
	shaders[id]:postdraw()
end

function love.mousepressed(x,y)
	shaders[id].time = 0
	shaders[id]:setParameter{
		center = {x/1024,1-y/1024}
	}
end

function love.keypressed(b)
	b = tonumber(b)
	if shaders[b] then
		id = b
	end
end
