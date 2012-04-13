require 'MiddleClass'
require 'ShaderEffect'
require 'effect.shockwave'
require 'effect.blackhole'
require 'effect.zoomblur'
require 'effect.normal'
--require 'shader.zoomblur'
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
	--	radius = 0.3,
	}
	zb = ZoomblurEffect()
	zb:setParameter{
		center = {0.5,0.5},
	}
	
	hazenormal = love.graphics.newImage'effect/heathaze.png'
	hazenormal:setWrap('repeat','repeat')
	hz = HeathazeEffect()
	hz:setParameter{
		normal = hazenormal,
	}
	shaders = {s,bh,zb,hz}
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
