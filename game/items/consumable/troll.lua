
b_Troll = Buff:subclass('b_Troll')
function b_Troll:initialize()
	self.icon = requireImage'assets/buff/troll.png'
	self.genre = 'buff'
	self.p = particlemanager.getsystem'troll'
	self.p:setLifetime(3600)
	self.p:start()
end

function b_Troll:buff(unit,dt)
	self.p:setPosition(unit:getPosition())
	self.p:update(dt)
end
function b_Troll:draw()
	love.graphics.draw(self.p)
end
function b_Troll:start(unit)
end
function b_Troll:stop(unit)
end

TrollPotion = Consumable:subclass('TrollPotion')
function TrollPotion:initialize(x,y)
	super.initialize(self,'consumable',x,y)
	self.name = "TROLOLO POTION"
	self.stack = 1
	self.maxstack = 1
	self.time = -1
	self.hpregen = 20
	self.cd = 0
	self.groupname = 'TrollPotion'
	self.icon = requireImage'assets/buff/troll.png'
end


function TrollPotion:use(unit)
	if unit:getCD(self.groupname) then return end
	unit:startCD(self.groupname,self.cd)
	unit:addBuff(b_Troll(),self.time)
	return true
end
function TrollPotion:getPanelData()
	return {
		title = LocalizedString(self.name),
		type = LocalizedString(self.type),
		attributes = {
			{text=LocalizedString"U MAD BRO?"},
		}
	}
end

return TrollPotion