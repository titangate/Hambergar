Mat = Unit:subclass'Mat'

function Mat:initialize(...)
	super.initialize(self,...)
	self.controller = 'player'
end

function Mat:interact(unit)
	if unit:isKindOf(Assassin) then
		GetCharacter().manager:start()
		GetGameSystem().bottompanel.count=0
		pushsystem(GetCharacter().manager)
	end
end

function Mat:createBody(world)
	super.createBody(self,world)
	self.shape:setSensor(true)
end

requireImage('assets/vancouver/mat.png','mat')
function Mat:draw()
	love.graphics.draw(img.mat,self.x,self.y,0,1,1,64,64)
end