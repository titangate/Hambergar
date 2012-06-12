
b_EnergyPotion = Buff:subclass('b_EnergyPotion')
function b_EnergyPotion:initialize(mpregen)
	self.mpregen = mpregen
	self.icon = requireImage'assets/item/potionblue.png'
	self.genre = 'buff'
end
function b_EnergyPotion:start(unit)
	unit.MPRegen = unit.MPRegen + self.mpregen
end
function b_EnergyPotion:stop(unit)
	unit.MPRegen = unit.MPRegen - self.mpregen
end

EnergyPotion = Consumable:subclass('EnergyPotion')
function EnergyPotion:initialize(x,y)
	super.initialize(self,'consumable',x,y)
	self.name = "Energy POTION"
	self.stack = 1
	self.maxstack = 1
	self.time = 5
	self.mpregen = 20
	self.cd = 10
	self.groupname = 'EnergyPotion'
	self.icon = requireImage'assets/item/potionblue.png'
end


function EnergyPotion:use(unit)
	if unit:getCD(self.groupname) then return end
	unit:startCD(self.groupname,self.cd)
	unit:addBuff(b_EnergyPotion:new(self.mpregen),self.time)
	return true
end

function EnergyPotion:fillPanel(panel)
	panel:addItem(DescriptionAttributeItem:new(function()
		return self.name end,
		panel.w,30))
	panel:addItem(DescriptionAttributeItem:new(function()
		return "CONSUMABLE" end,
		panel.w,20))
	panel:addItem(DescriptionAttributeItem:new(function()
		return "Increase MP Regeneration within a period of time." end,
		panel.w,45))
	panel:addItem(SimpleAttributeItem:new(
		function()
		return self.mpregen end,
		function()
		return "MP Regeneration" end,
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

function EnergyPotion:getPanelData()
	return {
		title = self.name,
		type = self.type,
		attributes = {
			{text="Increase MP Regeneration within a period of time."},
			{data=self.mpregen,image=icontable.life,text="MP Regeneration"},
			{image=nil,text="Duration",data=self.time},
			{image=nil,text="Cooldown",data=self.cd},
		}
	}
end

function EnergyPotion:update(dt)
end
