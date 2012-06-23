require 'units.class.assassin'
KingOfDragons = Assassin:subclass'KingOfDragons'

function KingOfDragons:initialize(...)
	super.initialize(self,...)
	self.spritesheet = {
		stand = requireImage'assets/assassin/assassinstand.png',
		order = requireImage'assets/assassin/assassinorder.png',
		pray = img.assassinpose,
	}
	self.skills.portalofmisery = PortalOfMisery(self,1)
--	self.skills.pistol:setLevel(5)
	self.skills.dragoneye = DragonEye(self,1)
	self.skills.mantrashield = MantraShield(self,1)
	self.action = 'stand'
	self.facing = 0
	
end

function KingOfDragons:loadFromAssassin(unit)
	self.skills.weaponskill = unit.skills.weaponskill
	for k,v in pairs(unit.skills) do
		if self.skills[k] and self.skills[k].setLevel then
			self.skills[k]:setLevel(v:getLevel())
		else
			print (k)
		end
	end
	local i = unit.inventory
	self.inventory = i
	
	i.unit = self
	i:setEquipmentActive(true)
	
end

function KingOfDragons:update(dt)
	dragongate.update(dt)
	super.update(self,dt)
	local facing = GetOrderDirection()
	self.facing = math.atan2(facing[2],facing[1])
	if self.skill then
		self.action = 'order'
	else
		self.action = 'stand'
	end
end

function KingOfDragons:draw()
	love.graphics.draw(self.spritesheet[self.action],self.x,self.y,self.facing ,1,1,20,32)
	self:drawBuff()
	dragongate.draw(self.x,self.y,self.facing+math.pi/2)	
end

function KingOfDragons:missileSpawnPoint()
	return displacement(self.x,self.y,(math.random()-0.5)*1+self.facing+math.pi,math.random(100,200))
end


function KingOfDragons:getSkillpanelData()
	assert(self.skills.useitem)
	return {
		buttons = {
					{skill = self.skills.dash,hotkey=hotkeys.dash,face=requireImage'assets/icon/dash.png'},
					{skill = self.skills.roundaboutshot,hotkey=hotkeys.spiral,face=requireImage'assets/icon/spiral.png'},
					{skill = self.skills.stim,hotkey=hotkeys.stim,face=requireImage'assets/icon/stim.png'},
					{skill = self.skills.mindripfield,hotkey=hotkeys.mindripfield,face=requireImage'assets/icon/rip.png'},
					{skill = self.skills.portalofmisery,hotkey=hotkeys.portalofmisery,face=self.skills.weaponskill.icon},
					{skill = self.skills.mantrashield,hotkey=hotkeys.mantrashield,face=requireImage'assets/icon/mantrashield.png'},
					{skill = self.skills.dragoneye,hotkey=hotkeys.dragoneye,face=requireImage'assets/icon/summon.png'},
					{skill = self.skills.dws,hotkey=hotkeys.dws,face=requireImage'assets/icon/dws.png'},
					{skill = self.skills.useitem,hotkey=hotkeys.useitem,face=self.skills.useitem:getIcon()},
--[[			{skill = self.skills.dash,hotkey='b',face=requireImage'assets/icon/dash.png'},
			{skill = self.skills.roundaboutshot,hotkey='r',face=requireImage'assets/icon/spiral.png'},
			{skill = self.skills.stim,hotkey='e',face=requireImage'assets/icon/stim.png'},
			{skill = self.skills.mindripfield,hotkey='f',face=requireImage'assets/icon/rip.png'},
			{skill = self.skills.portalofmisery,hotkey='lb',face=self.skills.weaponskill.icon},
			{skill = self.skills.mantrashield,hotkey='v',face=requireImage'assets/icon/mantrashield.png'},
			{skill = self.skills.dragoneye,hotkey='g',face=requireImage'assets/icon/summon.png'},
			{skill = self.skills.dws,hotkey='z',face=requireImage'assets/icon/dws.png'},
			{skill = self.skills.useitem,hotkey='q',face=self.skills.useitem:getIcon()},]]
		}
	}
end

