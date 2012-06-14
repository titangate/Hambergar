AssassinAttributeItem = Object:subclass('AssassinAttributeItem')
function AssassinAttributeItem:initialize(x,y,w,h,part1,part2)
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.part1,self.part2=part1,part2
end

function AssassinAttributeItem:update(dt)end

function AssassinAttributeItem:draw()
	love.graphics.setColor(255,255,255,255)
	if self.part1.color then
		love.graphics.setColor(self.part1.color())
	end
	pfn(self.part1.text(),self.x,self.y,self.w,"left")
	if self.part2.color then
		love.graphics.setColor(self.part2.color())
	end
	pfn(self.part2.text(),self.x+100,self.y,self.w,"right")
	love.graphics.setColor(255,255,255,255)
end

AssassinCharacterPanel = Object:subclass('AssassinCharacterPanel')

function AssassinCharacterPanel:initInventory()
	local i = goo.inventory:new(self.container)
	i:setPos(20,0)
	i:setItemtype{'all','consumable','amplifier','trophy','artifact','weapon'}
	i:setInventory(self.unit.inventory)
	local eq = goo.equipment:new(self.container)
	eq:setPos(350,50)
	eq:setInventory(self.unit.inventory)
	eq:setItemtype{'consumable','amplifier','trophy','artifact','weapon'}
	local dp = goo.itempanel(self.container)
	dp:setSize(230,200)
	dp:setPos(screen.width-250,50)
	dp:setTitle('NO ITEM')
	dp:setVisible(false)
	dp:setFollowerPanel(true)
	function self.unit.inventory.updateInvUI()
		i:switchTab(i.currenttab)
		eq:updateEquipment()
	end
	function self.unit.inventory.updateInfoPanel(item)
		if item then
			dp:fillPanel(item:getPanelData())
			dp:setVisible(true)
		else
			dp:setVisible(false)
		end
	end
	self.container.highlighted = i
	self.inventory = i
	self.eq = eq
	self.switchToSkill = goo.button(self.container)
	function self.switchToSkill:onClick()
		GetGameSystem():shift'skill'
	end
	self.switchToSkill:setPos(screen.width - 200,screen.height - 100)
	self.switchToSkill:setSize(150,30)
	self.switchToSkill:setText(LocalizedString'Switch to Skill')
end
function AssassinCharacterPanel:initialize(unit)
	self.dt = 0
	self.unit = unit
	self.container = goo.object:new()
	self.container:setSize(screen.width,screen.height)
	local responds = {
		a = 1,
		d = 1,
		LSL = 1,
		LSR = 1,
	}
	local p = self
	function self.container:keypressed(k)
		if responds[k] then
			local x,y = controller:GetWalkDirection()
			local newlockon = self:direct(self.highlighted,{x,y},function(obj)
				return obj == p.inventory or obj == p.eq -- and newlockon:isKindOf(goo.itembutton) -- not obj:isKindOf(goo.imagelabel)
			end)
			if newlockon then
				local x,y = newlockon:getAbsolutePos()
--				love.mouse.setPosition(x+50,y+100)
				newlockon.invlist.list:focus()
				self.highlighted = newlockon	
			end
		end
	end
	
	self.attpanel = goo.itempanel:new(self.container)
	self.attpanel:setPos(680,75)
	self.attpanel:setSize(300)
	self.attpanel:fillPanel({
		title = LocalizedString'RIVER',
		type = LocalizedString'Assassin',
		attributes = {
			{image = icontable.life,text=LocalizedString'Hit Point',data=function()return string.format('%.1f',self.unit:getHP())..'/'..self.unit:getMaxHP() end},
			{image = icontable.life,text=LocalizedString'HP Regeneration',data=function()return self.unit.HPRegen end},
			{image = icontable.life,text=LocalizedString'Energy Point',data=function()return string.format('%.1f',self.unit:getMP())..'/'..self.unit:getMaxMP() end},
			{image = icontable.life,text=LocalizedString'Energy Regeneration',data=function()return self.unit.MPRegen end},
			{image = icontable.weapon,text=LocalizedString'Weapon Damage Bonus',data=
			function()
				local percent = self.unit.damageamplify.Bullet
				percent = percent or 1
				local bonus = self.unit.damagebuff.Bullet or 0
				return '+'..bonus..'/'..string.format('%.1f',percent*100).."%" 
			end},
			{image = icontable.weapon,text=LocalizedString'Mind Power Bonus',data=
			function()
				local percent = self.unit.damageamplify.Mind
				percent = percent or 1
				local bonus = self.unit.damagebuff.Mind or 0
				return '+'..bonus..'/'..string.format('%.1f',percent*100).."%" 
			end},
			{image = nil,text=LocalizedString'Armor',data=
			function()
				local percent = self.unit.damagereduction.Bullet
				percent = percent or 1
				local bonus = self.unit.armor.Bullet or 0
				return bonus..'/'..string.format('%.1f',percent*100).."%"
			end},
			{image = nil,text=LocalizedString'Electric Resistance',data=
			function()
				local percent = self.unit.damagereduction.Electric
				percent = percent or 1
				local bonus = self.unit.armor.Electric or 0
				return bonus..'/'..string.format('%.1f',percent*100).."%"
			end},
			{image = nil,text=LocalizedString'Fire Resistance',data=
			function()
				local percent = self.unit.damagereduction.Fire
				percent = percent or 1
				local bonus = self.unit.armor.Fire or 0
				return bonus..'/'..string.format('%.1f',percent*100).."%"
			end},
			{image = nil,text=LocalizedString'Mind Power Resistance',data=
			function()
				local percent = self.unit.damagereduction.Mind
				percent = percent or 1
				local bonus = self.unit.armor.Mind or 0
				return bonus..'/'..string.format('%.1f',percent*100).."%"
			end},
			
			{image = nil,text=LocalizedString'Wave Resistance',data=
			function()
				local percent = self.unit.damagereduction.Wave
				percent = percent or 1
				local bonus = self.unit.armor.Wave or 0
				return bonus..'/'..string.format('%.1f',percent*100).."%"
			end},
			
			{image = nil,text=LocalizedString'Stability',data=
			function()
				local bonus = self.unit.mass or 0
				return bonus
			end},
			
			{image = nil,text=LocalizedString'Critical Hit',data=
			function()
				self.unit.critical = self.unit.critical or {2,0}
				local d = self.unit.critical
				local amplify,chance = unpack(d)
				return string.format('%.1f',chance*100).."% chance deal "..amplify.." times damage"
			end},
			
			{image = nil,text=LocalizedString'Evade',data=
			function()
				local percent = self.unit.evade
				percent = percent or 0
				return string.format('%.1f',percent*100).."%"
			end},
		}
	},5 ) -- the number is for the space margin
	self:initInventory()
	self.container:setVisible(false)
end
function AssassinCharacterPanel:show()
	self.unit.inventory:gotoState()
--	self.container:setVisible(true)
end
function AssassinCharacterPanel:fold()
--	self.container:setVisible(false)
end

function AssassinCharacterPanel:update(dt)
	self.attpanel:updateData()
end

function AssassinCharacterPanel:keypressed(k)
	if k=='t' then
		self:fold()
	end
end

--requireImage( 'assets/UI/river.png','pioneer' )
function AssassinCharacterPanel:draw()
--	love.graphics.draw(img.pioneer,love.graphics.getWidth()-350,love.graphics.getHeight()-420)
	goo:draw()
--	drawcollections()
end