SimpleButton = Widget:subclass('EHButton')
function SimpleButton:initialize(...)
	self.text = arg[1]
	arg[1] = self
	super.initialize(unpack(arg))
	self.actors = {
		RectangleActor:new(self.w,self.h),
		TextActor:new(self.text)
	}
	self.actors[1]:setColor(64,255,128,255)
	self.actors[2]:setColor(0,0,0,255)
	self.actor = {
		update = function() end,
		draw = function(_,x,y)
			for k,v in ipairs(self.actors) do
				v:draw(x,y)
			end
		end
	}
end

function SimpleButton:mousereleased(x,y,b)
	if b=='l' and self.hovering then
		self:onClick()
	elseif b=='r' and self.hovering then
		self:onRightClick()
	end
end

function SimpleButton:onClick()
end

function SimpleButton:onRightClick()
end
