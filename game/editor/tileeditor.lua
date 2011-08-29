TileEditor = {}
local tiles = {}
local tile = nil
local tileaabb = nil
local image = nil
local picking = 0
local putting = 0
local tileindex = 0
local editorshift = {0,0}
local brushsize = 1
local brushes = {
	{{0,0}},
	{{0,0},
	{0,1},
	{0,-1},
	{1,0},
	{-1,0}},
	{{0,0},
	{0,1},
	{0,-1},
	{1,0},
	{-1,0},
	{2,0},
	{-2,0},
	{0,2},
	{0,-2},
	{1,1},
	{-1,1},
	{1,-1},
	{-1,-1}},
}
batches = {}
maps = tiles
local 
shifts = {a={-1,0},
	d={1,0},
	w={0,-1},
	s={0,1}}

function p(batch,map,i,t)
	map.map[i]=t
end

function inAABB(x,y,aabb)
	return x>aabb.x and x<aabb.x+aabb.w and y>aabb.y and y<aabb.y+aabb.h
end

function TileEditor:loadTile(filename)
	image = love.graphics.newImage( filename )
	tile = TileMap:new(image,50,50,40)
	tileindex = #tiles
	table.insert(tiles,tile)
	tileaabb = {
		x = love.graphics.getWidth()-image:getWidth(),
		y = 0,
		w = image:getWidth(),
		h = image:getHeight()
	}
end

function BinaryComposite(t,s,e)
	if e-s > 1 then
		local i = math.floor((e-s)/2)
		return BinaryComposite(t,s,s+i)..BinaryComposite(t,s+i+1,e)
	elseif e-s == 1 then
		return t[s]..t[s+1]
	else
	end
	return t[s]
end

function TileEditor:save(file)
	local generatorheader = [[
	local batches = {}
	local function p(b,map,i,t)
		local x,y = map:indexToCoordinate(i)
		local ix,iy = map:indexToCoordinateTile(t)
		quad:setViewport(ix*length,iy*length,length,length)
		b:addq(quad,x*length,y*length)
	end
]]
	local generatorconstants = [[
	length = 40
	]]
	local tiledef = {}
	for k,v in ipairs(tiles) do
		for k2,v2 in pairs(v.map) do
			table.insert(tiledef,"p(batches["..k.."],maps["..k.."],"..k2..","..v2..")\n")
		end
	end
	local s = BinaryComposite(tiledef,1,#tiledef)
--	print (s)
	love.filesystem.write(file,s,#s)
end

function TileEditor:update(dt)
	local x,y = love.mouse.getPosition()
	if tileon and inAABB(x,y,tileaabb) then
		--x,y=x-tileaabb.x,y-tileaabb.y
	else
		x,y=x-editorshift[1],y-editorshift[2]
		x,y = math.floor(x/tile.length),math.floor(y/tile.length)
		self.mapcoordinates = {x,y}
		if x<0 or x>=tile.w or y<0 or y>=tile.h then return end
		putting = tile:coordinateToIndex(x,y)
		if love.mouse.isDown('l') then
			if love.keyboard.isDown('lshift') then
				for k,v in ipairs(tiles) do
					for i2,v2 in ipairs(brushes[brushsize]) do
						local x,y=unpack(v2)
						local ox,oy = tile:indexToCoordinate(putting)
						x,y=ox+x,oy+y
						if x>=0 and x<tile.w and y>=0 and y<tile.h then
							v.map[tile:coordinateToIndex(x,y)] = nil
						end
					end
				end
			end	
			for i2,v2 in ipairs(brushes[brushsize]) do
				local x,y=unpack(v2)
				local ox,oy = tile:indexToCoordinate(putting)
				x,y=ox+x,oy+y
				if x>=0 and x<tile.w and y>=0 and y<tile.h then
					tile.map[tile:coordinateToIndex(x,y)] = picking
				end
			end
		elseif love.mouse.isDown('r') then
			for k,v in ipairs(tiles) do
			
				for i2,v2 in ipairs(brushes[brushsize]) do
					local x,y=unpack(v2)
					local ox,oy = tile:indexToCoordinate(putting)
					x,y=ox+x,oy+y
					if x>=0 and x<tile.w and y>=0 and y<tile.h then
						v.map[tile:coordinateToIndex(x,y)] = nil
					end
				end
			end
		end
	end
end

function TileEditor:draw()
	love.graphics.push()
	love.graphics.translate(unpack(editorshift))
	love.graphics.rectangle('line',0,0,tile.w*tile.length,tile.h*tile.length)
	for k,v in ipairs(tiles) do
		v:drawEditingMap()
	end
	love.graphics.setColor(255,255,255,125)
	
		for i2,v2 in ipairs(brushes[brushsize]) do
			local x,y=unpack(v2)
			local ox,oy = tile:indexToCoordinate(putting)
			x,y=ox+x,oy+y
			if x>=0 and x<tile.w and y>=0 and y<tile.h then
		tile:drawSingleTile(tile:coordinateToIndex(x,y),picking)
			end
		end
	love.graphics.setColor(255,255,255,255)
	
	love.graphics.translate(-editorshift[1],-editorshift[2])
	if tileon then tile:drawTile(tileaabb.x,tileaabb.y) end
	if tileon then 
		local x,y = tile:indexToCoordinateTile(picking)
		love.graphics.rectangle('line',tileaabb.x+x*tile.length,tileaabb.y+y*tile.length,tile.length,tile.length)
	end
	love.graphics.pop()
	love.graphics.print ('coordinate'..self.mapcoordinates[1]..','..self.mapcoordinates[2],10,10)
end

function TileEditor:mousepressed(x,y,b)
	if b=='wu' then
		if love.keyboard.isDown('lshift') then
			brushsize = math.min(3,brushsize+1)
			return
		end
		tileindex = tileindex + 1
		if tileindex > #tiles then
			tileindex = 1
		end
		tile = tiles[tileindex]
		picking = 0
		local image = tile.image
		tileaabb = {
			x = love.graphics.getWidth()-image:getWidth(),
			y = 0,
			w = image:getWidth(),
			h = image:getHeight()
		}
	elseif b=='wd' then
			if love.keyboard.isDown('lshift') then
				brushsize = math.max(1,brushsize-1)
				return
			end
		tileindex = tileindex - 1
		if tileindex <= 0 then
			tileindex = #tiles
		end
		tile = tiles[tileindex]
		picking = 0
		local image = tile.image
		tileaabb = {
			x = love.graphics.getWidth()-image:getWidth(),
			y = 0,
			w = image:getWidth(),
			h = image:getHeight()
		}
	elseif b=='l' then
		if tileon and inAABB(x,y,tileaabb) then
			x,y=x-tileaabb.x,y-tileaabb.y
			picking = tile:coordinateToIndexTile(math.floor(x/tile.length),math.floor(y/tile.length),tileaabb)
		end
	else
	end
end

eshifts = {
	w={0,1},
	s={0,-1},
	a={1,0},
	d={-1,0}
}

tshifts = {
	k={0,1},
	i={0,-1},
	l={1,0},
	j={-1,0}
}

function TileEditor:keypressed(k)
	if shifts[k] then
		local x,y = unpack(eshifts[k])
		x,y=x*40,y*40
		editorshift = {x+editorshift[1],y+editorshift[2]}
	elseif
		tshifts[k] then
		local x,y = unpack(tshifts[k])
		picking = picking + x + y*tile.imagew
		picking = math.max(math.min(picking,tile.imagew*tile.imageh-1),0)
	end
	if k=='t' then
		tileon = not tileon
	elseif k=='f' then
		self:save('testscene.lua')
	end
end

--love.keyboard.setKeyRepeat( 200, 20 )

TileEditor:loadTile('assets/tile/tile1.png')
TileEditor:loadTile('assets/tile/tile2.png')
TileEditor:loadTile('assets/tile/tile3.png')
TileEditor:loadTile('assets/tile/special.png')


require 'tests/scene1.lua'