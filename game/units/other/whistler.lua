EmergencyStop = Unit:subclass'EmergencyStop'
function EmergencyStop:initialize(x,y)
	super.initialize(self,x,y,16,48)
end


--requireImage('assets/drainable/emergencystop.png','emergencystop')
function EmergencyStop:draw()
	love.graphics.draw(img.station,self.x,self.y,self.body:getAngle(),1,1,48,48)
end