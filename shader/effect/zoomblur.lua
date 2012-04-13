ZoomblurEffect = ShaderEffect:subclass'ZoomblurEffect'
function ZoomblurEffect:initialize()
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
	
	self.canvas = love.graphics.newCanvas(1024,1024)
	self.xf = xf
	self.time = 0
end

function ZoomblurEffect:setParameter(p)
	for k,v in pairs(p) do
		self.xf:send(k,v)
	end
end

function ZoomblurEffect:update(dt)
	super.update(self,dt)
	self.time = self.time + dt
	local x,y = love.mouse.getPosition()
	self.xf:send("center",{x/1024,1-y/1024})
--	self.xf:send("time",self.time)
end

function ZoomblurEffect:predraw()
	self.c = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canvas)
	
end

function ZoomblurEffect:postdraw()
	love.graphics.setCanvas(self.c)
	love.graphics.setPixelEffect(self.xf)
	love.graphics.draw(self.canvas)
	love.graphics.setPixelEffect()
end
