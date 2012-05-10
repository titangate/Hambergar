
Battery = Skill:subclass('Battery')
function Battery:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Drain'
	self.effecttime = 9999
	self.effect = DrainEffect
	self:setLevel(level)
	self.movementspeedbuffpercent = 10
	self.maxlevel = 15
	self.isHub = true
end

function Battery:getSublevel(skill)
	if skill:isKindOf(CPU) then
		return math.ceil(self.level*0.66)
	elseif skill:isKindOf(Transmitter) then
		return math.floor((self.level)/2)
	end
	return math.floor(self.level/3.4+1)
end

function Battery:getPanelData()
	return{
		title = 'Fusion reactor',
		type = 'BASE COMPONENT',
		attributes = {
			{text = "The energy source which maintains the functionalities of HOLLY and the life of the electrician himself."},
			{text = "Provide 1 unit of energy supply per level. Energy supply restrict the electrician's other chips."},
			{text = "Upgrades increase the effeciency of draining."},
			{text = "Ultimate upgrade",data='Automatic Drain'},
		}
	}
end

function Battery:setLevel(lvl)
	self.level = lvl
	if lvl>1 then
		return {
			self.unit.skills.drain,
			self.unit.skills.cpu,
			self.unit.skills.transmitter,
			self.unit.skills.ionicpool,
		}
	else
	return {}
end
end


b_Drain = Buff:subclass('b_Drain')
function b_Drain:initialize(unit,caster,skill)
	self.skill = skill
end

function b_Drain:start(u)
	u.state = 'slide'
	local sources = map:findUnitsWithCondition(
		function(unit)
			return withincirclearea(unit,u.x,u.y,self.skill.range) and unit.drainablemana
	end)
	self.sources={}
	for k,v in pairs(sources) do
		self.sources[v]=true
	end
	self.beams = {}
	for v,_ in pairs(self.sources) do
		local l = DrainBeam:new(v,u,99,{255,255,255})
		map:addUpdatable(l)
		self.beams[v]=l
	end
end

function b_Drain:stop(unit)
	for k,v in pairs(self.beams) do
		v.life=0.5
	end
end

function b_Drain:buff(unit,dt)
	unit.allowmovement = false
	unit.allowactive = false
	for v,_ in pairs(self.sources) do
		if v.drainablemana then
			unit.mp = unit.mp+dt*self.skill.manaregen
			v:drain(unit,dt*self.skill.manaregen)
		else
			self.sources[v]=nil
			self.beams[v].life=0.5
			self.beams[v]=nil
		end
	end
end

DrainEffect = UnitEffect:new()
DrainEffect:addAction(function(unit,caster,skill)
	local buff = b_Drain:new(unit,caster,skill)
	caster:addBuff(buff,99)
	skill.buff = buff
end)

Drain = Skill:subclass('Drain')
function Drain:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'Drain'
	self.effecttime = 9999
	self.effect = DrainEffect
	self:setLevel(level)
	self.manaregen = 10
	self.maxlevel = 5
	self.range = 200
end

function Drain:getPanelData()
	return{
		title = 'Drain',
		type = 'ACTIVE',
		attributes = {
			{text = "Drain electronic energy from nearby environment."},
			{text = 'Type',data = function() if self.level==self.maxskill then return 'Automatic' else return 'Manually' end end},
			{text = 'Energy Regeneration',data = function()return self.manaregen end},
		}
	}
end

function Drain:startChannel()
	self.effect:effect(self:getorderinfo())
	self.unit:playAnimation('drain',1,true)
end

function Drain:endChannel()
	if self.buff then
		self.unit:removeBuff(self.buff)
	end
	self.unit:resetAnimation()
end

function Drain:geteffectinfo()
	return GetOrderDirection(),self.unit,self
end

function Drain:stop()
	self.time = 0
end

function Drain:setLevel(lvl)
	self.manaregen = lvl*5+5
	self.level = lvl
end
