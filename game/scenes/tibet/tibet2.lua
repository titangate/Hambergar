--require 'libraries.scene'
--require 'libraries.unit'
require 'scenes.tibet.tibetgamesystem'

preload('assassin','commonenemies','tibet')
Tibet2 = Map:subclass('Tibet2')

function Tibet2:playCutscene(scene)
	self.cutscene = scene
end
function Tibet2:initialize()
	super.initialize(self,2000,2000)
	self.background = tibetbackground
	self.savedata = {
		map = 'scenes.tibet.tibet2',
	}
end
function Tibet2:update(dt)
	super.update(self,dt)
	self.background:update(dt)
	if self.cutscene and self.cutscene:update(dt)==STATE_SUCCESS then
		self.cutscene = nil
	end
end
function Tibet2:draw()
	super.draw(self)
	if self.cutscene then 
		self.cutscene:draw() 
	end
end

function Tibet2:load()
	love.graphics.setBackgroundColor(70,129,200,255)
	batches = love.filesystem.load('scenes/tibet/tile2.lua')()
end

function Tibet2:loadCheckpoint(checkpoint)
	if checkpoint == 'opening' then
		self:opening_load()
	elseif checkpoint == 'boss' then
		self:boss_load()
	end
end

function Tibet2:boss_load()
	local leon = GetGameSystem():loadobj 'Assassin'
	leon.direction = {0,-1}
	leon.controller = 'player'
	leon.x,leon.y = 0,0
	SetCharacter(leon)
	map:addUnit(leon)
	map.camera = FollowerCamera:new(leon)
--	GetGameSystem():loadCharacter(leon)
	GetGameSystem().bottompanel:fillPanel(GetCharacter():getSkillpanelData())
	GetGameSystem().bottompanel:setPos(screen.halfwidth-512,screen.height - 140)
	self:boss_loaded()
end

function Tibet2:boss_loaded()
	local meethans = CutSceneSequence:new()
	meethans:push(ExecFunction:new(function()
		hans = BossHans:new(0,-200,'enemy')
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
		PlayMusic('music/boss1.mp3')
		hans:enableAI()
		GetGameSystem().bossbar = AssassinHPBar:new(function()return hans:getHPPercent() end,screen.halfwidth-400,screen.height-100,800)
		PlayTutorial(tutorialtable.bosshans)
	end),0)
	self.tibet2listener = {}
	function self.tibet2listener.handle(listener,event)
		if event.type == 'death' then
			if event.unit == GetCharacter() then
				self.update = function()
					GetGameSystem():loadCheckpoint()
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
					local text = 'DEMO END. THANKS FOR PLAYING!'
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
					local sp = nil
					dws:push(ExecFunction:new(function()
					 sp = goo.itempanel:new(self.container)
					sp:setSize(screen.width-200,100)
					sp:setPos(100,150)
					sp:fillPanel({
						title = 'CREDITS',
						type = 'DEDICATED TO MY AWESOME FRIENDS',
						attributes = {
							{text = 'DESIGN',data = 'LEON JIANG'},
							{text = 'PROGRAM',data = 'LEON JIANG'},
							{text = 'TEST',data = 'LEON JIANG'},
							{text = 'ARTWORK',data = 'LEON JIANG'},
							{text = 'TOP DOWN SPRITE PACK',data = 'VENI-MORTEM @ DEVIANT ART'},
							{text = 'SOUND RESOURCES',data = 'FROM WARCRAFT III: REIGN OF CHAOS'},
							{text = 'MUSIC',data = "FROM THE WITCHER II: ASSASSINS OF KINGS"},
							{text = 'PHYSICS ENGINE',data = 'BOX2D'},
							{text = 'GAME ENGINE',data = 'LOVE2D'},
							{text = 'PRODUCED BY',data = 'GAMEMASTER STUDIO'},
							{text = ' ',data = 'RING0DEV'},
						}
					})
					anim:easy(sp,'opacity',0,255,2,'linear')
					end),0)
					dws:wait(10)
					dws:push(ExecFunction:new(function()
					panel1:destroy()
					panel2:destroy()
					end),2)
					dws:push(FadeOut:new('fadeout',nil,{0,0,0},2),2)
					dws:wait(2)
					dws:push(ExecFunction:new(function()
						sp:destroy()
						popsystem()
						love.graphics.reset()
						PlayTutorial()
						pushsystem(MainMenu)
						mainmenu = love.filesystem.load("mainmenu/mainmenu.lua")()
						mainmenu:birth()
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

function Tibet2:boss_enter()
	gamelistener:unregister(self.tibet2listener)
	self:boss_loaded()
end

function Tibet2:opening_load()
	local leon = GetGameSystem():loadobj 'Assassin'
	leon.direction = {0,-1}
	leon.controller = 'player'
	leon.x,leon.y = 0,0
	SetCharacter(leon)
	map:addUnit(leon)
	map.camera = FollowerCamera:new(leon)
	GetGameSystem().bottompanel:fillPanel(GetCharacter():getSkillpanelData())
	GetGameSystem().bottompanel:setPos(screen.halfwidth-512,screen.height - 140)
	self:opening_loaded()
end


function Tibet2:opening_enter()
	GetCharacter().x,GetCharacter().y = 10,10
	self:addUnit(GetCharacter())
	self.camera = FollowerCamera:new(GetCharacter())
	self:opening_loaded()
end

function Tibet2:nextwave()
	self.wave = self.wave + 1
	if self.wave == 1 then
		for i=1,3 do
			hans = IALSwordsman:new(i*100,-500,'enemy')
			hans:enableAI()
			map:addUnit(hans)
		end
	elseif self.wave == 2 then
		for i=1,7 do
			local u = IALSwordsman:new(i*100,-500,'enemy')
			u:enableAI()
			map:addUnit(u)
		end
	elseif self.wave == 3 then
		for i=1,5 do
			local u = IALSwordsman:new(i*100,-500,'enemy')
			u:enableAI()
			map:addUnit(u)
		end
		for i=1,3 do
			local u = IALMachineGunner:new(i*100,-800,'enemy')
			u:enableAI()
			map:addUnit(u)
		end
	
	elseif self.wave == 4 then
		for i=1,2 do
			local u = IALShotgunner:new(i*100,-500,'enemy')
			u:enableAI()
			map:addUnit(u)
		end
		for i=1,3 do
			local u = IALMachineGunner:new(i*100,-800,'enemy')
			u:enableAI()
			map:addUnit(u)
		end
	
	elseif self.wave == 5 then
		PlayTutorial(tutorialtable.ultimate)
		for i=1,3 do
			local u = IALShotgunner:new(i*100,-500,'enemy')
			u:enableAI()
			map:addUnit(u)
		end
		for i=1,5 do
			local u = IALMachineGunner:new(i*100,-650,'enemy')
			u:enableAI()
			map:addUnit(u)
		end
		for i=1,10 do
			local u = IALSwordsman:new(i*100,-800,'enemy')
			u:enableAI()
			map:addUnit(u)
		end
	else
		self:boss_enter()
	end
end

function Tibet2:opening_loaded()
	local intro = CutSceneSequence:new()
	intro:push(FadeOut:new('fadein',nil,{0,0,0},2),0)
	intro:wait(2)
	intro:push(ExecFunction:new(function()
	end),0)
	
	self.tibet2listener = {}
	local entered = {}
	function self.tibet2listener.handle(listener,event)
		if event.type == 'openpanel' then
			PlayTutorial(tutorialtable.abilitypanel)
		elseif event.type == 'shiftpanel' then
			if event.panel == 'character' then
				PlayTutorial(tutorialtable.characterpanel)
			end
		end
		if event.type == 'death' then
			if event.unit == GetCharacter() then
				self.update = function()
					GetGameSystem():loadCheckpoint()
				end
			else
					print (self.count.enemy)
				if self.count.enemy <= 0 then
					self:nextwave()
					return
				end
			end
		end
	end
	gamelistener:register(self.tibet2listener)
	self:playCutscene(intro)
	PlayTutorial(tutorialtable.openpanel)
	print (self.savedata)
	self.savedata.checkpoint = 'opening'
	GetGameSystem():saveAll()
	GetGameSystem():gotoState()
	PlayMusic('music/fight1.ogg')
	self.wave = 0
	self:nextwave()
end


function Tibet2:destroy()
	gamelistener:unregister(self.tibet2listener)
end

return Tibet2