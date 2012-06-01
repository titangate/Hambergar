

b_pray = Buff:subclass('b_pray')
function b_pray:initialize(hpregen)
	self.hpregen = hpregen
	self.particle = {}
end
function b_pray:start(unit)
	unit.HPRegen = unit.HPRegen + self.hpregen
	unit.damagereduction.Bullet = unit.damagereduction.Bullet or 1
	unit.damagereduction.Bullet = unit.damagereduction.Bullet + 5
end
function b_pray:stop(unit)
	unit.HPRegen = unit.HPRegen - self.hpregen
	unit.damagereduction.Bullet = unit.damagereduction.Bullet - 5
end

function b_pray:buff(unit,dt)
	local r = math.random()*math.pi*2
	table.insert(self.particle,{
		life = 1,
		x = math.cos(r)*500,
		y = math.sin(r)*500,
	})
	
	self.particle[#self.particle].vx = -self.particle[#self.particle].x
	self.particle[#self.particle].vy = -self.particle[#self.particle].y
	for i,v in ipairs(self.particle) do
		v.life = v.life - dt
		if v.life > 0 then
			v.x = v.x + v.vx * dt
			v.y = v.y + v.vy * dt
		end
	end
end

requireImage'assets/sparkle.png'
function b_pray:draw(unit)
	for i,v in ipairs(self.particle) do
		if v.life > 0 then
			love.graphics.draw(img.sparkle,unit.x + v.x,unit.y + v.y,0,2,2,16,16)
		end
	end
end


MasterYuenImageMelee = Melee:subclass('MasterYuenImageMelee')
function MasterYuenImageMelee:initialize(unit)
	super.initialize(self,unit)
	self.damage = 50
end

MasterYuenImage = Unit:subclass('MasterYuenImage')

local frametime = 0.16
function MasterYuenImage:initialize(x,y,controller)
	
	super.initialize(self,x,y,16,10)
	self.animation = MasterYuenAnimation()
	self.controller = controller
	self.hp = 500
	self.maxhp = 500
	self.mp = 500
	self.maxmp = 500
	self.skills = {
		melee = MasterYuenImageMelee:new(self)
	}
	self.animation:resetAnimation()
	self.speedlimit = self.speedlimit * 2
end

function MasterYuenImage:skilleffect(skill)
	if skill then
		local c = math.random(3)
		if c==1 then
			self.animation:playAnimation('crane',1)
		elseif c==2 then
			self.animation:playAnimation('kick',1)
		else
			self.animation:playAnimation('fist',1)
		end
	end
end

function MasterYuenImage:update(dt)
	super.update(self,dt)
	self.animation:update(dt)
	self:damage('Bullet',self.maxhp/3*dt)
end

function MasterYuenImage:enableAI(ai)
	self.ai = ai or AI.ApproachAndAttack(self,GetCharacter(),self.skills.melee,50,100)
end

function MasterYuenImage:draw()
	self.animation:draw(self.x,self.y,self:getAngle())
end