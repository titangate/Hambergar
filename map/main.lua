require 'MiddleClass'
require 'globalmap'
require 'blur'

screen = {
	width = love.graphics.getWidth(),
	height = love.graphics.getHeight(),
	halfwidth = love.graphics.getWidth()/2,
	halfheight = love.graphics.getHeight()/2,
}

local blurbuffer = love.graphics.newFramebuffer()
map = GlobalMap:new()
function love.update(dt)
	map:update(dt)
	Blureffect.update(dt)
end

function love.draw()
	Blureffect.begin('zoom')
	map:draw()
	Blureffect.finish()
end

function love.keypressed(k)
	if k=='1' then
		map:zoomInCity('vancouver')
		Blureffect.blur('zoom',{},0,2.3)
	elseif k=='2' then
		map:zoomOutCity('vancouver')
		Blureffect.blur('zoom',{},0,2.3)
	end
end