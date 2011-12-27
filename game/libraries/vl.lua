local Lighteffect = {dt=0,time=0,on=false}
local buffer = blurbuffer[1]
local lightpic = love.graphics.newImage'light.png'
function Lighteffect.lightOn(source)
	Lighteffect.source = source
end

function Lighteffect.stop()
	Lighteffect.source = nil
end

function Lighteffect.begin(units)
	if not Lighteffect.source then return end
	love.graphics.setRenderTarget(buffer)
	love.graphics.clear()
	map.camera:apply()
	love.graphics.setColor(255,255,255,255)
	love.graphics.setBlendMode('additive')
	love.graphics.draw(lightpic,Lighteffect.source.x,Lighteffect.source.y,0,Lighteffect.source.sx,Lighteffect.source.sy,512,512)
	love.graphics.setBlendMode('subtractive')
	love.graphics.setColor(0,0,0,130)
	for unit,v in pairs(units) do
		if unit ~= Lighteffect.source and unit.drawLight then unit:drawLight(Lighteffect.source.x,Lighteffect.source.y) end
	end
--	map.camera:revert()
end

function Lighteffect.finish()
	if not Lighteffect.source then return end
	love.graphics.setRenderTarget()
--	love.graphics.reset()

	love.graphics.setColor(255,255,255,255)
	love.graphics.setBlendMode('alpha')
	
--	map.camera:apply()
	map.camera:revert()
	map.camera:revert()
	love.graphics.draw(buffer)
	map.camera:apply()
end

function Lighteffect.isOn()
	return Lighteffect.source ~= nil
end
return Lighteffect