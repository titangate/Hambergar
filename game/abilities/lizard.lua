
LizardPistol = Skill:subclass('LizardPistol')
function LizardPistol:initialize(unit)
	super.initialize(self)
	self.unit = unit
	self.bullettype = Bullet
	self.name = 'LizardPistol'
	self.effecttime = 0.1
	self.casttime = 1
	self.damage = 50
	self.effect = PistolEffect
	self.bulleteffect = BulletEffect
	self.bullettype = Bullet
end

function LizardPistol:stop()
	self.time = 0
end



