


files = love.filesystem.enumerate('items/amplifier/')
for i,v in ipairs(files) do
	local f = 'items/amplifier/'..v
	if love.filesystem.isFile(f) and v~='.DS_Store' then
		table.insert(itemlist,love.filesystem.load (f)())
	end
end