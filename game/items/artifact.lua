

files = love.filesystem.enumerate('items/artifact/')
for i,v in ipairs(files) do
	local f = 'items/artifact/'..v
	if love.filesystem.isFile(f) then
		require (f)
	end
end