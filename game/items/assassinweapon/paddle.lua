
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
		type = LocalizedString'IMPOSSIBLE WEAPON',
		attributes = {
			{text=LocalizedString"The ultimate weapon of war, forged in Ms. Chan's cooking fire with recycled line papers. It is known that the holder of this weapon can summon storms and death at will."},
			{data=200,image=icontable.life,text=LocalizedString"HP Bonus"},
			{data=150,image=icontable.mind,text=LocalizedString"Energy Bonus"},
			{image=nil,text=LocalizedString"Movement Speed Bonus",data=string.format("0/%.1f%%",100)},
			{image=icontable.ionicform,text=LocalizedString"Attack",data='1200 Electric'},
		--	{image=nil,text="Armor",data=self.armor},
		}
	}
end


function Paddle:draw(x,y)
	love.graphics.draw(requireImage'assets/item/paddle.png',x,y,r,1,1,20,32)
end

return Paddle
