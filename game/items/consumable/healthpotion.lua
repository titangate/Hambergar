
b_HealthPotion = Buff:subclass('b_HealthPotion')
function b_HealthPotion:initialize(hpregen)
	self.hpregen = hpregen
	self.icon = requireImage'assets/item/potionred.png'
	self.genre = 'buff'
end
function b_HealthPotion:start(unit)
	unit.HPRegen = unit.HPRegen + self.hpregen
end
function b_HealthPotion:stop(unit)
	unit.HPRegen = unit.HPRegen - self.hpregen
end

HealthPotion = Consumable:subclass('HealthPotion')
function HealthPotion:initialize(x,y)
	super.initialize(self,'consumable',x,y)
	self.name = "HEALTH POTION"
	self.stack = 1
	self.maxstack = 1
	self.time = 5
	self.hpregen = 20
	self.cd = 10
	self.groupname = 'HealthPotion'
	self.icon = requireImage'assets/item/potionred.png'
end


function HealthPotion:use(unit)
	if unit:getCD(self.groupname) then return end
	unit:startCD(self.groupname,self.cd)
	unit:addBuff(b_HealthPotion:new(self.hpregen),self.time)
	return true
end
function HealthPotion:getPanelData()
	return {
		title = self.name,
		type = self.type,
		attributes = {
			{text="Increase HP Regeneration within a period of time."},
			{data=self.hpregen,image=icontable.life,text="HP Regeneration"},
			{image=nil,text="Duration",data=self.time},
			{image=nil,text="Cooldown",data=self.cd},
		}
	}
end

function HealthPotion:update(dt)
end

function HealthPotion:draw(x,y)
	if not x then x,y = self.body:getPosition() end
	love.graphics.draw(requireImage'assets/item/potionred.png',x,y,0,0.375,0.375,64,64)
end

return HealthPotion
--[[
BigHealthPotion = HealthPotion:subclass('BigHealthPotion')
function BigHealthPotion:initialize(x,y)
	super.initialize(self,x,y)
	self.name = "BIG HEALTH POTION"
	self.hpregen = 20
	self.value = 10
end
]]