requireImage( 'assets/mainmenu/credits.png','credits' )
requireImage( 'assets/mainmenu/menutop.png','menutop' )

requireImage( "assets/mainmenu/grid.png",'grid' )
requireImage( "assets/mainmenu/gradient.png",'gradient' )
img.grid:setWrap("repeat","repeat")
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
	love.graphics.setBackgroundColor(0,0,0)
	love.graphics.clear()
	if self.refreshdt > 0 then
		if self.oldimage then love.graphics.draw(self.oldimage,80,150,0,0.5,0.5) end
		local progresspc = 1 - self.refreshdt / self.refreshtime
		local starty = progresspc*1.5*love.graphics.getHeight()
		love.graphics.setScissor(0,0,love.graphics.getWidth(),starty+40)
		love.graphics.drawq(img.grid,gridquad,0,0)
		love.graphics.draw(img.gradient,0,starty,0,love.graphics.getWidth(),1)
		love.graphics.setColor(0,0,0,255)
		love.graphics.rectangle('fill',0,0,3000,starty-400)
		love.graphics.draw(img.gradient,0,starty,math.pi,3000,10,0.5,0)
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(self.image,80,150,0,0.5,0.5)
		love.graphics.setScissor()
	else
		if self.oldimage ~= self.image then
			self.oldimage = self.image
		end
		love.graphics.draw(self.oldimage,80,150,0,0.5,0.5)
	end
	love.graphics.draw(img.credits,screen.width-img.credits:getWidth()-10,screen.height-img.credits:getHeight()-10)
	love.graphics.draw(img.menutop,screen.width-img.menutop:getWidth()-10,80)
	goo:draw()
end
