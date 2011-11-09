Skill = StatefulObject:subclass('Skill')
function Skill:initialize()
	super.initialize(self)
	self.time = 0
	self.effecttime = 0.1
	self.casttime = 0.3
	self.effected = false
	self.endtime = 0
end

function Skill:getorderinfo()
	return self:geteffectinfo()
end

function Skill:stop()
	self.time = 0
end


function Skill:getLevel()
	if self.level then return self.level end
end

function Skill:update(dt)
	if self.effecttime < 0 then return end
	self.time = dt + self.time
	if self.time >= self.effecttime and not self.effected then
		if self.effect then self.effect:effect(self:getorderinfo()) end
		if self.unit then self.unit:skilleffect(self) end
		self.effected = true
	end
	if self.time >= self.casttime then
		self.effected = false
		if self.stop then self:stop() end
	end
end

function Skill:startChannel()
	self.time = math.max(self.casttime,love.timer.getTime()-self.endtime+self.time)
	self.effected = true
end

function Skill:endChannel()
	self.endtime = love.timer.getTime()
end


ActiveSkill = Skill:subclass('ActiveSkill')

function ActiveSkill:cdupdate(dt)
	if self.available then return end
	self.cdtime = self.cdtime - dt
	if self.cdtime <= 0  then
		self.available = true
	end
end

function ActiveSkill:active()
	local groupname = self.groupname or self:className()
	self.unit:startCD(groupname,self.cd)
	self.unit:notifyListeners({type='active',skill = self})
end

function ActiveSkill:getRemainingCD()
	local groupname = self.groupname or self:className()
	return self.unit:getCD(groupname)
end

function ActiveSkill:getCDPercent()
	local groupname = self.groupname or self:className()
	local cddt = self.unit:getCD(groupname) or 0
	return cddt/self.cd
end

function ActiveSkill:isCD()
	local groupname = self.groupname or self:className()
	return self.unit:getCD(groupname) or not(self.unit.allowactive)
end
