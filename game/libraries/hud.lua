DisplayBar = Object:subclass('DisplayBar')
barbackground = love.graphics.newImage('assets/UI/barbackground.png')

function DisplayBar:initialize(funcr,x,y,length)
	self.funcr = funcr
	self.x,self.y=x,y
	self.length = length
end

AssassinHPBar = DisplayBar:subclass('AssassinHPBar')
function AssassinHPBar:initialize(funcr,x,y,length)
	super.initialize(self,funcr,x,y,length)
	self.trail = WaypointTrail:new(x,y+12,{{0,0},{80,0},{95,-12},{105,12},{120,0},{200,0}},100,length/200,1)
end

function AssassinHPBar:update(dt)
	self.trail.sx = self.funcr()*self.length/200
	self.trail:update(dt)
end

function AssassinHPBar:draw()
	love.graphics.draw(barbackground,self.x,self.y,0,self.length,1)
	love.graphics.setColor(255,80,80,255)
	love.graphics.draw(barbackground,self.x,self.y,0,self.length*self.funcr(),1)
	love.graphics.setColor(255,255,255,255)
	self.trail:draw()
end

AssassinMPBar = DisplayBar:subclass('AssassinMPBar')
function AssassinMPBar:initialize(funcr,x,y,length)
	super.initialize(self,funcr,x,y,length)
	self.trail = Trail:new(30,72,1,1)
		self.trail.getPosition = function(trail,dt) 
		trail.dy = math.cos(trail.xcoord/5)*3
		trail.xcoord = 100*dt + trail.xcoord
		if trail.xcoord>length then trail.xcoord = 0 end
	return trail.x+trail.xcoord*trail.sx,trail.y+trail.dy*trail.sy
	end
end

function AssassinMPBar:update(dt)

	self.trail.sx = self.funcr()
	self.trail:update(dt)
end
function AssassinMPBar:draw()
	love.graphics.draw(barbackground,self.x,self.y,0,self.length,1)
	love.graphics.setColor(80,80,255,255)
	love.graphics.draw(barbackground,self.x,self.y,0,self.length*self.funcr(),1)
	love.graphics.setColor(255,255,255,255)
	self.trail:draw()
end

SkillButton = Button:subclass('SkillButton')
function SkillButton:initialize(skill,group,x,y,w,h)
	super.initialize(self,group,x,y,w,h)
	self.skill = skill
	self.face = character[self.skill.name]
	self.scale = 48/self.face:getHeight()
	if self.skill:isKindOf(ActiveSkill) then
		self.cd = CDActor:new(self.skill,x+w/2,y+h/2)
	end
end

function SkillButton:click()
	if not self.skill then return end
	if self.skill:getLevel() > 0 and self.skill:isKindOf(ActiveSkill) then
		self.skill:active()
	end
end

function SkillButton:pressed()
	if not self.skill:isKindOf(ActiveSkill) then self.group.unit:switchChannelSkill(self.skill) end
	self.group.clickcount = self.group.clickcount + 1
end

function SkillButton:released()
	self.group.clickcount = self.group.clickcount - 1
	if self.group.clickcount <= 0 then
		self.group.unit:switchChannelSkill(nil)
	end
end

assassincd = love.graphics.newImage('assets/UI/assassincd.png')
scrollpanel = love.graphics.newImage('assets/UI/scrollpanel.png')
AssassinSkillButton = SkillButton:subclass('AssassinSkillButton')

function AssassinSkillButton:draw()
	if not self.skill then return end
	if self.skill:getLevel() <= 0 then return end
	if self.skill:isKindOf(ActiveSkill) then
		local p = self.skill:getCDPercent()
		love.graphics.draw(self.face,self.x,self.y,0,self.scale,self.scale)
	--	if p > 0 then
			self.cd:draw()
	--		love.graphics.setColor(255,255,255,200*(1-p))
	--		love.graphics.rectangle('fill',self.x,self.y,self.w*(1-p),self.h)
	--		love.graphics.setColor(255,255,255,255)
	--	end
	else
		love.graphics.draw(self.face,self.x,self.y,0,self.scale,self.scale)
	end
end


SkillButtonGroup = Object:subclass('SkillButtonGroup')
function SkillButtonGroup:initialize(unit)
	self.unit = unit
	self.clickcount = 0
	self.buttons = {}
	self.key2button = {b=1,r=2,f=3,g=4,z=5,c=6,v=7,ml=8,mr=9}
	self.button2key = {'b','r','f','g','z','c','v','ml','mr'}
end

function SkillButtonGroup:keypressed(k)
	local i = self.key2button[k]
	if i then
		self.buttons[i]:pressed()
	end
end

function SkillButtonGroup:keyreleased(k)
	local i = self.key2button[k]
	if i and self.buttons[i] then
		self.buttons[i]:released()
		self.buttons[i]:click()
	end
end

function SkillButtonGroup:mousepressed(x,y,k)
	k = 'm'..k
	local i = self.key2button[k]
	if i then
		self.buttons[i]:pressed()
	end
end

function SkillButtonGroup:mousereleased(x,y,k)
	k = 'm'..k
	local i = self.key2button[k]
	if i then
		self.buttons[i]:released()
		self.buttons[i]:click()
	end
end

function SkillButtonGroup:update(dt)
	for k,v in pairs(self.buttons) do
		v:update(dt)
	end
end

function SkillButtonGroup:draw()
	love.graphics.draw(scrollpanel,love.graphics.getWidth()/2,love.graphics.getHeight()-150,0,love.graphics.getWidth()/scrollpanel:getWidth(),nil,scrollpanel:getWidth()/2)
	for k,v in pairs(self.buttons) do
		love.graphics.setColor(0,0,0,255)
		love.graphics.print(self.button2key[k],v.x,v.y-v.h/2)
		love.graphics.setColor(255,255,255,255)
		v:draw()
	end
end

AssassinSkillButtonGroup = SkillButtonGroup:subclass('AssassinSkillButtonGroup')
function AssassinSkillButtonGroup:initialize(unit)
	super.initialize(self,unit)
	table.insert(self.buttons,AssassinSkillButton:new(unit.skills.dash,self,100,love.graphics.getHeight()-52,48,48))
	table.insert(self.buttons,AssassinSkillButton:new(unit.skills.roundaboutshot,self,152,love.graphics.getHeight()-52,48,48))
	table.insert(self.buttons,AssassinSkillButton:new(unit.skills.stim,self,204,love.graphics.getHeight()-52,48,48))
	--table.insert(self.buttons,AssassinSkillButton:new(unit.skills.stim,self,256,love.graphics.getHeight()-52,48,48))
	table.insert(self.buttons,AssassinSkillButton:new(unit.skills.mindripfield,self,308,love.graphics.getHeight()-52,48,48))
	self.buttons[8]=AssassinSkillButton:new(unit.skills.pistol,self,500,love.graphics.getHeight()-52,48,48)
	self.buttons[9]=AssassinSkillButton:new(unit.skills.mindripfield,self,600,love.graphics.getHeight()-52,48,48)
end

CDActor = Object:subclass('CDActor')
local cd = love.graphics.newImage('assets/UI/cd.png')
function CDActor:draw(x,y,percent)
--	print ('cddraw')
	if x then
		self.x,self.y = x,y
	end
	for i=1,math.floor(percent*33) do
		love.graphics.draw(cd,self.x,self.y,0.19*i,1,1,24,24)
	end
end
cdactor = CDActor:new()
function DrawCD(x,y,percent)
	cdactor:draw(x,y,percent)
end