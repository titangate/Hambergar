preload('assassin','commonenemies','tibet')
tibetbackground = {cloudtime = 0}
requireImage('assets/tile/cloud.png','cloud')
img.cloud:setWrap('repeat','repeat')
cloudquad = love.graphics.newQuad(0,0,8000,8000,600,600)
requireImage('maps/snowcliff.png','snowcliff')
requireImage('maps/snowbg.png','snowbg')
requireImage('maps/platformedge.png','platformedge')
img.snowbg:setWrap('repeat','repeat')
local snowq = love.graphics.newQuad(0,0,8000,8000,img.snowbg:getWidth(),img.snowbg:getHeight())
local snow = require 'scenes.weather.snow'

local ox,oy = 960,960
local pos = {}
for i=1,48 do
	local r = i*math.pi*2/48
	table.insert(pos,{ox+math.cos(r)*15*64,oy+math.sin(r)*15*64})
end

function tibetbackground:update(dt)
	self.cloudtime = self.cloudtime + dt*50
	snow:update(dt,map.camera:getViewport())
end
function tibetbackground:draw()
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
	for i,v in ipairs(pos) do
		local x,y = unpack(v)
		love.graphics.draw(img.platformedge,x,y,i*math.pi*2/#pos,1.2,1.2,32,64)
	end
	love.graphics.pop()
	snow:draw()
end
Tibet = Map:subclass('Tibet')

function Tibet:initialize()
	local w = 30*64
	local h = 75*64
	self.w,self.h=w,h
	super.initialize(self,w,h)
	local m = self:loadTiled'tibet.tmx'
	tibetbackground.m = m
	self.background = tibetbackground
	self.savedata = {
		map = 'scenes.tibet.tibet',
	}
end

function Tibet:load()
	
end


function Tibet:opening_load()
	local x,y = unpack(map.waypoints.chr)
	local leon = Assassin:new(x,y,32,10)
	leon.direction = {0,-1}
	leon.controller = 'player'
	local save = [[return {{["map"]="Tibet",["character"]={2},["checkpoint"]="opening",["depends"]="	require 'scenes.tibet.tibet'\n	",["gamesystem"]="return require 'scenes.tibet.tibetgamesystem'",},{["movementspeedbuffpercent"]=1,["HPRegen"]=100,["timescale"]=1,["damagebuff"]={3},["hp"]=500,["speedlimit"]=20000,["damageamplify"]={4},["cd"]={5},["mp"]=500,["armor"]={6},["damagereduction"]={7},["spirit"]=1,["evade"]={8},["movingforce"]=500,["maxhp"]=500,["maxmp"]=500,["MPRegen"]=0,["critical"]={9},["movementspeedbuff"]=0,["skills"]={10},["spellspeedbuffpercent"]=1,["inventory"]={11},},{["Bullet"]=0,},{},{},{["Bullet"]=0,},{},{},{},{["stunbullet"]=0,["momentumbullet"]=0,["stim"]=2,["explosivebullet"]=0,["pistol"]=3,["invis"]=1,["dws"]=1,["snipe"]=2,["pistoldwsalt"]=6,["dash"]=1,["roundaboutshot"]=1,["mindripfield"]=1,["mind"]=1,},{["FiveSlash"]='equip',["Theravada"]="equip",},}--|]]
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
	PlayMusic'music/fight1.ogg'
	leon:pickUp(Bomb())
end

function Tibet:checkpoint1_loaded()
	self.trigs = {}
	local r1 = Trigger(function(trig,event)
		if event.index == '1' and event.unit == GetCharacter() then
			trig:close()
			assert(self.unitdict)
			for _,obj in ipairs(self.unitdict[1]) do
				map:loadUnitFromTileObject(obj)
			end
		end
	end)
	r1:registerEventType'add'
	local r2 = Trigger(function(trig,event)
		if event.index == '2' and event.unit == GetCharacter() then
			trig:close()
			assert(self.unitdict)
			for _,obj in ipairs(self.unitdict[2]) do
				map:loadUnitFromTileObject(obj)
			end
		end
	end)
	r2:registerEventType'add'
	local r3 = Trigger(function(trig,event)
		if event.index == '3' and event.unit == GetCharacter() then
			trig:close()
			assert(self.unitdict)
			for _,obj in ipairs(self.unitdict[3]) do
				map:loadUnitFromTileObject(obj)
			end
		end
	end)
	r3:registerEventType'add'
	
	local r4 = Trigger(function(trig,event)
		if event.index == '4' and event.unit == GetCharacter() then
			trig:close()
			self.finalwave = true
			assert(self.unitdict)
			for _,obj in ipairs(self.unitdict[4]) do
				map:loadUnitFromTileObject(obj)
			end
		end
	end)
	r4:registerEventType'add'
	local boss = Trigger(function(trig,event)
			if event.unit == GetCharacter() then
				self.update = function()
					GetGameSystem():pushState'retry'
				end
			else
				if self.count.enemy <= 0 and self.finalwave then
					self:boss_enter()
					return
				end
			end
	end)
	boss:registerEventType'death'
	table.insert(self.trigs,r1)
	table.insert(self.trigs,r2)
	table.insert(self.trigs,r3)
	table.insert(self.trigs,r4)
	table.insert(self.trigs,boss)
end

function Tibet:boss_enter()
	self.finalwave = false
	self:boss_loaded()
	
	for i,v in ipairs(self.trigs) do
		v:destroy()
	end
	self.trigs = {}
end

function Tibet:loadCheckpoint(checkpoint)
	if checkpoint == 'opening' then
		self:opening_load()
	elseif checkpoint == 'boss' then
		self:boss_load()
	end
end

function Tibet:boss_load()
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

function Tibet:boss_loaded()
	local meethans = CutSceneSequence:new()
	meethans:push(ExecFunction:new(function()
		local x,y = unpack(self.waypoints.hans)
		hans = BossHans:new(x,y,'enemy')
		map:addUnit(hans)
		hans:face(GetCharacter())
		GetCharacter():face(hans)
		meethans.camera,map.camera = map.camera,Camera:new(-GetCharacter().x,-GetCharacter().y)
		map.camera:pan(hans,2)
		hans:playAnimation('attack',0.5,false)
		GetGameSystem():gotoState('cutscene')
		GetGameSystem().bottompanel:conversation('HANS THE VOLCANO',"Looks like I have to deal with you myself.")
		GetCharacter():stop()
	end),0)
	meethans:wait(5)
	meethans:push(ExecFunction:new(function()
		map.camera:pan(GetCharacter(),2)
		GetGameSystem().bottompanel:conversation('RIVER',"And die in the end. Yes.")
	end),0)

	meethans:wait(4)
	meethans:push(ExecFunction:new(function()
		map.camera:pan(hans,20)
		GetGameSystem().bottompanel:conversation('HANS THE VOLCANO',"May Maitreya bless your gun and my sword.")
	end),0)
	meethans:wait(5)
	meethans:push(ExecFunction:new(function()
		GetGameSystem().bottompanel:conversation('RIVER',"Amitabha.")
	end),0)
	meethans:wait(3)
	meethans:push(ExecFunction:new(function()
		map.camera = ContainerCamera:new(200,nil,hans,GetCharacter())
		GetGameSystem():gotoState()
		GetGameSystem().bottompanel:conversation()
		PlayMusic'music/boss1.mp3'
		hans:enableAI()
		GetGameSystem().bossbar = AssassinHPBar:new(function()return hans:getHPPercent() end,screen.halfwidth-400,screen.height-100,800)
	end),0)
	self.tibet2listener = {}
	function self.tibet2listener.handle(listener,event)
		if event.type == 'death' then
			if event.unit == GetCharacter() then
				self.update = function()
					GetGameSystem():pushState'retry'
				end
			else
				if self.count.enemy <= 0 then
					local dws = CutSceneSequence:new()
					map.timescale = 0.25
					local panel2 = goo.object:new()
					local divide = goo.image:new(panel2)
					divide:setPos(screen.width-200,screen.halfheight)
					divide:setImage(character.gun)
					local panel1 = goo.object:new()
					anim:easy(panel1,'x',-300,0,1,'quadInOut')
					anim:easy(panel2,'x',300,0,1,'quadInOut')
					local text = 'HANS THE VOLCANO KILLED'
					local x,y = 100,screen.halfheight-50
					for c in text:gmatch"." do
						dws:push(ExecFunction:new(function()
							local ib = goo.DWSText:new(panel1)
							ib:setText(c)
							ib:setPos(x,y)
							local textscale = 2
							x = x+ib.w*textscale
							local animsx = anim:new({
								table = ib,
								key = 'xscale',
								start = 5*textscale,
								finish = 2*textscale,
								time = 0.3,
								style = anim.style.linear}
							)
							local animsy = anim:new({
								table = ib,
								key = 'yscale',
								start = 5*textscale,
								finish = 2*textscale,
								time = 0.3,
								style = anim.style.linear}
							)
							local animg = anim.group:new(animsx,animsy)
							animg:play()
							local animwx = anim:new({
								table = ib,
								key = 'xscale',
								start = 2*textscale,
								finish = 1*textscale,
								time = 0.5,
								style = 'elastic'
							})
							local animwy = anim:new({
								table = ib,
								key = 'yscale',
								start = 2*textscale,
								finish = 1*textscale,
								time = 0.5,
								style = 'elastic'
							})
							local animw = anim.group:new(animwx,animwy)
							local animc = anim.chain:new(animg,animw)
							animc:play()
							TEsound.play('sound/thunderclap.wav')
						end),0)
						dws:wait(0.1)
					end	
					dws:wait(0.5)
					dws:push(ExecFunction:new(function()
					anim:easy(panel1,'x',0,screen.width,2,'quadInOut')
					anim:easy(panel2,'x',0,-screen.width,2,'quadInOut')
					map.timescale = 1
					end),0)
					dws:push(ExecFunction:new(function()
						popsystem()
						
					end),2)
					map:playCutscene(dws)
				end
			end
		end
	end
	local entered = {}
	gamelistener:register(self.tibet2listener)
	self:playCutscene(meethans)
	self.savedata.checkpoint = 'boss'
	GetGameSystem():saveAll()
	GetGameSystem():gotoState()
end

function Tibet:playCutscene(scene)
	self.cutscene = scene
	scene:reset()
end
function Tibet:update(dt)
	super.update(self,dt)
	if self.cutscene and self.cutscene:update(dt)==STATE_SUCCESS then
		self.cutscene = nil
	end
end
function Tibet:draw()
	super.draw(self)
	if self.cutscene then self.cutscene:draw() end
end



function Tibet:destroy()
	for i,v in ipairs(self.trigs) do
		v:destroy()
	end
end

return Tibet()
