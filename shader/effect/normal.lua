HeathazeEffect = ShaderEffect:subclass'HeathazeEffect'
function HeathazeEffect:initialize()
	super.initialize(self)
	local xf = love.graphics.newPixelEffect[[
		extern Image normal;// Normal map
		const int normalscale = 64;
		extern vec2 offset;
		vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
		{
			vec2 hazeoffset = vec2(int(pixel_coords.x) % normalscale,int(pixel_coords.y) % normalscale)/normalscale;
			vec2 hazenormal = Texel(normal,hazeoffset+offset).rg/255;
			return color * Texel(texture, texture_coords+hazenormal);
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
