
background = love.graphics.newImage('assets/qmsht.jpg')
scroll = love.graphics.newImage('assets/scroll.png')
requireImage('assets/scrollbackground.jpg','scrollbackground')
scroll:setWrap('repeat','repeat')
scrollq = love.graphics.newQuad(0,0,50,640,50,320)
function getExplosionAction(impact,buff,filter)
	return function (area,caster,skill)
		local units = map:findUnitsInArea(area)
		for k,v in pairs(units) do
			if filter(v) then
				local x,y=normalize(v.x-area.x,v.y-area.y)
				x,y=x*impact,y*impact
				if buff then v.buffs[buff:new()] = true end
				if v.body and not v.immuneimpact then
					v.body:applyImpulse(x,y)
				end
			end
		end
	end
end

PANEL_ASSASSIN_ABI = 0
PANEL_ASSASSIN_CHAR = 1

AssassinPanelManager = Object:subclass('PanelManager')
function AssassinPanelManager:initialize(unit)
	self.tree = AssassinAbiTree:new(unit)
	self.character = AssassinCharacterPanel:new(unit)
	self.currentsystem = self.tree
	self.dt = 0
end

function AssassinPanelManager:start(system)
	if system == PANEL_ASSASSIN_ABI then
		self.currentsystem = self.tree
	elseif system == PANEL_ASSASSIN_CHAR then
		self.currentsystem = self.character
	end
	self:show()
end

function AssassinPanelManager:shift(system)
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

function AssassinPanelManager:keypressed(k)
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

function AssassinPanelManager:keyreleased(k)
	if self.currentsystem.keyreleased then self.currentsystem:keyreleased(k) end
end

function AssassinPanelManager:mousepressed(x,y,k)
	if self.currentsystem.mousepressed then self.currentsystem:mousepressed(x,y,k) end
end

function AssassinPanelManager:mousereleased(x,y,k)
	if self.currentsystem.mousereleased then self.currentsystem:mousereleased(x,y,k) end
end

function AssassinPanelManager:show()
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
function AssassinPanelManager:fold()
	self.folddt = 0
end
function AssassinPanelManager:update(dt)
	self.dt = self.dt+dt
	if self.folddt<1.1 then self.folddt = self.folddt+dt end
	if not self.shifttime then
	else
		self.shifttime = self.shifttime - dt
		if self.shifttime < 0 then
			self.shifttime = nil
			self.currentsystem = self.shiftsystem
		end
	end
	self.currentsystem:update(dt)
end

function AssassinPanelManager:draw()
	if self.dt < 1.1 then
		map:draw()
		love.graphics.setScissor(0,0,love.graphics.getWidth()*self.dt,love.graphics.getHeight())
		love.graphics.draw(img.background,-self.dt/self.time*background:getWidth(),0,0,1.1,1.1)
		self.currentsystem:draw()
		love.graphics.drawq(img.scroll,scrollq,love.graphics.getWidth()*self.dt-50,0,0,1,1)
		love.graphics.setScissor()
	elseif self.folddt < 1 then
		map:draw()
		
		love.graphics.setScissor(0,0,love.graphics.getWidth()*(1-self.folddt),love.graphics.getHeight())
		love.graphics.draw(img.background,-self.dt/self.time*background:getWidth(),0,0,1.1,1.1)
		
		self.currentsystem:draw()
		love.graphics.setScissor()
		love.graphics.drawq(img.scroll,scrollq,love.graphics.getWidth()*(1-self.folddt)-50,0,0,1,1)
		if self.folddt>=0.95 then
			if self.currentsystem.container then
				self.currentsystem.container:setVisible(false)
			end
			popsystem()
		end
	elseif self.shifttime then
		love.graphics.draw(img.background,-self.dt/self.time*background:getWidth(),0,0,1.1,1.1)
		love.graphics.translate((1-self.shifttime)*love.graphics.getWidth(),0)
		self.currentsystem:draw()
		love.graphics.translate(-love.graphics.getWidth(),0)
		self.shiftsystem:draw()
	else
		love.graphics.draw(img.background,-self.dt/self.time*background:getWidth(),0,0,1.1,1.1)
		self.currentsystem:draw()
	end
end
