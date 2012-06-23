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

requireImage('assets/dot.png','dot')
GameSystem = StatefulObject:subclass'GameSystem'
function GameSystem:initialize()
	super.initialize(self)
	self.bottompanel = goo.bottompanel:new()
	self.conversationpanel = goo.conversationpanel()
	self.conversationpanel:setPos(screen.width-450,20)
	self:gotoState()
	self.hpbar = AssassinHPBar(function()return GetCharacter():getHPPercent() end,30,30,200)
	self.mpbar = AssassinMPBar(function()return GetCharacter():getMPPercent() end,30,60,200)
	self.fader = goo.image()
	self.fader:setImage(img.dot)
	self.fader:fill(screen.width,screen.height)
	self.fader.opacity = 0
	local dp = goo.itempanel()
	dp:setSize(200,100)
	dp:setPos(30,170)
	dp:setTitle('NO ITEM')
	dp:setVisible(false)
	self.buffpanel = dp
	self.critlistener = {
	handle = function(self,event)
		local t = goo.imagelabel()
		t:setTextColor({250,209,68})
		local x,y = map.camera:transform(event.target:getPosition())
		t:setFont(fonts.oldsans20)
		t:setPos(x+screen.halfwidth,y+screen.halfheight)
		t:setText(string.format("%d",event.damage))
		anim:easy(t,'opacity',255,0,0.5)
		Timer(2,1,function()t:destroy()end)
		t:setSize(love.graphics.getFont():getWidth('Evade!'),50)
	end,
	eventtype = 'crit'}
	gamelistener:register(self.critlistener)
	
	self.evadelistener = {
	handle = function(self,event)
		local t = goo.imagelabel()
		t:setTextColor({255,255,255})
		local x,y = map.camera:transform(event.unit:getPosition())
		t:setFont(fonts.oldsans20)
		t:setPos(x+screen.halfwidth,y+screen.halfheight)
		t:setText(LocalizedString'Evade!')
		t:setSize(love.graphics.getFont():getWidth('Evade!'),50)
		anim:easy(t,'opacity',255,0,0.5)
		Timer(2,1,function()t:destroy()end)
	end,
	eventtype = 'evade'}
	gamelistener:register(self.evadelistener)
end


function GameSystem:fillBuffPanel(genre,buff)
	self.buffpanel:setVisible(true)
	self.buffpanel:fadeOutIn(1)
	self.buffpanel:fillPanel(buff)
end

function GameSystem:reloadBottompanel()
--	assert(self.character,'needs a character')
	if not self.character then return end
	self.bottompanel:fillPanel(self.character:getSkillpanelData())
end

function GameSystem:setCharacter(c)
--	c.evade = 0
--	c.critical = {2,0}
	self:save(GetCharacter(),GetCharacter():className())
	self.character = c
	goo:setSkinAllObjects(c:getSkin())
	self:reloadBottompanel()
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
	love.filesystem.write('checkpoint',table.save(map.savedata))
	self:save(GetCharacter(),GetCharacter():className())
end

function GameSystem:load()
end

function GameSystem:prepareToContinue(checkpoint)
	self.m = table.load(love.filesystem.read(checkpoint))
	self.map = require(self.m.map)
--	print (self.map,'map',self.map.class)
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
	gamelistener:register(self.critlistener)
	gamelistener:register(self.evadelistener)
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

function GameSystem:drawBuffs(buffs)
	local length = 36
	local startx = 30+24
	local y = 110
	for v,duration in pairs(buffs) do
		if v.icon then
			local rw,rh = v.icon:getWidth(),v.icon:getHeight()
			love.graphics.setColor(0,0,0,125)
			love.graphics.circle('fill',startx,y,length/2)
			if v.genre == 'buff' then
				
				love.graphics.setColor(0,255,0,255)
			elseif v.genre == 'debuff' then
				
				love.graphics.setColor(255,0,0,255)
			elseif v.genre == 'special' then
				
				love.graphics.setColor(255,255,255,255)
			else
				
				love.graphics.setColor(0,0,0,255)
			end
			
			love.graphics.circle('line',startx,y,length/2)
			love.graphics.setColor(255,255,255,255)
			love.graphics.draw(v.icon,startx,y,0,length/rw,length/rh,rw/2,rh/2)
			love.graphics.setColor(0,0,0,255)
			sfn(fonts.oldsans12)
			pfn(string.format("%.1f",duration),startx-length/2,y+15,36,'center')
			startx = startx + 36
		end
	end
end

function GameSystem:update(dt)
	self.buffs = {}
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
	filtermanager:draw(function()map:draw()end)
	self.hpbar:draw()
	self.mpbar:draw()
	if self.bossbar then self.bossbar:draw() end
	goo:draw()
	if GetCharacter() then
		self:drawBuffs(GetCharacter().buffs)
	end
	love.graphics.setColor(255,255,255)
end

function GameSystem:pushed()
	love.mouse.setVisible(false)
	self:reloadBottompanel()
	self.bottompanel:setVisible(true)
end

function GameSystem:poped()
	love.mouse.setVisible(true)
	self.bottompanel:setVisible(false)
end

function GameSystem:keypressed(k)
	if k=='t' then
--		GetCharacter().manager.tree.learning = true
		GetCharacter().manager:start()
		self.bottompanel.count=0
		pushsystem(GetCharacter().manager)
		return
	end
	if k=='m' then
		scenetest(k)
	end
	if k==' ' then
		
	end
	if k=='escape' then
		self:pushState('pause')
	end
	if k=='k' then
		self:pushState'retry'
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

local paused = GameSystem:addState'pause'
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
	paused.enterState(self)
end

function paused:poppedState()
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


local retry = GameSystem:addState'retry'
function retry:keypressed()
end
function retry:update(dt)
	dt = dt /2
	self.buffs = {}
	local x,y,walk = controller:GetWalkDirection()
	map:update(dt)
	self.hpbar:update(dt)
	self.mpbar:update(dt)
	if self.bossbar then self.bossbar:update(dt) end
end

function retry:enterState()
--	self.retryscreen = goo.retryscreen()
--	self.retryscreen:open()
--	assert(self.retryscreen)
	local pausemenu = love.filesystem.load('mainmenu/retrymenu.lua')()
	pausemenu:birth()
	map:disableAI()
	love.mouse.setVisible(true)
	map.anim:easy(self,'intensity',0,10,10)
	map.anim:easy(map,'timescale',1,0,10)
	self.intensity = 0
	filtermanager:setFilterArguments('Gaussianblur',{
		mask = img.dot,
	--	baseintensity = self.intensity ,
	})
end
function retry:pushedState()
	retry.enterState(self)
end

function retry:poppedState()
	love.mouse.setVisible(false)
--	self.retryscreen:close()
end

function retry:draw()
	filtermanager:requestFilter'Gaussianblur'
	filtermanager:setFilterArguments('Gaussianblur',{
		intensity = self.intensity,
	})
	
	filtermanager:draw(function()map:draw()end)
--	GameSystem.draw(self)
	self.hpbar:draw()
	self.mpbar:draw()
	if bossbar then bossbar:draw() end
	local x,y = unpack(GetOrderDirection())
	
	local px,py = love.mouse.getPosition()
	love.graphics.setColor(0,0,0,15*self.intensity)
	love.graphics.rectangle('fill',-1000000,-100000,10000000,1000000)
	goo:draw()
end

local GS = GameSystem()
return GS
