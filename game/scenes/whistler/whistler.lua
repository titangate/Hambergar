preload('assassin','commonenemies','Whistler','whistler')
requireImage('assets/tile/cloud.png','cloud')
img.cloud:setWrap('repeat','repeat')
cloudquad = love.graphics.newQuad(0,0,8000,8000,600,600)
requireImage('maps/snowcliff.png','snowcliff')
requireImage('maps/snowbg.png','snowbg')
requireImage('maps/platformedge.png','platformedge')
img.snowbg:setWrap('repeat','repeat')

require 'lightpuzzle.lighter'

Whistlerbackground = {
	cloudtime = 0,
	bridgeangle = 0,
	bridgeangleshift = -math.pi/2,
}

local loader = require("AdvTiledLoader/Loader")
loader.path = "maps/"
local m = loader.load('rotatingbridge.tmx')
m.useSpriteBatch=true
m.drawObjects=false
Whistlerbackground.bridge = m

local snowq = love.graphics.newQuad(0,0,8000,8000,img.snowbg:getWidth(),img.snowbg:getHeight())
local snow = require 'scenes.weather.snow'

local ox,oy = 960,960
local pos = {}
for i=1,48 do
	local r = i*math.pi*2/48
	table.insert(pos,{ox+math.cos(r)*15*64,oy+math.sin(r)*15*64})
end

function Whistlerbackground:update(dt)
	self.cloudtime = self.cloudtime + dt*50
	snow:update(dt,map.camera:getViewport())
	if self.dt then
		self.dt = self.dt - dt
		if self.dt <= 0 then
			self.dt = nil
		end
		self.bridgeangle = self.bridgeangle+self.turningangle*dt
	end
end
function Whistlerbackground:draw()
	if self.cloudtime > 3000 then
		self.cloudtime = 0
	end
	local x,y = map.camera.x,map.camera.y
	love.graphics.push()
			love.graphics.translate(-x*0.9,-y*0.9)
		love.graphics.drawq(img.snowbg,snowq,0,0,0,2,2,4000,4000)
	love.graphics.pop()
	for j = 1,2 do
		love.graphics.push()
		love.graphics.scale(1.2)
		love.graphics.setColor(255,255,255,120)
		love.graphics.drawq(img.cloud,cloudquad,self.cloudtime,-j*40,0,2,2,4000,4000)
		love.graphics.setColor(255,255,255,255)	
	end
	for j = 1,2 do
		love.graphics.pop()
	end
	
	love.graphics.push()
	love.graphics.translate(-map.w/2,-map.h/2)
	self.m:draw()
		
		
	
	love.graphics.pop()
	map.l:draw()
	love.graphics.push()
	assert(Whistlerbackground.bridgeposition[1])
--		love.graphics.translate(100,500)
		love.graphics.translate(self.bridgeposition[1],self.bridgeposition[2])
			love.graphics.rotate(self.bridgeangle+self.bridgeangleshift)
			love.graphics.translate(-5*64/2,0)
		self.bridge:draw()
	love.graphics.pop()
	snow:draw()
end

function Whistlerbackground:rotateTo(angle)
	map.anim:easy(self,'bridgeangle',self.bridgeangle,angle,3,'linear')
	--[[
	if angle>self.bridgeangle then
		self.turningangle = 0.5
		self.dt = (angle-self.bridgeangle)/self.turningangle
	elseif angle<self.bridgeangle then
		self.turningangle = -0.5
		self.dt = (angle-self.bridgeangle)/self.turningangle
	end]]
end

Whistler = Map:subclass('Whistler')

function Whistler:initialize()
	local w = 80*64
	local h = 120*64
	self.w,self.h=w,h
	
	self.l = Lighter()
	super.initialize(self,w,h)
	local m = self:loadTiled'whistler.tmx'
	Whistlerbackground.m = m
	Whistlerbackground.bridgeposition = self.waypoints.bridgeanchor
	self.background = Whistlerbackground
	self.savedata = {
		map = 'scenes.Whistler.Whistler',
	}
	
	self:setObstacleState('bridgeright',false)
	self.trigs = {}
end

function Whistler:load()
	
end


function Whistler:opening_load()
	local x,y = unpack(map.waypoints.chr)
	local leon = Assassin:new(x,y,32,10)
	leon.direction = {0,-1}
	leon.controller = 'player'
	local save = [[return {{["map"]="Whistler",["character"]={2},["checkpoint"]="opening",["depends"]="	require 'scenes.Whistler.Whistler'\n	",["gamesystem"]="return require 'scenes.Whistler.Whistlergamesystem'",},{["movementspeedbuffpercent"]=1,["HPRegen"]=0,["timescale"]=1,["damagebuff"]={3},["hp"]=500,["speedlimit"]=20000,["damageamplify"]={4},["cd"]={5},["mp"]=500,["armor"]={6},["damagereduction"]={7},["spirit"]=1,["evade"]={8},["movingforce"]=500,["maxhp"]=500,["maxmp"]=500,["MPRegen"]=0,["critical"]={9},["movementspeedbuff"]=0,["skills"]={10},["spellspeedbuffpercent"]=1,["inventory"]={11},},{["Bullet"]=0,},{},{},{["Bullet"]=0,},{},{},{},{["stunbullet"]=0,["momentumbullet"]=0,["stim"]=2,["explosivebullet"]=0,["pistol"]=3,["invis"]=1,["dws"]=1,["snipe"]=2,["pistoldwsalt"]=6,["dash"]=1,["roundaboutshot"]=1,["mindripfield"]=1,["mind"]=1,},{["FiveSlash"]='equip',["Theravada"]="equip",},}--|]]
	save = table.load(save)
	leon:load(save.character)
	SetCharacter(leon)
	map:addUnit(leon)
	map.camera = FollowerCamera:new(leon,{
		x1 = -self.w/2+screen.halfwidth,
		y1 = -self.h/2+screen.halfheight,
		x2 = self.w/2-screen.halfwidth,
		y2 = self.h/2-screen.halfheight
	})
	GetGameSystem().bottompanel:fillPanel(GetCharacter():getSkillpanelData())
	GetGameSystem().bottompanel:setPos(screen.halfwidth-512,screen.height - 140)
	self:checkpoint1_loaded()
	PlayEnvironmentSound'sound/windloop.ogg'
	leon:pickUp(Bomb())
	leon:pickUp(Bomb())
	
	for i=1,6 do
		local pillar = loadstring("return pillar"..tostring(i))()
		local star = loadstring("return star"..tostring(i))()
		pillar.color = {math.random(255),math.random(255),math.random(255),}
		star.color = pillar.color
	end
	
	local r1 = Trigger(function(trig,event)
		if event.index == 'entertemple' and event.unit == GetCharacter() then
			trig:close()
			assert(self.unitdict)
			for _,obj in ipairs(self.unitdict.entertemple) do
				map:loadUnitFromTileObject(obj)
			end
		end
	end)
	r1:registerEventType'add'
	
	
	local keycombo = {
		["nga chu nga chu "] = function()
			self.background:rotateTo(0)
			self:setBridgeDirection'east'
			self:setObstacleState('bridgeleft',true)
			self:setObstacleState('bridgeright',false)
			self:setObstacleState('bridgebot',true)
		end,
	
		["chik nga chu chik "] = function()
			self.background:rotateTo(math.pi/2)
			self:setBridgeDirection'bottom'
			
			self:setObstacleState('bridgeleft',true)
			self:setObstacleState('bridgeright',true)
			self:setObstacleState('bridgebot',false)
		end,
		["chu nga chik chik "] = function()
			self.background:rotateTo(math.pi)
			self:setBridgeDirection'west'
			
			self:setObstacleState('bridgeleft',false)
			self:setObstacleState('bridgeright',true)
			self:setObstacleState('bridgebot',true)
		end,
	}
	local t1=Trigger(function(trig,event)
			if event.unit == doortrigger then
				if event.state == 'chik' then
					door1:open()
					door2:close()
					event.unit:switch'chu'
				elseif event.state == 'chu' then
					door1:close()
					door2:open()
					event.unit:switch'chik'
				end
			end
			for i,v in ipairs(self.switchplates) do
				if v==event.unit then
					local f= {'chik','nga','chu'}
					event.unit:switch(f[math.random(3)])
				end
			end
			phrase = ''
			for i,v in ipairs(self.switchplates) do
				phrase = phrase..v.target..' '
				print (v.target)
			end
			print (phrase)
			if keycombo[phrase] then
				keycombo[phrase]()
			end
		end)
	t1:registerEventType'switch'
	
	self.switchplates = {}
	table.insert(self.switchplates,switch1)
	table.insert(self.switchplates,switch2)
	table.insert(self.switchplates,switch3)
	table.insert(self.switchplates,switch4)
	
	local eastq = Trigger(function(trig,event)
			if event.unit == GetCharacter() then
				self.update = function()
					GetGameSystem():pushState'retry'
				end
			elseif self.eastquadenemy[event.unit] then
				self.eastquadenemy[event.unit] = nil
				if not next(self.eastquadenemy) then
					self.wave = self.wave + 1
					self:eastQuadWave(self.wave)
				end
			end
	end)
	local eastenter = Trigger(function(trig,event)
		if event.index == 'eastquadenter' and event.unit == GetCharacter() then
			trig:close()
			eastq:registerEventType'death'
			self.wave = 1
			self:eastQuadWave(1)
		end
	end)
	eastenter:registerEventType'add'
	
	
	
	local pancake = Trigger(function(trig,event)
		if event.unit == rotateswitch1 then
			innercircle:rotateDelta(math.pi/2)
			middlecircle:rotateDelta(-math.pi/2)
		elseif event.unit == rotateswitch2 then
			innercircle:rotateDelta(-math.pi/2)
			middlecircle:rotateDelta(math.pi/2)
			outercircle:rotateDelta(-math.pi/2)
		elseif event.unit == rotateswitch3 then
			outercircle:rotateDelta(math.pi/2)
			middlecircle:rotateDelta(-math.pi/2)
		end
	end)
	pancake:registerEventType'switch'
	
	
	local pickupamulet = Trigger(function(trig,event)
		if event.item == amulet then
			innercircle:kill()
			middlecircle:kill()
			outercircle:kill()
		end
	end)
	pickupamulet:registerEventType'pickup'
	
	local pickupskull = Trigger(function(trig,event)
		print (event.item,event.action)
		if event.item.class == AuroSkull then
			if event.action == 'equip' then
				Lighteffect.lightOn(GetCharacter())
				self.l:setGlobalLightsource(GetCharacter())
			else
				Lighteffect.stop()
				self.l:setGlobalLightsource()
			end
		end
	end)
	pickupskull:registerEventType'equip'
	
	
	local lightedstatue = Trigger(function(trig,event)
		local success = true
		for i=1,6 do
			local star = loadstring("return star"..tostring(i))()
			success = success and star.lighted
		end
		if success then
			trig:close()
			Lighteffect.stop()
			for i=1,6 do
				local pillar = loadstring("return pillar"..tostring(i))()
				pillar:kill(pillar)
			end
			local x,y = unpack(self.waypoints.symbol)
			local symbol = FloorSymbol(x,y)
			map:addUnit(symbol)
		end
	end)
	lightedstatue:registerEventType'lighted'
	
	local southq = Trigger(function(trig,event)
			if event.unit == GetCharacter() then
				self.update = function()
					GetGameSystem():pushState'retry'
				end
			elseif self.southquadenemy[event.unit] then
				self.southquadenemy[event.unit] = nil
				if not next(self.southquadenemy) then
					self.wave = self.wave + 1
					self:southQuadWave(self.wave)
				end
			end
	end)
	local southenter = Trigger(function(trig,event)
		if event.index == 'southquadenter' and event.unit == GetCharacter() then
			trig:close()
			southq:registerEventType'death'
			self.wave = 1
			self:southQuadWave(1)
		end
	end)
	southenter:registerEventType'add'
	local ending = Trigger(function(trig,event)
		if event.index == 'fountainenter' and event.unit == GetCharacter() then
			trig:close()
			require 'scenes.whistler.discoverfountain'()
		end
	end)
	ending:registerEventType'add'
	
	local enterhall = Trigger(function(trig,event)
		if event.unit == GetCharacter() and event.index == 'enterhall' then
			trig:close()
			map.camera = ContainerCamera:new(200,nil,topleftplate,botrightplate,GetCharacter())
		end
	end)
	enterhall:registerEventType'add'
	
	local lighter = Trigger(function(trig,event)
		local color = event.beam.color
		if event.object == lsensor3 then
			if color[1]==0 and color[2]==255 and color[3]==0 then
				portal2.l:link()
				portal1.l:link(portal3.l)
			end
		end
		if event.object == lsensor2 then 
			if color[1]==255 and color[2]==0 and color[3]==0 then
				obstacle1.l:enable(false)
				pickupskull:close()
				Lighteffect.stop()
				self.l:setGlobalLightsource()
				map.camera = FollowerCamera(leon)
				lightdoor:open()
			end
		end
	end)
	
	lighter:registerEventType'lightcast'
	
	portal1.l:link(portal2.l)
	obstacle1.l.r = 50
	filtertop.l.color = {0,255,0}
	
	local bosskill = Trigger(function(trig,event)
		if event.unit == bossreaper then
			map.camera = FollowerCamera:new(leon)
			GetGameSystem().bossbar = nil
			PauseMusic()
		end
	end)
	bosskill:registerEventType'kill'
end

function Whistler:finish()
	anim:easy(GetGameSystem().fader,'opacity',0,255,1,'linear')
	Timer(1,1,function()
	end)
	Timer(2,1,function()
	self:destroy()
	self.update = function()
			
			require 'scenes.whistler.dreamSequence'
			map = DreamMaze()
			map:load()
			map:checkpoint1_enter()
			PlayEnvironmentSound()
			loadingscreen.finished = function ()
			end
			pushsystem(loadingscreen)
			
		end
	end)
end
function scenetest()
	map:finish()
end

function Whistler:eastQuadWave(wave)
	if wave > 3 then
		return
	end
	self.eastquadenemy = {}
	local dict
	if wave == 1 then 
		for _,obj in ipairs(self.unitdict.eastquad0) do
			map:loadUnitFromTileObject(obj)
		end
		dict = self.unitdict.eastquad1
	end
	if wave == 2 then dict = self.unitdict.eastquad2 end
	if wave == 3 then dict = self.unitdict.eastquad3 end
	for _,obj in ipairs(dict) do
		self.eastquadenemy[map:loadUnitFromTileObject(obj)] = true
	end
end

function Whistler:southQuadWave(wave)
	if wave > 3 then
		map.camera = ContainerCamera:new(200,nil,bossreaper,GetCharacter())
		bossreaper:enableAI()
		bossreaper.controller = 'enemy'
		GetGameSystem():gotoState()
		GetGameSystem().bottompanel:conversation()
		GetGameSystem().bossbar = AssassinHPBar:new(function()return bossreaper:getHPPercent() end,screen.halfwidth-400,screen.height-100,800) 
	 end
	self.southquadenemy = {}
	local dict
	if wave == 1 then
		dict = self.unitdict.southquad1
		
		PlayMusic'music/fight2.mp3'
	end
	if wave == 2 then dict = self.unitdict.southquad2 end
	if wave == 3 then dict = self.unitdict.southquad3 end
	for _,obj in ipairs(dict) do
		self.southquadenemy[map:loadUnitFromTileObject(obj)] = true
	end
end


function Whistler:setBridgeDirection()
end

function Whistler:checkpoint1_loaded()

end

function Whistler:boss_enter()
	self.finalwave = false
	self:boss_loaded()
	
	for i,v in ipairs(self.trigs) do
		v:destroy()
	end
	self.trigs = {}
end

function Whistler:loadCheckpoint(checkpoint)
	if checkpoint == 'opening' then
		self:opening_load()
	elseif checkpoint == 'boss' then
		self:boss_load()
	end
end

function Whistler:boss_load()
	local leon = GetGameSystem():loadobj 'Assassin'
	leon.direction = {0,-1}
	leon.controller = 'player'
	leon.x,leon.y = 0,0
	SetCharacter(leon)
	map:addUnit(leon)
	map.camera = FollowerCamera:new(leon)
	GetGameSystem().bottompanel:fillPanel(GetCharacter():getSkillpanelData())
	GetGameSystem().bottompanel:setPos(screen.halfwidth-512,screen.height - 140)
	self:boss_loaded()
end

function Whistler:boss_loaded()
	self.savedata.checkpoint = 'boss'
	GetGameSystem():saveAll()
	GetGameSystem():gotoState()
end


function Whistler:update(dt)
	super.update(self,dt)
	if self.cutscene and self.cutscene:update(dt)==STATE_SUCCESS then
		self.cutscene = nil
	end
	self.l:update(dt)
end

function Whistler:draw()
	super.draw(self)
	if self.cutscene then self.cutscene:draw() end
end

function Whistler:destroy()
	for i,v in ipairs(self.trigs) do
		print (i,v)
		v:destroy()
	end
end

return Whistler
