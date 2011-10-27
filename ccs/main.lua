require 'MiddleClass'

ImageLoader = {}
local imagedata = {}
function ImageLoader.load(img)
	assert(type(img)=='string')
	if not imagedata[img] then
		imagedata[img] = love.graphics.newImageData(img)
	end
	return love.graphics.newImage(imagedata[img])
end

ComicCutsceneElement = class('ComicCutsceneElement')

Scrap = ComicCutsceneElement:subclass('Scrap')
function Scrap:initialize(img)
	assert(img)
	if type(img)=='string' then
		self.img = ImageLoader.load(img)
	else
		self.img = img
	end
	self.x,self.y = 0,0
	self.r = 0
	self.sx,self.sy = 0,0
	self.ox,self.oy = 0,0
	self.quad = nil
end

function Scrap:draw()
	assert(self.img)
	local x,y,r = self.x,self.y,self.r
	local sx,sy = self.sx,self.sy
	local ox,oy = self.ox,self.oy
	if self.quad then
		love.graphics.drawq(self.img,self.quad,x,y,r,sx,sy,ox,oy)
	else
		love.graphics.draw(self.img,x,y,r,sx,sy,ox,oy)
	end
end

ComicCutscene = class('ComicCutscene')
function ComicCutscene:initialize()
end