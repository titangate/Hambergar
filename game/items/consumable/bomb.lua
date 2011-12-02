
requireImage('assets/electrician/lightningball.png','lightningball')
BombUnit = Missile:subclass('BombUnit')

function BombUnit:preremove()
	super.preremove(self)
	self.skill.bulleteffect:effect({self.x,self.y},self.unit,self.skill)
--	local ip = LightningImpact:new(self,30,0.25,0.05,1,{255,255,255},1)
--	map:addUpdatable(ip)
end

function BombUnit:update(dt)
	super.update(self,dt)
	if self.dt>1 then
		self.body:setLinearVelocity(0,0)
	end
end

function BombUnit:draw()
	love.graphics.draw(img.lightningball,self.x,self.y,math.random(),1,1,32,32)
end

BombDropEffect = ShootMissileEffect:new()
BombDropEffect:addAction(function(point,caster,skill)
	assert(skill)
	local sx,sy = point[1]-caster.x,point[2]-caster.y
--	local v = math.sqrt(sx*sx+sy*sy)
	sx,sy=normalize(sx,sy)
	local m = BombUnit(4,1,10,caster.x,caster.y,sx,sy)
--	local ip = LightningImpact:new(Missile,30,0.1,0.05,4,{255,255,255},0.3)
--	map:addUpdatable(ip)
	m.controller = caster.controller..'Missile'
	m.effect = BallDamageEffect
	m.skill = skill
	m.unit = caster
	map:addUnit(m)
--	caster:playAnimation('attack',1,false)
end)

BallDamageEffect = CircleAoEEffect:new(200)
BallDamageEffect:addAction(function (area,caster,skill)
	local units = map:findUnitsInArea(area)
	for k,v in pairs(units) do
		if v:isKindOf(Unit) then
			local impact = skill.impact
			local x,y=normalize(v.x-area.x,v.y-area.y)
			x,y=x*impact,y*impact
			if v.body and not v.immuneimpact then
				v.body:applyImpulse(x,y)
			end
			v:damage('Bomb',skill.damage,caster)
		end
	end
	TEsound.play('sound/thunderclap.wav')
end)


requireImage'assets/item/bomb.png'
Bomb = Consumable:subclass'Bomb'
BombEffect = CircleAoEEffect:new(100)
BombEffect:addAction(function (area,caster,skill)
	local actor = MindRipFieldActor:new(area.x,area.y)
	local impact = skill.impact
	map:addUpdatable(actor)
	actor.x,actor.y=area.x,area.y
	local units = map:findUnitsInArea(area)
	for k,v in pairs(units) do
		if v:isKindOf(Unit) then
			local x,y=normalize(v.x-area.x,v.y-area.y)
			x,y=x*impact,y*impact
			v:damage('Bomb',caster:getDamageDealing(skill.damage,'Mind'),caster)
			
			if v.body and not v.immuneimpact then
				v.body:applyImpulse(x,y)
			end
		end
	end
end)

function Bomb:initialize(x,y)
	super.initialize(self,'consumable',x,y)
	self.name = "Bomb"
	self.stack = 1
	self.maxstack = 1
	self.time = 5
	self.hpregen = 10
	self.cd = 10
	self.groupname = 'Bomb'
	self.damage = 100
	self.impact = 250
	self.bulleteffect = BombEffect
end

function Bomb:use(unit)
	if unit:getCD(self.groupname) then return end
	unit:startCD(self.groupname,self.cd)
	BombDropEffect:effect(GetOrderPoint(),unit,self)
	return true
end

function Bomb:getPanelData()
	return {
		title = self.name,
		type = self.type,
		attributes = {
			{text="Damage units in area and push them away from the center."},
			{data=self.damage,image=nil,text="Damage"},
			{data=self.impact,image=nil,text="Impact"},
			{image=nil,text="Duration",data=self.time},
			{image=nil,text="Cooldown",data=self.cd},
		}
	}
end

function Bomb:update(dt)
end

function Bomb:draw(x,y)
	if not x then x,y = self.body:getPosition() end
	love.graphics.draw(img.bomb,x,y,0,1,1,24,24)
end
