MasterYuen = Unit:subclass'MasterYuen'

function MasterYuen:initialize(x,y)
	super.initialize(self,x,y,16,10)
	self.actor = MasterYuenActor()
	self.x,self.y = x,y
	self.actor:playAnimation('kick',1,true)
end

function MasterYuen:update(dt)
	self.actor:update(dt)
end

function MasterYuen:draw()
	self.actor:draw(self.x,self.y,self.r)
end