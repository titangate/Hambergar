Slider = Widget:subclass('Slider')
function Slider:initialize(...)
	self:setDelegate(arg[5])
	table.insert(arg,1,self)
	super.initialize(unpack(arg))
	self.value = 0
	self.actor = ProgressBarActor:new()
	self.actor:setValue(0)
	self.actor.w,self.actor.h = self.w,self.h
end

function Slider:setDelegate(d)
	self.delegate = d
end

function Slider:update(dt,x,y)
	if mouseDown('l') and self:inAABB(x,y) then
		self:setValue((x-self.x)/self.w)
		self.actor:setValue(self.value)
	end
end

function Slider:setValue(v)
	self.value = math.min(math.max((v-0.5)*1.1+0.5,0),1)
	if self.delegate then
		self.delegate.setValue(v)
	end
end
