
Hourglass = Item:subclass('Hourglass')
requireImage( 'assets/item/hourglass.png','hourglass' )

function Hourglass:initialize(x,y)
	super.initialize(self,'artifact',x,y)
	self.name = "The Client"
	self.stack = 1
	self.maxstack = 1
	self.timescale = 0.35
end

function Hourglass:equip(unit)
	super.equip(self,unit)
	unit.timescale = self.timescale + unit.timescale
end

function Hourglass:unequip(unit)
	super.unequip(self,unit)
	unit.timescale = unit.timescale - self.timescale
end

function Hourglass:getPanelData()
	return {
		title = self.name,
		type = self.type,
		attributes = {
			{text="A mystical hourglass that accelerate the time of its bearer."},
			{data=self.timescale,image=nil,text="Increase bearer timescale"},
		--	{image=nil,text="Armor",data=self.armor},
		}
	}
end

function Hourglass:update(dt)
end

function Hourglass:draw(x,y)
	if not x then x,y = self.body:getPosition() end
	love.graphics.draw(img.hourglass,x,y,0,0.1875,0.1875,128,128)
end