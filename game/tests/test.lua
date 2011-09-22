function test()
	local inv = Inventory:new()
	local hp = HealthPotion:new()
	hp.stack = 3
	inv:addItem(hp)
	local fv = FiveSlash:new()
	inv:addItem(fv)
	inv:addItem(PeacockFeather:new())
	inv:addItem(BigHealthPotion:new())
	print ('Inventory has Health Potion',inv:hasItem'HEALTH POTION')
	print ('Inventory has Mana Potion',inv:hasItem'MANA POTION')
	for k,item in inv:iterateItems('consumable') do
		print ('Inventory has *consumable*',k,item)
	end
	for k,item in inv:iterateItems() do
		print ('Inventory has',item.type,k,item)
	end
	inv:removeItem('HEALTH POTION')
	print ('Health potion removed')
	for k,item in inv:iterateItems() do
		print ('Inventory has',item.type,k,item)
	end
	local i = goo.inventory:new()
	i:setPos(400,0)
	i:setSize(600,200)
	i:setInventory(inv)
	i:setItemtype{'all','consumable','amplifier','trophy','artifact'}
	
	local eq = goo.equipment:new()
	eq:setSize(400,200)
	eq:setInventory(inv)
	eq:setItemtype{'consumable','amplifier','trophy','artifact'}
end