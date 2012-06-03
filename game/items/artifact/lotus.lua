
Lotus = Item:subclass('Lotus')
requireImage( 'assets/item/lotus.png','Lotus' )

b_Lotus = Buff:subclass('b_Lotus')
function b_Lotus:initialize()
	self.opacity = 255
	self.intensity = 1
	self.icon = img.Lotus
	self.genre = 'debuff'
end

requireImage( 'assets/buff/stun.png','stunimg' )
function b_Lotus:buff(unit,dt)
	self.intensity = self.intensity - dt
end
function b_Lotus:draw(unit)
	if self.intensity > 0 then
		filtermanager:requestFilter('Bloom')
		filtermanager:setFilterArguments('Bloom',{
			bloomintensity = self.intensity*5 ,
			bloomsaturation = self.intensity*5 ,
		})
		love.graphics.setColor(255,255,255,255-255*self.intensity)
		love.graphics.draw(img.Lotus,unit.x,unit.y,0,1,1,128,128)
		love.graphics.setColor(255,255,255)
	end
end

function b_Lotus:getPanelData()
	return {
		title = 'Lotus Revived',
		type = 'Debuff',
		attributes = {
			{text = 'You have revived.'}}
	}
end
function Lotus:initialize(x,y)
	super.initialize(self,'artifact',x,y)
	self.name = "Lotus"
	self.stack = 1
	self.maxstack = 1
	self.cd = 40
	self.hprestore = 0.5
	self.mprestore = 0.5
end

function Lotus:equip(unit)
	super.equip(self,unit)
	unit:lotus(self.hprestore,self.mprestore,b_Lotus,self.cd)
end

function Lotus:unequip(unit)
	super.unequip(self,unit)
	unit.timescale = unit.timescale - self.timescale
	unit:lotus()
end

function Lotus:getPanelData()
	return {
		title = self.name,
		type = self.type,
		attributes = {
			{text="Release inner serenity."},
			{text="Upon receiving a deadly hit, restore life and energy"},
			{data=self.cd,image=nil,text="Cooldown"},
			{data=string.format("%.2f",self.hprestore*100)..'%',image=nil,text="HP Restoration"},
			{data=string.format("%.2f",self.mprestore*100)..'%',image=nil,text="MP Restoration"},
		--	{image=nil,text="Armor",data=self.armor},
		}
	}
end

function Lotus:update(dt)
end

function Lotus:draw(x,y)
	if not x then x,y = self.body:getPosition() end
	love.graphics.draw(img.Lotus,x,y,0,0.1875,0.1875,128,128)
end