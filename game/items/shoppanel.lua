
ShopPanel = Object:subclass('ShopPanel')

function ShopPanel:initInventory()
	local i = goo.inventory:new(self.container)
	i:setPos(20,0)
	i:setItemtype{'all','consumable','amplifier','trophy','artifact','weapon'}
--	local eq = goo.equipment:new(self.container)
--	eq:setPos(350,50)
--	eq:setInventory(self.unit.inventory)
--	eq:setItemtype{'consumable','amplifier','trophy','artifact','weapon'}

	local s = goo.inventory(self.container)
	s:setPos(700,0)
	s:setItemtype{'all'}
	s:setInventory(self.shopkeeper.inventory)
	
	self.inventory = ShopInventory(self.unit.inventory)
	local dp = goo.itempanel:new(self.container)
	function self.inventory.updateInvUI()
		i:switchTab(i.currenttab)
		s:switchTab(s.currenttab)
	end
	function self.inventory.updateInfoPanel(item)
		if item then
			dp:fillPanel(item:getPanelData())
			dp:setVisible(true)
		else
			dp:setVisible(false)
		end
	end
	i:setInventory(self.inventory)
	
	
	dp:setSize(230,200)
	dp:setPos(screen.width-250,50)
	dp:setTitle('NO ITEM')
	dp:setVisible(false)
	dp:setFollowerPanel(true)
	

	self.shopkeeper.inventory.updateInvUI = self.inventory.updateInvUI
	self.shopkeeper.inventory.updateInfoPanel = self.inventory.updateInfoPanel
	
	self.shopkeeper.inventory.buyerinventory = self.inventory
	self.inventory.shop = self.shopkeeper.inventory
end

function ShopPanel:initialize(unit,shopkeeper)
	assert(unit)
	assert(shopkeeper)
	self.dt = 0
	self.unit = unit
	self.shopkeeper = shopkeeper
	self.container = goo.object:new()
	self:initInventory(unit,shopkeeper)
--	self.container:setVisible(false)
end
function ShopPanel:show()
	self.container:setVisible(true)
end
function ShopPanel:fold()
	self.container:setVisible(false)
end

function ShopPanel:update(dt)
--	self.attpanel:updateData()
end

function ShopPanel:keypressed(k)
	if k=='t' then
		self:destroy()
		popsystem()
	end
end

function ShopPanel:destroy()
	self.container:destroy()
end

--requireImage( 'assets/UI/river.png','pioneer' )
function ShopPanel:draw()
--	love.graphics.draw(img.pioneer,love.graphics.getWidth()-350,love.graphics.getHeight()-420)
	goo:draw()
--	drawcollections()
end