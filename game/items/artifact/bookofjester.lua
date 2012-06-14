
BookOfJester = Item:subclass('BookOfJester')
requireImage( 'assets/item/feather.png','feather' )

function BookOfJester:initialize(x,y)
	super.initialize(self,'artifact',x,y)
	self.name = "Book Of Jester"
	self.stack = 1
	self.maxstack = 1
	self.movementspeedbuffpercent = 0.3
	self.spellspeedbuffpercent = 0.2
end

function BookOfJester:equip(unit)
	super.equip(self,unit)
	unit.movementspeedbuffpercent = self.movementspeedbuffpercent + unit.movementspeedbuffpercent
	unit.spellspeedbuffpercent = self.spellspeedbuffpercent + unit.spellspeedbuffpercent
end

function BookOfJester:unequip(unit)
	super.unequip(self,unit)
	unit.movementspeedbuffpercent = unit.movementspeedbuffpercent -self.movementspeedbuffpercent 
	unit.spellspeedbuffpercent = self.spellspeedbuffpercent - unit.spellspeedbuffpercent
end

function BookOfJester:getPanelData()
	return {
		title = self.name,
		type = self.type,
		attributes = {
			{image=icontable.quote,text="What do you call a yeti in a whorehouse? Him-a-layin'"},
			{image=icontable.jesterpuzzle},
			{text="HAHA!"},
			{data=self.movementspeedbuffpercent,image=icontable.mind,text="Movement Speed Bonus"},
			{data=self.spellspeedbuffpercent,image=icontable.mind,text="Skill Speed Bonus"},
		--	{image=nil,text="Armor",data=self.armor},
		}
	}
end

function BookOfJester:update(dt)
end

function BookOfJester:draw(x,y)
	if not x then x,y = self.body:getPosition() end
	love.graphics.draw(img.feather,x,y,0,1,1,24,24)
end
return BookOfJester
