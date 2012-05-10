--[[require 'libraries.scene'
require 'libraries.unit'
require 'libraries.hud'
require 'libraries.conversation']]
preload('swift','assassin','commonenemies','tibet')

requireImage("assets/gridfilter.png",'gridfilter')
hpbar = AssassinHPBar:new(function()return GetCharacter():getHPPercent() end,30,30,200)
mpbar = AssassinMPBar:new(function()return GetCharacter():getMPPercent() end,30,60,200)
local manager = nil

TestGameSystem = StatefulObject:subclass('TestGameSystem')
function TestGameSystem:load()
	self.bottompanel = goo.bottompanel:new()
	self.conversationpanel=goo.conversationpanel:new()
	self.conversationpanel:setPos(screen.width-450,20)
--	self.bottompanel:setPos(-500,-500)
	self:gotoState()
	goo:setSkinAllObjects('default')
end

function TestGameSystem:save()
	self.savedata = {
		gamesystem = "return require 'scenes.test.testgamesystem'",
		map = self.checkpoint_map:getName(),
		checkpoint = self.checkpoint_point,
		character = GetCharacter():save(),
		depends = self.checkpoint_depends,
	}
	love.filesystem.write('lastsave.sav',table.save(self.savedata))
end

function TestGameSystem:runMap(m,checkpoint)
	if map and map.destroy then
		 map:destroy()
	end
	gamelistener = Listener:new()
	map = m:new()
	map:load()
	map:loadCheckpoint(checkpoint)
end

function TestGameSystem:setCheckpoint(m,c,depends)
	self.checkpoint_map,self.checkpoint_point = m,c
	self.checkpoint_depends = depends
	self:save()
end

function TestGameSystem:loadCharacter(c)
	if not self.savedata then
		self.savedata = table.load([[return {{["map"]="Tibet1",["character"]={2},["checkpoint"]="opening",["depends"]="	require 'scenes.tibet.tibet1'\n	",["gamesystem"]="return require 'scenes.tibet.TestGameSystem'",},{["movementspeedbuffpercent"]=1,["HPRegen"]=0,["timescale"]=1,["damagebuff"]={3},["hp"]=500,["speedlimit"]=20000,["damageamplify"]={4},["cd"]={5},["mp"]=500,["armor"]={6},["damagereduction"]={7},["spirit"]=1,["evade"]={8},["movingforce"]=500,["maxhp"]=500,["maxmp"]=500,["MPRegen"]=0,["critical"]={9},["movementspeedbuff"]=0,["skills"]={10},["spellspeedbuffpercent"]=1,["inventory"]={11},},{["Bullet"]=0,},{},{},{["Bullet"]=0,},{},{},{},{["stunbullet"]=0,["momentumbullet"]=0,["stim"]=2,["explosivebullet"]=0,["pistol"]=3,["invis"]=1,["dws"]=0,["snipe"]=2,["pistoldwsalt"]=6,["dash"]=1,["roundaboutshot"]=1,["mindripfield"]=1,["mind"]=1,},{[21]="FiveSlash",[23]="PeacockFeather",},}--|]])
	end
	c:load(self.savedata.character)
end

function TestGameSystem:continueFromSave(save)
	self.savedata = save or table.load(love.filesystem.read('lastsave.sav'))
	loadstring(self.savedata.depends)()
	self:runMap(loadstring( 'return '..self.savedata.map)(),self.savedata.checkpoint)
end

function TestGameSystem:loadCheckpoint()
	if self.checkpoint_map and self.checkpoint_point then
		self:runMap(self.checkpoint_map,self.checkpoint_point)
	end
end

function TestGameSystem:update(dt)
	local x,y,walk = controller:GetWalkDirection()
	GetCharacter().direction = {normalize(x,y)}
	if walk then
		GetCharacter().state = 'move'
	else
		GetCharacter().state = 'slide'
	end	
	map:update(dt)
	hpbar:update(dt)
	mpbar:update(dt)
	if bossbar then bossbar:update(dt) end
	TutorialSystem:update(dt)
end

requireImage('assets/UI/pointer.png','cursor')
function TestGameSystem:draw()
	map:draw()
	hpbar:draw()
	mpbar:draw()
	if bossbar then bossbar:draw() end
	goo:draw()
	love.graphics.setColor(255,255,255)
--	print (x,y)
end

function TestGameSystem:pushed()
	love.mouse.setVisible(false)
	self.bottompanel:setVisible(true)
end

function TestGameSystem:poped()
	love.mouse.setVisible(true)
	self.bottompanel:setVisible(false)
end

function TestGameSystem:keypressed(k)
	if k=='t' then
		GetCharacter().manager:start()
		self.bottompanel.count=0
		pushsystem(GetCharacter().manager)
		return
	end
	if k==' ' then
		
	end
end

function TestGameSystem:changeState(state)
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


function TestGameSystem:keyreleased(k)
	if k=='escape' then
		self:pushState('pause')
	end
		if k=='i' then
			local u = IALSwordsman:new(0,0,'enemy')
--			u:enableAI()
			map:addUnit(u)
			u.interact = function()
				print 'interacting'
			end
		end
		if k=='k' then
			GetCharacter().chain:tornado(10)
		elseif k== 'm' then
		end
		if k=='u' then
			self.conversationpanel:birth()
			self.conversationpanel:play('HOLLY','REBOOTING.............',nil,5)
			Timer:new(5,1,function()
				self.conversationpanel:play('LAWRENCE','ARRRR... What the hell happened',nil,5)
			end,true,true)
			
			Timer:new(10,1,function()
				self.conversationpanel:play('HOLLY','INITIATING LIFE SEQUENCING PROTOCAL',nil,5)
			end,true,true)
			
			Timer:new(15,1,function()
				self.conversationpanel:play('LAWRENCE','What is this... I remember i was trying to.. ARRR MY HEAD HURTS!',nil,5)
--				anim:easy(self.conversationpanel,'opacity',255,0,1)
			end,true,true)
			
			Timer:new(20,1,function()
--				self.conversationpanel:play('LAWRENCE','What is this... I remember i was trying to.. ARRR MY HEAD HURTS!',nil,5)
				anim:easy(self.conversationpanel,'opacity',255,0,1)
			end,true,true)
		end
--	buttongroup:keyreleased(k)
end

function TestGameSystem:mousepressed(x,y,k)
--	buttongroup:mousepressed(x,y,k)
end

function TestGameSystem:mousereleased(x,y,k)
--	buttongroup:mousereleased(x,y,k)
end

local conversation = TestGameSystem:addState('conversation')
function conversation:enterState()
	self.bottompanel:hideButton()
end

function conversation:exitState()
	self.bottompanel:showButton()
end
local cutscene = TestGameSystem:addState('cutscene')
function cutscene:enterState()
	self.bottompanel:hideButton()
end


function cutscene:exitState()
	self.bottompanel:showButton()
end

function cutscene:update(dt)
	map:update(dt)
	hpbar:update(dt)
	mpbar:update(dt)
	if bossbar then bossbar:update(dt) end
	TutorialSystem:update(dt)
end

local paused = TestGameSystem:addState('pause')
function paused:keypressed()
end
function paused:update(dt)
end

function paused:enterState()
	local pausemenu = love.filesystem.load('mainmenu/pausemenu.lua')()
	pausemenu:birth()
end
function paused:pushedState()
	local pausemenu = love.filesystem.load('mainmenu/pausemenu.lua')()
	pausemenu:birth()
end


function paused:draw()
	map:draw()
	hpbar:draw()
	mpbar:draw()
	if bossbar then bossbar:draw() end
	local x,y = unpack(GetOrderDirection())
	local px,py = love.mouse.getPosition()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(img.cursor,px,py,math.atan2(y,x),1,1,16,16)
	love.graphics.setColor(0,0,0,180)
	love.graphics.rectangle('fill',-1000000,-100000,10000000,1000000)
	goo:draw()
end

local TestGameSystem = TestGameSystem:new()
return TestGameSystem