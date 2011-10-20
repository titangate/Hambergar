
Shop=InventoryBase:subclass('Shop')

function Shop:purchase(item)
	assert(false)
end

function Shop:sell(item)
	self:removeItem(item.name,1)
	
end

function Shop:interactItem(item,condition)
	print (item)
	if item then
		if condition == 'shop' then
			assert(self.buyerinventory)
			if self.buyerinventory:purchase(item) then
				self:sell(item)
			end
		end
	end
end

function Shop:populateList(list,type)
	list:clear()
	for k,v in self:iterateItems(type) do
		local b = goo.itembutton:new(list)
		b:setItem(v)
		b:setSize(list.w,50)
		b:setInventory(self)
		b.buttontype = 'shop'
		list:addItem(b,k)
	end
end

-- the inventory on player side when the player is using a shop
ShopInventory = Inventory:subclass'ShopInventory'
function ShopInventory:initialize(origin)
	super.initialize(self)
	self.items=origin.items
	self.unit=origin.unit
	self.equipments=origin.equipments
end
function ShopInventory:purchase(item)
	print (item.name)
	if price then
		-- determine
	end
	self:addItem(item)
	return true
end

function ShopInventory:sell(item)
	item:unequip(self.unit)
	self.equipments[item.type]=nil
	self.updateInvUI()
end

function ShopInventory:interactItem(item,condition)
	print 'SHOP INTERACTION'
	if item then
		if condition == 'inventory' then
			assert(self.shop)
			self.shop:purchase(item)
		end
	end
end
