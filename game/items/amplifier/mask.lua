
MaskOfBerserker = Item:subclass('MaskOfBerserker')
requireImage'assets/item/mask.png'

function MaskOfBerserker:initialize(x,y)
	super.initialize(self,'amplifier',x,y)
	self.name = "Mask of Berserker"
	self.stack = 1
	self.maxstack = 1
	self.critdmg = 1
	self.critchance = 0.15
end


function MaskOfBerserker:equip(unit)
	super.equip(self,unit)
	unit:berserker(true)
end

function MaskOfBerserker:unequip(unit)
	super.unequip(self,unit)	
	unit:berserker(false)
end

function MaskOfBerserker:getPanelData()
	return {
		title = LocalizedString(self.name),
		type = LocalizedString(self.type),
		attributes = {
			{text=LocalizedString"RRRRRAAAAAAAAHHHHHHHHH",image=icontable.quote},
			{text=LocalizedString"Removes offensive skills' cooldowns."},
			{image=nil,text=LocalizedString"Critical Hit Chance",data=string.format('%.1f',self.critchance*100)},
			{image=nil,text=LocalizedString"Critical Hit Damage",data=self.critdmg},
		}
	}
end
function MaskOfBerserker:update(dt)
end

function MaskOfBerserker:draw(x,y)
	if not x then x,y = self.body:getPosition() end
	love.graphics.draw(img.mask,x,y,0,0.1875,0.1875,128,128)
end
