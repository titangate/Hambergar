
local frametime = 0.16

MasterYuenAnimation = Object:subclass'MasterYuenAnimation'
function MasterYuenAnimation:playAnimation(animation,speed,loop)
	self.activeanim = animation or 'stand'
	self.speed = speed or 1
	self.loop = loop or false
	self.time = 0
end

function MasterYuenAnimation:resetAnimation()
	self:playAnimation(stand,1,true)
end


function MasterYuenAnimation:initialize(x,y,controller)
	self.activeanim = 'stand'
	self.anim = {
		stand = {
			myimg.fist.fist1,
		},
		fist = {
			myimg.fist.fist1,
			myimg.fist.fist1,
			myimg.fist.fist2,
			myimg.fist.fist3,
			myimg.fist.fist4,
			myimg.fist.fist5,
			myimg.fist.fist6,
			myimg.fist.fist5,
			myimg.fist.fist4,
			myimg.fist.fist7,
		},
		pray = {
			myimg.pray.pray
		},
		hold = {
			myimg.hold.hold1,
			myimg.hold.hold2,
			myimg.hold.hold3,
		},
		kick = {
		
			myimg.fist.fist1,
--			myimg.kick.kick2,
			myimg.kick.kick3,
			myimg.kick.kick3,
			myimg.kick.kick3,
		},
		crane = {
			myimg.fist.fist1,
			myimg.kick.kick2,
			myimg.kick.kick3,
			myimg.kick.kick3,
			myimg.kick.crane1,
			myimg.kick.crane1,
			myimg.kick.crane2,
			myimg.kick.crane3,
			myimg.kick.crane4,
			myimg.kick.crane10,
			myimg.kick.crane6,
			myimg.kick.crane5,
			myimg.kick.crane6,
		}
		
	}
	self.time = 0
	self.speed = 1
	self.loop = true
	self.sprite = self.anim.stand[1]
	self:resetAnimation()
end


function MasterYuenAnimation:draw(x,y,r)
	
	love.graphics.draw(self.sprite,x,y,r,0.7,0.7,80,80)
end

function MasterYuenAnimation:update(dt)
	self.time = self.time + dt * self.speed
	local frame = math.ceil(self.time / frametime)
	if self.loop then
		frame = frame % #self.anim[self.activeanim] + 1
	else
		frame = math.min(frame,#self.anim[self.activeanim])
	end
	self.sprite = self.anim[self.activeanim][frame]
	assert(self.sprite)
end


MasterYuenActor = Object:subclass'MasterYuenActor'
myimg = {
}

local function loadImage()
	local DIR_MASTERY = 'assets/mastery/'
	local dirs = love.filesystem.enumerate(DIR_MASTERY)
	for _,d in ipairs(dirs) do
		if love.filesystem.isDirectory(DIR_MASTERY..d) then
			local files = love.filesystem.enumerate(DIR_MASTERY..d)
			myimg[d] = {}
			for _,file in ipairs(files) do
				if string.sub(file,-4)=='.png' then
					requireImage(DIR_MASTERY..d..'/'..file,string.sub(file,1,-5),myimg[d])
				end
			end
		end
	end
	myimg.loaded = true
	
end


function MasterYuenActor:initialize()
	if not myimg.loaded then
		loadImage()
	end
	
	self.activeanim = 'stand'
	self.anim = {
		stand = {
			myimg.fist.fist1,
		},
		fist = {
			myimg.fist.fist1,
			myimg.fist.fist1,
			myimg.fist.fist2,
			myimg.fist.fist3,
			myimg.fist.fist4,
			myimg.fist.fist5,
			myimg.fist.fist6,
			myimg.fist.fist5,
			myimg.fist.fist4,
			myimg.fist.fist7,
		},
		pray = {
			myimg.pray.pray
		},
		hold = {
			myimg.hold.hold1,
			myimg.hold.hold2,
			myimg.hold.hold3,
		},
		kick = {
		
			myimg.fist.fist1,
--			myimg.kick.kick2,
			myimg.kick.kick3,
			myimg.kick.kick3,
			myimg.kick.kick3,
		},
		crane = {
			myimg.fist.fist1,
			myimg.kick.kick2,
			myimg.kick.kick3,
			myimg.kick.kick3,
			myimg.kick.crane1,
			myimg.kick.crane1,
			myimg.kick.crane2,
			myimg.kick.crane3,
			myimg.kick.crane4,
			myimg.kick.crane10,
			myimg.kick.crane6,
			myimg.kick.crane5,
			myimg.kick.crane6,
		},
		kneel = {
			myimg.pray.kneel
		}
		
	}
	self.shadow = {}
	self.time = 0
	self.speed = 1
	self.loop = true
	self.sprite = self.anim.stand[1]
end

function MasterYuenActor:playAnimation(animation,speed,loop)
	self.activeanim = animation or 'stand'
	self.speed = speed or 1
	self.loop = loop or false
	self.time = 0
end

function MasterYuenActor:reset()
	self:playAnimation(stand,1,true)
end

function MasterYuenActor:setEffect(effect)
--	self.time = 0
	self.effect = effect
	
end

function MasterYuenActor:update(dt)
	self.time = self.time + dt * self.speed
	local frame = math.ceil(self.time / frametime)
	if self.loop then
		frame = frame % #self.anim[self.activeanim] + 1
	else
		frame = math.min(frame,#self.anim[self.activeanim])
	end
	self.sprite = self.anim[self.activeanim][frame]
	assert(self.sprite)
end

function MasterYuenActor:draw(x,y,r)
	if self.effect == 'glow' then
		love.graphics.setColor(255,166,70,127)
		love.graphics.setPixelEffect(pixeleffect.singcolor)
		love.graphics.draw(self.sprite,x,y,r,0.8,0.8,80,80)
		love.graphics.setColor(0,0,0,255)
		love.graphics.draw(self.sprite,x,y,r,0.7,0.7,80,80)
		love.graphics.setPixelEffect()
	elseif self.effect == 'haze' then
		
		filtermanager:requestFilter('Heathaze',function()
		love.graphics.draw(self.sprite,x,y,r,0.7,0.7,80,80)
		end)
		love.graphics.draw(self.sprite,x,y,r,0.7,0.7,80,80)
	elseif self.effect == 'invis' then
		love.graphics.setColor(255,166,70,math.max(0,255-self.time * 255))
		love.graphics.draw(self.sprite,x,y,r,0.7+self.time,0.7+self.time,80,80)
	else
		
		love.graphics.draw(self.sprite,x,y,r,0.7,0.7,80,80)
	end
	love.graphics.setColor(255,255,255)
end

MantraActor = Object:subclass'MantraActor'

requireImage'assets/northvan/mantra1.png'
function MantraActor:initialize()
	self.time = 0
	self.level = 1
	self.on = false
	self.opacity = 255
end

function MantraActor:update(dt)
	self.time = self.time + dt
end

function MantraActor:setState(state)
	if state then
		map.anim:easy(self,'opacity',0,255,0.5)
	else
		map.anim:easy(self,'opacity',255,0,0.5)
	end
end

function MantraActor:draw(x,y)
	if self.opacity > 0 then
		love.graphics.setColor(255,255,255,self.opacity)
		if self.level > 0 then
			love.graphics.draw(img.mantra1,x,y,self.time,1,1,256,256)
			if self.level > 1 then
				love.graphics.draw(img.mantra2,x,y,-self.time,1,1,256,256)
			end
		end
		love.graphics.setColor(255,255,255)
	end
end

FireChainActor = Object:subclass'FireChainActor'
function FireChainActor:initialize(x,y,vx,vy,time)
	self.sx,self.sy = x,y
	self.vx,self.vy = vx,vy
	self.r = math.atan2(vy,vx)
	self.dt = 0
	self.time = time
	self.p = particlemanager.getsystem'fire'
	self.p:setLifetime(5)
	self.p:start()
end

function FireChainActor:update(dt)
	if self.dt>self.time then return end
	self.dt = self.dt + dt
	self.p:setPosition(self.sx+self.vx*self.dt,self.sy+self.vy*self.dt)
	self.p:update(dt)
	
end

function FireChainActor:draw()
	local g = requireImage('assets/swift/link.png')
	for i=1,math.ceil(self.dt/0.02) do
		love.graphics.draw(g,self.sx+self.vx*i*0.02,self.sy+self.vy*i*0.02,self.r,1,1,g:getWidth()/2,g:getHeight()/2)
	end
	love.graphics.draw(self.p)
end