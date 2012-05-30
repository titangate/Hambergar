
Heathaze = Filter:subclass'Heathaze'

function Heathaze:initialize()
	super.initialize(self)
	local xf = love.graphics.newPixelEffect[[
		extern Image normal;// Normal map
		extern Image hzmask; // bluring mask
		const int normalscale = 64;
		extern vec2 offset;
		extern number ref = 1024;
		vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
		{
			number alpha = Texel(hzmask, texture_coords).a;
			if (alpha > 0) {
				vec2 hazeoffset = vec2(int(pixel_coords.x) % normalscale,int(pixel_coords.y) % normalscale)/normalscale;
				vec2 hazenormal = (Texel(normal,hazeoffset+offset).rg-vec2(1,1))/ref*20;
				vec4 texcolor = Texel(texture, texture_coords+hazenormal);
				return color * (texcolor*alpha)+Texel(texture,texture_coords)*(1-alpha);//vec4(texcolor.rgb,texcolor.a*Texel(hzmask, texture_coords).a);
			}
			else {
				return color * Texel(texture,texture_coords);
			}
		}
	]]
	self.priority = 60
	self.xf = xf
	self.time = 0
end

function Heathaze:setMask(mask)
	self.xf:send('hzmask',mask)
end

function Heathaze:setArguments(tab)
	for k,v in pairs(tab) do
		self.xf:send(k,v)
	end
end

function Heathaze:update(dt)
	super.update(self,dt)
	self.time = self.time + dt
	self.xf:send('offset',{self.time,self.time})
end

function Heathaze:reset()
	self.time = 0
end

function Heathaze:draw(c,requestfunc)
	local length = math.max(screen.w,screen.h)
	local result = requestfunc(length,length)
	love.graphics.setCanvas(result)
--	love.graphics.draw(c)
	love.graphics.setPixelEffect(self.xf)
	love.graphics.draw(c)
	love.graphics.setPixelEffect()
	return result
end

return Heathaze
