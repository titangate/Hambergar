Particle1 = ShaderEffect:subclass'Particle1'
function Particle1:initialize()
	super.initialize(self)
	local xf = love.graphics.newPixelEffect[[
		extern number time = 0; // effect elapsed time
		vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
		{
			if (texture_coords.x < time) {
				return color * Texel(texture, texture_coords);
			}
			else{
			vec2 center = vec2(texture_coords.x,0.3);
			vec2 diff = texture_coords - center;
			
			return color * Texel(texture, texture_coords + diff + diff * 3);
			}
		}
	]]
	self.canvas = love.graphics.newCanvas(1024,1024)
	self.xf = xf
	self.time = 0
end

function Particle1:setParameter(p)
	for k,v in pairs(p) do
		self.xf:send(k,v)
	end
end

function Particle1:update(dt)
	super.update(self,dt)
	self.time = self.time + dt * 0.1
	self.xf:send("time",self.time)
end

function Particle1:predraw()
	self.c = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canvas)
end

function Particle1:postdraw()
	love.graphics.setCanvas(self.c)
	love.graphics.setPixelEffect(self.xf)
	love.graphics.draw(self.canvas)
	love.graphics.setPixelEffect()
end
