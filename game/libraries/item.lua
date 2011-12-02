function join(di,t)
	w = ''
	for i,v in ipairs(t) do
		if i==1 then
			w = v
		else
			w = w..di..v
		end
	end
	return w
end

Item = Object:subclass('Item')
function Item:initialize(type,x,y)
	self.type = type
	self.x,self.y = x,y
	self.stack = 1
end

function Item:createBody(world)
	self.body = love.physics.newBody(world,self.x,self.y)
	self.shape = love.physics.newCircleShape(self.body,0,0,16)
	self.shape:setSensor(true)
	self.shape:setMask(1,2,4,5,6,7,8,9,10,11,12,13,14,15,16)
	self.shape:setData(self)
end

function Item:add(b,coll)
	if b:isKindOf(Character) then
		b.inventory:addItem(self)
		map:removeUnit(self)
	end
end

function Item:getQuickInfo()
	local t = {string.upper(self.type)}
	if self.stack > 1 then
		table.insert(t,'STACK '..tostring(self.stack))
	end
	if self.equipped then
		table.insert(t,'EQUIPPED')
	end
	return join(' // ',t)
end
	
function Item:preremove()
	self.shape:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
end

function Item:destroy()
	self.shape:destroy()
	self.body:destroy()
end

function Item:allow(item)
	return not self.fixed
end

function Item:equip()
	self.equipped = true
end

function Item:unequip()
	self.equipped = false
end

function Item:isEquipment()
	return self.equipped
end

function Item:getCDPercent()
	local groupname = self.groupname or self:className()
	local cddt = self.unit:getCD(groupname) or 0
	return cddt/self.cd
end

requireImage( 'assets/UI/slot.png','slotimg' )
ItemSlot = Button:subclass('ItemSlot')
function ItemSlot:initialize(group,x,y,w,h,id)
	self.id = id
	super.initialize(self,group,x,y,w,h)
end

function ItemSlot:draw()
	love.graphics.setColor(255,255,255,163)
	love.graphics.draw(img.slotimg,self.x+self.w/2,self.y+self.h/2,0,1,1,32,32)
	love.graphics.setColor(255,255,255,255)
end
--[[
Inventory = Object:subclass('Inventory')
function Inventory:initialize(x,y,w,h,unit)
	self.w,self.h = w,h
--	self.itemstack = {}
	self.itembutton = {}
	self.typeitem = {}
	self.grid = {}
	self.panel = AttributeCollection:new(self.w*50,self.h*50)
	self.itempanel = AttributeCollection:new(300,0)
	self.unit = unit
	self.equipslots = {}
	self.equipslots[-1] = ITEM_CONSUMABLE
	self.equipslots[-2] = ITEM_AMPLIFIER
	self.equipslots[-3] = ITEM_ARTIFACT
	self.equipslots[-4] = ITEM_TROPHY
	self.equipslots[-5] = ITEM_SECONDARY
	self.equipbuttons = {
		ItemSlot:new(self,love.graphics.getWidth()-170,love.graphics.getHeight()-200,50,50,-2),
			ItemSlot:new(self,love.graphics.getWidth()-104,love.graphics.getHeight()-314,50,50,-3),
				ItemSlot:new(self,love.graphics.getWidth()-50,love.graphics.getHeight()-220,50,50,-4),
					ItemSlot:new(self,love.graphics.getWidth()-335,love.graphics.getHeight()-260,50,50,-5),
		ItemSlot:new(self,60,love.graphics.getHeight()-90,50,50,-1)
	}
	self.equipments = {}
end

function Inventory:draw()
	self.panel:d_draw(self.x,self.y)
	for k,v in pairs(self.equipbuttons) do
		v:draw()
	end
	for k,v in pairs(self.itembutton) do
		v:draw()
	end
end

function Inventory:updateEquip()
	for k,v in ipairs(self.equipments) do
		v:unequip(self.unit)
	end
	self.equipments = {}
	for k,v in pairs(self.equipslots) do
		local equipment = self.grid[k]
		print (equipment)
		if equipment and equipment.equip then
			equipment:equip(self.unit)
			table.insert(self.equipments,equipment)
		end
	end
end

function Inventory:update(dt)
end

function Inventory:i_update(dt)
	for k,v in pairs(self.itembutton) do
		v:update(dt)
	end
	for k,v in pairs(self.equipbuttons) do
		v:update(dt)
	end
end

function Inventory:removeItem(item)
	self.itembutton[item]=nil
	for k,v in ipairs(self.typeitem[item:className()]) do
		if v==item then
			table.remove(self.typeitem[item:className()],k)
		end
	end
	for i,v in pairs(self.grid) do
		if v==item then
			self.grid[i] = nil
		end
	end
end

function Inventory:findEmplySlotOnGrid()
	for i = 0,self.w*self.h do
		print ('stuff on grid',i,self.grid[i])
		if not self.grid[i] then
			return i
		end
	end
	return nil
end

function Inventory:findPositionOnGrid(x,y)
	for k,v in pairs(self.equipbuttons) do
		if v.hover then
			return v.id
		end
	end
	local x,y=x-self.x,y-self.y
	if x>50*self.w or x<0 then return nil end
	x,y=math.floor(x/50),math.floor(y/50)
	local i = x+self.w*y
	print (i)
	if self.equipslots[i] then return i end
	if i<0 or i>self.w*self.h then return nil end
	return i
end

function Inventory:findGridPosition(i)
	if i<0 then
		for k,v in pairs(self.equipbuttons) do
			if v.id == i then
				return v.x,v.y
			end
		end
	end
	return self.x+(i%self.w)*50,self.y+math.floor(i/self.w)*50
end

function Inventory:findTargetItem(i)
	return self.grid[i]
end

function Inventory:repositionItem(item,i)
	for k,v in pairs(self.grid) do
		if v==item then
			self.grid[k] = nil
		end
	end
	self.grid[i] = item
	local button = self.itembutton[item]
--	print (item)
	button.x,button.y = self:findGridPosition(i)
--	self:updateEquip()
end

function Inventory:addToGrid(item)
	local slot = self:findEmplySlotOnGrid()
	if not slot then return false end
	print ('fount slot',slot)
	local x,y = self:findGridPosition(slot)
	self.itembutton[item] = ItemButton:new(self,x,y,48,48,item)
	self.grid[slot] = item
	item.unit = self.unit
	self.typeitem[item:className()] = self.typeitem[item:className()] or {}
	table.insert(self.typeitem[item:className()],item)
	return true
end

function Inventory:pickUp(item)
	local itemtype = item:className()
	--if self.typeitem[itemtype] ~= {} then
	print ('start iterating typeitem')
	if self.typeitem[itemtype] then
		for i,v in ipairs(self.typeitem[itemtype]) do
			print (i,v)
			if v.stack < v.maxstack then
				v.stack = item.stack + v.stack
				return true
			end
		end
		print ('not found')
		return self:addToGrid(item)
	else
		return self:addToGrid(item)
	end
end]]
