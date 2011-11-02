
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


Paddle = Weapon:subclass('Paddle') --小乘佛法
function Paddle:initialize(x,y)
	super.initialize(self,'Assassin',x,y)
	self:setSkill(Pistol)
	self.name = 'Paddle'
end

function Paddle:drawBody(x,y,r)
	love.graphics.draw(img.assassinpistol,x,y,r,1,1,20,32)
end

function Paddle:getPanelData()
	return {
		title = self.name,
		type = 'IMPOSSIBLE WEAPON',
		attributes = {
			{text="The ultimate weapon of war, forged in Ms. Chan's cooking fire with recycled line papers. It is known that the holder of this weapon can summon storms and death at will."},
			{data=200,image=icontable.life,text="HP Bonus"},
			{data=150,image=icontable.mind,text="Energy Bonus"},
			{image=nil,text="Movement Speed Bonus",data=string.format("0/%.1f%%",100)},
			{image=icontable.ionicform,text="Attack",data='1200 Electric'},
		--	{image=nil,text="Armor",data=self.armor},
		}
	}
end

requireImage( 'assets/item/paddle.png','paddle' )

function Paddle:draw(x,y)
	love.graphics.draw(img.paddle,x,y,r,1,1,20,32)
end
