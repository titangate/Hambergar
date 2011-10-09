
SwiftPanelManager = Object:subclass('SwiftPanelManager')

function SwiftPanelManager:initialize(unit)
	self.tree = SwiftAbiTree:new(unit)
	self.character = SwiftCharacterPanel:new(unit)
	self.currentsystem = self.tree
	self.dt = 0
	self.unit=unit
end

function SwiftPanelManager:start(system)
	if system == PANEL_ASSASSIN_ABI then
		self.currentsystem = self.tree
	elseif system == PANEL_ASSASSIN_CHAR then
		self.currentsystem = self.character
	end
	self:show()
end

function SwiftPanelManager:shift(system)
	if system == self.currentsystem then
		return
	end
	if self.currentsystem.container then
		self.currentsystem.container:setVisible(false)
	end
	self.shiftsystem = system
	self.shifttime = 1
	if self.shiftsystem.container then
		self.shiftsystem.container:setVisible(true)
	end
	if self.shiftsystem.show then
		self.shiftsystem:show()
	end
end

function SwiftPanelManager:keypressed(k)
	if self.shifttime or self.folddt < 1 or self.dt < 1.1 then
		return
	end
	if k=='t' then
		self:fold()
	end
	if k=='LB' or k=='c' then
		self:shift(self.character)
		gamelistener:notify({type = 'shiftpanel',panel = 'character'})
	end
	if k=='RB' or k=='a' then
		self:shift(self.tree)
		gamelistener:notify({type = 'shiftpanel',panel = 'ability'})
	end
	if self.currentsystem.keypressed then self.currentsystem:keypressed(k) end
end

function SwiftPanelManager:keyreleased(k)
	if self.currentsystem.keyreleased then self.currentsystem:keyreleased(k) end
end

function SwiftPanelManager:mousepressed(x,y,k)
	if self.currentsystem.mousepressed then self.currentsystem:mousepressed(x,y,k) end
end

function SwiftPanelManager:mousereleased(x,y,k)
	if self.currentsystem.mousereleased then self.currentsystem:mousereleased(x,y,k) end
end

function SwiftPanelManager:show()
	self.time = 100
	self.dt = 0
	self.folddt = 100
	if self.currentsystem.container then
		self.currentsystem.container:setVisible(true)
	end
		if self.currentsystem.show then
			self.currentsystem:show()
		end
	gamelistener:notify({type = 'openpanel'})
end
function SwiftPanelManager:fold()
	self.folddt = 0
end
function SwiftPanelManager:update(dt)
	self.currentsystem:update(dt)
	self.dt = self.dt + dt
	self.folddt = self.folddt+dt
	if not self.shifttime then
	else
		self.shifttime = self.shifttime - dt
		if self.shifttime < 0 then
			self.shifttime = nil
			self.currentsystem = self.shiftsystem
		end
	end
end

function SwiftPanelManager:draw()
	if self.dt < 1 then
		map:draw()
		love.graphics.translate(screen.halfwidth,screen.halfheight)
		local scale = 2-self.dt
		love.graphics.scale(scale)
		love.graphics.translate(-screen.halfwidth,-screen.halfheight)
		self.currentsystem:draw()
	elseif self.folddt < 1 then
		map:draw()
		love.graphics.translate(screen.halfwidth,screen.halfheight)
		local scale = self.folddt+1
		love.graphics.scale(scale)
		love.graphics.translate(-screen.halfwidth,-screen.halfheight)
		self.currentsystem:draw()
		if self.folddt>=0.95 then
			if self.currentsystem.container then
				self.currentsystem.container:setVisible(false)
			end
			popsystem()
		end
	elseif self.shifttime then
		map:draw()
		love.graphics.translate((1-self.shifttime)*love.graphics.getWidth(),0)
		self.currentsystem:draw()
		love.graphics.translate(-love.graphics.getWidth(),0)
		self.shiftsystem:draw()
	else
		map:draw()
		self.currentsystem:draw()
	end
end
