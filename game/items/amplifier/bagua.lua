
Bagua = Item:subclass('Bagua')
requireImage'assets/item/taiji.png'

function Bagua:initialize(x,y)
	super.initialize(self,'amplifier',x,y)
	self.name = "TAIJI"
	self.stack = 1
	self.maxstack = 1
	self.critdmg = 1
	self.critchance = 0.15
end


function Bagua:equip(unit)
	super.equip(self,unit)
	unit.critical = unit.critical or {2,0}
	unit.critical[1] = unit.critical[1] + self.critdmg
	unit.critical[2] = unit.critical[2] + self.critchance
end

function Bagua:unequip(unit)
	super.unequip(self,unit)
	unit.critical[1] = unit.critical[1] - self.critdmg
	unit.critical[2] = unit.critical[2] - self.critchance
end

function Bagua:getPanelData()
	return {
		title = LocalizedString(self.name),
		type = LocalizedString(self.type),
		attributes = {
			{text=LocalizedString"The ancient founder of Taoism has figured the intention of the creator. He has forged this powerful symbol that can help its bearer master his destiny."},
			{image=nil,text=LocalizedString"Critical Hit Chance",data=string.format('%.1f',self.critchance*100)},
			{image=nil,text=LocalizedString"Critical Hit Damage",data=self.critdmg},
		}
	}
end

function Bagua:update(dt)
end

function Bagua:draw(x,y)
	if not x then x,y = self.body:getPosition() end
	love.graphics.draw(img.taiji,x,y,0,0.1875,0.1875,128,128)
end
