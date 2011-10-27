function GetCharacter()
	return chr
end

function SetCharacter(c)
	if chr then
		chr:unregister()
	end
	chr = c
	GetGameSystem():setCharacter(c)
	c:register()
end

GameSystem = StatefulObject:subclass'GameSystem'
function GameSystem:initialize()
	super.initialize(self)
	self.bottompanel = goo.bottompanel:new()
	self.conversationpanel = goo.conversationpanel()
	self.conversationpanel:setPos(screen.width-450,20)
	self:gotoState()
	self.hpbar = AssassinHPBar(function()return GetCharacter():getHPPercent() end,30,30,200)
	self.mpbar = AssassinMPBar(function()return GetCharacter():getMPPercent() end,30,60,200)
	
end

function GameSystem:setCharacter(c)
	self:save(GetCharacter(),GetCharacter():className())
	self.character = c
	goo:setSkinAllObjects(c:getSkin())
	GetGameSystem().bottompanel:fillPanel(GetCharacter():getSkillpanelData())
	GetGameSystem().bottompanel:setPos(screen.halfwidth-512,screen.height - 150)
end

function GameSystem:save(thing,label)
	assert(thing.save)
	local savedata = {
		class = thing:className(),
		data = thing:save()
	}
	love.filesystem.write(label,table.save(savedata))
end

function GameSystem:saveAll()
--	love.filesystem.write('checkpoint',table.save(map.savedata))
--	self:save(GetCharacter(),GetCharacter():className())
end

function GameSystem:load()
end

function GameSystem:prepareToContinue(checkpoint)
	self.m = table.load(love.filesystem.read(checkpoint))
	self.map = require(self.m.map)
end

function GameSystem:continue()
--	local m = table.load(love.filesystem.read(checkpoint))
	self:runMap(self.map,self.m.checkpoint)
end

function GameSystem:loadobj(label)
	local savedata = table.load(love.filesystem.read(label))
	local obj = loadstring('return '..savedata.class)()()
	assert(obj)
	obj:load(savedata.data)
	return obj
end

function GameSystem:runMap(m,checkpoint)
	if map and map.destroy then
		map:destroy()
	end
	gamelistener = Listener:new()
	map = m()
	map:load()
	if map.loadCheckpoint and checkpoint then
		map:loadCheckpoint(checkpoint)
	end
end

function GameSystem:setCheckpoint(m,c,depends)
	self.checkpoint_map,self.checkpoint_point = m,c
	self.checkpoint_depends = depends
	self:save()
end

function GameSystem:update(dt)
	local x,y,walk = controller:GetWalkDirection()
	GetCharacter().direction = {normalize(x,y)}
	if walk then
		GetCharacter().state = 'move'
	else
		GetCharacter().state = 'slide'
	end	
	map:update(dt)
	self.hpbar:update(dt)
	self.mpbar:update(dt)
	if self.bossbar then self.bossbar:update(dt) end
end

requireImage('assets/UI/pointer.png','cursor')
function GameSystem:draw()
	map:draw()
	self.hpbar:draw()
	self.mpbar:draw()
	if self.bossbar then self.bossbar:draw() end
	goo:draw()
	love.graphics.setColor(255,255,255)
end

function GameSystem:pushed()
	love.mouse.setVisible(false)
	self.bottompanel:setVisible(true)
end

function GameSystem:poped()
	love.mouse.setVisible(true)
	self.bottompanel:setVisible(false)
end

function GameSystem:keypressed(k)
	if k=='t' then
		GetCharacter().manager.tree.learning = nil
		GetCharacter().manager:start()
		self.bottompanel.count=0
		pushsystem(GetCharacter().manager)
		return
	end
	if k==' ' then
		Lighteffect.lightOn(GetCharacter())
	end
	if k=='escape' then
		self:pushState('pause')
	end
end

function GameSystem:changeState(state)
	if state == self.state then
		return
	end
	if state == 'cutscene' then
		self.bottompanel:hideButton()
	elseif state == 'game' then
		self.bottompanel:showButton()
	elseif state == 'conversation' then
		self.bottompanel:hideButton()
	end
	self.state = state
end

function GameSystem:loadCheckpoint(point)
	local map = require(point.map)
	self:runMap(map,point)
end

function GameSystem:addGameTimer(...)
	map:addUpdatable(...)
end

function GameSystem:removeGameTimer(...)
	map:removeUpdatable(...)
end

local conversation = GameSystem:addState('conversation')
function conversation:enterState()
	self.bottompanel:hideButton()
end

function conversation:exitState()
	self.bottompanel:showButton()
end
local cutscene = GameSystem:addState('cutscene')
function cutscene:enterState()
	self.bottompanel:hideButton()
end


function cutscene:exitState()
	self.bottompanel:showButton()
end

function cutscene:update(dt)
	map:update(dt)
	self.hpbar:update(dt)
	self.mpbar:update(dt)
	if self.bossbar then self.bossbar:update(dt) end
end

local paused = GameSystem:addState('pause')
function paused:keypressed()
end
function paused:update(dt)
end

function paused:enterState()
	local pausemenu = love.filesystem.load('mainmenu/pausemenu.lua')()
	pausemenu:birth()
	love.mouse.setVisible(true)
end
function paused:pushedState()
	local pausemenu = love.filesystem.load('mainmenu/pausemenu.lua')()
	pausemenu:birth()
	love.mouse.setVisible(true)
end

function paused:popedState()
	love.mouse.setVisible(false)
end

function paused:draw()
	map:draw()
	self.hpbar:draw()
	self.mpbar:draw()
	if bossbar then bossbar:draw() end
	local x,y = unpack(GetOrderDirection())
	local px,py = love.mouse.getPosition()
	love.graphics.setColor(0,0,0,180)
	love.graphics.rectangle('fill',-1000000,-100000,10000000,1000000)
	goo:draw()
end

local GS = GameSystem()
return GS
