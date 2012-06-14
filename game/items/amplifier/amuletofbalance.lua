
AmuletOfBalance = Item:subclass('AmuletOfBalance')
requireImage( 'assets/item/fiveslash.png','fiveslash' )

function AmuletOfBalance:initialize(x,y)
	super.initialize(self,'amplifier',x,y)
	self.name = "Amulet of Balance"
	self.stack = 1
	self.maxstack = 1
	self.HPRegen = 10
	self.MPRegen = 10
	self.armor = 10
	self.damage = 20
end


function AmuletOfBalance:equip(unit)
	super.equip(self,unit)
	unit.HPRegen = self.HPRegen + unit.HPRegen
	unit.MPRegen = self.MPRegen + unit.MPRegen
	unit.armor.Bullet = unit.armor.Bullet or 0
	unit.armor.Bullet = self.armor + unit.armor.Bullet
	unit.damagebuff.Bullet = unit.damagebuff.Bullet or 0
	unit.damagebuff.Bullet = unit.damagebuff.Bullet + self.damage
end

function AmuletOfBalance:unequip(unit)
	super.unequip(self,unit)
	unit.HPRegen = unit.HPRegen -self.HPRegen 
	unit.MPRegen =  unit.MPRegen - self.MPRegen
	unit.armor.Bullet =  unit.armor.Bullet - self.armor
	unit.damagebuff.Bullet = unit.damagebuff.Bullet - self.damage
end

function AmuletOfBalance:getPanelData()
	return {
		title = LocalizedString(self.name),
		type = LocalizedString(self.type),
		attributes = {
			{text="Homage to infinite light."},
			{data=self.HPregen,image=icontable.life,text="HP Regeneration"},
			{data=self.MPregen,image=icontable.mind,text="Energy Regeneration"},
			{image=nil,text="Damage Bonus",data=self.damage},
			{image=nil,text="Armor",data=self.armor},
		}
	}
end
function AmuletOfBalance:update(dt)
end

function AmuletOfBalance:draw(x,y)
	if not x then x,y = self.body:getPosition() end
	love.graphics.draw(icontable.amuletofbalance,x,y,0,1,1,24,24)
end
