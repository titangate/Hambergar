goo.inventory = class('goo inventory',goo.object)

function goo.inventory:initialize(parent)
	super.initialize(self,parent)
	self.invlist = goo.listcontainer:new(self)
	self.invlist:setPos(0,50)
	self.invlist:setSize(300,400)
	-- tab button
	self.tabs = {}
	self.currenttab = 'all'
end

function goo.inventory:setItemtype(itemtype)
	for i,v in ipairs(itemtype) do
		local b = goo.button:new(self)
		b:setPos(i*60,0)
		b:setSize(50,30)
		b:setText(v)
		table.insert(self.tabs,b)
		b.onClick = function(button)
			self:switchTab(v)
		end
	end
end

function goo.inventory:setInventory(inv)
	self.inv = inv
	self:switchTab()
end

function goo.inventory:addTab(tab,image)
	
end

function goo.inventory:switchTab(tab)
	tab = tab or 'all'
	if tab=='all' then
		self.inv:populateList(self.invlist.list)
	else
		self.inv:populateList(self.invlist.list,tab)
	end
	self.invlist.list:setPos(0,0)
	self.currenttab = tab
end

return goo.inventory