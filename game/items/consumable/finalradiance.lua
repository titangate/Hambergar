
b_FinalRadiance = Buff:subclass('b_FinalRadiance')
function b_FinalRadiance:initialize(cd,cc)
	self.icon = requireImage'assets/item/potiongold.png'
	self.genre = 'buff'
	self.critdmg = cd
	self.critchance = cc
	self.p = particlemanager.getsystem'goldensparkle'
	self.p:setLifetime(3.5)
	self.p:start()
end

function b_FinalRadiance:buff(unit,dt)
	local x,y = unit:getPosition()
	self.p:setPosition(x,y)
	self.p:update(dt)
	
end
function b_FinalRadiance:draw()
	love.graphics.draw(self.p)
end
function b_FinalRadiance:start(unit)
	unit.preventdeath = true
end
function b_FinalRadiance:stop(unit)
	unit.preventdeath = false
end

FinalRadiance = Consumable:subclass('FinalRadiance')
function FinalRadiance:initialize(x,y)
	super.initialize(self,'consumable',x,y)
	self.name = "FinalRadiance"
	self.stack = 1
	self.maxstack = 1
	self.time = 4
	self.hpregen = 20
	self.cd = 45
	self.groupname = 'FinalRadiance'
	self.icon = requireImage'assets/item/potiongold.png'
end


function FinalRadiance:use(unit)
	if unit:getCD(self.groupname) then return end
	unit:startCD(self.groupname,self.cd)
	unit:addBuff(b_FinalRadiance(self.critdmg,self.critchance),self.time)
	return true
end
function FinalRadiance:getPanelData()
	return {
		title = LocalizedString(self.name),
		type = LocalizedString(self.type),
		attributes = {
			{text=LocalizedString"prevent deadly damage."},
			{image=nil,text=LocalizedString"Duration",data=self.time},
		}
	}
end

return FinalRadiance