
b_Catalyst = Buff:subclass('b_Catalyst')
function b_Catalyst:initialize(cd,cc)
	self.icon = requireImage'assets/item/catalyst.png'
	self.genre = 'buff'
	self.critdmg = cd
	self.critchance = cc
	self.p = particlemanager.getsystem'catalyst'
	self.p:setLifetime(17)
	self.p:start()
end

function b_Catalyst:buff(unit,dt)
	local x,y = unit:getPosition()
	x,y = displacement(x,y,math.pi+unit:getAngle(),50)
	self.p:setPosition(x,y)
	self.p:update(dt)
	
end
function b_Catalyst:draw()
	love.graphics.draw(self.p)
end
function b_Catalyst:start(unit)
	unit.critical[1] = unit.critical[1] + self.critdmg
	unit.critical[2] = unit.critical[2] + self.critchance
end
function b_Catalyst:stop(unit)
	unit.critical[1] = unit.critical[1] - self.critdmg
	unit.critical[2] = unit.critical[2] - self.critchance
end

Catalyst = Consumable:subclass('Catalyst')
function Catalyst:initialize(x,y)
	super.initialize(self,'consumable',x,y)
	self.name = "CATALYST"
	self.stack = 1
	self.maxstack = 1
	self.time = 20
	self.hpregen = 20
	self.cd = 45
	self.groupname = 'Catalyst'
	self.icon = requireImage'assets/item/catalyst.png'
	self.critdmg = 1.5
	self.critchance = 0.15
end


function Catalyst:use(unit)
	if unit:getCD(self.groupname) then return end
	unit:startCD(self.groupname,self.cd)
	unit:addBuff(b_Catalyst(self.critdmg,self.critchance),self.time)
	return true
end
function Catalyst:getPanelData()
	return {
		title = self.name,
		type = self.type,
		attributes = {
			{text="Temperarily increase the effect of critial strikes."},
			{image=nil,text="Critical Hit Chance",data=string.format('%.1f',self.critchance*100)},
			{image=nil,text="Critical Hit Damage",data=self.critdmg},
		}
	}
end

function Catalyst:update(dt)
end

return Catalyst
