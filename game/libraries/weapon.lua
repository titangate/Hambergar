Weapon = Item:subclass('Weapon')
function Weapon:initialize(char,x,y)
	super.initialize(self,'weapon',x,y)
	self.char = char
end

function Weapon:equip(unit)
	unit:setWeaponSkill(self.skill(unit,1))
end

function Weapon:unequip(unit)
	unit:setWeaponSkill()
end

function Weapon:update(dt)
end

function Weapon:drawBody(unit)
end

function Weapon:setSkill(skill)
	assert(skill)
	self.skill = skill
end

function Weapon:getSkill()
	assert(self.skill)
	return self.skill
end

FireWeapon = StatefulObject:subclass('FireWeapon')
function FireWeapon:initialize(unit)
	super.initialize(self)
	assert(unit)
	self.unit = unit
end

function FireWeapon:setSkill(skill)
	self.skill = skill or Skill()
	if skill then
		self.level = skill.level
	else
		self.level = 1
	end
end

function FireWeapon:getorderinfo()
	return self.skill:getorderinfo()
end

function FireWeapon:stop()
	return self.skill:stop()
end

function FireWeapon:getLevel()
	return self.skill:getLevel()
end

function FireWeapon:update(dt)
	return self.skill:update(dt)
end

function FireWeapon:startChannel()
	return self.skill:startChannel()
end

function FireWeapon:endChannel()
	return self.skill:endChannel()
end

Interact = FireWeapon:addState('interact')

function Interact:update(dt)
	local u = GetOrderUnit()
	GetCharacter():switchChannelSkill()
	if u and u.interact then
		u:interact(self.unit)
	end
end

local dws = FireWeapon:addState'DWS'
function dws:enterState()
	self.skill:gotoState'DWS'
end

function dws:exitState()
	self.skill:gotoState()
end


UseItem = StatefulObject:subclass'UseItem'
function UseItem:initialize(unit)
	super.initialize(self)
	assert(unit)
	self.unit = unit
	self.level = 1
end

function UseItem:setItem(item)
--	assert(item)
	self.item = item
end

function UseItem:getorderinfo()
--	return self.skill:getorderinfo()
end

function UseItem:stop()
--	return self.skill:stop()
end

function UseItem:active()
	assert(self.item)
	self.unit.inventory:useItem(self.item.name)
end

function UseItem:getLevel()
	return self.level
--	return self.skill:getLevel()
end

function UseItem:update(dt)
--	return self.skill:update(dt)
end

function UseItem:startChannel()
--	return self.skill:startChannel()
end

function UseItem:endChannel()
--	return self.skill:endChannel()
end

