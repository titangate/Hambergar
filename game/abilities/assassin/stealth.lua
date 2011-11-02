
b_Takedown = b_Stun:subclass('b_Takedown')

Takedown = ActiveSkill:subclass('Takedown')
function Takedown:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Takedown'
	self.effecttime = -1
	self.cd = 8
	self.cdtime = 0
	self.available = true
	self:setLevel(level)
end

function Takedown:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end	
	local u = GetOrderUnit()
	if self.unit.takingdown then
		u:drop()
		u:stop()
		u:addBuff(b_Takedown(),3600)
		u.ai:pause()
		super.active(self)
		self.unit.alertlevel = self.unit.alertlevel + 1
		Timer(3,1,function()
			self.unit.alertlevel = self.unit.alertlevel - 1
		end)
	end
	StealthSystem.lethalAttract()
end

function Takedown:getPanelData()
	return{
		title = 'Takedown',
		type = 'ACTIVE',
		attributes = {
			{text = 'Instantly stun an enemy if he has not spotted you.'},
		}
	}
end

function Takedown:geteffectinfo()
	return self.unit,self.unit,self
end

function Takedown:setLevel(lvl)
	self.level = lvl
end

ChangeOutfit = ActiveSkill:subclass('Takedown')
function ChangeOutfit:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Takedown'
	self.effecttime = -1
	self.cd = 8
	self.cdtime = 0
	self.available = true
	self:setLevel(level)
end

function ChangeOutfit:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end	
	local u = GetOrderUnit()
	if u:hasBuff(b_Takedown) then
		self.unit.animation = u.animation
		self.unit.outfit = u.class
		self.unit:resetAnimation()
		self.unit.alertlevel = self.unit.alertlevel + 1
		Timer(3,1,function()
			self.unit.alertlevel = self.unit.alertlevel - 1
		end)
	end
	StealthSystem.lethalAttract()
end

function ChangeOutfit:getPanelData()
	return{
		title = 'ChangeOutfit',
		type = 'ACTIVE',
		attributes = {
			{text = 'Change to another outfit to avoid suspicious.'},
		}
	}
end

function ChangeOutfit:geteffectinfo()
	return self.unit,self.unit,self
end

function ChangeOutfit:setLevel(lvl)
	self.level = lvl
end


