EmergencyStop = Unit:subclass'EmergencyStop'
function EmergencyStop:initialize(x,y)
	super.initialize(self,x,y,16,48)
end


--requireImage('assets/drainable/emergencystop.png','emergencystop')
function EmergencyStop:draw()
	love.graphics.draw(img.station,self.x,self.y,self.body:getAngle(),1,1,48,48)
end


Lily = Unit:subclass'Lily'
function Lily:initialize(x,y)
	super.initialize(self,x,y,16,10)
--	self.controller = 'player'
end

requireImage('assets/whistler/lily.png','lily')

function Lily:draw()
	love.graphics.draw(img.lily,self.x,self.y,0,1,1,20,32)
end
