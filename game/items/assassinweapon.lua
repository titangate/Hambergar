
requireImage('assets/assassin/assassinpistol copy.png','assassinpistol')
Theravada = Weapon:subclass('Theravada') --小乘佛法
function Theravada:initialize(x,y)
	super.initialize(self,'Assassin',x,y)
	self:setSkill(Pistol)
	self.name = 'Theravada'
end

function Theravada:drawBody(x,y,r)
	love.graphics.draw(img.assassinpistol,x,y,r,1,1,20,32)
end

function Theravada:getPanelData()
	return {
		title = self.name,
		type = self.type,
		attributes = {
			{text="weapon."},
		}
	}
end

function Theravada:draw(x,y)
end
