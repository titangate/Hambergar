
Spirit = Item:subclass('Spirit')

function Spirit:initialize(x,y)
	super.initialize(self,'artifact',x,y)
	self.name = "Spirit of the North"
	self.stack = 1
	self.maxstack = 1
	self.timescale = 0.35
end

function Spirit:equip(unit)
	super.equip(self,unit)
	unit.timescale = self.timescale + unit.timescale
end

function Spirit:unequip(unit)
	super.unequip(self,unit)
	unit.timescale = unit.timescale - self.timescale
end

function Spirit:getPanelData()
	return {
		title = LocalizedString(self.name),
		type = LocalizedString(self.type),
		attributes = {
			{text="A mystical Spirit that accelerate the time of its bearer."},
			{data=self.timescale,image=nil,text="Increase bearer timescale"},
		--	{image=nil,text="Armor",data=self.armor},
		}
	}
end

function Spirit:update(dt)
end

function Spirit:draw(x,y)
	if not x then x,y = self.body:getPosition() end
	love.graphics.draw(requireImage('assets/item/spirit.png','spiriticon'),x,y,0,0.1875,0.1875,128,128)
end

return Spirit