


files = love.filesystem.enumerate('items/amplifier/')
for i,v in ipairs(files) do
	local f = 'items/amplifier/'..v
	if love.filesystem.isFile(f) then
		require (f)
	end
end