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

function WaterlooSite:initialize()
	local w = 6000
	local h = w
	super.initialize(self,w,h)
	self.flows = {}
	self.background = WaterlooSiteBackground
	self.emitrate = 1
	self.emittime = 1
	self.birthtime = 0
	for k,v in pairs(oj) do
		if v.name == 'obstacles' then
			for k2,v2 in pairs(v) do
				print (k2,v2)
			end
			for _,obj in pairs(v.objects) do
				self:placeObstacle(obj.x-3000,obj.y-3000,obj.width,obj.height,0)
			end
		end
	end
end
function WaterlooSite:update(dt)

	super.update(self,dt)
end

requireImage("assets/gridfilter.png",'gridfilter')
function WaterlooSite:draw()
	super.draw(self)
	for i,v in ipairs(self.flows) do
		love.graphics.draw(v[1],0,0)
	end
end


function WaterlooSite:load()
end

function WaterlooSite:opening_load()
	local lawrence = Electrician:new(-1000,-1000,32,10)
	lawrence.direction = {0,-1}
	lawrence.controller = 'player'
	SetCharacter(lawrence)
	map:addUnit(lawrence)
	map.camera = FollowerCamera:new(lawrence)
	GetGameSystem():loadCharacter(lawrence)
	GetGameSystem().bottompanel:fillPanel(GetCharacter():getSkillpanelData())
	GetGameSystem().bottompanel:setPos(screen.halfwidth-512,screen.height - 150)
end


function WaterlooSite:loadCheckpoint(checkpoint)
	if checkpoint == 'opening' then
		self:opening_load()
	elseif checkpoint == 'boss' then
		self:boss_load()
	end
end
