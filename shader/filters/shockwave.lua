
Shockwave = Filter:subclass'Shockwave'

function Shockwave:initialize()
	super.initialize(self)
	local xf = love.graphics.newPixelEffect[[
		extern vec2 center; // Center of shockwave
		extern number time; // effect elapsed time
		extern vec3 shockParams = vec3(10,0.8,0.1); // 100.0, 8, 100
		
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
	self.priority = 100
	self.xf = xf
	self.time = 0
end

function Shockwave:setArguments(tab)
	for k,v in pairs(tab) do
		self.xf:send(k,v)
	end
end

function Shockwave:update(dt)
	super.update(self,dt)
	self.time = self.time + dt
	self.xf:send('time',self.time)
--	local x,y = love.mouse.getPosition()
--	self.xf:send("center",{x/screen.w,1-y/screen.h})
end

function Shockwave:reset()
	self.time = 0
end

function Shockwave:draw(c,requestfunc)
	local length = math.max(screen.w,screen.h)
	local result = requestfunc(length,length)
	love.graphics.setCanvas(result)
	love.graphics.setPixelEffect(self.xf)
	love.graphics.draw(c)
	love.graphics.setPixelEffect()
	return result
end

return Shockwave
