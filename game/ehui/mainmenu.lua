requireImage( 'assets/UI/menubuttonbackground.png','menubuttonbackground' )
MenuButtonActor = Actor:subclass('MenuButtonActor')
function MenuButtonActor:setState(state)
	self.state = state
	if state == 'hover' then
		self.anim = ColorTransformAnimation:new(0.5)
		self.anim:setOrigin(255,255,255,180)
		self.anim:setDest(255,255,255,255)
		self:setColor(255,255,255,255)
	else
		local c = nil
		if self.anim then
			c = self.anim.c
		else
			c = {255,255,255,255}
		end
		self.anim = ColorTransformAnimation:new(0.5)
		self.anim:setDest(255,255,255,180)
		self.anim:setOrigin(unpack(c))
		self:setColor(255,255,255,180)
	end
end
function MenuButtonActor:update(dt)
	if self.anim then
		if self.anim:update(dt)=='finish' then
			self.anim = nil
		end
	end
end
function MenuButtonActor:draw(x,y)
	if self.color then love.graphics.setColor(unpack(self.color)) end
	if self.anim then self.anim:apply() end
	love.graphics.draw(img.menubuttonbackground,x,y)
	if self.anim then self.anim:revert() end
	love.graphics.setColor(unpack(color.defaultcolor))
end

b_MenuButton = Widget:subclass('b_MenuButton')
function b_MenuButton:initialize(...)
	self.text = arg[1]
	arg[1] = self
	super.initialize(unpack(arg))
	self.actors = {
		MenuButtonActor:new(),
		TextActor:new(self.text,bigfont)
	}
	self.actors[1]:setColor(255,255,255,180)
	self.actors[2]:setColor(0,0,0,255)
	self.actor = {
		update = function(_,dt)
			for k,v in ipairs(self.actors) do
				v:update(dt)
			end
		end,
		draw = function(_,x,y)
			for k,v in ipairs(self.actors) do
				v:draw(x,y)
			end
		end
	}
end

function b_MenuButton:mousereleased(x,y,b)
	if b=='l' and self.hovering then
		self:onClick()
	elseif b=='r' and self.hovering then
		self:onRightClick()
	end
end

function b_MenuButton:hover()
	super.hover(self)
	self.actors[1]:setState('hover')
end

function b_MenuButton:unhover()
	super.unhover(self)
	self.actors[1]:setState('unhover')
end

function b_MenuButton:onClick()
end

function b_MenuButton:onRightClick()
end
