
Shop=InventoryBase:subclass('Shop')

function Shop:purchase(item)
	if not item.value then
		return 0
	end
	self:addItem(item)
	return item.value
end

function Shop:sell(item)
	self:removeItem(item.name,1)
end

function Shop:interactItem(item,condition)
	if item then
		if condition == 'shop' then
			assert(self.buyerinventory)
			if self.buyerinventory:purchase(item.class(),item.value) then
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
		list:addItem(b)
	end
end

-- the inventory on player side when the player is using a shop
ShopInventory = Inventory:subclass'ShopInventory'
function ShopInventory:initialize(origin)
	super.initialize(self)
	self.items=origin.items
	self.unit=origin.unit
	self.equipments=origin.equipments
	self.origin = origin
	self.money = self.origin.money or 0
end
function ShopInventory:purchase(item,price)
	if price then
		-- determine
		if self.origin:spend(price) then
			self.origin:addItem(item,1)
			self.money = self.origin.money
			return true
		else
			return false
		end
	end
	self.origin:addItem(item)
	self.updateInvUI()
	return true
end

function ShopInventory:sell(item,price)
	self.origin:removeItem(item.name)
	self.origin:gain(price)
	self.money = self.origin.money
	self.updateInvUI()
end

function ShopInventory:interactItem(item,condition)
	if item then
		if condition == 'inventory' then
			assert(self.shop)
			local m = self.shop:purchase(item)
			if m>0 then
				self:sell(item,m)
			end
		end
	end
end
