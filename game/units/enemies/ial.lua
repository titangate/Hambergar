


IALSwordsmanMelee = Melee:subclass('IALSwordsmanMelee')
function IALSwordsmanMelee:initialize(unit)
	super.initialize(self,unit)
	self.damage = 50
end

IALMachineGun = MachineGun:subclass('IALMachineGun')
function IALMachineGun:initialize(unit)
	super.initialize(self,unit)
	self.damage = 20
	self.casttime = 0.25
end

IALThreewayShotgun = ThreewayShotgun:subclass('IALThreewayShotgun')
function IALThreewayShotgun:initialize(unit)
	super.initialize(self,unit)
	self.damage = 50
end


animation.mansword = Animation:new(love.graphics.newImage('assets/ial/mansword.png'),49.5,43,0.08,1.8,1.8,6,23)

IALSwordsman = AnimatedUnit:subclass('IALSwordsman')
function IALSwordsman:initialize(x,y,controller)
	super.initialize(self,x,y,16,10)
	self.controller = controller
	self.hp = 500
	self.maxhp = 500
	self.mp = 500
	self.maxmp = 500
	self.skills = {
		melee = IALSwordsmanMelee:new(self)
	}
	self.animation = {
		stand = animation.mansword:subSequence(1,1),
		attack = animation.mansword:subSequence(2,7)
	}
	self:resetAnimation()
	self.speedlimit = self.speedlimit * 2
end

function IALSwordsman:skilleffect(skill)
	if skill then
		self:playAnimation('attack',0.4,false)
	end
end

function IALSwordsman:enableAI(ai)
	self.ai = ai or AI.ApproachAndAttack(self,GetCharacter(),self.skills.melee,50,100)
end

animation.manmachinefire = Animation:new(love.graphics.newImage('assets/ial/manmachinefire.png'),59,26,0.04,1.8,1.8,8,8)
IALMachineGunner = AnimatedUnit:subclass('IALMachineGunner')
function IALMachineGunner:initialize(x,y,controller)
	super.initialize(self,x,y,16,10)
	self.controller = controller
	self.hp = 500
	self.maxhp = 500
	self.mp = 500
	self.maxmp = 500
	self.skills = {
		melee = IALSwordsmanMelee:new(self),
		gun = IALMachineGun:new(self)
	}
	self.animation = {
		stand = animation.manmachinefire:subSequence(1,1),
		attack = { animation.manmachinefire:subSequence(1,2),
		animation.manmachinefire:subSequence(3,4),
		animation.manmachinefire:subSequence(5,6),
		animation.manmachinefire:subSequence(7,8),
		}
	}
	self:resetAnimation()
end

function IALMachineGunner:skilleffect(skill)
	if skill then
		self:playAnimation('attack',0.4,false)
	end
end

function IALMachineGunner:enableAI(ai)
	self.ai = ai or AI.ApproachAndAttack(self,GetCharacter(),self.skills.gun,300,400)
end

animation.manshotgunfire = Animation:new(love.graphics.newImage('assets/ial/manshotgun.png'),55,20,0.04,1.8,1.8,7,7)
IALShotgunner = AnimatedUnit:subclass('IALShotgunner')
function IALShotgunner:initialize(x,y,controller)
	super.initialize(self,x,y,16,10)
	self.controller = controller
	self.hp = 500
	self.maxhp = 500
	self.mp = 500
	self.maxmp = 500
	self.skills = {
		melee = IALSwordsmanMelee:new(self),
		gun = IALThreewayShotgun:new(self)
	}
	self.animation = {
		stand = animation.manshotgunfire:subSequence(1,1),
		attack = animation.manshotgunfire:subSequence(2,5),
	}
	self:resetAnimation()
end
function IALShotgunner:skilleffect(skill)
	if skill then
		self:playAnimation('attack',0.4,false)
	end
end

function IALShotgunner:enableAI(ai)
	self.ai = ai or AI.ApproachAndAttack(self,GetCharacter(),self.skills.gun,300,400)
end
