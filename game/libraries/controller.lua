ControllerBase = Object:subclass('ControllerBase')
function ControllerBase:initialize()
self.probetime = 0.02
self.probedt = 0
end

function ControllerBase:setLockAvailability(state)
	self.lockstate = state
end

function ControllerBase:lock(u)
	if u == GetCharacter() then return end
	if self.lockstate then
		if not self.lockunit or getdistance(GetCharacter(),u) <= self.lockdistance then
			self.lockunit = u
			self.lockdistance = getdistance(GetCharacter(),u)
			self.locktime = 0.3
		end
	end
end


function ControllerBase:GetOrderDirection()
	if self.lockunit then
		local x1,y1 = normalize(self.lockunit.x-GetCharacter().x,self.lockunit.y-GetCharacter().y)
		local x2,y2 = unpack(self:GetRawOrderDirection())
		if math.abs(x1*y2-x2*y1) < 0.3 then
			return {x1,y1}
		else
			return {x2,y2}
		end
	else
		return self:GetRawOrderDirection()
	end
end

function ControllerBase:update(dt)
	if self.lockunit then
		self.locktime = self.locktime - dt
		if self.locktime <= 0 then
			self.lockunit = nil
			self.lockdistance = 999999
		end
	end
end
JoystickController = ControllerBase:subclass('JoystickController')

-- The default configuration would be assumed to be XBOX controller.
function JoystickController:initialize(index)
	super.initialize(self)
	self.index = index
	love.joystick.open(index)
	self.newmap = {}
	self.numbuttons = love.joystick.getNumButtons(index)
	self.numaxis = love.joystick.getNumAxes(index)
	self.numhats = love.joystick.getNumHats(index)
	-- balls are not my concern
	self.axisPressCap = 0.8
	print (self.numbuttons,self.numaxis,self.numhats)
	for k=0,self.numaxis-1 do
		self.newmap['axe'..k]=0
	end
	for k=0,self.numbuttons-1 do
		self.newmap[k] = false
	end
end

function JoystickController:update(dt)
	super.update(self,dt)
	-- Use the old map and the newly computed map to figure out the delta
	self.oldmap = self.newmap
	self.newmap = {}
	for k=0,self.numbuttons-1 do
		self.newmap[k] = love.joystick.isDown(self.index,k)
		if self.oldmap[k] ~= self.newmap[k] then
			if self.newmap[k] then
				self:pressed(k)
			else
				self:released(k)
			end
		end
	end
	for i=0,self.numaxis-1 do
		k = 'axe'..i
		self.newmap[k] = love.joystick.getAxis(self.index,i)
		if math.abs(self.newmap[k]) < self.axisPressCap and math.abs(self.oldmap[k]) >= self.axisPressCap then
			self:released(k,'axis',self.oldmap[k])
		end
		if math.abs(self.newmap[k]) >= self.axisPressCap and math.abs(self.oldmap[k]) <self.axisPressCap then
			self:pressed(k,'axis',self.newmap[k])
		end
	end
--	print (self.newmap)
end

function JoystickController:pressed(b,t,v)
	print (b,t,v,'pressed')
end
function JoystickController:released(b,t,v)
	print (b,t,v,'released')
end

xboxmap = {
	[0] = 'A',
	[1] = 'B',
	[2] = 'X',
	[3] = 'Y',
	[4] = 'LB',
	[5] = 'RB',
	[6] = 'BACK',
	[7] = 'START',
	[8] = 'LSP',
	[9] = 'RSP',
	['axe0'] = {'LSL','LSR'},
	['axe1'] = {'LSU','LSD'},
	['axe2'] = {'RT','LT'},
	['axe3'] = {'RSU','RSD'},
	['axe4'] = {'RSL','RSR'},
	['RS'] = 'RS',
}
	
XBOX360Controller = JoystickController:subclass('XBOX360Controller')
function XBOX360Controller:initialize(index)
	super.initialize(self,index)
	self.newmap['RS'] = false
end

function XBOX360Controller:pressed(b,t,v)
	local b = xboxmap[b]
	if type(b)=='table' then
		if v>0 then
			b = b[2]
		else
			b = b[1]
		end
	end
	print (b)
	self:keypressed(b)
end
function XBOX360Controller:released(b,t,v)
	local b = xboxmap[b]
	if type(b)=='table' then
		if v>0 then
			b = b[2]
		else
			b = b[1]
		end
	end
	self:keyreleased(b)
end

function XBOX360Controller:update(dt)
	super.update(self,dt)
	self.orderpoint = nil
	self.orderdirection = nil
	self.walkdirection = nil
	local rx,ry = self.newmap['axe4'],self.newmap['axe3']
	local k = 'RS'
	self.newmap[k] = rx*rx+ry*ry>0.5
	if self.oldmap[k] ~= self.newmap[k] then
		if self.newmap[k] then
			self:pressed(k)
		else
			self:released(k)
		end
	end
end

xboxkeymap = 
{
	LB = 'b',
	RB = 'g',
	A = 'return',
	B = 'r',
	Y = 'v',
	X = 'z',
	LT = 'f',
	START = 't',
	BACK = 'escape',
	RSP = 'r',
	LSP = 'e',
}

function XBOX360Controller:keypressed(b)
	if xboxkeymap[b] then
		love.keypressed(xboxkeymap[b])
	end
	love.keypressed(b)
	if b == 'RS' then
		love.mousepressed(0,0,'l')
	end
end

function XBOX360Controller:keyreleased(b)
	if xboxkeymap[b] then
		love.keyreleased(xboxkeymap[b])
	else
		love.keyreleased(b)
	end
	if b == 'RS' then
		love.mousereleased(0,0,'l')
	end
end

function XBOX360Controller:GetRawOrderDirection()
	if not self.orderdirection then
	local x,y = self.newmap['axe4'],self.newmap['axe3']
		if x==0 and y==0 then
			self.orderdirection = {1,0}
		else
			self.orderdirection = {normalize(x,y)}
		end
	end
	return self.orderdirection
end
function XBOX360Controller:GetOrderPoint()
	if not self.orderpoint then
	local x,y =  self.newmap['axe4'],self.newmap['axe3']
	x,y = x*250,y*250
	self.orderpoint = {GetCharacter().x+x,GetCharacter().y+y}
	end
	return self.orderpoint
end

function XBOX360Controller:GetWalkDirection()
for i=0,self.numaxis-1 do
		k = 'axe'..i
		self.newmap[k] = love.joystick.getAxis(self.index,i)
	end
	if not self.walkdirection then
	local x,y =  self.newmap['axe0'],self.newmap['axe1']
	self.walkdirection = {x,y,(x*x+y*y)>0.5}
	end
	return unpack(self.walkdirection)
end
KeyboardController = ControllerBase:subclass('KeyboardController')
k = KeyboardController:new()
function k:GetOrderPoint()
	local x,y = love.mouse.getPosition()
	return {map.camera:untransform(x,y)}
end

function k:GetOrderDirection()
	if self.lockunit then
		local x1,y1 = normalize(self.lockunit.x-GetCharacter().x,self.lockunit.y-GetCharacter().y)
		local x2,y2 = unpack(self:GetRawOrderDirection())
		if math.abs(x1*y2-x2*y1) < 0.3 then
			return {x1,y1}
		else
			return {x2,y2}
		end
	else
		return self:GetRawOrderDirection()
	end
end

function k:GetRawOrderDirection()
	local x,y = love.mouse.getPosition()
	assert(map.camera)
	x,y = map.camera:untransform(x,y)
	if x==0 and y==0 then
		return {1,0}
	end
	return {normalize(x-GetCharacter().x,y-GetCharacter().y)}
end

local commandshifts = {a={-1,0},
	d={1,0},
	w={0,-1},
	s={0,1}}
function k:GetWalkDirection()
	local walk = false
		local x,y = 0,0
		for k,v in pairs(commandshifts) do
			if love.keyboard.isDown(k) then
				walk = true
				x,y=x+v[1],y+v[2]
			end
		end
		return x,y,walk
	end
controller = k

function GetOrderUnit()
	return controller.lockunit
end

function GetOrderPoint()
	return controller:GetOrderPoint()
end

function GetOrderDirection()
	return controller:GetOrderDirection()
end
