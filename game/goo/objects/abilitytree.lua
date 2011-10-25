goo.learnbutton = class('goo learnbutton',goo.object)

function goo.learnbutton:initialize(parent)
	super.initialize(self,parent)
end
function goo.learnbutton:setSkill(skill,face)
	assert(skill)
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
	end
end

function goo.learnbutton:draw()
	super.draw(self)
	self:setColor({255,255,255})
	if self.face then love.graphics.draw(self.face,0,0,0,self.drawscale) end
	drawSkillLevel(0,0,self.skill.level,self.skill.maxlevel)
end

return goo.learnbutton