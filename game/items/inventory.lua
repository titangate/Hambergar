-- inventory
Inventory=Object:subclass('Inventory')
function Inventory:initialize(unit)
	self.items={}
	self.unit=unit
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
end

function Inventory:hasItem(itemtype)
	for k,v in pairs(self.items) do
		if v[itemtype] then
			return true
		end
	end
	return false
end

function Inventory:removeItem(item,count)
	count = count or 1
	for k,v in pairs(self.items) do
		if v[itemtype] then
			local item=v[itemtype]
			item.stack = item.stack - count
			if item.stack<=0 then
				v[itemtype]=nil
			end
		end
	end
end

function Inventory:useItem(item)
	assert(self.unit)
	for k,v in pairs(self.items) do
		if v[item] then
			item:use(self.unit)
		end
	end
end

function Inventory:getItemByType(itemtype)
	for k,v in pairs(self.items) do
		if v[itemtype] then
			return v[itemtype]
		end
	end
end

function Inventory:interateItems(itemtype)
	if itemtype then
		return function()
			return next,self.items[itemtype],nil
		end
	else
		local it=function()
			for _,itemtype in pairs(self.items) do
				for name,item in pairs(itemtype) do
					coroutine.yield(item)
				end
			end
		end
		return coroutine.wrap(it)
	end

end
