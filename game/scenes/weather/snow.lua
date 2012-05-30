local snow = {
	dt = 0,
	rate = 60,
	particles = {},
	on = true,
}
function snow:update(dt,viewport)
	if self.on then
		for i = 1,math.ceil(dt*self.rate) do
			self:birth(math.random(viewport.x,viewport.x+viewport.w),math.random(viewport.y,viewport.y+viewport.h))
		end
	end
	for v,_ in pairs(self.particles) do
		v.life = v.life - dt
		if v.life <= 0 then
			self.particles[v] = nil
		end
	end
end
function snow:birth(x,y)
	self.particles[{
		x = x,
		y = y,
		life = 1,
		angle = math.random(math.pi*2)
	}] = true
end
requireImage('assets/part1.png','part1')
function snow:draw()
--	love.graphics.setBackgroundColor(255,255,255)
	for v,_ in pairs(self.particles) do
		love.graphics.setColor(255,255,255,255-255*v.life)
		love.graphics.draw(img.part1,v.x,v.y,v.angle,v.life*2,nil)
	end
	love.graphics.setColor(255,255,255)
end

return snow