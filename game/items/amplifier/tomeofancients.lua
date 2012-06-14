
TomeOfAncients = Item:subclass('TomeOfAncients')
requireImage'assets/item/tome.png'

function TomeOfAncients:initialize(x,y)
	super.initialize(self,'amplifier',x,y)
	self.name = "Tome of Ancient"
	self.stack = 1
	self.maxstack = 1
end


function TomeOfAncients:equip(unit)
	super.equip(self,unit)
	unit:tome(true)
end

function TomeOfAncients:unequip(unit)
	super.unequip(self,unit)	
	unit:tome(false)
end

function TomeOfAncients:getPanelData()
	return {
		title = LocalizedString(self.name),
		type = LocalizedString(self.type),
		attributes = {
			{text=LocalizedString"PUSHEEN IS AWESOME",image=icontable.quote},
			{text=LocalizedString"Decrease the ultimate cooldown by half. Ignore ultimate launch requirement."},
		}
	}
end
function TomeOfAncients:update(dt)
end

function TomeOfAncients:draw(x,y)
	if not x then x,y = self.body:getPosition() end
	love.graphics.draw(img.tome,x,y,0,0.1875,0.1875,128,128)
end
