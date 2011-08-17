require 'actor.init'
Panel = Widget:subclass('Panel')
function Panel:initialize(...)
	super.initialize(self,...)
	self.actor = RectangleActor:new(self.w,self.h)
end