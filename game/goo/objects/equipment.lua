goo.equipment = class('goo equipment',goo.object)

function goo.equipment:initialize(parent)
	super.initialize(self,parent)
	self.invlist = goo.listcontainer:new(self)
	self.invlist:setPos(0,0)
	self.invlist:setSize(300,400)
	self.tabs = {}
end

function goo.equipment:setInventory(inv)
	self.inv = inv
end

function goo.equipment:setItemtype(itemtype)
	for i,v in ipairs(itemtype) do
		local b = goo.itembutton:new(self.invlist.list)
		b:setSize(400,50)
		b:setInventory(self.inv)
		b.buttontype = 'equipment'
		table.insert(self.tabs,{v,b})
		local label = goo.imagelabel(self.invlist.list)
		label:setText(v)
		self.invlist.list:addItem(label)
		self.invlist.list:addItem(b)
	end
	self:updateEquipment()
end

function goo.equipment:updateEquipment()
	for i,v in ipairs(self.tabs) do
		itemtype,button = unpack(v)
		button:setItem(self.inv:getEquip(itemtype))
	end
end

return goo.equipment