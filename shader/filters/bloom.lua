
Bloom = Filter:subclass'Bloom'

function Bloom:initialize()
	super.initialize(self)
	local xf = love.graphics.newPixelEffect[[
//		extern Image edge; // bluring mask
		extern number intensity = 1; // effect intensity
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
//		extern Image edge; // bluring mask
		extern number intensity = 1; // effect intensity

			extern number rt_h = 512.0; // render target height


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

				return color * vec4(tc, texcolor.a);
			}
	]]
	self.bloom = love.graphics.newPixelEffect[[
         extern number threshold = 0.35;
         
         float luminance(vec3 color)
         {
            // numbers make 'true grey' on most monitors, apparently
            return (0.212671 * color.r) + (0.715160 * color.g) + (0.072169 * color.b);
         }
         
         vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
         {
            vec4 texcolor = Texel(texture, texture_coords);
            
            vec3 extract = smoothstep(threshold * 0.7, threshold, luminance(texcolor.rgb)) * texcolor.rgb;
            return vec4(extract, 1.0);
         }
      ]]
	self.combine = love.graphics.newPixelEffect[[
         extern Image bloomtex;
		extern Image mask;

         extern number basesaturation = 1.0;
         extern number bloomsaturation = 1.0;

         extern number baseintensity = 1.0;
         extern number bloomintensity = 1.0;

         vec3 AdjustSaturation(vec3 color, number saturation)
         {
             vec3 grey = vec3(dot(color, vec3(0.212671, 0.715160, 0.072169)));
             return mix(grey, color, saturation);
         }

         vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
         {
            vec4 basecolor = Texel(texture, texture_coords);
            vec4 bloomcolor = Texel(bloomtex, texture_coords);

            bloomcolor.rgb = AdjustSaturation(bloomcolor.rgb, bloomsaturation) * bloomintensity;
            basecolor.rgb = AdjustSaturation(basecolor.rgb, basesaturation) * baseintensity;

            basecolor.rgb *= (1.0 - clamp(bloomcolor.rgb, 0.0, 1.0));

            bloomcolor.a = 0.0;

            return clamp(basecolor + bloomcolor, 0.0, 1.0);
         }]]
	self.priority = 60
	self.xf = xf
	self.xf2 = xf2
	self.time = 0
end

function Bloom:setArguments(tab)
	for k,v in pairs(tab) do
		self.xf:send(k,v)
	end
end

function Bloom:update(dt)
	super.update(self,dt)
	self.time = self.time + dt
end

function Bloom:reset()
	self.time = 0
end

function Bloom:draw(c,requestfunc)
	
	local blendmode = love.graphics.getBlendMode()
	love.graphics.setBlendMode("premultiplied")
	local length = math.max(screen.w,screen.h)
--	self.xf:send('rt_h',length/2)
--	self.xf2:send('rt_h',length/2)
	local blurbufferh = requestfunc(length/2,length/2)
	local blurbufferw = requestfunc(length/2,length/2)
	local bloombuffer = requestfunc(length/2,length/2)
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
	love.graphics.setCanvas(bloombuffer)
	love.graphics.setPixelEffect(self.bloom)
	love.graphics.draw(c)

	love.graphics.pop()
         
	-- apply horizontal blur shader to extracted bloom
	love.graphics.setCanvas(blurbufferw)
	love.graphics.setPixelEffect(self.xf)
	love.graphics.draw(bloombuffer)

	-- apply vertical blur shader to blurred bloom
	love.graphics.setCanvas(blurbufferh)
	love.graphics.setPixelEffect(self.xf2)
	love.graphics.draw(blurbufferw)

	-- render final scene combined with bloom canvas
	love.graphics.setCanvas(result)
	self.combine:send("bloomtex", blurbufferh)
	love.graphics.setPixelEffect(self.combine)
	love.graphics.draw(c, 0, 0)

	love.graphics.setPixelEffect()
	love.graphics.setBlendMode(blendmode)
	return result
end

return Bloom
