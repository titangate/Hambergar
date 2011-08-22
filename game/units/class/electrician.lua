

Electrician = Character:subclass('Electrician')

files = love.filesystem.enumerate('assets/electrician')
electricianicon = {}
for i,v in ipairs(files) do
	if love.filesystem.isFile('assets/electrician/icon/'..v) then
		local f = v:gmatch("(%w+).(%w+)")
		local file,ext=f()
		if ext=='png' then
			character[file] = love.graphics.newImage('assets/electrician/icon/'..v)
		end
	end
end

function Electrician:initialize(x,y)
	super.initialize(self,x,y,16,10)
	self.hp = 500
	self.maxhp = 500
	self.mp = 500
	self.maxmp = 500
	self.skills = {
		pistol = Pistol:new(self,1),
	}
	self.spirit = 10
--	self.manager = ElectricianPanelManager:new(self)
end

function Electrician:damage(...)
	super.damage(self,...)
	local b = BloodTrail:new(self)
	map:addUpdatable(b)
end

function Electrician:getSkillpanelData()
	return {
		buttons = {
			{skill = self.skills.pistol,hotkey='lb',face=character[self.skills.pistol.name]},
		}
	}
end

function Electrician:draw()
	if self.invisible then
		love.graphics.setColor(255,255,255,100)
	end
	local facing = GetOrderDirection()
	facing = math.atan2(facing[2],facing[1])
	love.graphics.draw(assassinpose,self.x,self.y,facing,1,1,20,32)
	love.graphics.draw(assassinpistol,self.x,self.y,facing,1,1,20,32)
	self:drawBuff()
	love.graphics.setColor(255,255,255,255)
	if self.lockunit then
		love.graphics.circle('fill',self.lockunit.x,self.lockunit.y,64)
	end
end
