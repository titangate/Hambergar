
requireImage('assets/UI/slot.png','slotimg')
goo.itembuttonslot = class('goo itembuttonslot', goo.object)
function goo.itembuttonslot:initialize( parent )
	super.initialize(self,parent)
end
function goo.itembuttonslot:update(dt)
	super.update(self,dt)
end
function goo.itembuttonslot:draw()
	super.draw(self)
	if self.isEquipment then
		love.graphics.draw(img.slotimg)
	end
end

function goo.itembuttonslot:takeItem(item)
	if self.item then
		return false
	end
	self.item = item
	return true
end


function goo.itembuttonslot:clearItem()
	if self.item and self.isEquipment then
		if self.parent.unit then
			self.item.item:unequip(self.parent.unit)
		end
	end
	self.item = nil
end


goo.inventory = class('goo inventory', goo.object)
function goo.inventory:initialize(parent)
	super.initialize(self,parent)
	self.slots = {}
	self.availableslots = {}
end

function goo.inventory:update(dt)
	self.hoverslot = nil
	super.update(self,dt)
	for i,v in ipairs(self.slots) do
		if v:inBounds(love.mouse.getPosition()) then
			self.hoverslot = v
			break
		end
	end
end

function goo.inventory:removeItem(item)
	for k,v in pairs(self.slots) do
		if v.item == item then
			v:clearItem()			
		end
	end
end

function goo.inventory:handleDrag(item)
	local success = true
	if not self.hoverslot then
		success = false
	else
		if self.hoverslot.item == item then
			return success
		end
		if self.hoverslot:takeItem(item.item) then
		else
			success = false
		end
	end
	if success then
		item:setPos(self.hoverslot.x,self.hoverslot.y)
		self.hoverslot.item = item
		if self.hoverslot.isEquipment then
			if self.unit then
				item.item:equip(self.unit)
			end
		end
		if self.originslot then self.originslot:clearItem() end
	else
		item:setPos(item.originX,item.originY)
	end
	return success
end

function goo.inventory:setEquipmentActive(state)
	for k,v in pairs(self.slots) do
		if v.isEquipment and v.item then
			if state then
				v.item.item:equip(self.unit)
			else
				v.item.item:unequip(self.unit)
			end
		end
	end
end

function goo.inventory:addSlot(x,y,t,isEquipment)
	local is = goo.itembuttonslot:new(self)
	is:setSize(64,64)
	is:setPos(x,y)
	is.isEquipment = isEquipment
	if t then
		is.takeItem = function(self,item)
		
			if self.item or item.type ~= t then
				return false
			end
			self.item = item
			return true
		end
	end
	self.highlighted=is
	table.insert(self.slots,is)
	t = t or 'normal'
	if not self.availableslots[t] then
		self.availableslots[t] = {}
	end
	table.insert(self.availableslots[t],is)
end

function goo.inventory:pickUp(item)
	local slot = self:findEmptySlot(item.type)
	if not slot then return end
	item.button = goo.itembutton:new(self)
	item.button.item = item
	item.button:setPos(0,0)
	item.button:setSize(64,64)
	self.hoverslot = slot
	self.highlighted = self.hoverslot
	return item.button
end

function goo.inventory:findEmptySlot(t)
	if self.availableslots[t] then
		for k,v in ipairs(self.availableslots[t]) do
			if v.item == nil then
				return v
			end
		end
	end
	for k,v in ipairs(self.availableslots['normal']) do
		if v.item == nil then
			print (v,'is found on normal slot')
			return v
		end
	end

end

function goo.inventory:setItemPanels(panel1,panel2)
	-- panel 1 is for the panel on display
	-- panel 2 is for the reference display(equipped item for comparison etc. i don't have intention to implement this yet)
	self.panel1 = panel1 or self.panel1
	self.panel2 = panel2 or self.panel2
end

function goo.inventory:setUnit(unit)
	self.unit = unit
end

function goo.inventory:draw()
	local x,y = 0,0
	self:setColor(255,255,255)
	goo.drawBox(x,y,self.w,self.h)
end

function goo.inventory:save()
	local save = {}
	for k,v in pairs(self.slots) do
		if v.item and v.item.item then
			save[k]=v.item.item:className()
		end
	end
	return save
end

local responds = {
	LSL = 1,
	LSR = 1,
	LSU = 1,
	LSD = 1,
	w = 1,
	a = 1,
	s = 1,
	d = 1,
}

function goo.inventory:keypressed(k)
	if responds[k] then
		local x,y = controller:GetWalkDirection()
		local newlockon = self:direct(self.highlighted,{x,y},function(obj)
			return obj:isKindOf(goo.itembuttonslot)
		end)
		if newlockon then
			print (newlockon.x,newlockon.y)
			love.mouse.setPosition(self.x+newlockon.x+24,self.y+newlockon.y+24)
			self.highlighted = newlockon
		end
	end
end
function goo.inventory:clear()
	for k,v in pairs(self.slots) do
		if v.item then
			if v.isEquipment  then
				v.item.item:unequip(self.unit)
			end
			v.item:destroy()
			v.item = nil
		end
	end
end
function goo.inventory:load(save)
	for k,v in pairs(save) do
		local item = loadstring('return '..v..':new(0,0)')()
		self.hoverslot = self.slots[k]
		self:handleDrag(self:pickUp(item))
	end
end

goo.itempanel = class('goo itempanel', goo.ehpanel)
function goo.itempanel:initialize(parent)
	super.initialize(self,parent)
	self.elements = {}
	self.attributes={}
end
local function getstring(n)
	if type(n)=='function' then
		return tostring(n())
	else
		return tostring(n)
	end
end

function goo.itempanel:update(dt)
	super.update(self,dt)
	if self.follow then
		local x,y = love.mouse.getPosition()
		if y+self.h+20>screen.height then
			y = y-20-self.h
		else
			y = y+20
		end
		if x+self.w+20>screen.width then
			x = x-20-self.w
		else
			x = x+20
		end
		self:setPos(x,y)
	end
end

function goo.itempanel:updateData()
	for k,v in pairs(self.attributes) do
		if v.data then
			v:setText(getstring(v.data))
		end
	end
end

function goo.itempanel:setFollowerPanel(follow)
	self.follow = follow
end

function goo.itempanel:fillPanel(data,pedal)
	pedal = pedal or 5
	for k,v in pairs(self.attributes) do
		v:destroy()
	end
	for k,v in pairs(self.elements) do
		v:destroy()
	end
	self.elements = {}
	self.attributes={}
	self:setTitle(string.upper(data.title))
	local h = 0
	self.elements.type = goo.imagelabel:new(self)
	self.elements.type:setAlignMode('center')
	self.elements.type:setSize(self.w,30)
	self.elements.type:setText(string.upper(data.type))
	h = h+ self.elements.type.h + pedal
	for i,v in ipairs(data.attributes) do
		local a = goo.imagelabel:new(self)
		a:setSize(self.w,10)
		if v.image then
			a:setImage(v.image)
		end	
		a:setPos(0,h)
		a:setText(getstring(v.text))
		table.insert(self.attributes,a)
		if v.data then
			local b = goo.imagelabel:new(self)
			b:setAlignMode('right')
			b:setSize(self.w,10)
			b:setPos(0,h)
			b.data = v.data
			b:setText(getstring(v.data))
			table.insert(self.attributes,b)
		end
		h = h+a.h+pedal
	end	
	self:setSize(self.w,h+self.titleHeight)
end
return goo.inventory