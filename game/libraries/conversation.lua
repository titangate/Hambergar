local conversationpanel
function PlayConversation(image,talker,message,time)
	if not conversationpanel then
		conversationpanel = goo.conversation:new()
		
	end
end

AnimationGoal = Object:subclass('AnimationGoal')
function AnimationGoal:initialize(time)
	self.time = 0
	self.totaltime = time
	self.z = 0
end
function AnimationGoal:update(dt)
	self.time = self.time + dt
	if self.time >= self.totaltime then
		return STATE_SUCCESS,dt
	end
end
FadeOut = AnimationGoal:subclass('FadeOut')
function FadeOut:initialize(type,image,color,time)
	super.initialize(self,time)
	self.type = type
	self.color = color
	self.destalpha = self.color[4] or 255
	self.image = image
	if image then
		self.sx,self.sy = love.graphics.getWidth()/image:getWidth(),love.graphics.getHeight()/image:getHeight()
	end
	self.z = 100
end

function FadeOut:draw()
	if self.type == 'fadein' then
		self.color[4] = (1-self.time/self.totaltime)*self.destalpha
	elseif self.type == 'fadeout' then
		self.color[4] = (self.time/self.totaltime)*self.destalpha
	end
	love.graphics.setColor(unpack(self.color))
	if self.image then
		love.graphics.draw(self.image,0,0,0,self.sx,self.sy)
	else
		love.graphics.rectangle('fill',0,0,love.graphics.getWidth(),love.graphics.getHeight())
	end	
		love.graphics.setColor(255,255,255,255)
end

CutSceneSequence = Object:subclass('CutSceneSequence')

function CutSceneSequence:initialize()
	self.goals = {}
	self.time = 0
	self.dt = 0
end

function CutSceneSequence:destroy()
	self:reset()
end

function CutSceneSequence:reset()
	self.dt = 0
end

function CutSceneSequence:update(dt)
	self.dt = self.dt + dt
	-- iterate through goals
	-- process the active goal
	for v,t in pairs(self.goals) do
		if t <= self.dt then
			local status, used = v:update(dt)
			if status == STATE_ACTIVE then
			--	return STATE_ACTIVE, used
			elseif status == STATE_FAIL then
			--	return STATE_FAIL, used	
				self.goals[v] = nil
			elseif status == STATE_SUCCESS or status == STATE_FAIL then
				-- move to the next goal
				self.goals[v] = nil
			end
		end
	end
	--if dt == used then
	return STATE_ACTIVE, used
	--end
	--return self:process(dt-used,owner)
end


ExecFunction = AnimationGoal:subclass('ExecFunction')
function ExecFunction:initialize(func)
	self.func = func
end
function ExecFunction:update(dt)
	self.func()
	return STATE_SUCCESS
end

function CutSceneSequence:push(goal,time)
	assert(goal)
	self.goals[goal]=time+self.time
end

function CutSceneSequence:wait(time)
	self.time = self.time + time
end

function CutSceneSequence:clear()
	self:reset()
	self.goals={}
end

function CutSceneSequence:draw()
	local draws = {}
	for v,t in pairs(self.goals) do
		if t<=self.dt then table.insert(draws,v) end
	end
	table.sort(draws, function(a,b) return a.z<b.z end)
	for i,v in ipairs(draws) do
		if v.draw then
			v:draw()
		end
	end
end