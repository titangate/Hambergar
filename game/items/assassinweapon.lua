
--require 'abilities.assassin.common'
files = love.filesystem.enumerate('items/assassinweapon/')
for i,v in ipairs(files) do
	local f = 'items/assassinweapon/'..v
	if love.filesystem.isFile(f) and v~='.DS_Store' then
		love.filesystem.load (f)()
	end
end