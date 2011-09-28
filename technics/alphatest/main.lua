fb = love.graphics.newFramebuffer()
function love.draw()
	love.graphics.setRenderTarget(fb)
	love.graphics.setBackgroundColor(0,0,0,255)
	love.graphics.clear()
--	love.graphics.setColorMode'replace'
	love.graphics.setColor(255,255,255,100)
	love.graphics.circle('fill',300,300,100,36)
	love.graphics.setColor(255,255,255,255)
	love.graphics.setRenderTarget()
	love.graphics.draw(fb)
end