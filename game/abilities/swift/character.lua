SwiftCharacterPanel = Object:subclass('SwiftCharacterPanel')

function SwiftCharacterPanel:initInventory()
	local i = goo.inventory:new(self.container)
	i:setPos(20,0)
	i:setItemtype{'all','consumable','amplifier','trophy','artifact'}
	i:setInventory(self.unit.inventory)
	local eq = goo.equipment:new(self.container)
	eq:setPos(350,50)
	eq:setInventory(self.unit.inventory)
	eq:setItemtype{'consumable','amplifier','trophy','artifact'}
	function self.unit.inventory.updateInvUI()
		print ('switch')
		i:switchTab(i.currenttab)
		eq:updateEquipment()
	end
	dp = goo.itempanel:new()
	dp:setSize(230,200)
	dp:setPos(screen.width-250,50)
	dp:setTitle('NO ITEM')
	dp:setVisible(false)
	dp:setFollowerPanel(true)
	function self.unit.inventory.updateInfoPanel(item)
		if item then
			dp:fillPanel(item:getPanelData())
			dp:setVisible(true)
		else
			dp:setVisible(false)
		end
	end
	self.inventory = i
end

function SwiftCharacterPanel:initialize(unit)
	self.dt = 0
	self.unit = unit
	self.container = goo.object:new()
	
	self.attpanel = goo.itempanel:new(self.container)
	self.attpanel:setPos(680,75)
	self.attpanel:setSize(300)
	self.attpanel:fillPanel({
		title = 'LAWRENCE FU',
		type = 'Swift',
		attributes = {
			{image = icontable.life,text='Hit Point',data=function()return self.unit:getHP()..'/'..self.unit:getMaxHP() end},
			{image = icontable.life,text='HP Regeneration',data=function()return self.unit.HPRegen end},
			{image = icontable.life,text='Energy Point',data=function()return self.unit:getMP()..'/'..self.unit:getMaxMP() end},
			{image = icontable.life,text='Energy Regeneration',data=function()return self.unit.MPRegen end},
			{image = icontable.weapon,text='Weapon Damage Bonus',data=
			function()
				local percent = self.unit.damageamplify.Bullet
				percent = percent or 1
				local bonus = self.unit.damagebuff.Bullet or 0
				return '+'..bonus..'/'..string.format('%.1f',percent*100).."%" 
			end},
			{image = icontable.weapon,text='Mind Power Bonus',data=
			function()
				local percent = self.unit.damageamplify.Mind
				percent = percent or 1
				local bonus = self.unit.damagebuff.Mind or 0
				return '+'..bonus..'/'..string.format('%.1f',percent*100).."%" 
			end},
			{image = nil,text='Armor',data=
			function()
				local percent = self.unit.damagereduction.Bullet
				percent = percent or 1
				local bonus = self.unit.armor.Bullet or 0
				return bonus..'/'..string.format('%.1f',percent*100).."%"
			end},
			{image = nil,text='Electric Resistance',data=
			function()
				local percent = self.unit.damagereduction.Electric
				percent = percent or 1
				local bonus = self.unit.armor.Electric or 0
				return bonus..'/'..string.format('%.1f',percent*100).."%"
			end},
			{image = nil,text='Fire Resistance',data=
			function()
				local percent = self.unit.damagereduction.Fire
				percent = percent or 1
				local bonus = self.unit.armor.Fire or 0
				return bonus..'/'..string.format('%.1f',percent*100).."%"
			end},
			{image = nil,text='Mind Power Resistance',data=
			function()
				local percent = self.unit.damagereduction.Mind
				percent = percent or 1
				local bonus = self.unit.armor.Mind or 0
				return bonus..'/'..string.format('%.1f',percent*100).."%"
			end},
			
			{image = nil,text='Wave Resistance',data=
			function()
				local percent = self.unit.damagereduction.Wave
				percent = percent or 1
				local bonus = self.unit.armor.Wave or 0
				return bonus..'/'..string.format('%.1f',percent*100).."%"
			end},
			
			{image = nil,text='Stability',data=
			function()
				local bonus = self.unit.mass or 0
				return bonus
			end},
			
			{image = nil,text='Critical Hit',data=
			function()
				local d = self.unit.critical.Bullet
				d = d or {0,2}
				local chance,amplify = unpack(d)
				return string.format('%.1f',chance*100).."% chance deal "..amplify.." times damage"
			end},
			
			{image = nil,text='Evade',data=
			function()
				local percent = self.unit.evade.Bullet
				percent = percent or 0
				return string.format('%.1f',percent*100).."%"
			end},
		}
	},5 ) -- the number is for the space margin
	self:initInventory()
	self.container:setVisible(false)
end
function SwiftCharacterPanel:show()
--	self.container:setVisible(true)
end
function SwiftCharacterPanel:fold()
--	self.container:setVisible(false)
end

function SwiftCharacterPanel:update(dt)
	self.attpanel:updateData()
end

function SwiftCharacterPanel:keypressed(k)
	if k=='t' then
		self:fold()
	end
end

--requireImage( 'assets/UI/river.png','pioneer' )
function SwiftCharacterPanel:draw()
--	love.graphics.draw(img.pioneer,love.graphics.getWidth()-350,love.graphics.getHeight()-420)
	goo:draw()
--	drawcollections()
end