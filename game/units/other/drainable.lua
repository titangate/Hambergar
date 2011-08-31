function drain(unit,source,amount)
	if unit.drainablemana then
		unit.drainablemana = unit.drainablemana-amount
		if unit.drainablemana <= 0 then
			unit.drainablemana = nil
		end
	end
end

requireImage('assets/drainable/station.png','station')
Station = Unit:subclass('Station')
function Station:initialize(x,y)
	super.initialize(self,x,y,48,10)
	self.drainablemana = 100
	self.drain = function()end
end

function Station:draw()
	love.graphics.draw(img.station,self.x,self.y,self.body:getAngle(),1,1,48,48)
	if self.drainablemana then
		drawDrainLevel(self.x,self.y,3,3)
	end
end

requireImage('assets/drainable/computer.png','computer')
Computer = Unit:subclass('Computer')
function Computer:initialize(x,y)
	super.initialize(self,x,y,12,10)
	self.drainablemana = 100
	self.drain = drain
end

function Computer:draw()
	love.graphics.draw(img.computer,self.x,self.y,self.body:getAngle(),1,1,16,11)
	if self.drainablemana then
		drawDrainLevel(self.x,self.y,math.ceil(self.drainablemana/34),3)
	end
end


requireImage('assets/drainable/tv.png','tv')
TV = Unit:subclass('TV')
function TV:initialize(x,y)
	super.initialize(self,x,y,12,10)
	self.drainablemana = 100
	self.drain = drain
end

function TV:draw()
	love.graphics.draw(img.tv,self.x,self.y,self.body:getAngle(),1,1,16,11)
	if self.drainablemana then
		drawDrainLevel(self.x,self.y,math.ceil(self.drainablemana/34),3)
	end
end
