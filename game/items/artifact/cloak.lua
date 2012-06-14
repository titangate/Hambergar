
Cloak = Item:subclass('Cloak')
requireImage( 'assets/item/cloak.png','Cloak' )

function Cloak:initialize(x,y)
	super.initialize(self,'artifact',x,y)
	self.name = "The Judge"
	self.stack = 1
	self.maxstack = 1
end

function Cloak:equip(unit)
	super.equip(self,unit)
	unit.cloak = true
end

function Cloak:unequip(unit)
	super.unequip(self,unit)
	unit.cloak = false
end

function Cloak:getPanelData()
	return {
		title = self.name,
		type = self.type,
		attributes = {
			{text="Justice be served.",image = icontable.quote},
			{text="Decrease all negative buffs' druations by half."},
		}
	}
end

function Cloak:update(dt)
end

function Cloak:draw(x,y)
	if not x then x,y = self.body:getPosition() end
	love.graphics.draw(img.Cloak,x,y,0,0.1875,0.1875,128,128)
end

return Cloak