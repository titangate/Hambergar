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
	love.graphics.printf(self.part1.text(),self.x,self.y,self.w,"left")
	if self.part2.color then
		love.graphics.setColor(self.part2.color())
	end
	love.graphics.printf(self.part2.text(),self.x+100,self.y,self.w,"right")
	love.graphics.setColor(255,255,255,255)
end

AssassinCharacterPanel = Object:subclass('AssassinCharacterPanel')

function AssassinCharacterPanel:initInventory()
	local i = goo.inventory:new(self.container)
	i:setPos(20,screen.height-160)
	i:setSize(640,128)
	for n=0,9 do
		i:addSlot(n*64,0)
	end
	for n=0,9 do
		i:addSlot(n*64,64)
	end
	i:addSlot(screen.width-170-i.x,screen.height-200-i.y,'amplifier',true)
	i:addSlot(screen.width-104-i.x,screen.height-314-i.y,'artifact',true)
	i:addSlot(screen.width-50-i.x,screen.height-220-i.y,'trophy',true)
	i:addSlot(screen.width-335-i.x,screen.height-260-i.y,'secondary',true)
	i:setUnit(self.unit)
	dp = goo.itempanel:new()
	dp:setSize(230,200)
	dp:setPos(screen.width-250,50)
	i:setItemPanels(dp)
	dp:setTitle('NO ITEM')
	dp:setVisible(false)
	dp:setFollowerPanel(true)
	self.inventory = i
	self.unit.inventory = i
end
function AssassinCharacterPanel:initialize(unit)
	self.dt = 0
	self.unit = unit
	self.container = goo.object:new()
	
	self.attpanel = goo.itempanel:new(self.container)
	self.attpanel:setPos(450,50)
	self.attpanel:setSize(300)
	self.attpanel:fillPanel({
		title = 'RIVER',
		type = 'Assassin',
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
				local bonusw = self.unit.armor.Electric or 0
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
function AssassinCharacterPanel:show()
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

local pioneer = love.graphics.newImage('assets/UI/river.png')
function AssassinCharacterPanel:draw()
	love.graphics.draw(pioneer,love.graphics.getWidth()-350,love.graphics.getHeight()-420)
	goo:draw()
--	drawcollections()
end