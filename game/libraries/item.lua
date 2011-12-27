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
		gamelistener:notify{
			type = 'pickup',
			unit = b,
			item = self,
		}
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

function Item:equip(unit)
	self.equipped = true
	gamelistener:notify{
		type = 'equip',
		item = self,
		unit = unit,
		action = 'equip',
	}
end

function Item:unequip(unit)
	self.equipped = false
	
	gamelistener:notify{
		type = 'equip',
		item = self,
		unit = unit,
		action = 'unequip',
	}
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
