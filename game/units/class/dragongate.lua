
dragongate = {
	f1 = love.graphics.newCanvas(256,256),
	f2 = love.graphics.newCanvas(256,256),
	r = 0,
	pe = love.graphics.newPixelEffect[[
	extern number c = 0.35;
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
	{
		number b = (texture_coords.y)*c;
		number nx = (texture_coords.x-b)/(1-2*b);
		number ny = pow(texture_coords.y,1+5*c);
//		if (nx<0 || nx>1) {return vec4(0,0,0,0);}
		return color * Texel(texture,vec2(nx,ny));
	}
	]],
}

function dragongate.draw(x,y,r)
--	print (x,y,r)
	love.graphics.draw(dragongate.f2,x,y,r,1,1,128,0)
end

function dragongate.update(dt)
	dragongate.r = dragongate.r + dt
end

function dragongate.predraw()
	love.graphics.setColor(255,255,255)
	love.graphics.setBackgroundColor(0,0,0,0)
	local prev = love.graphics.getCanvas()
	love.graphics.setCanvas(dragongate.f1)
	love.graphics.draw(requireImage'assets/assassin/gate.png',128,128,dragongate.r,1,1,128,128)
	love.graphics.setPixelEffect(dragongate.pe)
	love.graphics.setCanvas(dragongate.f2)
	love.graphics.draw(dragongate.f1,-128,0,0,2,1)
	love.graphics.setCanvas(prev)
	love.graphics.setPixelEffect()
end