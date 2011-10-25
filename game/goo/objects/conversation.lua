goo.conversationpanel = goo.object:subclass('goo conversation panel')
function goo.conversationpanel:initialize(parent)
	super.initialize(self,parent)
	self.text=''
	self.portrait=nil
	self.speaker=''
	self.time=0
	self.fold=3
--	self:setPos(x,y)
	self:setSize(400,150)
	self.opacity=0
end

function goo.conversationpanel:birth()
	anim:easy(self,'opacity',0,255,1,'linear')
	self.fold=0
end

function goo.conversationpanel:play(speaker,text,portrait,time)
	self.speaker = speaker
	self.portrait = portrait
	self.text = text
--	self:birth()
end

function goo.conversationpanel:update(dt)
	super.update(self,dt)
	if self.fold<2 then
		self.fold = self.fold+dt
	end
end

function goo.conversationpanel:draw()
	super.draw(self)
	self:setColor({255,255,255})
	if self.fold<1 then
		love.graphics.setScissor(0+self.x,0+self.y,self.w,self.h*self.fold)
		love.graphics.draw(img.conversationbg)
--		love.graphics.draw(img.gridfilter,0,self.h*self.fold-16,0,100,1,16,16)
	else
		love.graphics.setScissor(0+self.x,0+self.y,self.w,self.h)
		love.graphics.draw(img.conversationbg)	
--		love.graphics.draw(img.gridfilter,0,self.h*self.fold-16,0,100,1,16,16)
	end
	local textoffset = 50
	if self.portrait then
		textoffset = textoffset+self.portrait:getWidth()
		love.graphics.draw(self.portrait,10,40)
	end
	love.graphics.setFont(self.style.speakerFont)
	love.graphics.printf(self.speaker,50,30,400,'center')
	love.graphics.setFont(self.style.textFont)
	love.graphics.printf(self.text,textoffset,60,350-textoffset,'left')
	love.graphics.setScissor()
end

return goo.conversationpanel