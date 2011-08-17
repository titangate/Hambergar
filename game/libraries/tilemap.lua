TileMap = Object:subclass('TileMap')
function TileMap:initialize(image,w,h,length)
	self.image = image
	self.length = length
	self.w,self.h = w,h
	local w = math.floor(image:getWidth()/self.length)
	local h = math.floor(image:getHeight()/self.length)
--	print (w,h)
--	self.batch = love.graphics.newSpriteBatch(image,w*h)
	self.map = {}
	self.imagew,self.imageh=w,h
	self.quad = love.graphics.newQuad(0,0,40,40,self.image:getWidth(),self.image:getHeight())
end

function TileMap:indexToCoordinate(i)
	if i<0 or i>=self.w*self.h then return end
	local x,y = i%self.w,math.floor(i/self.w)
	return x,y
end

function TileMap:coordinateToIndex(x,y)
	return math.min(self.w*self.h,math.max(0,x+y*self.w))
end

function TileMap:indexToCoordinateTile(i)
	if i<0 or i>=self.imagew*self.imageh then return end
	local x,y = i%self.imagew,math.floor(i/self.imagew)
	return x,y
end

function TileMap:coordinateToIndexTile(x,y)
	return math.min(self.imagew*self.imageh,math.max(0,x+y*self.imagew))
end

function TileMap:drawTile(x,y)
	love.graphics.translate(x,y)
	love.graphics.draw(self.image)
--	local x,y=unpack(self.highlightblock)
--	love.graphics.rectangle('line',x*self.length,y*self.length,self.length,self.length)
	love.graphics.translate(-x,-y)
end

function TileMap:generate()
end

function TileMap:drawSingleTile(p,i)
	local dx,dy = self:indexToCoordinate(p)
	local x,y = i%self.imagew,math.floor(i/self.imagew)
	self.quad:setViewport(x*self.length,y*self.length,self.length,self.length)
	love.graphics.drawq(self.image,self.quad,dx*self.length,dy*self.length)
end

function TileMap:drawEditingMap()
	for i,v in pairs(self.map) do
		local x,y = v%self.imagew,math.floor(v/self.imagew)
--		print ("image coordinates:",x*self.length,y*self.length)
		self.quad:setViewport(x*self.length,y*self.length,self.length,self.length)
		local x,y = self:indexToCoordinate(i)
--		print ("map coordinates:",x,y)
		love.graphics.drawq(self.image,self.quad,x*self.length,y*self.length)
	end
end

function TileMap:demo()
	for i=0,self.imagew*self.imageh-1 do
		self.map[i] = i
	end
end

function TileMap:draw()
--	love.graphics.draw(self.batch)
end