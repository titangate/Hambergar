
Blackhole = Filter:subclass'Blackhole'

function Blackhole:initialize()
	super.initialize(self)
	local xf = love.graphics.newPixelEffect[[
			extern vec2 center; // Center of shockwave
			extern number time = 0; // effect elapsed time
			extern number radius; // effect radius (blackhole)
			extern number angle = 6.28; // distortion angle
	//		const vec2 rt = vec2(1,0.75);

			vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
			{
				number dis = distance(texture_coords,center);

				if ( dis <= radius ) {
					vec2 diff = texture_coords - center;
					number factor = pow( dis/radius , -time );
					diff = diff * factor;
					number cosr = cos ( angle * factor );
					number sinr = sin ( angle * factor );
					mat2 trans = mat2(
						cosr, -sinr,
						sinr, cosr
					);
					// trans * diff
					return Texel(texture, center + trans * diff);
				}
				else {
					return Texel(texture, texture_coords);
				}
				// return color * vec4(tc, texcolor.a);
			}
	]]
	self.priority = 100
	self.xf = xf
	self.time = 0
end

function Blackhole:setArguments(tab)
	for k,v in pairs(tab) do
		self.xf:send(k,v)
	end
end

function Blackhole:update(dt)
	super.update(self,dt)
	
	self.time = self.time + dt * 0.1
	self.xf:send("time",self.time)
	self.xf:send("radius",0.3-0.3*self.time*self.time)
end

function Blackhole:reset()
	self.time = 0
end

function Blackhole:draw(c,requestfunc)
	local length = math.max(screen.w,screen.h)
	local result = requestfunc(length,length)
	love.graphics.setCanvas(result)
	love.graphics.setPixelEffect(self.xf)
	love.graphics.draw(c)
	love.graphics.setPixelEffect()
	return result
end

return Blackhole
