
FiveSlash = Item:subclass('FiveSlash')
requireImage( 'assets/item/fiveslash.png','fiveslash' )

function FiveSlash:initialize(x,y)
	super.initialize(self,'amplifier',x,y)
	self.name = "FIVE SLASHES"
	self.stack = 1
	self.maxstack = 1
	self.HPRegen = 10
	self.MPRegen = 10
	self.armor = 10
	self.damage = 20
end


function FiveSlash:equip(unit)
	unit.HPRegen = self.HPRegen + unit.HPRegen
	unit.MPRegen = self.MPRegen + unit.MPRegen
	unit.armor.Bullet = unit.armor.Bullet or 0
	unit.armor.Bullet = self.armor + unit.armor.Bullet
	unit.damagebuff.Bullet = unit.damagebuff.Bullet or 0
	unit.damagebuff.Bullet = unit.damagebuff.Bullet + self.damage
end

function FiveSlash:unequip(unit)
	unit.HPRegen = unit.HPRegen -self.HPRegen 
	unit.MPRegen =  unit.MPRegen - self.MPRegen
	unit.armor.Bullet =  unit.armor.Bullet - self.armor
	unit.damagebuff.Bullet = unit.damagebuff.Bullet - self.damage
end

function FiveSlash:fillPanel(panel)
	panel:addItem(DescriptionAttributeItem:new(function()
		return self.name end,
		panel.w,30))
	panel:addItem(DescriptionAttributeItem:new(function()
		return "AMPLIFIER" end,
		panel.w,20))
	panel:addItem(DescriptionAttributeItem:new(function()
		return "A SYMBOL OF POWER AND STRENGTH" end,
		panel.w,45))
	panel:addItem(SimpleAttributeItem:new(
		function()
		return self.HPRegen end,
		function()
		return "HP Regeneration" end,
		'life',panel.w))
	panel:addItem(SimpleAttributeItem:new(
		function()
		return self.MPRegen end,
		function()
		return "Energy Regeneration" end,
		'mind',panel.w))
	panel:addItem(SimpleAttributeItem:new(
		function()
		return self.damage end,
		function()
		return "Damage Bonus" end,
		nil,panel.w))
	panel:addItem(SimpleAttributeItem:new(
		function()
		return self.armor end,
		function()
		return "Armor" end,
		nil,panel.w))
end


function FiveSlash:getPanelData()
	return {
		title = self.name,
		type = self.type,
		attributes = {
			{text="A symbol of courage and power."},
			{data=self.HPregen,image=icontable.life,text="HP Regeneration"},
			{data=self.MPregen,image=icontable.mind,text="Energy Regeneration"},
			{image=nil,text="Damage Bonus",data=self.damage},
			{image=nil,text="Armor",data=self.armor},
		}
	}
end
function FiveSlash:update(dt)
end

function FiveSlash:draw(x,y)
	if not x then x,y = self.body:getPosition() end
	love.graphics.draw(img.fiveslash,x,y,0,1,1,24,24)
end