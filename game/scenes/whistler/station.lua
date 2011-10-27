preload('assassin','commonenemies','tibet','vancouver')
KingEdStation = Map:subclass('KingEdStation')


local kingedbg={}
function kingedbg:update(dt)
end
function kingedbg:draw()
	love.graphics.push()
	love.graphics.translate(-800,-800)
	self.m:draw()
	love.graphics.pop()
end
function KingEdStation:initialize()

	local w = 1600
	local h = w
	self.w,self.h=w,h
	super.initialize(self,w,h)
	local m = self:loadTiled'armory.tmx'
	kingedbg.m = m
	self.background = kingedbg
	self.savedata = {
		map = 'scenes.tibet.station',
	}
end
function KingEdStation:update(dt)
	super.update(self,dt)
end
function KingEdStation:draw()
	super.draw(self)
end

function KingEdStation:load()
	
end

function KingEdStation:loadCheckpoint(checkpoint)
	if checkpoint == 'opening' then
		self:checkpoint1_load()
	end
end

function KingEdStation:checkpoint1_load()
	local leon = Assassin:new(-120,650,32,10)
	leon.direction = {0,-1}
	leon.controller = 'player'
	SetCharacter(leon)
	map:addUnit(leon)
	map.camera = FollowerCamera:new(leon)
	GetGameSystem().bottompanel:fillPanel(GetCharacter():getSkillpanelData())
	GetGameSystem().bottompanel:setPos(screen.halfwidth-512,screen.height - 140)
	self:checkpoint1_loaded()
end

function KingEdStation:checkpoint1_loaded()
	local i = IALSwordsman(100,0,'enemy')
	i.ai = StealthNormal(i,GetCharacter())
	map:addUnit(i)
end

function KingEdStation:destroy()
end

return KingEdStation()
