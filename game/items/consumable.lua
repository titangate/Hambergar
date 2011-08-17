
b_HealthPotion = Buff:subclass('b_HealthPotion')
function b_HealthPotion:initialize(hpregen)
	self.hpregen = hpregen
end
function b_HealthPotion:start(unit)
	unit.HPRegen = unit.HPRegen + self.hpregen
end
function b_HealthPotion:stop(unit)
	unit.HPRegen = unit.HPRegen - self.hpregen
end

HealthPotion = Item:subclass('HealthPotion')
local healthpotion = love.graphics.newImage('assets/item/healthpotion.png')
function HealthPotion:initialize(x,y)
	super.initialize(self,'consumable',x,y)
	self.name = "HEALTH POTION"
	self.stack = 1
	self.maxstack = 1
	self.time = 5
	self.hpregen = 10
	self.cd = 10
	self.groupname = 'HealthPotion'
end

function HealthPotion:getCDPercent()
	local groupname = self.groupname or self:className()
	local cddt = self.unit:getCD(groupname) or 0
	return cddt/self.cd
end

function HealthPotion:use(unit)
	if unit:getCD(self.groupname) then return end
	unit:startCD(self.groupname,self.cd)
	unit:addBuff(b_HealthPotion:new(self.hpregen),self.time)
	self.stack = self.stack - 1
	if self.stack == 0 then
		unit.inventory:removeItem(self)
	end
end

function HealthPotion:fillPanel(panel)
	panel:addItem(DescriptionAttributeItem:new(function()
		return self.name end,
		panel.w,30))
	panel:addItem(DescriptionAttributeItem:new(function()
		return "CONSUMABLE" end,
		panel.w,20))
	panel:addItem(DescriptionAttributeItem:new(function()
		return "Increase HP Regeneration within a period of time." end,
		panel.w,45))
	panel:addItem(SimpleAttributeItem:new(
		function()
		return self.hpregen end,
		function()
		return "HP Regeneration" end,
		'life',panel.w))
	panel:addItem(SimpleAttributeItem:new(
		function()
		return self.time end,
		function()
		return "Duration" end,
		nil,panel.w))
	panel:addItem(SimpleAttributeItem:new(
		function()
		return self.cd end,
		function()
		return "Cooldown" end,
		nil,panel.w))
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
	love.graphics.draw(healthpotion,x,y,0,1,1,24,24)
end

BigHealthPotion = HealthPotion:subclass('BigHealthPotion')
function BigHealthPotion:initialize(x,y)
	super.initialize(self,x,y)
	self.name = "BIG HEALTH POTION"
	self.hpregen = 20
end