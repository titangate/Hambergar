
SpiritStone = Item:subclass('SpiritStone')

function SpiritStone:initialize(x,y)
	super.initialize(self,'trophy',x,y)
	self.name = "The Arch"
	self.stack = 1
	self.maxstack = 1
	self.damagereduction = 0.4
	self.icon = requireImage'assets/item/spiritstone.png'
	self.HPRegen = 10
	self.MPRegen = 10
end

function SpiritStone:equip(unit)
super.equip(self,unit)
--	unit.movementspeedbuffpercent = self.movementspeedbuffpercent + unit.movementspeedbuffpercent
unit.HPRegen = self.HPRegen + unit.HPRegen
unit.MPRegen = self.MPRegen + unit.MPRegen
--	unit.maxmp = self.maxmp + unit.maxmp
end

function SpiritStone:unequip(unit)
super.unequip(self,unit)
--	unit.movementspeedbuffpercent = unit.movementspeedbuffpercent -self.movementspeedbuffpercent 
unit.HPRegen =  unit.HPRegen - self.HPRegen
unit.MPRegen =  unit.MPRegen - self.MPRegen
--	unit.maxmp =  unit.maxmp - self.maxmp
end

function SpiritStone:getPanelData()
	return {
		title = LocalizedString(self.name),
		type = LocalizedString'TROPHY FROM MASTER YUEN',
		attributes = {
			{text=LocalizedString"The spirit lies within."},
			{data=self.HPRegen,image=icontable.life,text=LocalizedString"HP Regeneration"},
			{data=self.MPRegen,image=icontable.mind,text=LocalizedString"MP Regeneration"},
--			{data=self.maxmp,image=icontable.mind,text="Energy Bonus"},
--			{image=nil,text="Movement Speed Bonus",data=string.format("0/%.1f%%",self.movementspeedbuffpercent*100)},
		}
	}
end

function SpiritStone:update(dt)
end

function SpiritStone:draw(x,y)
	if not x then x,y = self.body:getPosition() end
	love.graphics.draw(self.icon,x,y,0,0.375,0.375,64,64)
end


return SpiritStone
