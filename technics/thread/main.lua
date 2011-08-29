t = love.thread.newThread('loadingthread','sub.lua')
function love.update(dt)
end

function love.keypressed(k)
	if k=='t' then
		t:start()
	end
end

function love.draw()
end