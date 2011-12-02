local plateimg = {
	chik = love.graphics.newImage'assets/switchplate/chik.png',
	chu = love.graphics.newImage'assets/switchplate/chu.png',
	nga = love.graphics.newImage'assets/switchplate/nga.png',
	troll = love.graphics.newImage'assets/switchplate/troll.png',
}
requireImage'assets/switchplate/switchplatebase.png'
requireImage'assets/switchplate/switchplateflip.png'
local ox,oy = 32,32
SwitchPlate = Unit:subclass'SwitchPlate'
function SwitchPlate:initialize(x,y,controller)
	super.initialize(self,x,y,16,0)
	self.hp = 10000
	self.maxhp = 10000
	self.controller = controller
	self.state = 'slide'
	self.switchStates = {
		'chik',
		'chu',
		'nga',
		'troll',
	}
	self.target = 'chik'
	self.present = 'chik'
	self.dt = 1
end

function SwitchPlate:switch(state)
	assert(plateimg[state])
	self.target = state
	self.dt = 1
end

function SwitchPlate:update(dt)
	super.update(self,dt)
	if self.dt then
		self.dt = self.dt - dt
		if self.dt <= 0 then
			self.present = self.target
			self.dt = nil
		end
	end
end

function SwitchPlate:damage(...)
	super.damage(self,...)
	self:notifyListeners{type='switch',unit=self,state=self.present}
--	self:switch(self.switchStates[math.random(#self.switchStates)])
end

function SwitchPlate:draw()
	love.graphics.draw(img.switchplatebase,self.x,self.y,self.body:getAngle(),1,1,ox,oy)
	if self.dt then
		if self.dt > 0.5 then
			local scale = (self.dt-0.5)*2
			love.graphics.draw(img.switchplateflip,self.x,self.y,self.body:getAngle(),scale,1,ox,oy)
			love.graphics.draw(plateimg[self.present],self.x,self.y,self.body:getAngle(),scale,1,ox,oy)
		else
			local scale = (0.5-self.dt)*2
			love.graphics.draw(img.switchplateflip,self.x,self.y,self.body:getAngle(),scale,1,ox,oy)
			love.graphics.draw(plateimg[self.target],self.x,self.y,self.body:getAngle(),scale,1,ox,oy)
		end
	else
		love.graphics.draw(img.switchplateflip,self.x,self.y,self.body:getAngle(),1,1,ox,oy)
		love.graphics.draw(plateimg[self.present],self.x,self.y,self.body:getAngle(),1,1,ox,oy)
	end
end