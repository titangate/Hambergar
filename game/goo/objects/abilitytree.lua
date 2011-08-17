goo.learnbutton = class('goo learnbutton',goo.object)

function goo.learnbutton:initialize(parent)
	super.initialize(self,parent)
end
function goo.learnbutton:setSkill(skill,face)
	self.skill = skill
	self.face = face
	self.drawscale = 64/face:getHeight()
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
		self.parent.learn(self.skill)
	end
end

function goo.learnbutton:draw()
	super.draw(self)
	self:setColor({255,255,255})
--	if not self.skill or self.skill.level<= 0 then return end
	if self.face then love.graphics.draw(self.face,0,0,0,self.drawscale) end
	love.graphics.setFont(self.style.textFont)
	self:setColor(self.style.textColor)
	love.graphics.printf('LEVEL'..self.skill.level,0,48,64,'center')
end

return goo.learnbutton