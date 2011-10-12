
-- inventory
Inventory=Object:subclass('Inventory')
function Inventory:initialize(unit)
	self.items={}
	self.unit=unit
	self.equipments={}
	self.updateInvUI=function()
		print ('attempt to update UI')
	end
	-- item is stored as a 2-d array, indexed (itemtype,itemname)
end

function Inventory:addItem(item)
	local t=item.type
	local n=item.name
	self.items[t]=self.items[t] or {}
	if self.items[t][n] then
		self.items[t][n].stack = self.items[t][n].stack+1 
	else
		self.items[t][n]=item
	end
	self.updateInvUI()
end

function Inventory:hasItem(itemtype)
	for k,v in pairs(self.items) do
		if v[itemtype] then
			return true
		end
	end
	return false
end

function Inventory:removeItem(itemtype,count)
	count = count or 1
	for k,v in pairs(self.items) do
		if v[itemtype] then
			local item=v[itemtype]
			item.stack = item.stack - count
			if item.stack==0 then
				v[itemtype]=nil
				for k,v in pairs(self.equipments) do
					if v==item then
						self.equipments[k] = nil
					end
				end
				self.updateInfoPanel()
			end
		end
	end
	self.updateInvUI()
end

function Inventory:useItem(item)
	assert(self.unit)
	for k,v in pairs(self.items) do
		if v[item] then
			v[item]:use(self.unit)
			self:removeItem(item,1)
		end
	end
	self.updateInvUI()
end

function Inventory:getItemByType(itemtype)
	for k,v in pairs(self.items) do
		if v[itemtype] then
			return v[itemtype]
		end
	end
end

function Inventory:iterateItems(itemtype)
	if itemtype then
		self.items[itemtype]=self.items[itemtype] or {}
		return pairs(self.items[itemtype])
	else
		local it=function()
			for _,itemtype in pairs(self.items) do
				for name,item in pairs(itemtype) do
					coroutine.yield(name,item)
				end
			end
		end
		return coroutine.wrap(it)
	end

end

function Inventory:equipItem(item)
	if item.type == 'weapon' and item.char ~= self.unit:className() then
		return 
	end
	local i = self.equipments[item.type]
	if i then
		i:unequip(self.unit)
	end
	item:equip(self.unit)
	self.equipments[item.type]=item
	self.updateInvUI()
end

function Inventory:unequipItem(item)
--	local item = self:getItemByType(item)
	item:unequip(self.unit)
	self.equipments[item.type]=nil
	self.updateInvUI()
end

function Inventory:getEquip(itemtype)
	return self.equipments[itemtype]
end

function Inventory:interactItem(item,condition)
	if item then
		if condition == 'inventory' then
			if item.use then
				if not self.unit:getCD(item.groupname) then
					self:useItem(item.name)
				end
			elseif item.equip then
				self:equipItem(item)
			end
		elseif condition == 'equipment' then
			self:unequipItem(item)
		end
	end
end

function Inventory:populateList(list,type)
	list:clear()
	for k,v in self:iterateItems(type) do
		local b = goo.itembutton:new(list)
		b:setItem(v)
		b:setSize(list.w,50)
		b:setInventory(self)
		b.buttontype = 'inventory'
		list:addItem(b,k)
	end
end

function Inventory:clear()
	self.items = {}
end

function Inventory:save()
	-- TODO
	local t = {}
	for k,v in self:iterateItems() do
		t[v:className()]=v.stack
	end
	for k,v in pairs(self.equipments) do
		t[v:className()] = 'equip'
	end
	return t
end

function Inventory:load(save)
	-- TODO
	for k,v in pairs(save) do
		local f = loadstring('return '..k)
		if f() then
			local k = f()()
			self:addItem(k)
			if v=='equip' then
				self:equipItem(k)
			else
				k.stack = v
			end
		end
	end
end

function Inventory:setEquipmentActive(status)
	if status then
		for k,v in pairs(self.equipments) do
			v:equip(self.unit)
		end
	else
		for k,v in pairs(self.equipments) do
			v:unequip(self.unit)
		end
	end
end
