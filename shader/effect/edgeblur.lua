EdgeblurEffect = ShaderEffect:subclass'EdgeblurEffect'
function EdgeblurEffect:initialize()
	super.initialize(self)
	local xf = love.graphics.newPixelEffect[[
		extern Image edge; // bluring mask
		extern number intensity = 2; // effect intensity
		extern number alphadeduct = 50; // alpha deduction
		
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

				return color * vec4(tc, texcolor.a*Texel(edge,texture_coords).a);
			}
		
	]]
	
	self.canvas = love.graphics.newCanvas(512,512)
--	self.canvas2 = love.graphics.newCanvas(512,512)
	self.xf = xf
	self.time = 0
end

function EdgeblurEffect:setParameter(p)
	for k,v in pairs(p) do
		self.xf:send(k,v)
	end
end

function EdgeblurEffect:update(dt)
	super.update(self,dt)
	self.time = self.time + dt
	local x,y = love.mouse.getPosition()
--	self.xf:send("time",self.time)
end

function EdgeblurEffect:predraw()
	self.c = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canvas)
	love.graphics.push()
	love.graphics.scale(0.5,0.5)
	
end

function EdgeblurEffect:postdraw()
	love.graphics.pop()
	love.graphics.setPixelEffect(self.xf)
	love.graphics.draw(self.canvas)
	
	love.graphics.setPixelEffect()
	love.graphics.setCanvas(self.c)
	love.graphics.push()
	love.graphics.scale(2,2)
	love.graphics.draw(self.canvas)
	love.graphics.pop()
	
	
end
