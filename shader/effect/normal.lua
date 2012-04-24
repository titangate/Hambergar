HeathazeEffect = ShaderEffect:subclass'HeathazeEffect'
function HeathazeEffect:initialize()
	super.initialize(self)
	local xf = love.graphics.newPixelEffect[[
		extern Image normal;// Normal map
		extern Image mask; // bluring mask
		const int normalscale = 64;
		extern vec2 offset;
		const vec2 offsetfix = vec2(0.006,0.006);
		vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
		{
			vec2 hazeoffset = vec2(int(pixel_coords.x) % normalscale,int(pixel_coords.y) % normalscale)/normalscale;
			vec2 hazenormal = Texel(normal,hazeoffset+offset).rg/125-offsetfix;
			vec4 texcolor = Texel(texture, texture_coords+hazenormal);
			return color * vec4(texcolor.rgb,texcolor.a*Texel(mask, texture_coords).a);
		}
	]]
	
	self.canvas = love.graphics.newCanvas(1024,1024)
	self.xf = xf
	self.time = 0
end

function HeathazeEffect:setParameter(p)
	for k,v in pairs(p) do
		self.xf:send(k,v)
	end
end

function HeathazeEffect:update(dt)
	super.update(self,dt)
	self.time = self.time + dt
	local x,y = love.mouse.getPosition()
--	self.xf:send("center",{x/1024,1-y/1024})
	self.xf:send("offset",{self.time,self.time})
end

function HeathazeEffect:predraw()
	self.c = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canvas)
	
end

function HeathazeEffect:postdraw()
	love.graphics.setCanvas(self.c)
	love.graphics.setPixelEffect(self.xf)
	love.graphics.draw(self.canvas)
	love.graphics.setPixelEffect()
end
