

Consumable = Item:subclass'Consumable'

function Consumable:equip(unit)
--	if unit.skills.useitem then
		unit:setUseItem(self)
--	end
end

files = love.filesystem.enumerate('items/consumable/')
for i,v in ipairs(files) do
	local f = 'items/consumable/'..v
	if love.filesystem.isFile(f) then
		require (f)
	end
end