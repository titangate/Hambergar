
Zoomblur = Filter:subclass'Zoomblur'

function Zoomblur:initialize()
	super.initialize(self)
	local xf = love.graphics.newPixelEffect[[
		extern vec2 center; // Center of blur
		extern number intensity = 1; // effect intensity
		const number offset[5] = number[](1,1.05,1.1,1.15,1.2);
		const number weight[5] = number[](0.5,0.2,0.1,0.1,0.1);
		
		vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
		{
			vec4 texcolor = Texel(texture, texture_coords);
			vec3 tc = texcolor.rgb * weight[0]*0.5;
			vec2 diff = texture_coords - center;
			for (int i=1;i<5;i++)
			{
				tc += Texel(texture,center + diff/offset[i]).rgb*0.2;
			}
			return color * vec4(tc, texcolor.a);
		}
	]]
	self.xf = xf
	
	self.priority = 20
	self.time = 0
end

function Zoomblur:update(dt)
	super.update(self,dt)
	self.time = self.time + dt
	local x,y = love.mouse.getPosition()
	self.xf:send("center",{x/screen.w,1-y/screen.w})
end


function Zoomblur:draw(c,requestfunc)
	local length = math.max(screen.w,screen.h)
	local result = requestfunc(length,length)
	love.graphics.setCanvas(result)
	love.graphics.setPixelEffect(self.xf)
	love.graphics.draw(c)
	love.graphics.setPixelEffect()
	return result
end

return Zoomblur
