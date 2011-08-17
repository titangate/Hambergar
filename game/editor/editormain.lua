Editor = {}

function Editor:update(dt)
	if self.updated then
		map:update(dt)
		self.updated = nil
	end
end

function Editor:draw()
	map:draw()
end

function Editor:mousepressed(x,y,b)
	x,y=unpack(GetOrderPoint())
	map:setBlock(x,y,not(map:getBlock(x,y)))
	self.updated = 1
end

function Editor:keypressed(k)
	if k==' ' then
		popsystem()
	end
end