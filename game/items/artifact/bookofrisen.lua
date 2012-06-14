
BookOfRisen = Item:subclass('BookOfRisen')
requireImage( 'assets/item/feather.png','feather' )

function BookOfRisen:initialize(x,y)
	super.initialize(self,'artifact',x,y)
	self.name = "Book Of Risen"
	self.stack = 1
	self.maxstack = 1
	self.maxhp = 10
	self.maxmp = 50
	self.MPRegen = 5
	self.damage = 20
end

function BookOfRisen:equip(unit)
	super.equip(self,unit)
	unit.MPRegen = self.MPRegen + unit.MPRegen
	unit.maxmp = self.maxmp + unit.maxmp
end

function BookOfRisen:unequip(unit)
	super.unequip(self,unit)
	unit.MPRegen =  unit.MPRegen - self.MPRegen
	unit.maxmp =  unit.maxmp - self.maxmp
end

function BookOfRisen:getPanelData()
	return {
		title = LocalizedString(self.name),
		type = LocalizedString(self.type),
		attributes = {
			{text="The pages on this book is surprising clean as if it was untouched for ages"},
			{image=icontable.quote,text="It is told that the yetis in Whistler are not capable of verbal communication. That's simply not true. After spending years learning their language, I was finally able to write down one of their most well known legend: the Risen. 3000 years ago, one god they worshipped appeared in front of them in the form of a traveller. The blood thirsty yetis ripped his gut out. The death of the god is accompanied with significant change in weather, that's why they were exiled into the snow for years and years to come. They built this temple to remind themselves of what brute force did to them."},
			{data=self.MPRegen,image=icontable.mind,text="MP Regen"},
			{data=self.maxmp,image=icontable.mind,text="Energy Bonus"},
		--	{image=nil,text="Armor",data=self.armor},
		}
	}
end

function BookOfRisen:update(dt)
end

function BookOfRisen:draw(x,y)
	if not x then x,y = self.body:getPosition() end
	love.graphics.draw(img.feather,x,y,0,1,1,24,24)
end

return BookOfRisen