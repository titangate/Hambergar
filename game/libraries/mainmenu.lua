mainmenubg = love.graphics.newImage('assets/mainmenu.png')

local grid = love.graphics.newImage("assets/mainmenu/grid.png")
local gradient = love.graphics.newImage("assets/mainmenu/gradient.png")
grid:setWrap("repeat","repeat")
local gridquad = love.graphics.newQuad(0,0,love.graphics.getWidth(),love.graphics.getHeight(),40,40)
MainMenu = {
	refreshdt = 1,
	refreshtime = 1,
	image = gameicon
}

function MainMenu:update(dt,bupdate)
	if self.refreshdt > 0 then
		self.refreshdt = self.refreshdt - dt
	end
end

function MainMenu:refreshWithImage(image)
	self.oldimage = self.image
	self.image = image
	self.refreshdt = 1
end

function MainMenu:draw()
	if self.refreshdt > 0 then
		if self.oldimage then love.graphics.draw(self.oldimage,80,150,0,0.5,0.5) end
		local progresspc = 1 - self.refreshdt / self.refreshtime
		local starty = progresspc*1.5*love.graphics.getHeight()
		love.graphics.setScissor(0,0,love.graphics.getWidth(),starty+40)
		love.graphics.drawq(grid,gridquad,0,0)
		love.graphics.draw(gradient,0,starty,0,love.graphics.getWidth(),1)
		love.graphics.setColor(0,0,0,255)
		love.graphics.rectangle('fill',0,0,3000,starty-400)
		love.graphics.draw(gradient,0,starty,math.pi,3000,10,0.5,0)
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(self.image,80,150,0,0.5,0.5)
		love.graphics.setScissor()
	else
		if self.oldimage ~= self.image then
			self.oldimage = self.image
		end
		love.graphics.draw(self.oldimage,80,150,0,0.5,0.5)
	end
	love.graphics.draw(mainmenubg,love.graphics.getWidth()/2,love.graphics.getHeight()/2,0,self.imagescale,self.imagescale,mainmenubg:getWidth()/2,mainmenubg:getHeight()/2)
	goo:draw()
end
