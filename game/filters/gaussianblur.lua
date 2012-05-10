
Gaussianblur = Filter:subclass'Gaussianblur'

function Gaussianblur:initialize()
	super.initialize(self)
	local xf = love.graphics.newPixelEffect[[
//		extern Image edge; // bluring mask
		extern number intensity = 1.5; // effect intensity
			extern number rt_h = 512.0; // render target height


			const number offset[3] = number[](0.0, 1.3846153846, 3.2307692308);
			const number weight[3] = number[](0.2270270270, 0.3162162162, 0.0702702703);

			vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
			{
				vec4 texcolor = Texel(texture, texture_coords);
				vec3 tc = texcolor.rgb * weight[0];

				tc += Texel(texture, texture_coords + intensity * vec2(0.0, offset[1])/rt_h).rgb * weight[1];
				tc += Texel(texture, texture_coords - intensity * vec2(0.0, offset[1])/rt_h).rgb * weight[1];

				tc += Texel(texture, texture_coords + intensity * vec2(0.0, offset[2])/rt_h).rgb * weight[2];
				tc += Texel(texture, texture_coords - intensity * vec2(0.0, offset[2])/rt_h).rgb * weight[2];
				
				return color * vec4(tc, texcolor.a);
			}
	]]
	local xf2 = love.graphics.newPixelEffect[[
		extern number intensity = 1.5; // effect intensity
		extern Image mask;
		extern Image origin;
		extern number rt_h = 512.0; // render target height
		extern number brightness = 0;

		const number offset[3] = number[](0.0, 1.3846153846, 3.2307692308);
		const number weight[3] = number[](0.2270270270, 0.3162162162, 0.0702702703);

		vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
		{
			vec4 texcolor = Texel(texture, texture_coords);
			vec3 tc = texcolor.rgb * weight[0];

			tc += Texel(texture, texture_coords + intensity * vec2(offset[1],0)/rt_h).rgb * weight[1];
			tc += Texel(texture, texture_coords - intensity * vec2(offset[1],0)/rt_h).rgb * weight[1];

			tc += Texel(texture, texture_coords + intensity * vec2(offset[2],0)/rt_h).rgb * weight[2];
			tc += Texel(texture, texture_coords - intensity * vec2(offset[2],0)/rt_h).rgb * weight[2];
			number alpha = Texel(mask, texture_coords).a;
			return color * (vec4(tc,texcolor.a)*alpha)+Texel(origin,texture_coords)*(1-alpha+brightness);
			}
	]]
	self.priority = 60
	self.xf = xf
	self.xf2 = xf2
	self.time = 0
end

function Gaussianblur:setArguments(tab)
	for k,v in pairs(tab) do
		if k=='mask' then
			self.xf2:send('mask',v)
		end
	end
end

function Gaussianblur:update(dt)
	super.update(self,dt)
	self.time = self.time + dt
end

function Gaussianblur:reset()
	self.time = 0
end

function Gaussianblur:draw(c,requestfunc)
	
	local length = math.max(screen.w,screen.h)
--	self.xf:send('rt_h',length/2)
--	self.xf2:send('rt_h',length/2)
	local blurbufferh = requestfunc(length/2,length/2)
	local result = requestfunc(length,length)
	--[[
	love.graphics.push()
	love.graphics.scale(0.5,0.5)
	love.graphics.setCanvas(blurbuffer1)
	love.graphics.setPixelEffect(self.xf)
	love.graphics.draw(c)
	love.graphics.pop()
--	love.graphics.setCanvas(blurbuffer2)
	love.graphics.setCanvas(result)
	love.graphics.setPixelEffect()
	love.graphics.setPixelEffect(self.xf2)
	love.graphics.draw(blurbuffer1,0,0,0,2,2)
	love.graphics.setPixelEffect()
--	love.graphics.setColor(255,255,255,200)
--	love.graphics.draw(c)
--	love.graphics.setColor(255,255,255,255)
--	love.graphics.draw(blurbuffer2,0,0,0,2,2)]]

	love.graphics.push()
	love.graphics.scale(0.5,0.5)

	-- apply bloom extract shader
	love.graphics.setCanvas(blurbufferh)
	love.graphics.setPixelEffect(self.xf)
	love.graphics.draw(c)

	love.graphics.pop()
         
	-- apply horizontal blur shader to extracted bloom
	love.graphics.setCanvas(result)
	self.xf2:send("origin",c)
	love.graphics.setPixelEffect(self.xf2)
	love.graphics.draw(blurbufferh,0,0,0,2,2)

	love.graphics.setPixelEffect()
	return result
end

return Gaussianblur
