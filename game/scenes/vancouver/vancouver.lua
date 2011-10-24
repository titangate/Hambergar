require 'scenes.vancouver.waterfall'
require 'scenes.vancouver.granvilleisland'
require 'scenes.vancouver.armory'
preload('assassin','swift','commonenemies','tibet','vancouver')
--vancouverbg = {}

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

local place = {
	waterfall = {
		loc = {
			x = 200,
			y = 300,
		},
		map = Waterfall,
	},
	granvilleisland = {
		loc = {
			x = 400,
			y = 300,
		},
		map = GranvilleIsland,
	},
	
	armory = {
		loc = {
			x = 600,
			y = 300,
		},
		map = Armory,
	}
}

function VancouverMap:initialize()
	self.anim = {}
	self.container = goo.object()
	self.flags = {}
	for k,p in pairs(place) do
		local f = goo.flag(self.container)
		f:setPos(p.loc.x,p.loc.y)
		f:setSize(100,40)
		f:setText(string.upper(k))
		table.insert(self.flags,f)
		f.onClick = function(button)
			map:destroy()
			map = p.map()
			map:enter_load()
			self:zoomInCity('vancouver')
			self.closetime = 1
		end
	end
	self.container:setVisible(false)
end

function VancouverMap:zoomOutCity(city)
	map.disableBlur = true
	assert(cities[city])
	local c = cities[city]
	Blureffect.blur('motion',
	{x = screen.halfwidth,
	y = screen.halfheight},0,2)
	
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
	
	self.container:setVisible(true)
	for i,v in ipairs(self.flags) do
		anim:easy(v,'opacity',0,255,2)
	end
end

function VancouverMap:zoomInCity(city)
	map.disableBlur = true
	assert(cities[city])
	local c = cities[city]
	Blureffect.blur('motion',
	{x = screen.halfwidth,
	y = screen.halfheight},0,2)
	table.insert(self.anim,{
		time = 10,
		dt = 0,
		x = 512,
		y = 300,
		ox = 256,
		oy = 150,
		sx = 1,
		sy = 1,
		delay = 1,
		alpha = 0,
		transform = {
			sx = {vf=1,vi=0.001},
			sy = {vf=1,vi=0.001},
			alpha = {vf=255,vi=0},
			ox = {vi=256,vf=512*c.loc.x},
			oy = {vi=150,vf=300*c.loc.y},
		},
	})
	
	table.insert(self.anim,{
		time = 5,
		dt = 0,
		x = 512,
		y = 300,
		ox = 256,
		oy = 150,
		sx = 2,
		sy = 2,
		alpha = 0,
		delay = 0,
		transform = {
			sx = {vf=4,vi=2},
			sy = {vf=4,vi=2},
			alpha = {vf=0,vi=255}
		},
		img = cities[city].img[2]
	})
	self.container:setVisible(false)
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
	if self.closetime then
		self.closetime = self.closetime - dt
		if self.closetime <=0 then
			self.closetime = nil
			popsystem()
			map.camera.sx,map.camera.sy = 1,1
		end
	end
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
	goo:draw()
	Blureffect.finish()
end

vancouver = VancouverMap()
--return vancouvermap