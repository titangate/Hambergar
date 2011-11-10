

AssassinAbiTree = Object:subclass('AssassinAbiTree')
files = love.filesystem.enumerate('assets/characters')
character = {}
for i,v in ipairs(files) do
	if love.filesystem.isFile('assets/characters/'..v) then
		local f = v:gmatch("(%w+).(%w+)")
		local file,ext=f()
		if ext=='png' then
			character[file] = love.graphics.newImage('assets/characters/'..v)
		end
	end
end

requireImage('assets/spirit.png','spirit')

function AssassinAbiTree:initialize(unit)
	self.unit = unit
	self.container = goo.object:new()
	local t = {
		{face = character[unit.skills.pistol.name],
		skill = unit.skills.pistol,
		pos = {75,75}},
		{face = character[unit.skills.stunbullet.name],
		skill = unit.skills.stunbullet,
		pos = {175,75}},
		{face = character[unit.skills.explosivebullet.name],
		skill = unit.skills.explosivebullet,
		pos = {275,75}},
		{face = character[unit.skills.momentumbullet.name],
		skill = unit.skills.momentumbullet,
		pos = {375,75}},
		{face = character[unit.skills.dash.name],
		skill = unit.skills.dash,
		pos = {75,175}},
		{face = character[unit.skills.roundaboutshot.name],
		skill = unit.skills.roundaboutshot,
		pos = {175,175}},
		{face = character[unit.skills.stim.name],
		skill = unit.skills.stim,
		pos = {275,175}},
		{face = character[unit.skills.invis.name],
		skill = unit.skills.invis,
		pos = {375,175}},
		{face = character[unit.skills.mind.name],
		skill = unit.skills.mind,
		pos = {475,75}},
		{face = character.divide,
		skill = unit.skills.dws,
		pos = {675,325}},
	}
	self.buttongroup = {}
	for k,v in ipairs(t) do
		local b = goo.learnbutton:new(self.container)
		b:setPos(unpack(v.pos))
		b:setSize(64,64)
		b:setSkill(v.skill,v.face)
		self.buttongroup[v.skill]=b
	end
	self.enabletime = 0
	self.container.panel1 = goo.itempanel:new(self.container)
	self.container.panel1:setPos(600,50)
	self.container.panel1:setSize(300,10)
	self.container.panel1:setVisible(false)
	self.container:setVisible(false)
	self.container.panel1:setFollowerPanel(true)
	local responds = {
		LSL = 1,
		LSR = 1,
		LSU = 1,
		LSD = 1,
		w = 1,
		a = 1,
		s = 1,
		d = 1,
	}
	self.container.highlighted = self.buttongroup[unit.skills.pistol]
	function self.container:keypressed(k)
		if responds[k] then
			local x,y = controller:GetWalkDirection()
			for k,v in pairs(self.highlighted) do
		end
			local newlockon = self:direct(self.highlighted,{x,y},function(obj)
				return obj:isKindOf(goo.learnbutton)
			end)
			if newlockon then
				love.mouse.setPosition(newlockon.x+24,newlockon.y+24)
				self.highlighted = newlockon
			end
		end
		print (k,'is received by tree')
		if k=='return' then
			local x,y = love.mouse.getPosition()
			love.mousepressed(x,y,'l')
		end
	end
	local sp = goo.itempanel:new(self.container)
	sp:setSize(500,100)
	sp:setPos(screen.halfwidth-sp.w/2,screen.height - 150)
	
	local lb = goo.imagelabel:new(sp)
	lb:setSize(500,50)
	lb:setFont(fonts.oldsans32)
	lb:setAlignMode('center')
	lb:setPos(0,35)
	self.sp = sp
	self.spiritlabel = lb
	self.container.learn = function(skill) self:learn(skill) end
end

function AssassinAbiTree:enableabi(originalskill,targetskill)
	local originbutton=self.buttongroup[originalskill]
	local targetbutton=self.buttongroup[targetskill]

	self.enabletime = 4
	self.enableco = {originbutton.x+originbutton.w/2,originbutton.y+originbutton.h/2}
	self.stepco = {(targetbutton.x-originbutton.x),(targetbutton.y-originbutton.y)}
	self.targetbutton = targetbutton
	self.originbutton = originbutton
end

function AssassinAbiTree:update(dt)
	self.container.panel1:updateData()
	self.spiritlabel:setText(self.unit.spirit)
	if self.enabletime > 0 then
		if self.enabletime > 2 then
			systems[6]:setPosition(unpack(self.enableco))
			systems[6]:start()
			self.enableco = {self.enableco[1]+self.stepco[1]*dt/2,self.enableco[2]+self.stepco[2]*dt/2}
		else
			self.targetbutton:setVisible(true)
			if self.targetbutton ~= self.originbutton then self.targetbutton.skill:setLevel(0) end
		end
		systems[6]:update(dt)
		self.enabletime = self.enabletime - dt
	end
end

function AssassinAbiTree:show()
	for k,v in pairs(self.buttongroup) do
		if v.skill.level<0 then v:setVisible(false) end
	end
	local t
	if self.learning then
		t = 'ACQUIRE HAMBER SPIRIT TO UPGRADE YOUR ABILITIES'
	else
		t = 'MEDITATE TO DISTRIBUTE HAMBER SPIRIT'
	end
	self.sp:fillPanel({
		title = 'HAMBER SPIRIT',
		type = t,
		attributes = {
	--		{image = spirit,text ='BLAH'}
		}
	})
	self.sp:setSize(500,130)
end

function AssassinAbiTree:keypressed(k)
end

function AssassinAbiTree:learn(skill)
	if not self.learning then return end
	if self.enabletime >0 then
		return 
	end
	local maxlevel = skill.maxlevel or 999
	if skill.level<maxlevel then
		if self.unit.spirit>=1 then
			local s = skill:setLevel(skill.level+1)
			self.unit.spirit = self.unit.spirit - 1
			if s and s[1] then
				self:enableabi(skill,s[1])
			else
				self:enableabi(skill,skill)
			end
		end
	end
end

function AssassinAbiTree:draw()
	if self.enabletime > 0 then love.graphics.draw(systems[6]) end
	goo:draw()
end
