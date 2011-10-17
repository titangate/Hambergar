vancouverbg = {}

VancouverMap = Object:subclass('VancouverMap')

cities = {vancouver = {
	img = {
		love.graphics.newImage('maps/vancouver2.png'),
		love.graphics.newImage('maps/vancouver1.png'),
	},
	loc = {
		x = 0.64,
		y = 0.22,
	}
}
}

function VancouverMap:initialize()
	self.anim = {}
	
end

function VancouverMap:zoomOutCity(city)
	map.disableBlur = true
	assert(cities[city])
	local c = cities[city]
	Blureffect.blur('motion',
	{x = screen.halfwidth,
	y = screen.halfheight},0,2)
	table.insert(self.anim,{
		time = 5,
		dt = 0,
		x = 512,
		y = 300,
		ox = 256,
		oy = 150,
		sx = 1,
		sy = 1,
		delay = 0,
		alpha = 0,
		transform = {
			sx = {vi=1,vf=0.001},
			sy = {vi=1,vf=0.001},
			alpha = {vi=255,vf=0},
			ox = {vf=256,vi=512*c.loc.x},
			oy = {vf=150,vi=300*c.loc.y},
		},
	})
	
	table.insert(self.anim,{
		time = 10,
		dt = 0,
		x = 512,
		y = 300,
		ox = 256,
		oy = 150,
		sx = 4,
		sy = 4,
		alpha = 0,
		delay = 1,
		transform = {
			sx = {vf=2,vi=4},
			sy = {vf=2,vi=4},
			alpha = {vf=255,vi=0}
		},
		img = cities[city].img[2]
	})
end

function VancouverMap:zoomInCity(city)
	assert(cities[city])
	local c = cities[city]
	
	table.insert(self.anim,{
		time = 10,
		dt = 0,
		x = 512,
		y = 300,
		ox = 256,
		oy = 150,
		delay = 10,
		sx = 2,
		sy = 2,
		alpha = 155,
		transform = {
			sx = {vi=2,vf=4},
			sy = {vi=2,vf=4},
			alpha = {vi=155,vf=0}
		},
		img = cities[city].img[2]
	})
	table.insert(self.anim,{
		time = 10,
		dt = 0,
		x = 512,
		y = 300,
		ox = 256,
		oy = 150,
		sx = 2,
		sy = 2,
		delay = 5,
		alpha = 155,
		transform = {
			sx = {vi=2,vf=4},
			sy = {vi=2,vf=4},
			alpha = {vi=155,vf=0}
		},
		img = cities[city].img[1]
	})
	table.insert(self.anim,{
		time = 10,
		dt = 0,
		x = 512,
		y = 300,
		ox = 256,
		oy = 150,
		sx = 2,
		sy = 2,
		delay = 0,
		transform = {
			sx = {vi=2,vf=15},
			sy = {vi=2,vf=15},
			alpha = {vi=255,vf=125},
			ox = {vi=256,vf=512*c.loc.x},
			oy = {vi=150,vf=300*c.loc.y},
		},
		img = VancouverMap
	})
end

function quadInOut( t, b, c, d )
	local p = t/(d/2)
	if p < 1 then return c/2*p*p + b end
	return -c/2 * ((p-1)*(p-3)-1) + b
end

function linear(t,b,c,d)
	return t/d*(c)+b
end

function VancouverMap:update(dt)
	Blureffect.update(dt)
	dt = dt * 10
	for k,v in ipairs(self.anim) do
		if v.delay then
			v.delay = v.delay - dt
			if v.delay <= 0 then
				v.delay = nil
			end
		else
			v.dt = v.dt + dt
			if v.dt >= v.time then
				table.remove(self.anim,k)
			end
			assert(v.transform)
			if v.transform then
				for prop,item in pairs(v.transform) do
					v[prop] = linear(v.dt,item.vi,item.vf-item.vi,v.time)
				end
			end
		end
	end
end

function VancouverMap:draw()
	Blureffect.begin()
	love.graphics.setColor(255,255,255,255)
	if #self.anim == 0 then
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(cities.vancouver.img[2],512,300,0,2,2,256,150)
	end
	for k,v in ipairs(self.anim) do
		love.graphics.setColor(255,255,255,v.alpha)
		if v.img then
			love.graphics.draw(v.img,v.x,v.y,v.r,v.sx,v.sy,v.ox,v.oy)
		else
			map.camera.sx,map.camera.sy = v.sx,v.sy
			map:draw()
		end
	end
	Blureffect.finish()
end
