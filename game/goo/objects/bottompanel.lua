goo.skillbutton = class('goo skillbutton',goo.object)
function goo.skillbutton:initialize(parent)
	super.initialize(self,parent)
end
function goo.skillbutton:setSkill(skill,face)
	self.skill = skill
	self.face = face
	self.drawscale = 48/face:getHeight()
end

function goo.skillbutton:setHotkey(hotkey)
	self.hotkey = hotkey
end

function goo.skillbutton:keypressed(k)
	if not self.skill or self.skill.level<=0 then return end
	if k==self.hotkey then
		if self.skill:isKindOf(ActiveSkill) then
			self.skill:active()
		else
			GetCharacter():switchChannelSkill(self.skill)
			self.parent.count = self.parent.count + 1
		end
	end
end

function goo.skillbutton:keyreleased(k)
	if not self.skill or self.skill.level<=0 then return end
	if k==self.hotkey then
		if not self.skill:isKindOf(ActiveSkill) then
			self.parent.count = math.max(0,self.parent.count - 1)
--			print (self.visible)
			if self.parent.count <= 0 then
				GetCharacter():switchChannelSkill(nil)
			end
		end
	end
end

function goo.skillbutton:draw()
	super.draw(self)
	self:setColor({255,255,255})
	if not self.skill or self.skill.level<= 0 then return end
	if self.face then love.graphics.draw(self.face,0,0,0,self.drawscale) end
	if self.hotkey then
		love.graphics.setFont(self.style.textFont)
		self:setColor(self.style.textColor)
		love.graphics.printf(string.upper(self.hotkey),0,self.style.yMargin,48,'center')
	end
	if self.skill:isKindOf(ActiveSkill) then
		DrawCD(24,24,self.skill:getCDPercent())
	end
end

goo.bottompanel = class ('goo bottompanel',goo.object)
function goo.bottompanel:initialize(parent)
	super.initialize(self,parent)
	self.count = 0
	self.buttons = {}
end

function goo.bottompanel:setSkin()
	goo.bottompanel.image = love.graphics.newImage(goo.skin..'skillpanel.png')
end

function goo.bottompanel:hideButton()
	for i,v in ipairs(self.buttons) do
		v:setAvailable(false)
		anim:easy(v,'opacity',255,0,1,'linear')
	end
	self.count = 0
end

function goo.bottompanel:showButton()
	for i,v in ipairs(self.buttons) do
		v:setAvailable(true)
		anim:easy(v,'opacity',0,255,1,'linear')
	end
	self.count = 0
end

function goo.bottompanel:draw()
	super.draw(self)
	self:setColor(255,255,255)
	love.graphics.draw(goo.bottompanel.image)
end

function goo.bottompanel:fillPanel(data,pedal)
	pedal = pedal or 5
	for i,v in ipairs(self.buttons) do
		v:destroy()
	end
	self.buttons = {}
	for i,v in ipairs(data.buttons) do
		local b = goo.skillbutton:new(self)
		b:setPos(self.style.xMargin+i*60,self.style.yMargin)
		b:setSize(48,48)
		b:setSkill(v.skill,v.face)
		b:setHotkey(v.hotkey)
		table.insert(self.buttons,b)
	end
end

function goo.bottompanel:conversation(speaker,text,image)
	if not self.speakerlabel then
		self.speakerlabel = goo.imagelabel:new(self)
		self.speakerlabel:setPos(100,20)
		self.speakerlabel.textcolor={0,0,0}
		self.speakerlabel:setSize(screen.width-200,10)
		self.speakerlabel:setFont(fonts.oldsans24)
		
		self.text = goo.imagelabel:new(self)
		self.text:setPos(100,80)
		self.text.textcolor={0,0,0}
		self.text:setFont(fonts.midfont)
		self.text:setSize(screen.width-200,10)
		self.text:setAlignMode('center')
	end
	if not (speaker or text or image) then
		anim:easy(self.speakerlabel,'opacity',255,0,1,'linear')
		anim:easy(self.text,'opacity',255,0,1,'linear')
	else
		self.speakerlabel:setImage(image)
		self.speakerlabel:setText(speaker)
		self.text:setText(text)
		anim:easy(self.speakerlabel,'opacity',0,255,1,'linear')
		anim:easy(self.text,'opacity',0,255,1,'linear')
	end
end

return goo.bottompanel