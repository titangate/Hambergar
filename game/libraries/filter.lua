
Filter = Object:subclass'Filter'
function Filter:update(dt)
end

pixeleffect = {}
pixeleffect.singcolor = love.graphics.newPixelEffect[[
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
	{
		vec4 texcolor = Texel(texture,texture_coords);
		if (texcolor.a>0)
		{
			return color;
		}
	}
]]
