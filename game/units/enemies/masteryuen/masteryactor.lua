MasterYuenActor = Object:subclass'MasterYuenActor'
local myimg = {
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

local frametime = 0.16

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
	}
	
	self.time = 0
	self.speed = 1
	self.loop = true
	self.sprite = self.anim.stand[1]
end

function MasterYuenActor:playAnimation(animation,speed,loop)
	self.activeanim = animation or 'stand'
	self.speed = speed or 1
	self.loop = loop or true
end

function MasterYuenActor:reset()
	self:playAnimation(stand,1,true)
end

function MasterYuenActor:setEffect()
end

function MasterYuenActor:update(dt)
	self.time = self.time + dt
	local frame = math.ceil(self.time / frametime)
	if self.loop then
		frame = frame % #self.anim[self.activeanim] + 1
	else
		frame = math.max(frame,#self.anim[self.activeanim])
	end
	self.sprite = self.anim[self.activeanim][frame]
	assert(self.sprite)
end

function MasterYuenActor:draw(x,y,r)
	love.graphics.draw(self.sprite,x,y,r,0.7,0.7,80,80)
end