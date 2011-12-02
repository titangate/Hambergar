EmergencyStop = Unit:subclass'EmergencyStop'
function EmergencyStop:initialize(x,y)
	super.initialize(self,x,y,16,48)
end


--requireImage('assets/drainable/emergencystop.png','emergencystop')
function EmergencyStop:draw()
	love.graphics.draw(img.station,self.x,self.y,self.body:getAngle(),1,1,48,48)
end


Lily = Unit:subclass'Lily'
function Lily:initialize(x,y)
	super.initialize(self,x,y,16,10)
--	self.controller = 'player'
end

requireImage('assets/whistler/lily.png','lily')

function Lily:draw()
	love.graphics.draw(img.lily,self.x,self.y,0,1,1,20,32)
end

requireImage('assets/doodad/gate.png','gate')
GrandDoor = Unit:subclass'GrandDoor'
function GrandDoor:initialize(x,y,controller)
	super.initialize(self,x,y,100,0)
	self.hp = 5000
	self.controller = controller
	self.state = 'slide'
end
function GrandDoor:createBody(world)
	self.body = love.physics.newBody(world,self.x,self.y,self.mass,self.mass)
	self.shape = love.physics.newRectangleShape(self.body,0,0,128,32)
	if self.controller then
		category,masks = unpack(typeinfo[self.controller])
		self.shape:setCategory(category)
		self.shape:setMask(unpack(masks))
	end
	self.updateShapeData = true -- a hack to fix the crash when set data in a coroutine
	if self.r then
		self.body:setAngle(self.r)
	end
end

function GrandDoor:damage()
end

function GrandDoor:open()
	self:gotoState'open'
end

function GrandDoor:close()
	self:gotoState()
end

function GrandDoor:drawOpen()
	love.graphics.draw(img.gate,self.x,self.y,self.body:getAngle(),1,1,64,16)
	self:drawBuff()
end

function GrandDoor:draw()
	love.graphics.setColor(255,0,0,255)
	love.graphics.draw(img.gate,self.x,self.y,self.body:getAngle(),1,1,64,16)
	self:drawBuff()
	love.graphics.setColor(255,255,255)
end

local open = GrandDoor:addState'open'
function open:draw()
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(img.gate,self.x,self.y,self.body:getAngle(),1,1,64,16)
	self:drawBuff()
	love.graphics.setColor(255,255,255)
end

function open:enterState()
	self.shape:setSensor(true)
end

function open:exitState()
	self.shape:setSensor(false)
end

requireImage'assets/whistler/arcanecircle.png'
ArcaneCircle = Unit:subclass'ArcaneCircle'
function ArcaneCircle:initialize(x,y,controller)
	super.initialize(self,x,y,64,0)
	self.ignorelock = true
	self.controller = controller
end

function ArcaneCircle:createBody(world)
	super.createBody(self,world)
	self.shape:setSensor(true)
end

function ArcaneCircle:draw()
	love.graphics.draw(img.arcanecircle,self.x,self.y,self.body:getAngle(),1,1,64,64)
end

function ArcaneCircle:add(b,coll)
	if b==GetCharacter() then
		local i = b.inventory:getItemByType'Bomb'
		local stack = 0
		if not i then
			stack = 10
		elseif i.stack<=10 then
			stack = 10-i.stack
		end
		if stack > 0 then
			local bomb = Bomb()
			b:pickUp(bomb,stack)
		end
	end
end
