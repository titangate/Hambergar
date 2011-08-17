
PeacockFeather = Item:subclass('PeacockFeather')
feather = love.graphics.newImage('assets/item/feather.png')

function PeacockFeather:initialize(x,y)
	super.initialize(self,'trophy',x,y)
	self.name = "Peacock Feather"
	self.stack = 1
	self.maxstack = 1
	self.maxhp = 10
	self.maxmp = 10
	self.movementspeedbuffpercent = 0.5
	self.damage = 20
end

function PeacockFeather:equip(unit)
	unit.movementspeedbuffpercent = self.movementspeedbuffpercent + unit.movementspeedbuffpercent
	unit.maxhp = self.maxhp + unit.maxhp
	unit.maxmp = self.maxmp + unit.maxmp
end

function PeacockFeather:unequip(unit)
	unit.movementspeedbuffpercent = unit.movementspeedbuffpercent -self.movementspeedbuffpercent 
	unit.maxhp =  unit.maxhp - self.maxhp
	unit.maxmp =  unit.maxmp - self.maxmp
end

function PeacockFeather:fillPanel(panel)
	panel:addItem(DescriptionAttributeItem:new(function()
		return self.name end,
		panel.w,30))
	panel:addItem(DescriptionAttributeItem:new(function()
		return "TROPHY" end,
		panel.w,20))
	panel:addItem(DescriptionAttributeItem:new(function()
		return "THIS FEATHER WAS GIVEN BY RIVER'S LOVER." end,
		panel.w,45))
	panel:addItem(SimpleAttributeItem:new(
		function()
		return self.maxhp end,
		function()
		return "HP Bonus" end,
		'life',panel.w))
	panel:addItem(SimpleAttributeItem:new(
		function()
		return self.maxmp end,
		function()
		return "Energy Bonus" end,
		'mind',panel.w))
	panel:addItem(SimpleAttributeItem:new(
		function()
		return string.format("0/%.1f%%",self.movementspeedbuffpercent*100) end,
		function()
		return "Movement Speed Bonus" end,
		nil,panel.w))
end



function PeacockFeather:getPanelData()
	return {
		title = self.name,
		type = self.type,
		attributes = {
			{text="Given as a token of graditute by one of River's greatest companion."},
			{data=self.maxhp,image=icontable.life,text="HP Bonus"},
			{data=self.maxmp,image=icontable.mind,text="Energy Bonus"},
			{image=nil,text="Movement Speed Bonus",data=string.format("0/%.1f%%",self.movementspeedbuffpercent*100)},
		--	{image=nil,text="Armor",data=self.armor},
		}
	}
end

function PeacockFeather:update(dt)
end

function PeacockFeather:draw(x,y)
	if not x then x,y = self.body:getPosition() end
	love.graphics.draw(feather,x,y,0,1,1,24,24)
end