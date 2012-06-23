CutsceneManager = Object:subclass'CutsceneManager'
function CutsceneManager:initialize()
	self.anim = require 'cutscene.anim.anim'
	self.objs = {}
	self.timers = {}
	self.camera = CutsceneCamera()
--	self:play(c,true)
	self.canvas = love.graphics.newCanvas(screen.width,screen.height)
	self.blurbufferh = love.graphics.newCanvas(screen.width,screen.height)
	self.intensity = 1
end

function CutsceneManager:clear()
	self.objs = {}
end

function CutsceneManager:update(dt)
	local r = {}
	for v,_ in pairs(self.objs) do
--		print (v.class)
		if v.update then
			v:update(dt)
			if v.frame <= 0 then
				table.insert(r,v)
			end
		end
	end
	for i,v in ipairs(r) do
		self.objs[v] = nil
	end
	for v,_ in pairs(self.timers) do
		v:update(dt)
	end
	
	self.anim:update(dt)
	
	if self.convtime then
		self.convtime = self.convtime - dt
		if self.convtime <= 0 then
			self.convtime = nil
			self.conv = nil
		end
	end
end

function CutsceneManager:focus(u,intensity,time)
	if not u then
		if not time or time == 0 then
			self.focus = nil
			return
		else
			self.focusu = self.focusu or 0
			self.anim:easy(self,'focusu',self.focusu,0,time)
			return
		end
	end
	if not self.focusu then
		self.focusu = u.layer
	else
		self.anim:easy(self,'focusu',self.focusu,u.layer,time)
	end
	self.focusintensity = intensity
	
end

function CutsceneManager:play(sequence,replay)
	if self.seq == sequence and not replay then return end
	self.seq = sequence
	Trigger(sequence):run(self)
end

local idcount = 0
local function __genOrderedIndex(t)
	local orderedIndex = {}
	for key in pairs(t) do
		table.insert(orderedIndex, key)
	end
	table.sort(orderedIndex,function(a,b) return a.layer < b.layer end)
	idcount = idcount + 1
	return orderedIndex
end

local function orderedNext(t,state)
	if state==nil then
		t.__orderedIndex = __genOrderedIndex(t)
		local key = t.__orderedIndex[1]
		return key, t[key]
	end
	key = nil
	for i = 1,table.getn(t.__orderedIndex) do
		if t.__orderedIndex[i] == state then
			key = t.__orderedIndex[i+1]
		end
	end

	if key then
		return key, t[key]
	end
	
	idcount = idcount - 1
	-- no more value to return, cleanup
	t.__orderedIndex = nil
end

local function orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end



function CutsceneManager:playConversation(conv,speaker,time)
	if type(speaker) == 'number' then
		time,speaker = speaker,time
	end
	self.speaker = speaker
	
	if speaker then
		self.conv = speaker..LocalizedString' : '..conv
	else
		self.conv = conv
	end
	if conv then
		self.convtime = time or 10000
	else
		self.convtime = 0.1
	end
end

function CutsceneManager:draw()
	love.graphics.push()
	self.camera:draw()
	love.graphics.setBackgroundColor(255,255,255,0)
	if next(self.objs) then
		
		for v,_ in orderedPairs(self.objs) do
			if v.draw and self.focusu and v.layer ~=self.focusu then
				pixeleffect.blur1:send("intensity",math.abs(v.layer-self.focusu)*self.intensity)
				pixeleffect.blur2:send("intensity",math.abs(v.layer-self.focusu)*self.intensity)
				self.canvas:clear()
				self.blurbufferh:clear()
				love.graphics.setCanvas(self.canvas)
				v:draw()
				pixeleffect.blur2:send("mask",img.dot)
				local blurbufferh = self.blurbufferh
				love.graphics.push()
				love.graphics.setCanvas(blurbufferh)
				love.graphics.setPixelEffect(pixeleffect.blur1)
				love.graphics.draw(self.canvas)
				love.graphics.pop()
				love.graphics.setCanvas()
				love.graphics.setPixelEffect(pixeleffect.blur2)
				love.graphics.draw(blurbufferh)
				love.graphics.setPixelEffect()
			elseif v.draw then
				v:draw()
			end
		end
	end
	love.graphics.pop()
	love.graphics.setFont(fonts.oldsans24)
	local v = self.conv
	if v and self.convtime then
		local font = love.graphics.getFont()
		love.graphics.setColor(0,0,0,220)
		local w,h = font:getWidth(v)+10,select(2,fontGetWrap(font,v,624))*font:getHeight()+10
		love.graphics.rectangle('fill',screen.halfwidth - w/2,screen.height - 105 ,w,h)
		love.graphics.setColor(255,255,255,225)
		pfn(v,200,screen.height - 100,624,'center')
	end
end

function CutsceneManager:keypressed(k)
	if k=='escape' and self.skip then
		self.skip()
	end
end

function CutsceneManager:addUnit(...)
	for k,unit in ipairs(arg) do
		self.objs[unit] = true
	end
end

function CutsceneManager:removeUnit(...)
	for k,unit in ipairs(arg) do
		self.objs[unit] = nil
	end
end


function CutsceneManager:addGameTimer(...)
	for k,unit in ipairs(arg) do
		self.timers[unit] = true
	end
end

function CutsceneManager:removeGameTimer(...)
	for k,unit in ipairs(arg) do
		self.timers[unit] = nil
	end
end


CutsceneObject = Object:subclass'CutsceneObject'
function CutsceneObject:initialize(frame,img,ox,oy,quad)
	assert(img)
	self.transformations = {}
--	self.begin = begin
	self.frame = frame
	self.img = img
	self.quad = quad
	self.ox,self.oy = ox or img:getWidth()/2,oy or img:getHeight()/2
	self.x,self.y = 0,0
end

function CutsceneObject:update(dt)
	self.frame = self.frame - dt
	if self.frame<=0 then
--		GetGameSystem():removeUnit(self)
	end
	
end

function CutsceneObject:draw(canvas)
	if self.invis then return end
	local r,g,b
	if self.color then
		r,g,b = unpack(self.color)
	else
		r,g,b = 255,255,255
	end
	
	if self.opacity then
		love.graphics.setColor(r,g,b,self.opacity)
	else
		love.graphics.setColor(r,g,b)
	end
	local img = canvas or self.img
	local r = self.r or 0
	if canvas then r = r + math.pi end
	if img then
		if self.quad then
			love.graphics.draw(img,self.quad,self.x,self.y,r,self.sx,self.sy,self.ox,self.oy)
		else
			love.graphics.draw(img,self.x,self.y,r,self.sx,self.sy,self.ox,self.oy)
		end
	else
		-- TODO
	end
	love.graphics.setColor(255,255,255)
	goo:draw()
end

function CutsceneObject:drawbase()
	love.graphics.draw(self.img,0,0,math.pi)
end

function CutsceneObject:fit(w,h)
	if w then
		self.sx = w/self.img:getWidth()
		if not h then
			self.sy = self.sx
		end
	end
	if h then
		self.sy = h/self.img:getHeight()
		if not w then
			self.sx = self.sy
		end
	end
end

CutsceneCamera = CutsceneObject:subclass('CutsceneCamera')
function CutsceneCamera:initialize()
	self.x,self.y = -screen.halfwidth,-screen.halfheight
	self.sx,self.sy = 1,1
	self.r = 0
	self.ox,self.oy = 0,0
	self.transformations = {}
end

function CutsceneCamera:draw()
	love.graphics.translate(self.x*self.sx,self.y*self.sy)
	love.graphics.scale(self.sx,self.sy)
	love.graphics.rotate(self.r)
	love.graphics.translate((self.ox+screen.halfwidth)/self.sx,(self.oy+screen.halfheight)/self.sy)
end