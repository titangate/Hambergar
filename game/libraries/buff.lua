Buff = Object:subclass('Buff')
--b_Stun = Buff:subclass('b_Stun')
function Buff:initialize(priority,actor)
	self.priority = priority
	self.actor = actor
end

b_Stun = Buff:subclass('b_Stun')
function b_Stun:initialize(priority,actor)
self.r = 0
end

requireImage( 'assets/buff/stun.png','stunimg' )
function b_Stun:buff(unit,dt)
 	unit.state = 'slide'
--	unit:switchChannelSkill(nil)
	unit.allowskill = false
	self.r = self.r+3.14*dt
end
function b_Stun:draw(unit)
	love.graphics.draw(img.stunimg,unit.x,unit.y,self.r,1,1,32,32)
end
b_Stim = Buff:subclass('b_Stim')
function b_Stim:initialize(movementspeedbuffpercent,spellspeedbuffpercent)
	self.spellspeedbuffpercent = spellspeedbuffpercent
	self.movementspeedbuffpercent = movementspeedbuffpercent
end
function b_Stim:start(unit)
	unit.movementspeedbuffpercent = unit.movementspeedbuffpercent + self.movementspeedbuffpercent
	unit.spellspeedbuffpercent = unit.spellspeedbuffpercent + self.spellspeedbuffpercent
end
function b_Stim:stop(unit)
	unit.movementspeedbuffpercent = unit.movementspeedbuffpercent - self.movementspeedbuffpercent
	unit.spellspeedbuffpercent = unit.spellspeedbuffpercent - self.spellspeedbuffpercent
end

b_Summon = Buff:subclass('b_Summon')
function b_Summon:initialize(priority,actor)
self.r = 0
end
function b_Summon:buff(unit,dt)
	self.r = self.r+3.14*dt
end
function b_Summon:draw(unit)
	love.graphics.draw(img.stunimg,unit.x,unit.y,self.r,1,1,32,32)
end