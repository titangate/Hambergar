
b_MistyCloud = Buff:subclass('b_MistyCloud')
function b_MistyCloud:initialize(e)
	self.icon = requireImage'assets/buff/mistycloud.png'
	self.genre = 'buff'
	self.evade = e
	self.p = particlemanager.getsystem'mistycloud'
	self.p:setLifetime(17)
	self.p:start()
end
function b_MistyCloud:buff(unit,dt)
	self.p:setPosition(unit:getPosition())
	self.p:update(dt)
	
end
function b_MistyCloud:draw()
	love.graphics.draw(self.p)
end
function b_MistyCloud:start(unit)
	unit.evade = getdodgerate(unit.evade,self.evade)
end
function b_MistyCloud:stop(unit)
	
	unit.evade = getdodgerate(unit.evade,-self.evade)
end

MistyCloud = Consumable:subclass('MistyCloud')
function MistyCloud:initialize(x,y)
	super.initialize(self,'consumable',x,y)
	self.name = "MISTYCLOUD"
	self.stack = 1
	self.maxstack = 1
	self.time = 20
	self.hpregen = 20
	self.cd = 45
	self.groupname = 'MistyCloud'
	self.icon = requireImage'assets/item/mistycloud.png'
	self.evade = 0.35
end


function MistyCloud:use(unit)
	if unit:getCD(self.groupname) then return end
	unit:startCD(self.groupname,self.cd)
	unit:addBuff(b_MistyCloud(self.evade),self.time)
	return true
end
function MistyCloud:getPanelData()
	return {
		title = self.name,
		type = self.type,
		attributes = {
			{text="Temperarily increase evasion."},
			{image=nil,text="Dodge",data=string.format('%.1f',self.evade*100)},
		}
	}
end

return MistyCloud
