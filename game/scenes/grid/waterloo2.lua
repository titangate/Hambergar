--require 'libraries.scene'
--require 'libraries.unit'

local loader = require("AdvTiledLoader/Loader")
loader.path = "maps/"
local m = loader.load("waterloo outside.tmx")
m.useSpriteBatch=true
m.drawObjects=false
local oj = m.objectLayers
function GetCharacter()
	return chr
end

function SetCharacter(c)
	chr = c
end

Waterloo2Background={}
function Waterloo2Background:update(dt)
end

function Waterloo2Background:draw()
	love.graphics.push()
	love.graphics.translate(-2000,-2000)
	m:draw()
	love.graphics.pop()
end

Waterloo2 = Map:subclass('Waterloo2')
unitdict={}
adding = {}
function Waterloo2:loadUnitFromTileObject(obj)
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
		if obj.properties.id then
			_G[obj.properties.id]=object
		end
	end
end
function Waterloo2:initialize()
	local w = 4000
	local h = w
	self.w,self.h=w,h
	super.initialize(self,w,h)
	self.flows = {}
	self.background = Waterloo2Background
	self.emitrate = 1
	self.emittime = 1
	self.birthtime = 0
	unitdict={}
	for k,v in pairs(oj) do
		if v.name == 'obstacles' then
			for _,obj in pairs(v.objects) do
				self:placeObstacle(obj.x-w/2,obj.y-h/2,obj.width,obj.height,nil,obj.name)
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
				else
					self:loadUnitFromTileObject(obj,w,h)
				end
			end
		end
	end
	
end

function Waterloo2:playCutscene(scene)
	self.cutscene = scene
end
function Waterloo2:update(dt)
	if self.cutscene then
		self.cutscene:update(dt)
	end
	super.update(self,dt)
	if next(adding) then
		for k,v in ipairs(adding) do self:addUnit(v) end
		adding = {}
	end
end

function Waterloo2:draw()
	super.draw(self)
	for i,v in ipairs(self.flows) do
		love.graphics.draw(v[1],0,0)
	end
	if self.cutscene then
		self.cutscene:draw()
	end
end

function Waterloo2:opening_load()
	local x,y=unpack(self.waypoints.spawningpoint)
	local lawrence = Electrician:new(x,y,32,10)
	lawrence.direction = {0,-1}
	lawrence.controller = 'player'
	SetCharacter(lawrence)
	map:addUnit(lawrence)
	map.camera = FollowerCamera:new(lawrence)
	GetGameSystem():loadCharacter(lawrence)
	GetGameSystem().bottompanel:fillPanel(GetCharacter():getSkillpanelData())
	GetGameSystem().bottompanel:setPos(screen.halfwidth-512,screen.height - 140)
	self:opening_loaded()
end

function Waterloo2:opening_enter()
	GetCharacter().x,GetCharacter().y = unpack(self.waypoints.spawningpoint)
	self:addUnit(GetCharacter())
	self.camera = FollowerCamera:new(GetCharacter())
	self:opening_loaded()
end

function Waterloo2:opening_loaded()
	local intro = CutSceneSequence:new()
	intro:push(FadeOut:new('fadein',nil,{0,0,0},2),0)
	self:playCutscene(intro)
	local t = Trigger:new(function()
		GetGameSystem().conversationpanel:birth()
		GetGameSystem().conversationpanel:play('LAWRENCE','What is going on with this place?',nil,5)
		wait(5)
		GetGameSystem().conversationpanel:play('GP 8044','No time for details, head to the rocket launching site.',nil,3)
		wait(5)
		anim:easy(GetGameSystem().conversationpanel,'opacity',255,0,1)
	end)
	t:run()
	
	local areaTrigger = Trigger:new(function(self,event)
		if event.index == 'computergridenter' and event.unit==GetCharacter() then	
			self:close()	
			GetGameSystem():setCheckpoint(Waterloo2,"boss",[[
			require 'scenes.grid.waterloo2'
			]])
			map:boss_enter()
			self:destroy()
		end
	end)
	
	local victoryTrigger = Trigger:new(function(self,event)
		if event.index == 'chapterend' and event.unit == GetCharacter() then
			self:close()
			GetGameSystem():setCheckpoint(Waterloo2,"victory",[[
			require 'scenes.grid.waterloo2'
			]])
			map:victory()
			self:destroy()
		end
	end)
end

function Waterloo2:victory()
end

function Waterloo2:load()
end

function Waterloo2:victory_load()
end

function Waterloo2:boss_enter()
	self:boss_loaded()
end

function Waterloo2:boss_load()
	local x,y=unpack(self.waypoints.BossSpawnPoint)
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

function Waterloo2:boss_loaded()
	for _,obj in ipairs(unitdict.boss) do
		map:loadUnitFromTileObject(obj)
	end
	map.camera = ContainerCamera:new(400,{
		x1 = -2000,
		y1 = -2000,
		x2 = 2000,
		y2 = 2000
	},setmetatable({},{__index = function(_,key)
		if key == 'x' then
			return boss.x
		end
		if key == 'y' then
			return boss.y
		end
	end}),GetCharacter())
	PlayMusic('music/jasonboss.mp3')
	bossbar = AssassinHPBar:new(function()return boss:getHPPercent() end,screen.halfwidth-400,screen.height-100,800)
end

function Waterloo2:loadCheckpoint(checkpoint)
	if checkpoint == 'opening' then
		self:opening_load()
	elseif checkpoint == 'boss' then
		self:boss_load()
	elseif checkpoint == 'victory' then
		self:victory_load()
	end
end
