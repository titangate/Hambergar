function drain(unit,source,amount)
	if unit.drainablemana then
		unit.drainablemana = unit.drainablemana-amount
		if unit.drainablemana <= 0 then
			unit.drainablemana = nil
		end
	end
end

station = love.graphics.newImage('assets/drainable/station.png')
Station = Unit:subclass('Station')
function Station:initialize(x,y)
	super.initialize(self,x,y,48,10)
	self.drainablemana = 100
	self.drain = function()end
end

function Station:draw()
	love.graphics.draw(station,self.x,self.y,self.body:getAngle(),1,1,48,48)
	if self.drainablemana then
		drawDrainLevel(self.x,self.y,3,3)
	end
end

computer = love.graphics.newImage('assets/drainable/computer.png')
Computer = Unit:subclass('Computer')
function Computer:initialize(x,y)
	super.initialize(self,x,y,12,10)
	self.drainablemana = 100
	self.drain = drain
end

function Computer:draw()
	love.graphics.draw(computer,self.x,self.y,self.body:getAngle(),1,1,16,11)
	if self.drainablemana then
		drawDrainLevel(self.x,self.y,math.ceil(self.drainablemana/34),3)
	end
end


tv = love.graphics.newImage('assets/drainable/tv.png')
TV = Unit:subclass('TV')
function TV:initialize(x,y)
	super.initialize(self,x,y,12,10)
	self.drainablemana = 100
	self.drain = drain
end

function TV:draw()
	love.graphics.draw(tv,self.x,self.y,self.body:getAngle(),1,1,16,11)
	if self.drainablemana then
		drawDrainLevel(self.x,self.y,math.ceil(self.drainablemana/34),3)
	end
end
