--require 'libraries.scene'
--require 'libraries.unit'
require 'scenes.tibet.tibetgamesystem'
preload('assassin','commonenemies','tibet')
Tibet1 = Map:subclass('Tibet1')
function Tibet1:initialize(w,h)
	super.initialize(self,w,h)
end
function Tibet1:playCutscene(scene)
	self.cutscene = scene
	scene:reset()
end
function Tibet1:initialize()
	super.initialize(self,2000,2000)
	self.background = tibetbackground
	self.savedata = {
		map = 'scenes.tibet.tibet1',
	}
end
function Tibet1:update(dt)
	super.update(self,dt)
	self.background:update(dt)
	if self.cutscene and self.cutscene:update(dt)==STATE_SUCCESS then
		self.cutscene = nil
	end
end
function Tibet1:draw()
	super.draw(self)
	if self.cutscene then self.cutscene:draw() end
end

function Tibet1:load()
	love.graphics.setBackgroundColor(70,129,200,255)
	batches = love.filesystem.load('scenes/tibet/tile1.lua')()
	local x,y = unpack(map.waypoints[4])
	for i=x,x+240,32 do
		for j=y,y+200,32 do
			local b = Box:new(i,j)
			b.controller = 'enemy'
			map:addUnit(b)
		end
	end
end

function Tibet1:loadCheckpoint(checkpoint)
	if checkpoint == 'opening' then
		self:checkpoint1_load()
	end
end

function Tibet1:checkpoint1_load()
	local leon = Assassin:new(-120,650,32,10)
	leon.direction = {0,-1}
	leon.controller = 'player'
	SetCharacter(leon)
	local save = [[return {{["map"]="Tibet1",["character"]={2},["checkpoint"]="opening",["depends"]="	require 'scenes.tibet.tibet1'\n	",["gamesystem"]="return require 'scenes.tibet.tibetgamesystem'",},{["movementspeedbuffpercent"]=1,["HPRegen"]=0,["timescale"]=1,["damagebuff"]={3},["hp"]=500,["speedlimit"]=20000,["damageamplify"]={4},["cd"]={5},["mp"]=500,["armor"]={6},["damagereduction"]={7},["spirit"]=1,["evade"]={8},["movingforce"]=500,["maxhp"]=500,["maxmp"]=500,["MPRegen"]=0,["critical"]={9},["movementspeedbuff"]=0,["skills"]={10},["spellspeedbuffpercent"]=1,["inventory"]={11},},{["Bullet"]=0,},{},{},{["Bullet"]=0,},{},{},{},{["stunbullet"]=0,["momentumbullet"]=0,["stim"]=2,["explosivebullet"]=0,["pistol"]=3,["invis"]=1,["dws"]=0,["snipe"]=2,["pistoldwsalt"]=6,["dash"]=1,["roundaboutshot"]=1,["mindripfield"]=1,["mind"]=1,},{["FiveSlash"]='equip',["Theravada"]="equip",},}--|]]
	save = table.load(save)
	leon:load(save.character)
	map:addUnit(leon)
	map.camera = FollowerCamera:new(leon)
	GetGameSystem().bottompanel:fillPanel(GetCharacter():getSkillpanelData())
	GetGameSystem().bottompanel:setPos(screen.halfwidth-512,screen.height - 140)
	self:checkpoint1_loaded()
end

function Tibet1:checkpoint1_loaded()
	PlayTutorial(tutorialtable.movement)
	local meethans = CutSceneSequence:new()
	meethans:push(ExecFunction:new(function()
		hans = IALSwordsman:new(0,100,'enemy')
		map:addUnit(hans)
		hans:face(GetCharacter())
		meethans.camera,map.camera = map.camera,Camera:new(-GetCharacter().x,-GetCharacter().y)
		map.camera:pan(hans,2)
		hans:playAnimation('attack',0.5,false)
		GetGameSystem():gotoState('cutscene')
		GetGameSystem().bottompanel:conversation('VOLCANO',"Come no further, my old friend, or i shall have to kill you.")
		GetCharacter():stop()
	end),0)
	meethans:wait(5)
	meethans:push(ExecFunction:new(function()
		map.camera:pan(GetCharacter(),2)
		GetGameSystem().bottompanel:conversation('RIVER',"Stay out of my way, for that's not my friend would do.")
	end),0)

	meethans:wait(5)
	meethans:push(ExecFunction:new(function()
		map.camera:pan(hans,20)
		GetGameSystem().bottompanel:conversation('HANS',"I warn you as a friend. You have no reason to start a war that doesn't concern you. Turn back now, before Master Yuen gets angry.")
	end),0)
	meethans:wait(10)
	meethans:push(ExecFunction:new(function()
		GetGameSystem().bottompanel:conversation('RIVER',"You've talked too much. Die.")
	end),0)
	meethans:wait(5)
	meethans:push(ExecFunction:new(function()
		map.camera = meethans.camera
		GetGameSystem():gotoState()
		GetGameSystem().bottompanel:conversation()
		PlayTutorial(tutorialtable.mainweapon)
	end),0)

	local hansdisappear = CutSceneSequence:new()
	hansdisappear:push(ExecFunction:new(function()
		GetGameSystem():gotoState('conversation')
		GetGameSystem().bottompanel:conversation('RIVER',"Damn.. It's just a illusion.")
		GetCharacter():stop()
		PlayTutorial(tutorialtable.skill)
	end),0)

	hansdisappear:wait(5)
	hansdisappear:push(ExecFunction:new(function()
		GetGameSystem():gotoState()
		GetGameSystem().bottompanel:conversation()
	end),0)

	local finishscene = CutSceneSequence:new()
	finishscene:push(FadeOut:new('fadeout',nil,{0,0,0},2),0)
	finishscene:wait(2)
	finishscene:push(ExecFunction:new(function()
		if map and map.destroy then
			 map:destroy()
		end
		require 'scenes.tibet.tibet2'
		map = Tibet2:new(2000,2000)
		map:load()
		map:opening_enter()
	end),0)
	
	local entered = {}
	self.tibet1listener = {handle = function(handler,event)
		if event.type == 'death' and event.unit == hans then
			local box = Box:new(hans.x,hans.y,'enemy')
			box:addBuff(b_Summon:new(),3)
			map:addUnit(box)
			map:playCutscene(hansdisappear)
		elseif event.type == 'death' and event.unit == GetCharacter() then
			GetGameSystem():loadCheckpoint()
		elseif event.type == 'add' and event.unit == GetCharacter() then	
			if event.index == 2 and not entered[2] then
				entered[2] = true
				map:playCutscene(meethans)
			elseif event.index == 3 and not entered[3] then
				entered[3] = true
				map:playCutscene(finishscene)
			end
		end
	end}
	gamelistener:register(self.tibet1listener)
	self.savedata.checkpoint = 'opening'
	GetGameSystem():saveAll()
	GetGameSystem():gotoState()
end

function Tibet1:destroy()
	gamelistener:unregister(self.tibet1listener)
end

return Tibet1()
