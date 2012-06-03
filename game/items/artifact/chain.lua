
PrayerBeads = Item:subclass('PrayerBeads')
requireImage( 'assets/item/chain.png','PrayerBeads' )

function PrayerBeads:initialize(x,y)
	super.initialize(self,'artifact',x,y)
	self.name = "Prayer Beads"
	self.stack = 1
	self.maxstack = 1
end

function PrayerBeads:equip(unit)
	super.equip(self,unit)
	unit:beads(true)
end

function PrayerBeads:unequip(unit)
	super.unequip(self,unit)
	unit:beads(false)
end

function PrayerBeads:getPanelData()
	return {
		title = self.name,
		type = self.type,
		attributes = {
			{text="A jug fills drop by drop.",image = icontable.quote},
			{text="Decrease Dash cooldown and cost by half."},
		}
	}
end

function PrayerBeads:update(dt)
end

function PrayerBeads:draw(x,y)
	if not x then x,y = self.body:getPosition() end
	love.graphics.draw(img.PrayerBeads,x,y,0,0.1875,0.1875,128,128)
end