
RingOfFire = Item:subclass('RingOfFire')

function RingOfFire:initialize(x,y)
	super.initialize(self,'trophy',x,y)
	self.name = "Ring Of Fire"
	self.stack = 1
	self.maxstack = 1
	self.maxhp = 400
	self.icon = requireImage'assets/item/ringoffire.png'
end

function RingOfFire:equip(unit)
super.equip(self,unit)
--	unit.movementspeedbuffpercent = self.movementspeedbuffpercent + unit.movementspeedbuffpercent
	unit.maxhp = self.maxhp + unit.maxhp
--	unit.maxmp = self.maxmp + unit.maxmp
end

function RingOfFire:unequip(unit)
super.unequip(self,unit)
--	unit.movementspeedbuffpercent = unit.movementspeedbuffpercent -self.movementspeedbuffpercent 
	unit.maxhp =  unit.maxhp - self.maxhp
--	unit.maxmp =  unit.maxmp - self.maxmp
end

function RingOfFire:getPanelData()
	return {
		title = LocalizedString(self.name),
		type = LocalizedString'TROPHY FROM HANS',
		attributes = {
			{text=LocalizedString"This ring is boiling hot, the force of life in within."},
			{data=self.maxhp,image=icontable.life,text=LocalizedString"HP Bonus"},
--			{data=self.maxmp,image=icontable.mind,text="Energy Bonus"},
--			{image=nil,text="Movement Speed Bonus",data=string.format("0/%.1f%%",self.movementspeedbuffpercent*100)},
		}
	}
end

function RingOfFire:update(dt)
end

function RingOfFire:draw(x,y)
	if not x then x,y = self.body:getPosition() end
	love.graphics.draw(self.icon,x,y,0,0.375,0.375,64,64)
end

return RingOfFire