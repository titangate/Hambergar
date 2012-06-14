
DragonicShield = Item:subclass('DragonicShield')

function DragonicShield:initialize(x,y)
	super.initialize(self,'trophy',x,y)
	self.name = "Eternal Dragon"
	self.stack = 1
	self.maxstack = 1
	self.damagereduction = 0.4
	self.icon = requireImage'assets/item/shield.png'
	self.armor = 10
	self.MPRegen = 10
end

function DragonicShield:equip(unit)
super.equip(self,unit)
--	unit.movementspeedbuffpercent = self.movementspeedbuffpercent + unit.movementspeedbuffpercent
--unit.HPRegen = self.HPRegen + unit.HPRegen
--unit.MPRegen = self.MPRegen + unit.MPRegen
--	unit.maxmp = self.maxmp + unit.maxmp
	unit.armor.Bullet = unit.armor.Bullet or 0
	unit.armor.Bullet = self.armor + unit.armor.Bullet
end

function DragonicShield:unequip(unit)
super.unequip(self,unit)
--	unit.movementspeedbuffpercent = unit.movementspeedbuffpercent -self.movementspeedbuffpercent 
unit.armor.Bullet = - self.armor + unit.armor.Bullet
--	unit.maxmp =  unit.maxmp - self.maxmp
end

function DragonicShield:getPanelData()
	return {
		title = self.name,
		type = 'TROPHY FROM BRANDON',
		attributes = {
			{text="TBA"},
			{data=self.armor,text="Armor"},
--			{data=self.maxmp,image=icontable.mind,text="Energy Bonus"},
--			{image=nil,text="Movement Speed Bonus",data=string.format("0/%.1f%%",self.movementspeedbuffpercent*100)},
		}
	}
end

function DragonicShield:update(dt)
end

function DragonicShield:draw(x,y)
	if not x then x,y = self.body:getPosition() end
	love.graphics.draw(self.icon,x,y,0,0.375,0.375,64,64)
end

return DragonicShield

