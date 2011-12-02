require 'items.inventory'
require 'items.amplifier'
require 'items.consumable'
require 'items.trophy'
require 'items.artifact'
require 'items.shop'
require 'items.shoppanel'
require 'items.assassinweapon'
require 'items.misc'

local files = love.filesystem.enumerate('assets/item')
for i,v in ipairs(files) do
	if love.filesystem.isFile('assets/item/'..v) then
		local f = v:gmatch("(%w+).(%w+)")
		local file,ext=f()
		if ext=='png' then
			requireImage('assets/item/'..v,file,icontable)
		end
	end
end