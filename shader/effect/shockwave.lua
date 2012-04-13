ShockwaveEffect = ShaderEffect:subclass'ShockwaveEffect'
function ShockwaveEffect:initialize()
	super.initialize(self)
	local xf = love.graphics.newPixelEffect[[
		extern vec2 center; // Center of shockwave
		extern number time; // effect elapsed time
		extern vec3 shockParams; // 100.0, 8, 100
		
		vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
		{
			
			number dis = distance(texture_coords,center);
			if ((dis <= (time + shockParams.z)) &&
			       (dis >= (time - shockParams.z)))
				{
					number diff = (dis - time);
					number powDiff = 1.0 - pow(abs(diff*shockParams.x),shockParams.y);
					number diffTime = diff * powDiff;
					vec2 diffUV = normalize(texture_coords - center);
					texture_coords=texture_coords + diffUV * diffTime;
				}
			
			return Texel(texture, texture_coords);
			// return color * vec4(tc, texcolor.a);
		}
	]]
	
	self.canvas = love.graphics.newCanvas(1024,1024)
	self.xf = xf
	self.time = 0
end

function ShockwaveEffect:setParameter(p)
	for k,v in pairs(p) do
		self.xf:send(k,v)
	end
end

function ShockwaveEffect:update(dt)
	super.update(self,dt)
	self.time = self.time + dt
	self.xf:send("time",self.time)
end

function ShockwaveEffect:predraw()
	self.c = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canvas)
	
end

function ShockwaveEffect:postdraw()
	love.graphics.setCanvas(self.c)
	love.graphics.setPixelEffect(self.xf)
	love.graphics.draw(self.canvas)
	love.graphics.setPixelEffect()
end
