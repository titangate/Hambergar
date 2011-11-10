goo.retryscreen = class ('goo retry screen',goo.object)

function goo.retryscreen:initialize(...)
	super.initialize(self,...)
	local p = love.graphics.newParticleSystem(img.part1, 1000)
	p:setEmissionRate(100)
	p:setSpeed(100, 100)
	p:setGravity(0)
	p:setSize(2, 1)
	p:setColor(0, 0, 0, 255, 0, 0, 0, 0)
	p:setPosition(0, 0)
	p:setLifetime(3600)
	p:setParticleLife(1)
	p:setDirection(0)
	p:setSpread(360)
	p:setRadialAcceleration(0)
	p:setTangentialAcceleration(250)
	p:start()
	table.insert(systems, p)
	self.p = p
	self.lx = 0
end

function goo.retryscreen:open()
	anim:easy(self,'lx',-100,screen.halfwidth,1,'quadInOut')
	anim:easy(self,'rx',screen.width+100,screen.halfwidth,1,'quadInOut')
end

function goo.retryscreen:close()
	anim:easy(self,'lx',screen.halfwidth,-100,1,'quadInOut')
	anim:easy(self,'rx',screen.halfwidth,screen.width+100,1,'quadInOut')
	
end

function goo.retryscreen:draw()
	for i = 0,math.ceil(screen.height/100) do
		love.graphics.draw(self.p,self.lx,i*100)
		love.graphics.draw(self.p,self.rx,i*100)
	end
	love.graphics.draw(self.style.imgLeft,self.lx,0,0,1,1,self.style.imgLeft:getWidth(),0)
	love.graphics.draw(self.style.imgRight,self.rx,0,0,1,1,0,0)
end

function goo.retryscreen:update(dt)
--	self.p:start()
	if self.lx<=-100 then
		self:destroy()
	end
	self.p:update(dt)
end

return goo.retryscreen