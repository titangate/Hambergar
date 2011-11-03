UtilityBox = Unit:subclass'UtilityBox'
function UtilityBox:initialize(x,y)
	super.initialize(self,x,y,16,48)
end

function UtilityBox:interact(unit)
	StealthSystem.lethalAttract{x = self.x,
		y = self.y,
		region = self.region}
end


requireImage('assets/drainable/station.png','station')
function UtilityBox:draw()
	love.graphics.draw(img.station,self.x,self.y,self.body:getAngle(),1,1,48,48)
end
