Buff = Object:subclass('Buff')
--b_Stun = Buff:subclass('b_Stun')
function Buff:initialize(priority,actor)
	self.priority = priority
	self.actor = actor
end

function Buff:buff(...)
end


b_Stun = Buff:subclass('b_Stun')
function b_Stun:initialize(priority,actor)
	self.r = 0
	self.icon = requireImage'assets/icon/stun.png'
	self.genre = 'debuff'
end

requireImage( 'assets/buff/stun.png','stunimg' )
function b_Stun:buff(unit,dt)
 	unit.state = 'slide'
	unit.allowskill = false
	unit.allowactive = false
	self.r = self.r+3.14*dt
end
function b_Stun:draw(unit)
	love.graphics.draw(img.stunimg,unit.x,unit.y,self.r,1,1,32,32)
end

function b_Stun:getPanelData()
	return {
		title = 'Stun',
		type = 'Debuff',
		attributes = {
			{text = 'You can not use your ability or move or attack.'}}
	}
end


b_Pause = b_Stun:subclass('b_Pause')
function b_Pause:draw()
end

b_Stim = Buff:subclass('b_Stim')
function b_Stim:initialize(movementspeedbuffpercent,spellspeedbuffpercent)
	self.spellspeedbuffpercent = spellspeedbuffpercent
	self.movementspeedbuffpercent = movementspeedbuffpercent
	self.icon = requireImage('assets/icon/stim.png',icontable)
	self.genre = 'buff'
end
function b_Stim:start(unit)
	unit.movementspeedbuffpercent = unit.movementspeedbuffpercent + self.movementspeedbuffpercent
	unit.spellspeedbuffpercent = unit.spellspeedbuffpercent + self.spellspeedbuffpercent
end
function b_Stim:stop(unit)
	unit.movementspeedbuffpercent = unit.movementspeedbuffpercent - self.movementspeedbuffpercent
	unit.spellspeedbuffpercent = unit.spellspeedbuffpercent - self.spellspeedbuffpercent
end

function b_Stim:getPanelData()
	return {
		title = 'Stim',
		type = 'Buff',
		attributes = {
			{text = 'Temperarily increase movement speed and attack speed.'}}
	}
end

function b_Stim:draw()
	
--	filtermanager:requestFilter('Bloom')
	filtermanager:requestFilter('Gaussianblur')
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


b_Dash = Buff:subclass('b_Dash')
function b_Dash:initialize(point,caster,skill)
	self.point = point
	self.skill = skill
end

function b_Dash:start(unit)
	unit.movementspeedbuffpercent = unit.movementspeedbuffpercent + self.skill.movementspeedbuffpercent
--	unit.movingforce = unit.movingforce + unit.mass*200
end

function b_Dash:stop(unit)
	unit.state = 'slide'
	unit.movementspeedbuffpercent = unit.movementspeedbuffpercent - self.skill.movementspeedbuffpercent
--	unit.movingforce = unit.movingforce - unit.mass*200
end

function b_Dash:buff(unit,dt)
	unit.direction = self.point;
	unit.state = 'move';
end