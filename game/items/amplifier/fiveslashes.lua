
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
	super.equip(self,unit)
	unit.HPRegen = self.HPRegen + unit.HPRegen
	unit.MPRegen = self.MPRegen + unit.MPRegen
	unit.armor.Bullet = unit.armor.Bullet or 0
	unit.armor.Bullet = self.armor + unit.armor.Bullet
	unit.damagebuff.Bullet = unit.damagebuff.Bullet or 0
	unit.damagebuff.Bullet = unit.damagebuff.Bullet + self.damage
end

function FiveSlash:unequip(unit)
	super.unequip(self,unit)
	unit.HPRegen = unit.HPRegen -self.HPRegen 
	unit.MPRegen =  unit.MPRegen - self.MPRegen
	unit.armor.Bullet =  unit.armor.Bullet - self.armor
	unit.damagebuff.Bullet = unit.damagebuff.Bullet - self.damage
end

function FiveSlash:getPanelData()
	return {
		title = LocalizedString(self.name),
		type = LocalizedString(self.type),
		attributes = {
			{text=LocalizedString"A symbol of courage and power."},
			{data=self.HPregen,image=icontable.life,text=LocalizedString"HP Regeneration"},
			{data=self.MPregen,image=icontable.mind,text=LocalizedString"Energy Regeneration"},
			{image=nil,text=LocalizedString"Damage Bonus",data=self.damage},
			{image=nil,text=LocalizedString"Armor",data=self.armor},
		}
	}
end
function FiveSlash:update(dt)
end

function FiveSlash:draw(x,y)
	if not x then x,y = self.body:getPosition() end
	love.graphics.draw(img.fiveslash,x,y,0,1,1,24,24)
end

return FiveSlash
