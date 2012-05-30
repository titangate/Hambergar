Timer = Object:subclass('Timer')

-- Timer initialize
-- interval: interval time
-- count: count, -1 = fire forever
-- func: fire function. (function has to receive timer itself as the first arugment)
-- start: start at once
function Timer:initialize(interval,count,func,start,selfdestruct)
	self.interval = interval
	self.count = count
	self.func = func
	self.start = start or true
	self.time = 0
	self.selfdestruct = selfdestruct or true
	GetGameSystem():addGameTimer(self)
end

function Timer:kill()
	GetGameSystem():removeGameTimer(self)
end

function Timer:update(dt)
	if self.start and (self.count > 0 or self.count == -1) then
		self.time = self.time + dt
		if self.time > self.interval then
			self:func() -- fire the event
			gamelistener:notify{
				type='timer',
				timer=self
			}
			self.time = self.time - self.interval -- minus it rather than set it to 0 to increase precision
			if self.count ~= -1 then
				self.count = self.count - 1
			end
			if self.count == 0 and self.selfdestruct then
				GetGameSystem():removeGameTimer(self)
			end
		end
	end
end