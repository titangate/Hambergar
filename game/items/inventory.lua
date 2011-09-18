# inventory
Inventory=Object:subclass('Inventory')
function Inventory:initialize()
	self.items={}
end

function Inventory:addItem(item)
end

function Inventory:hasItem(itemtype)
end

function Inventory:removeItem(item,count)
end

function Inventory:useItem(item)
end

function Inventory:getItemByType(itemtype)
end

function Inventory:interateItems()
end