

Consumable = Item:subclass'Consumable'

function Consumable:equip(unit)
--	if unit.skills.useitem then
		unit:setUseItem(self)
--	end
end


function Consumable:getCDPercent(unit)
	local groupname = self.groupname or self:className()
	local cddt = unit:getCD(groupname) or 0
	return cddt/self.cd
end

files = love.filesystem.enumerate('items/consumable/')
for i,v in ipairs(files) do
	local f = 'items/consumable/'..v
	if love.filesystem.isFile(f) then
		love.filesystem.load (f)()
	end
end