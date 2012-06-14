
require 'cutscene.cutscene'
preload('assassin','commonenemies','tibet','masteryuen','kingofdragons')

local Mansionbg={}
function Mansionbg:update(dt)
end

local transition = 
{intensity = 1,
factor = -1,
}
function transition:terminate()
	return self.intensity<0
end
function transition:update(dt)
	self.intensity = self.intensity + dt*self.factor
	if self:terminate() then
		map:removeUpdatable(self)
	end
end

function transition:reset()
	self.intensity = 1
end

function transition:draw()
	filtermanager:requestFilter('Bloom')
	filtermanager:setFilterArguments('Bloom',{
		bloomintensity = self.intensity*5 ,
		bloomsaturation = self.intensity*5 ,
	})
end

requireImage('assets/vancouver/waterfall.png','waterfall')
function Mansionbg:draw()
--	love.graphics.draw(img.waterfall,0,300,0,2,2,300,150)
	love.graphics.push()
	love.graphics.translate(-720,-1024)
	self.m:draw()
	love.graphics.pop()
end

local mantrabg = {
	time = 0,
	intensity = 1,
}
function mantrabg:update(dt)
	self.time = self.time + dt
end

requireImage'assets/northvan/hellup.png'
requireImage'assets/northvan/eye.png'
requireImage'assets/northvan/hellspinarm.png'
requireImage'assets/northvan/mantra1.png'
requireImage'assets/northvan/mantra2.png'
requireImage'assets/northvan/mantra3.png'
function mantrabg:draw()
	love.graphics.push()
--	love.graphics.scale(0.5)
	if self.time > 3 then
		love.graphics.setColor(0,0,0)
	else
		love.graphics.push()
		love.graphics.scale(1-self.time/3)
		Mansionbg:draw()
		love.graphics.setColor(0,0,0,self.time*255/3)
		love.graphics.pop()
	end
	love.graphics.draw(img.dot,0,0,0,100000,100000,0.5,0.5)
	love.graphics.setColor(125,125,125,math.min(255,self.time*255/3))
	love.graphics.draw(img.hellspinarm,0,0,self.time,2,2,256,256)
	love.graphics.draw(img.hellspinarm,0,0,-self.time,2,2,256,256)
	love.graphics.draw(img.hellup,0,0,self.time/3,2,2,256,256)
	love.graphics.draw(img.eye,0,0,0,0.5,0.5,1164/2,588/2)
	
	love.graphics.draw(img.mantra1,0,0,self.time,2,2,256,256)
	love.graphics.draw(img.mantra2,0,0,-self.time,2,2,256,256)
	love.graphics.draw(img.mantra3,0,0,self.time,2,2,256,256)
	love.graphics.pop()
	filtermanager:requestFilter('Bloom')
	filtermanager:setFilterArguments('Bloom',{
		bloomintensity = self.intensity,
		bloomsaturation = self.intensity,
	}
	)
end



Mansion = Map:subclass'Mansion'
function Mansion:initialize()
	local w = 1440
	local h = 2048
	self.w,self.h=w,h
	super.initialize(self,w,h)
	local m = self:loadTiled'mansion.tmx'
	assert(m)
	Mansionbg.m = m
	self.background = Mansionbg
end

function Mansion:draw()
	if GetCharacter():isKindOf(KingOfDragons) then dragongate.predraw() end
	super.draw(self)
end
function Mansion:destroy()
--	self.exitTrigger:destroy()
end

function Mansion:opening_load()
	local leon = Assassin:new(10,10,32,10)
	leon.direction = {0,-1}
	leon.controller = 'player'
	map:addUnit(leon)
	SetCharacter(leon)
	controller:setLockAvailability(true)
	GetCharacter().skills.weaponskill:gotoState'interact'
	local inv = GetCharacter().inventory
	inv:addItem(FiveSlash())
	inv:addItem(PeacockFeather:new())
	inv:addItem(BigHealthPotion:new())
	local leon2 = Assassin(100,10,32,10)
	leon2.direction = {0,-1}
	leon2:gotoState'npc'
	leon2.controller = 'player'
	map:addUnit(leon2)
	self:loadDefaultCamera(leon2)
	leon2.interact = require 'scenes.vancouver.swift-visit-1'
end

function Mansion:enter_load(character)
	character = character or GetCharacter()
	assert(character)
	character.x,character.y = 0,-200
	map:addUnit(character)
	self:enter_loaded()
	self:loadDefaultCamera(character)
end

function Mansion:enterMantra()
	self.background = mantrabg
	mantrabg.time = 0
	TEsound.play'sound/entermantra.wav'
	TEsound.play'sound/masteryuenchant/immortality.mp3'
--	map.anim:easy(self,'intensity',5,1,3)
end

function Mansion:exitMantra()
--	map.anim:easy(self,'intensity',10,1,3)
	Trigger(function()
--		wait(3)
		self.background = Mansionbg
		TEsound.play'sound/exitmantra.wav'
		TEsound.play'sound/groan.mp3'
		transition:reset()
		map:addUpdatable(transition)
	end):run()
	
end

function Mansion:enter_loaded()
	if GetCharacter().class == Assassin then
		self:wake_loaded()
	else
		local leon2 = GetGameSystem():loadobj 'Assassin'
		leon2.x,leon2.y = 0,0
		leon2.direction = {0,-1}
		leon2.controller = 'player'
		leon2:gotoState'npc'
		map:addUnit(leon2)
		leon2.interact = require 'scenes.vancouver.swift-visit-1'
	end
	self:addUnit(Mat(0,150,60,5))
	
	self.exitTrigger = Trigger(function(self,event)
		if event.index == 'exit' and event.unit == GetCharacter() then
			pushsystem(vancouver)
			vancouver:zoomOutCity'vancouver'
		end
	end)
	self.exitTrigger:registerEventType('add')
	
end

function Mansion:wake_load()
	local leon2 = GetGameSystem():loadobj 'Assassin'
	leon2.x,leon2.y = 200,0
	leon2.direction = {0,-1}
	leon2.controller = 'player'
	map:addUnit(leon2)
	SetCharacter(leon2)
	self:wake_loaded()
	self:loadDefaultCamera(leon2)
end

function Mansion:bloomout()
	transition.intensity = 0
	transition.factor = 0.2
	
	function transition:terminate()
		return self.intensity > 2
	end
	map:addUpdatable(transition)
end

function Mansion:wake_loaded()
	my=MasterYuen()
	my.controller = 'enemy'
	map:addUnit(my)
end

function Mansion:load(x,y,c)
	self:wake_load()
end

function testimg()
	local img  = MasterYuenImage(-300,-300)
	img.controller = 'enemy'
	map:addUnit(img)
	img:enableAI()
end

function Mansion:finish()
	
	map:enterMantra()
	map:bloomout()
	Trigger(function()
		wait(5)
		self:phase5()
	end):run()
end

function Mansion:phase5()
	map:exitMantra()
	my:setImmunity(false)
	GetCharacter():removeBuff(b_Stun)
	local KoD = KingOfDragons(GetCharacter():getPosition())
	KoD.controller = 'player'
	KoD:loadFromAssassin(GetCharacter())
	map:removeUnit(GetCharacter())
	map:addUnit(KoD)
	SetCharacter(KoD)
	map.camera = FollowerCamera(KoD)
	GetGameSystem():reloadBottompanel()
--	require 'scenes.northvan.riverrevives'()
	
	PlayMusic'music/riverrise.mp3'
	
	local epic = {
		rise1 = 28,
		rise2 = 67,
		rise3cut = 60+33,
		rise3 = 60+57,
		rise4 = 120+38,
		rise5 = 180+13,
		finishmy = 180+56,
	}
	Timer(epic.rise1,1,function()self:rise1() end)
	Timer(epic.rise2,1,function()self:rise2() end)
	Timer(epic.rise3cut,1,function()self:rise3cut() end)
	Timer(epic.rise3,1,function()self:rise3() end)
	Timer(epic.rise4,1,function()self:rise4() end)
	Timer(epic.rise5,1,function()self:rise5() end)
	Timer(epic.finishmy,1,function()self:finishmy() end)
end

function Mansion:rise1()
	local spawnpoints = {
		self.waypoints.spawn1,
		self.waypoints.spawn2,
		
		self.waypoints.spawn3,
		self.waypoints.spawn4,
	}
	self.maxspawn = 20
	local armywave = Trigger(function(trig,event)
			if event.unit == GetCharacter() then
				self.update = function()
					GetGameSystem():pushState'retry'
				end
			else
				if self.count.enemy <= self.maxspawn then
					for i,v in ipairs(spawnpoints) do
						local x,y = unpack(v)
						local u = self.spawnunittype(x,y,'enemy')
						u.hp = u.hp/2
						u:enableAI()
						map:addUnit(u)
					end
				end
			end
	end)
	self.spawnunittype = IALSwordsman
	armywave:registerEventType'death'
	armywave:run({})
	self.armywave = armywave
--	GetCharacter().HPRegen = 1000
end

function Mansion:rise2()
	self:splashText('Mantra Shield',requireImage'assets/assassin/gate.png')
	GetCharacter().skills.mantrashield:active()
	self.spawnunittype = IALMachineGunner
end

function Mansion:rise3cut()
	Trigger(function()
		local k = KoDPowerUpActor(GetCharacter())
		map:addUpdatable(k)
		wait(10.5)
		map:removeUpdatable(k)
	end):run()
end

function Mansion:rise3()
	self:splashText("Phoniex's Grace",requireImage'assets/assassin/gate.png')
	GetCharacter().skills.dragoneye:active()
	self.maxspawn = 10
end

function Mansion:rise4()
	GetCharacter():resetCD()
	GetCharacter().mp = 10000
	GetCharacter().skills.dws:active()
end

function Mansion:rise5()
	my.actor:setEffect()
	self.armywave:destroy()
	my.hp = my.maxhp/2
	my.ai = my:rise()
end

function Mansion:finishmy()
	
	map:bloomout()
	Trigger(function()
		wait(5)
		require 'scenes.northvan.finishmy'()
		StopMusic()
	end):run()
end



function scenetest()
--	testimg()
	map.camera = ContainerCamera:new(200,nil,my,GetCharacter())
	PlayMusic'music/berserker.mp3'
	GetGameSystem().bossbar = AssassinHPBar:new(function()return my:getHPPercent() end,screen.halfwidth-400,screen.height-100,800)
	local self = my
	loadAllItems(GetCharacter())
	local p = HealthPotion()
	GetCharacter():pickUp(p,10)
--	map:addUnit(TempestWeapon(100,0))
--	my:enableAI()
	my.ai = my:phase3()
--	my.ai = my:phase4()
	--map:phase4()
	--map:rise5()
	
	

end
