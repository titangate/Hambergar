
AuroSkull = Item:subclass('AuroSkull')
requireImage( 'assets/item/feather.png','feather' )

function AuroSkull:initialize(x,y)
	super.initialize(self,'trophy',x,y)
	self.name = "Auro Skull"
	self.stack = 1
	self.maxstack = 1
	self.maxhp = 10
	self.maxmp = 10
	self.movementspeedbuffpercent = 0.5
	self.damage = 20
end

function AuroSkull:equip(unit)
super.equip(self,unit)
	unit.movementspeedbuffpercent = self.movementspeedbuffpercent + unit.movementspeedbuffpercent
	unit.maxhp = self.maxhp + unit.maxhp
	unit.maxmp = self.maxmp + unit.maxmp
end

function AuroSkull:unequip(unit)
super.unequip(self,unit)
	unit.movementspeedbuffpercent = unit.movementspeedbuffpercent -self.movementspeedbuffpercent 
	unit.maxhp =  unit.maxhp - self.maxhp
	unit.maxmp =  unit.maxmp - self.maxmp
end

function AuroSkull:getPanelData()
	return {
		title = self.name,
		type = self.type,
		attributes = {
			{text=LocalizedString"This mysterious skull keeps emiting ghostly light."},
			{data=self.maxhp,image=icontable.life,text=LocalizedString"HP Bonus"},
			{data=self.maxmp,image=icontable.mind,text=LocalizedString"Energy Bonus"},
			{image=nil,text=LocalizedString"Movement Speed Bonus",data=string.format("0/%.1f%%",self.movementspeedbuffpercent*100)},
		}
	}
end
function AuroSkull:update(dt)
end

function AuroSkull:draw(x,y)
	if not x then x,y = self.body:getPosition() end
	love.graphics.draw(img.feather,x,y,0,1,1,24,24)
end





return AuroSkull
