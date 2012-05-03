require 'MiddleClass'
require 'effect.filter'
require 'effect.filtermanager'
screen = {
	w = love.graphics.getWidth(),
	h = love.graphics.getHeight(),
	quad = love.graphics.newQuad(0,0,love.graphics.getWidth(),love.graphics.getHeight(),math.max(
	love.graphics.getWidth(),love.graphics.getHeight()),math.max(
	love.graphics.getWidth(),love.graphics.getHeight()))
}
debugmessages = {}
function DBGMSG(msg,time)
	time = time or 0
	debugmessages[msg] = time
end
function love.load()
	filtermanager = FilterManager()
	
	img = love.graphics.newImage('dream.png')
	filtermanager:loadFilters('filters/')
	filtermanager:setFilterArguments('Shockwave',{center = {0.5,0.3}})
	filtermanager:setFilterArguments('Blackhole',{center = {0.5,0.6},radius = 0.2})
	
	hazenormal = love.graphics.newImage'effect/heathaze.png'
	hazenormal:setWrap('repeat','repeat')
	mask = love.graphics.newImage'effect/oval.png'
	
	filtermanager:setFilterArguments('Heathaze',{normal = hazenormal,mask = mask})
	filtermanager:setFilterArguments('Gaussianblur',{mask = mask})
end

effects = {}

function love.update(dt)
--if hz then filtermanager:requestFilter('Heathaze') end
--	filtermanager:requestFilter('Shockwave')
--	filtermanager:requestFilter'Zoomblur'
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
end

function love.keypressed(b)
	b = tonumber(b)
	if b then
		na = filtermanager.filterindex[b]
		filtermanager:reset()
		effects[na] = not effects[na]
		DBGMSG(na.." is "..tostring(effects[na]),1)
	end
end

function love.draw()
	local d = function()
		love.graphics.draw(img)
		local height = 10
		for msg,time in pairs(debugmessages) do
			love.graphics.print(msg,10,height)
			height = height + 15
		end
	end
	filtermanager:draw(d)
end

