local images = {
	love.graphics.newImage('assets/tile/tile1.png'),
	love.graphics.newImage('assets/tile/tile2.png'),
	love.graphics.newImage('assets/tile/tile3.png')
}
local batches = {
	love.graphics.newSpriteBatch(images[1],512),
	love.graphics.newSpriteBatch(images[2],512),
	love.graphics.newSpriteBatch(images[3],512),
}
local maps = {
	TileMap:new(images[1],50,50,40),
	TileMap:new(images[2],50,50,40),
	TileMap:new(images[3],50,50,40)
}
local length = 40
local function p(b,map,i,t)
	local x,y = map:indexToCoordinate(i)
	local ix,iy = map:indexToCoordinateTile(t)
	map.quad:setViewport(ix*length,iy*length,length,length)
	b:addq(map.quad,x*length,y*length)
end

return batches