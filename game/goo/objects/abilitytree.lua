goo.learnbutton = class('goo learnbutton',goo.object)

function goo.learnbutton:initialize(parent)
	super.initialize(self,parent)
end
function goo.learnbutton:setSkill(skill,face)
	assert(skill,'skill needed')
	assert(face)
	self.skill = skill
	self.face = face
	self.drawscale = self.h/face:getHeight()
end


function goo.learnbutton:enterHover()
	if self.skill then
		self.parent.panel1:fillPanel(self.skill:getPanelData())
		self.parent.panel1:setVisible(true)
		self.parent.hoverbutton = self
	end
end

function goo.learnbutton:exitHover()
	if self.parent.hoverbutton == self then
		self.parent.panel1:setVisible(false)
		self.parent.hoverbutton = nil
	end
end

function goo.learnbutton:onClick()
	if self.parent.learn then
		self.parent.learn(self.skill,self)
		self:enterHover()
	end
end

function goo.learnbutton:draw()
	super.draw(self)
	local length = self.h
	local rw,rh = self.face:getWidth(),self.face:getHeight()
	local startx,y = 32,32
	love.graphics.setColor(0,0,0,125)
	love.graphics.circle('fill',startx,y,length/2)
	love.graphics.setColor(255,255,255,255)
	love.graphics.circle('line',startx,y,length/2)
	love.graphics.draw(self.face,startx,y,0,length/rw,length/rh,rw/2,rh/2)
--	if self.face then love.graphics.draw(self.face,0,0,0,self.drawscale) end
	drawSkillLevel(0,0,self.skill:getLevel(),self.skill.maxlevel)
end

return goo.learnbutton