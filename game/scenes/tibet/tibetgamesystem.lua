
tibetbackground = {cloudtime = 0}
batches = nil
cloud = love.graphics.newImage('assets/tile/cloud.png')
cloud:setWrap('repeat','repeat')
cloudquad = love.graphics.newQuad(0,0,8000,8000,600,600)
function tibetbackground:update(dt)
	self.cloudtime = self.cloudtime + dt*50
end
function tibetbackground:draw()
	if self.cloudtime > 3000 then
		self.cloudtime = 0
	end
	local x,y = map.camera.x,map.camera.y
	for j = 1,2 do
		map.camera:push(Camera:new(0,0,1.2,1.2))
		map.camera:apply()
		love.graphics.setColor(255,255,255,175)
		love.graphics.drawq(cloud,cloudquad,self.cloudtime,-j*40,0,2,2,4000,4000)
		love.graphics.setColor(255,255,255,255)	
		map.camera:revert()
	end
	map.camera:clear()
	for i,v in ipairs(batches) do
		love.graphics.draw(v,0,0,0,1,1,1000,1000)
	end
	for j = 1,2 do
		map.camera:push(Camera:new(0,0,1.2,1.2))
		map.camera:apply()
		love.graphics.setColor(255,255,255,175)
		love.graphics.drawq(cloud,cloudquad,self.cloudtime,-j*40,0,2,2,4000,4000)
		love.graphics.setColor(255,255,255,255)	
		map.camera:revert()
	end	
	map.camera:clear()
end

function GetCharacter()
	return chr
end

function SetCharacter(c)
	chr = c
end



hpbar = AssassinHPBar:new(function()return GetCharacter():getHPPercent() end,30,30,200)
mpbar = AssassinMPBar:new(function()return GetCharacter():getMPPercent() end,30,60,200)
local manager = nil

TibetGameSystem = StatefulObject:subclass('TibetGameSystem')
function TibetGameSystem:load()
	PlayEnvironmentSound("sound/windloop.ogg")
	environment_playing:setVolume(0.5)
	self.bottompanel = goo.bottompanel:new()
	
	self:gotoState()
end

function TibetGameSystem:save()
	self.savedata = {
		gamesystem = "return require 'scenes.tibet.tibetgamesystem'",
		map = self.checkpoint_map:getName(),
		checkpoint = self.checkpoint_point,
		character = GetCharacter():save(),
		depends = self.checkpoint_depends,
	}
	love.filesystem.write('lastsave.sav',table.save(self.savedata))
end

function TibetGameSystem:runMap(m,checkpoint)
	if map and map.destroy then
		 map:destroy()
	end
	map = m:new()
	map:load()
	map:loadCheckpoint(checkpoint)
end

function TibetGameSystem:setCheckpoint(m,c,depends)
	self.checkpoint_map,self.checkpoint_point = m,c
	self.checkpoint_depends = depends
	self:save()
end

function TibetGameSystem:loadCharacter(c)
	if not self.savedata then
		self.savedata = table.load([[return {{["map"]="Tibet1",["character"]={2},["checkpoint"]="opening",["depends"]="	require 'scenes.tibet.tibet1'\n	",["gamesystem"]="return require 'scenes.tibet.tibetgamesystem'",},{["movementspeedbuffpercent"]=1,["HPRegen"]=0,["timescale"]=1,["damagebuff"]={3},["hp"]=500,["speedlimit"]=20000,["damageamplify"]={4},["cd"]={5},["mp"]=500,["armor"]={6},["damagereduction"]={7},["spirit"]=1,["evade"]={8},["movingforce"]=500,["maxhp"]=500,["maxmp"]=500,["MPRegen"]=0,["critical"]={9},["movementspeedbuff"]=0,["skills"]={10},["spellspeedbuffpercent"]=1,["inventory"]={11},},{["Bullet"]=0,},{},{},{["Bullet"]=0,},{},{},{},{["stunbullet"]=0,["momentumbullet"]=0,["stim"]=2,["explosivebullet"]=0,["pistol"]=3,["invis"]=1,["dws"]=0,["snipe"]=2,["pistoldwsalt"]=6,["dash"]=1,["roundaboutshot"]=1,["mindripfield"]=1,["mind"]=1,},{[21]="FiveSlash",[23]="PeacockFeather",},}--|]])
	end
	c:load(self.savedata.character)
end

function TibetGameSystem:continueFromSave(save)
	self.savedata = save or table.load(love.filesystem.read('lastsave.sav'))
	loadstring(self.savedata.depends)()
	self:runMap(loadstring( 'return '..self.savedata.map)(),self.savedata.checkpoint)
end

function TibetGameSystem:loadCheckpoint()
	if self.checkpoint_map and self.checkpoint_point then
		self:runMap(self.checkpoint_map,self.checkpoint_point)
	end
end

function TibetGameSystem:update(dt)
--[[
	local walk = false
	local x,y = 0,0
	for k,v in pairs(commandshifts) do
		if love.keyboard.isDown(k) then
			walk = true
			x,y=x+v[1],y+v[2]
		end
	end]]
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

cursor = love.graphics.newImage('assets/UI/pointer.png')
function TibetGameSystem:draw()
	map:draw()
	hpbar:draw()
	mpbar:draw()
	if bossbar then bossbar:draw() end
	goo:draw()
	love.graphics.setColor(255,255,255)
--	print (x,y)
end

function TibetGameSystem:pushed()
	love.mouse.setVisible(false)
	self.bottompanel:setVisible(true)
end

function TibetGameSystem:poped()
	love.mouse.setVisible(true)
	self.bottompanel:setVisible(false)
end

function TibetGameSystem:keypressed(k)
	if k=='t' then
		GetCharacter().manager:start()
		pushsystem(GetCharacter().manager)
		return
	end
	if k==' ' then
		
	end
end

function TibetGameSystem:changeState(state)
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


function TibetGameSystem:keyreleased(k)
	if k=='escape' then
		self:gotoState('pause')
	end
--	buttongroup:keyreleased(k)
end

function TibetGameSystem:mousepressed(x,y,k)
--	buttongroup:mousepressed(x,y,k)
end

function TibetGameSystem:mousereleased(x,y,k)
--	buttongroup:mousereleased(x,y,k)
end

local conversation = TibetGameSystem:addState('conversation')
function conversation:enterState()
	self.bottompanel:hideButton()
end

function conversation:exitState()
	self.bottompanel:showButton()
end
local cutscene = TibetGameSystem:addState('cutscene')
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

local paused = TibetGameSystem:addState('pause')
function paused:keypressed()
end
function paused:update(dt)
end

function paused:enterState()
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
	love.graphics.draw(cursor,px,py,math.atan2(y,x),1,1,16,16)
	love.graphics.setColor(0,0,0,180)
	love.graphics.rectangle('fill',-1000000,-100000,10000000,1000000)
	goo:draw()
end

local tibetGameSystem = TibetGameSystem:new()
return tibetGameSystem