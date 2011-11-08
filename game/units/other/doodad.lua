files = love.filesystem.enumerate('assets/doodad')
doodads = {}
function defineDoodad(name,pic)
	local doodadclass = Unit:subclass(name)
	local w,h = pic:getWidth(),pic:getHeight()
	function doodadclass:initialize(x,y)
		super.initialize(self,x,y,math.max(w,h)/2,10)
		self.ignoreLock = true
	end
	function doodadclass:createBody(world)
		self.body = love.physics.newBody(world,self.x,self.y,10)
		self.shape = love.physics.newRectangleShape(self.body,0,0,w,h)
		if self.controller then
			category,masks = unpack(typeinfo[self.controller])
			self.shape:setCategory(category)
			self.shape:setMask(unpack(masks))
		end
		self.updateShapeData = true -- a hack to fix the crash when set data in a coroutine
		if self.r then
			self.body:setAngle(self.r)
		end
	end
	function doodadclass:draw()
		love.graphics.draw(pic,self.x,self.y,self.body:getAngle(),1,1,w/2,h/2)
	end
	_G[name] = doodadclass -- Globalize
end


for i,v in ipairs(files) do
	if love.filesystem.isFile('assets/doodad/'..v) then
		local f = v:gmatch("(%w+).(%w+)")
		local file,ext=f()
		if ext=='png' then
			defineDoodad(file, love.graphics.newImage('assets/doodad/'..v))
		end
	end
end
