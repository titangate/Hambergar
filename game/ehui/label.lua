Label = Widget:subclass('Label')
function Label:initialize(text,x,y,w,h)
	self.x,self.y = x,y
	w = w or #text*7
	h = h or 10
	self.w,self.h = w,h
	self.text = text
end

function Label:setText(text)
	self.text = text
end

function Label:draw(x,y)
	love.graphics.print(self.text,x,y)
end