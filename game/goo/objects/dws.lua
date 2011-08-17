
goo.DWSText = class('goo DWSText',goo.object)
function goo.DWSText:initialize(parent)
	super.initialize(self,parent)
	self.text = ''
end

function goo.DWSText:setText(text)
	self.text = text
	self.ox,self.oy = self.style.textFont:getWidth(text)/2,self.style.textFont:getHeight(text)/2
	self:setSize(self.ox*2,self.oy*2)
end

function goo.DWSText:draw()
	super.draw(self)
	self:setColor(self.style.textColor)
	love.graphics.setFont(self.style.textFont)
	love.graphics.print(self.text,-self.ox,-self.oy)
end

goo.DWSPanel = class('goo DWSPanel',goo.object)
function goo.DWSPanel:initialize(parent)
	super.initialize(self,parent)
end

function goo.DWSPanel:animateText(text,x,y)
	
end

return goo.DWSPanel