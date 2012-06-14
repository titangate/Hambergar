

files = love.filesystem.enumerate('items/artifact/')
for i,v in ipairs(files) do
	local f = 'items/artifact/'..v
	if love.filesystem.isFile(f) and v~='.DS_Store' then
		table.insert(itemlist,love.filesystem.load (f)())
	end
end