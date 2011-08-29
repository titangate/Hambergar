
requireImage( 'assets/assassin/life.png','icontable.life' )
requireImage( 'assets/assassin/mind.png','icontable.mind' )
requireImage( 'assets/assassin/weapon.png','icontable.weapon' )
icontable=
{
	life = img['icontable.life'],
	mind = img['icontable.mind'],
	weapon = img['icontable.weapon'],
}


AttributeItem = Object:subclass('AttributeItem')
HPAttributeItem = AttributeItem:subclass('HPAttributItem')
function HPAttributeItem:initialize(hpfunc,maxhpfunc,w)
	self.hpfunc,self.maxhpfunc = hpfunc,maxhpfunc
	self.w = w
	self.h = 15
end
function HPAttributeItem:draw(x,y)
	love.graphics.draw(img['icontable.life'],x,y)
	love.graphics.printf('HP',x+20,y,self.w,"left")
	local hp,maxhp = self.hpfunc(),self.maxhpfunc()
	love.graphics.printf(hp..'/'..maxhp,x,y,self.w,"right")
end
MPAttributeItem = HPAttributeItem:subclass('MPAttributeItem')
function MPAttributeItem:draw(x,y)
	love.graphics.draw(img['icontable.mind'],x,y)
	love.graphics.printf('Mind Power',x+20,y,self.w,"left")
	local hp,maxhp = self.hpfunc(),self.maxhpfunc()
	love.graphics.printf(hp..'/'..maxhp,x,y,self.w,"right")
end
SimpleAttributeItem = Object:subclass('SimpleAttributeItem')
function SimpleAttributeItem:initialize(hpfunc,description,icon,w)
	self.hpfunc,self.description,self.icon = hpfunc,description,icon
	self.w = w
	self.h = 15
end
function SimpleAttributeItem:draw(x,y)
	if self.icon then love.graphics.draw(img['icontable.'..self.icon],x,y) end
	love.graphics.printf(self.description(),x+20,y,self.w,"left")
	love.graphics.printf(self.hpfunc(),x,y,self.w,"right")
end

DescriptionAttributeItem = Object:subclass('DescriptionAttributeItem')
function DescriptionAttributeItem:initialize(description,w,h)
	self.description = description
	self.w = w
	self.h = h
end


function DescriptionAttributeItem:draw(x,y)
	love.graphics.printf(self.description(),x,y,self.w,"left")
end

requireImage( 'assets/UI/attritubebackground.png','attritubebackground' )
local quads = {
	topleft = love.graphics.newQuad(0,0,10,10,40,40),
	topright = love.graphics.newQuad(30,0,10,10,40,40),
	botleft = love.graphics.newQuad(0,30,10,10,40,40),
	botright = love.graphics.newQuad(30,30,10,10,40,40),
	top = love.graphics.newQuad(10,0,1,10,40,40),
	bot = love.graphics.newQuad(10,30,1,10,40,40),
	left = love.graphics.newQuad(0,10,10,1,40,40),
	right = love.graphics.newQuad(30,10,10,1,40,40),
	mid = love.graphics.newQuad(10,10,1,1,40,40)
}
AttributeCollection = Object:subclass('AttributeCollection')

function AttributeCollection:initialize(w,h)
	self.w,self.h=w,h
	self.items = {}
end

local draws = {}
function drawcollections()
	for i,v in ipairs(draws) do
		v()
	end
	draws = {}
end

function AttributeCollection:draw(x,y)
	if x+self.w>love.graphics.getWidth() then
		x = x - self.w
	end
	if y+self.h>love.graphics.getHeight() then
		y = y - self.h
	end
	table.insert(draws,function()
		love.graphics.setFont(smallfont)
		love.graphics.drawq(img.attritubebackground,quads.topleft,x-10,y-10)
		love.graphics.drawq(img.attritubebackground,quads.topright,x+self.w,y-10)
		love.graphics.drawq(img.attritubebackground,quads.botleft,x-10,y+self.h)
		love.graphics.drawq(img.attritubebackground,quads.botright,x+self.w,y+self.h)
		love.graphics.drawq(img.attritubebackground,quads.top,x,y-10,0,self.w,1)
		love.graphics.drawq(img.attritubebackground,quads.bot,x,y+self.h,0,self.w,1)
		love.graphics.drawq(img.attritubebackground,quads.left,x-10,y,0,1,self.h)
		love.graphics.drawq(img.attritubebackground,quads.right,x+self.w,y,0,1,self.h)
		love.graphics.drawq(img.attritubebackground,quads.mid,x,y,0,self.w,self.h)
		local h = 0
		for i=1,#self.items do
			local v = self.items[i]
			v:draw(x,y+5*i+h)
			h = h+ v.h
		end
		love.graphics.setFont(f)
	end)
end	
function AttributeCollection:d_draw(x,y)
		if x+self.w>love.graphics.getWidth() then
			x = x - self.w
		end
		if y+self.h>love.graphics.getHeight() then
			y = y - self.h
		end
			love.graphics.setFont(smallfont)
			love.graphics.drawq(img.attritubebackground,quads.topleft,x-10,y-10)
			love.graphics.drawq(img.attritubebackground,quads.topright,x+self.w,y-10)
			love.graphics.drawq(img.attritubebackground,quads.botleft,x-10,y+self.h)
			love.graphics.drawq(img.attritubebackground,quads.botright,x+self.w,y+self.h)
			love.graphics.drawq(img.attritubebackground,quads.top,x,y-10,0,self.w,1)
			love.graphics.drawq(img.attritubebackground,quads.bot,x,y+self.h,0,self.w,1)
			love.graphics.drawq(img.attritubebackground,quads.left,x-10,y,0,1,self.h)
			love.graphics.drawq(img.attritubebackground,quads.right,x+self.w,y,0,1,self.h)
			love.graphics.drawq(img.attritubebackground,quads.mid,x,y,0,self.w,self.h)
			local h = 0
			for i=1,#self.items do
				local v = self.items[i]
				v:draw(x,y+5*i+h)
				h = h+ v.h
			end
			love.graphics.setFont(f)
	end

function AttributeCollection:addItem(item)
	table.insert(self.items,item)
	self.h = self.h+item.h+5
end

function AttributeCollection:removeItem(item)
end

function AttributeCollection:clear()
	self.items = {}
	self.h = 0
end