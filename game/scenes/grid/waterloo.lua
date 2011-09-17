--require 'libraries.scene'
--require 'libraries.unit'

local loader = require("AdvTiledLoader/Loader")
loader.path = "maps/"
local m = loader.load("waterloo dom.tmx")
m.useSpriteBatch=true
m.drawObjects=false
local oj = m.objectLayers
function GetCharacter()
	return chr
end

function SetCharacter(c)
	chr = c
end

WaterlooSiteBackground={}
function WaterlooSiteBackground:update(dt)
end

function WaterlooSiteBackground:draw()
	love.graphics.push()
	love.graphics.translate(-3000,-3000)
	m:draw()
	love.graphics.pop()
end

WaterlooSite = Map:subclass('WaterlooSite')
unitdict={}
adding = {}
function WaterlooSite:loadUnitFromTileObject(obj)
	local w,h=self.w,self.h
	if loadstring('return '..obj.name)() then
		local object = loadstring('return '..obj.name..':new()')()
		object.x,object.y=obj.x-w/2,obj.y-h/2
		if obj.properties.controller then
			object.controller = obj.properties.controller
		end
		object.r = obj.properties.angle or math.random(3.14)
		table.insert(adding,object)
		if object.controller=='enemy' and object.enableAI then
			object:enableAI()
		end
	end
end
function WaterlooSite:initialize()
	local w = 6000
	local h = w
	self.w,self.h=w,h
	super.initialize(self,w,h)
	self.flows = {}
	self.background = WaterlooSiteBackground
	self.emitrate = 1
	self.emittime = 1
	self.birthtime = 0
	for k,v in pairs(oj) do
		if v.name == 'obstacles' then
			for _,obj in pairs(v.objects) do
				self:placeObstacle(obj.x-w/2,obj.y-h/2,obj.width,obj.height)
			end
		elseif v.name == 'areas' then
			for _,obj in pairs(v.objects) do
				self:placeObstacle(obj.x-w/2,obj.y-h/2,obj.width,obj.height,obj.name)
			end
		elseif v.name == 'objects' then
			for _,obj in pairs(v.objects) do
				if obj.properties.phrase then
					local p = obj.properties.phrase
					unitdict[p] = unitdict[p] or {}
					table.insert(unitdict[p],obj)
--					self:loadUnitFromTileObject(obj,w,h)
				else
					self:loadUnitFromTileObject(obj,w,h)
				end
			end
			--map:addUnit(IALSwordsman:new(math.random(200),math.random(200),'enemy'))
		end
	end
	
end

function WaterlooSite:playCutscene(scene)
	self.cutscene = scene
end
function WaterlooSite:update(dt)
	if self.cutscene then
		self.cutscene:update(dt)
	end
	super.update(self,dt)
	if next(adding) then
		for k,v in ipairs(adding) do self:addUnit(v) end
		adding = {}
	end
end

requireImage("assets/gridfilter.png",'gridfilter')
function WaterlooSite:draw()
	super.draw(self)
	for i,v in ipairs(self.flows) do
		love.graphics.draw(v[1],0,0)
	end
	if self.cutscene then
		self.cutscene:draw()
	end
end


function WaterlooSite:load()
end

function WaterlooSite:opening_load()
	local x,y=unpack(self.waypoints.SpawingPoint)
	local lawrence = Electrician:new(x,y,32,10)
	lawrence.direction = {0,-1}
	lawrence.controller = 'player'
	lawrence.mp=300
	SetCharacter(lawrence)
	map:addUnit(lawrence)
	map.camera = FollowerCamera:new(lawrence)
--	GetGameSystem():loadCharacter(lawrence)
	GetGameSystem().bottompanel:fillPanel(GetCharacter():getSkillpanelData())
	GetGameSystem().bottompanel:setPos(screen.halfwidth-512,screen.height - 150)
	local intro = CutSceneSequence:new()
	intro:push(FadeOut:new('fadein',nil,{0,0,0},2),0)
	self:playCutscene(intro)
	local t = Trigger:new(function()
		GetGameSystem().conversationpanel:birth()
		GetGameSystem().conversationpanel:play('LAWRENCE','ARRRR... What the hell happened... My head is exploding...',nil,5)
		wait(5)
		GetGameSystem().conversationpanel:play('???','INITIATING LIFE SEQUENCE',nil,3)
		wait(3)
		GetGameSystem().conversationpanel:play('LAWRENCE',"What's this voice in my head...",nil,3)
		wait(3)
		GetGameSystem().conversationpanel:play('LAWRENCE',"And this..wicked thing i'm seeing right now...",nil,4)
		wait(4)
		GetGameSystem().conversationpanel:play('GP 8044','WELCOME BACK, LAWRENCE FU. THE DATE IS OCTOBER 2nd, 2022. THE LOCATION IS VILLAGE ONE OF UWATERLOO. PLEASE TRY INITIATE DRAINNING SEQUENCE ON A NEARBY ELECTRIFIED OBJECT.',nil,7)
		wait(7)
		anim:easy(GetGameSystem().conversationpanel,'opacity',255,0,1)
		local timer = Timer:new(0.1,-1,function(self)
			
		end,true,true)
		local t = Trigger:new(function(self,event)
			if event.timer == timer and GetCharacter():getMPPercent()>=0.7 then
				timer.count = 1
				self:destroy()
				GetGameSystem().conversationpanel:birth()
				GetGameSystem().conversationpanel:play('LAWRENCE','I feel better now, but... why?',nil,3)
				wait(3)
				GetGameSystem().conversationpanel:play('GP 8044',"I'm afraid your school is no more, nor is this place of yours.",nil,4)
				wait(4)
				GetGameSystem().conversationpanel:play('LAWRENCE',"And I'm glad you got rid of all the cap locks. now tell me what you know.. and who you are.",nil,5)
				wait(5)
				GetGameSystem().conversationpanel:play('GP 8044',"I'm an AI embedded in your body. Now please head down to the computer grid, you will find a missing part of me there.",nil,6)
				wait(6)
				GetGameSystem().conversationpanel:play('LAWRENCE',"And why should i help you, intruder?",nil,5)
				wait(5)
				GetGameSystem().conversationpanel:play('GP 8044',"The entire Toronto has been nuked, you're damn lucky that you survived.",nil,6)
				wait(6)
				anim:easy(GetGameSystem().conversationpanel,'opacity',255,0,1)
			end
		end)
		t:registerEventType('timer')
		
	end)
	Timer:new(5,1,function()
		t:run()
	end,true,true)
	
	local areaTrigger = Trigger:new(function(self,event)
		
		if event.index == 'computergridenter' and event.unit==GetCharacter() then	
			self:close()	
			GetGameSystem():setCheckpoint(WaterlooSite,"boss",[[
			require 'scenes.grid.waterloo'
			]])
			map:boss_enter()
			self:destroy()
		end
			
	end)
	areaTrigger:registerEventType('add')
	local hallwayTrigger = Trigger:new(function(self,event)
		if event.index == 'Hallway1' and event.unit==GetCharacter() then
			self:close()
			wait(2)
			for _,obj in ipairs(unitdict.hallway) do
				map:loadUnitFromTileObject(obj)
			end
			self:destroy()
		end
			
	end)
	hallwayTrigger:registerEventType('add')
	
	local roomTrigger = Trigger:new(function(self,event)
		if event.index == 'engineeringroom' and event.unit==GetCharacter() then
			self:close()
			wait(2)
			for _,obj in ipairs(unitdict.room) do
				map:loadUnitFromTileObject(obj)
			end
			self:destroy()
		end
	end)
	roomTrigger:registerEventType('add')
end


function WaterlooSite:boss_enter()
	self:boss_loaded()
end

function WaterlooSite:boss_load()
	local x,y=unpack(self.waypoints.computergridenter)
	local lawrence = Electrician:new(x,y,32,10)
	lawrence.direction = {0,-1}
	lawrence.controller = 'player'
	SetCharacter(lawrence)
	map:addUnit(lawrence)
	map.camera = FollowerCamera:new(lawrence)
	GetGameSystem():loadCharacter(lawrence)
	GetGameSystem().bottompanel:fillPanel(GetCharacter():getSkillpanelData())
	GetGameSystem().bottompanel:setPos(screen.halfwidth-512,screen.height - 140)
	self:boss_loaded()
end


function WaterlooSite:boss_loaded()
	for _,obj in ipairs(unitdict.boss) do
		map:loadUnitFromTileObject(obj)
	end
end

function WaterlooSite:loadCheckpoint(checkpoint)
	if checkpoint == 'opening' then
		self:opening_load()
	elseif checkpoint == 'boss' then
		self:boss_load()
	end
end
