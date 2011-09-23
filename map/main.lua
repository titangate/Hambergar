require 'MiddleClass'
require 'globalmap'

local blurbuffer = love.graphics.newFramebuffer()
map = GlobalMap:new()
function love.update(dt)
	map:update(dt)
end

function love.draw()
	love.graphics.setColor(255,255,255,255)
	love.graphics.setRenderTarget(blurbuffer)
	love.graphics.setColor(255,255,255,255)
	map:draw()
	love.graphics.setRenderTarget()
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(blurbuffer)
end

function love.keypressed(k)
	if k=='1' then
		map:zoomInCity('vancouver')
	elseif k=='2' then
		map:zoomOutCity('vancouver')
	end
end