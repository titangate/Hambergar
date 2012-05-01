SandEffect = ShaderEffect:subclass'SandEffect'
function SandEffect:initialize()
	super.initialize(self)
	local xf = love.graphics.newPixelEffect[[
		extern Image normal;// Normal map
		extern number centerx;
		vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
		{
			if (texture_coords.x <= centerx) {
				return color * Texel(texture,texture_coords);
			}
			else {
				vec3 shift = Texel(normal,texture_coords).rgb;
				vec2 diff = texture_coords - vec2(centerx,texture_coords.y);
				return color * Texel(texture,texture_coords - diff*shift.z*100*centerx);
			}
		}
	]]
	
	self.canvas = love.graphics.newCanvas(1024,1024)
	self.xf = xf
	self.time = 0
end

function SandEffect:setParameter(p)
	for k,v in pairs(p) do
		self.xf:send(k,v)
	end
end

function SandEffect:update(dt)
	super.update(self,dt)
	self.time = self.time + dt
	local x,y = love.mouse.getPosition()
--	self.xf:send("center",{x/1024,1-y/1024})
	self.xf:send("centerx",self.time*0.01)
end

function SandEffect:predraw()
	self.c = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canvas)
	
end

function SandEffect:postdraw()
	love.graphics.setCanvas(self.c)
	love.graphics.setPixelEffect(self.xf)
	love.graphics.draw(self.canvas)
	love.graphics.setPixelEffect()
end
