
local generateChainlink = function()
	local chains = {}
	for i=1,20 do
		table.insert(chains,{})
	end
	local length = 5
	local branch
	branch = function(x,y,angle,recurse)
		local cosr,sinr = 20*math.cos(angle),20*math.sin(angle)
		local nx,ny = x,y
		for i=1,5 do
			nx,ny = x+cosr*i,y+sinr*i
			table.insert(chains[recurse*5+i],{nx,ny,angle})
		end
		
		if recurse < 3 then
			branch(nx,ny,angle-math.pi/3,recurse+1)
			branch(nx,ny,angle+math.pi/3,recurse+1)
			branch(nx,ny,angle-math.pi/2,recurse+1)
--			branch(nx,ny,angle+math.pi/2,recurse+1)
--			branch(nx,ny,angle-math.pi/1,recurse+1)
--			branch(nx,ny,angle+math.pi/1,recurse+1)
			branch(nx,ny,angle,recurse+1)
		end
	end
	branch(0,0,0,0)
	branch(0,0,math.pi*2/3,0)
	branch(0,0,-math.pi*2/3,0)
	return chains
end

local hellchains = generateChainlink()
HellOfSpikesActor = Object:subclass('HellOfSpikesActor')
function HellOfSpikesActor:initialize(x,y)
	self.x,self.y = x,y
	self.dt = 0
	self.time = 0.025
	self.hp = 4
	self.count = 1
end

function HellOfSpikesActor:update(dt)
	self.hp = self.hp - dt
	if self.hp<=0 then
		map:removeUpdatable(self)
	end
	self.dt = self.dt + dt
	if self.dt > self.time then
		self.dt = self.dt - self.time
		if self.hp > 3.5 then
			self.count = self.count + 1
		elseif self.hp < 0.5 then
			self.count = self.count - 1
		end
	end
end

function HellOfSpikesActor:draw()
	self.count = math.clamp(self.count,1,20)
	for i=1,self.count do
		for _,v in ipairs(hellchains[i]) do
			local x,y,r = unpack(v)
			x,y = x+self.x,y+self.y
			if i == self.count then
				love.graphics.draw(img.linkend,x,y,r)
			else
				love.graphics.draw(img.link,x,y,r)
			end
		end
	end
end

HellOfSpikesEffectAoE = CircleAoEEffect:new(300)
HellOfSpikesEffectAoE:addAction(function (area,caster,skill)
	local units = map:findUnitsInArea(area)
	for k,v in pairs(units) do
		if v:isKindOf(Unit) and v:isEnemyOf(caster) then
			map:addUpdatable(BloodStain(v.x,v.y))
			v:addBuff(b_Stun:new(100,nil),skill.stuntime)
			v:damage('Bullet',caster:getDamageDealing(skill.damage,'Bullet'),caster)
		end
	end
end)

HellOfSpikesEffect = UnitEffect:new()
HellOfSpikesEffect:addAction(function(unit,caster,skill)
	local chain = caster.chain
	local chain1,chain2 = unpack(caster.subchains)
	chain:setAngle(4.189)
	chain1:setAngle(0)
	chain2:setAngle(2.094)
	chain:tornado(12)
	chain1:tornado(12)
	chain2:tornado(12)
	local length = skill.length
	Timer(0.05,length+20,function(timer)-- to do
		if timer.count > length+15 then
			chain:setLength(length+25-timer.count)
			chain1:setLength(length+25-timer.count)
			chain2:setLength(length+25-timer.count)
		elseif timer.count <=5 then
			chain:setLength(timer.count+3)
			chain1:setLength(timer.count+3)
			chain2:setLength(timer.count+3)
		end
	end,true,true)
	Timer(2,1,function()
		caster.chain:revert()
		chain1:revert()
		chain2:revert()
	end,true,true)
	HellOfSpikesEffectAoE:effect({caster.x,caster.y},caster,skill)
	map:addUpdatable(HellOfSpikesActor(caster.x,caster.y))
	caster:addBuff(b_Pause(),4)
	Blureffect.blur('motion',{},0,5)
end)


HellOfSpikes = ActiveSkill:subclass('HellOfSpikes')

function HellOfSpikes:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'HellOfSpikes'
	self.groupname = 'Chain'
	self.effecttime = -1
	self.effect = HellOfSpikesEffect
	self.cd = 1
	self.cdtime = 0
	self.shots = 5
	self.available = true
	self:setLevel(level)
	self.damage = 200
	self.stuntime = 5
	self.length = 20
	self.hiteffect = HellOfSpikeshiteffect
end

function HellOfSpikes:active()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	self.unit:playAnimation('attack',1)
	super.active(self)
	self.effect:effect(self:getorderinfo())
	return true
end

function HellOfSpikes:getPanelData()
	return{
		title = 'HellOfSpikes',
		type = 'ACTIVE',
		attributes = {
			{text = 'HellOfSpikes your chain and deal damage.'},
		}
	}
end

function HellOfSpikes:geteffectinfo()
	return self.unit,self.unit,self
end

function HellOfSpikes:stop()
	self.time = 0
end

function HellOfSpikes:setLevel(lvl)
	self.level = lvl
end