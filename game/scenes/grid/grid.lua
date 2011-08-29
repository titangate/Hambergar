--require 'libraries.scene'
--require 'libraries.unit'
function GetCharacter()
	return chr
end

function SetCharacter(c)
	chr = c
end

Grid = Map:subclass('Grid')
local gridbackground = {}
love.graphics.setBackgroundColor(0,0,0,255)
love.graphics.setColor(40,238,75,255)
love.graphics.setLineWidth(1.5)

love.graphics.setColor(255,255,255,255)
function gridbackground:draw()
love.graphics.draw(img.greenearth,GetCharacter().x/10,GetCharacter().y/10)
love.graphics.draw(img.ore1,GetCharacter().x/3+190,GetCharacter().y/3-200)
love.graphics.draw(img.ore2,GetCharacter().x/7+400,GetCharacter().y/7+188)
--[[for i = 1,50 do
	local n = i*40
	love.graphics.line(n,0,n,2000)
	love.graphics.line(0,n,2000,n)
end]]
end
ore1 = love.graphics.newImage('assets/ore1.png')
ore2 = love.graphics.newImage('assets/ore2.png')
greenearth = love.graphics.newImage('assets/greenearth.png')
earth = {}
function earth:draw()
end
function Grid:initialize()
	local w = 2000
	local h = w
	super.initialize(self,w,h)
	self.flows = {}
	self.background = gridbackground
	self.emitrate = 1
	self.emittime = 1
	self.birthtime = 0
end

dirs = {
	{100,0},
	{-100,0},
	{0,100},
	{0,-100}
}
function Grid:update(dt)
	if self.birthtime > 0 then
		self.birthtime = self.birthtime - dt
	end
	self.emittime = self.emittime - dt
	if self.emittime < 0 then
		self.emittime = self.emittime + self.emitrate
		if math.random()>0.5 then
		local x,y=math.random(love.graphics.getWidth())-love.graphics.getWidth()/2,math.random(love.graphics.getHeight())-love.graphics.getHeight()/2
		self:generateFlow(math.floor((GetCharacter().x+x)/40)*40,math.floor((GetCharacter().y+y)/40)*40,dirs[math.random(#dirs)])
		end
	end
	for i,v in ipairs(self.flows) do
		local flow,time,direction = unpack(v)
		time = time - dt
		if time < 0 then
			table.remove(self.flows,i)
		else
			v[2] = time
			if time > 2 then
				flow:start()
				local x,y = flow:getX(),flow:getY()
				local sx,sy = unpack(direction)
				x,y=x-dt*sx,y-dt*sy
				flow:setPosition(x,y)
			end
			flow:update(dt)
		end
	end
	super.update(self,dt)
end

gridfilter = love.graphics.newImage("assets/gridfilter.png")
function Grid:draw()
	super.draw(self)
	for i,v in ipairs(self.flows) do
		love.graphics.draw(v[1],0,0)
	end
	if self.birthtime > 0 then
		love.graphics.setScissor(0,0,love.graphics.getWidth(),love.graphics.getHeight()*(1-self.birthtime))
		--print (love.graphics.getHeight()*(3-self.birthtime)/3+gridfilter:getHeight())
		--print (600*(1-self.birthtime)+gridfilter:getHeight()*2,self.birthtime)
		map.camera:revert()
		love.graphics.draw(img.gridfilter,0,600*(1-self.birthtime)-gridfilter:getHeight(),0,25,1,0,0)
		map.camera:apply()
	--[[	for x,y in self.aimap.terrain:keys() do
			love.graphics.setLineWidth(5)
			love.graphics.setColor(40,238,75,255)
			love.graphics.rectangle('line',x*40,y*40,40,40)
			love.graphics.setColor(255,255,255,255)
			love.graphics.setLineWidth(1.5)
		end]]
		love.graphics.setScissor()
	else
--[[	for x,y in self.aimap.terrain:keys() do
		love.graphics.setLineWidth(5)
		love.graphics.setColor(40,238,75,255)
		love.graphics.rectangle('line',x*40,y*40,40,40)
		love.graphics.setColor(255,255,255,255)
		love.graphics.setLineWidth(1.5)
	end]]
	end
end

function Grid:generateFlow(x,y,direction)
	local p = love.graphics.newParticleSystem(img.sparkle, 1000)
	p:setPosition(x,y)
	p:setEmissionRate(50)
	p:setGravity(0,0)
	p:setSpeed(-50,50)
	p:setSize(1, 1)
	p:setColor(20, 255, 75, 200, 20, 255, 75, 0)
	p:setLifetime(1)
	p:setParticleLife(2)
	p:setDirection(0)
	p:setSpread(360)
	p:setTangentialAcceleration(0)
	p:setRadialAcceleration(0)
	p:stop()
	table.insert(self.flows,{p,4,direction})
end

function Grid:birth()
	self.birthtime = 1
end

function Grid:load()
end

function Grid:opening_load()
	local lawrence = Electrician:new(10,10,32,10)
	lawrence.direction = {0,-1}
	lawrence.controller = 'player'
	SetCharacter(lawrence)
	map:addUnit(lawrence)
	map.camera = FollowerCamera:new(lawrence)
	GetGameSystem():loadCharacter(lawrence)
	GetGameSystem().bottompanel:fillPanel(GetCharacter():getSkillpanelData())
	GetGameSystem().bottompanel:setPos(screen.halfwidth-512,screen.height - 150)
--	self:opening_loaded()
end


function Grid:loadCheckpoint(checkpoint)
	if checkpoint == 'opening' then
		self:opening_load()
	elseif checkpoint == 'boss' then
		self:boss_load()
	end
end
