FilterManager = Object:subclass'FilterManager'
function FilterManager:initialize()
	self.filter = {}
	self.filterindex = {}
	self.filterrequest = {}
	self.canvas = {}
	self.canvascount = 0
end

function FilterManager:loadFilters(path)
	local files = love.filesystem.enumerate(path)
	for i,v in ipairs(files) do
		local file = path..v
		if love.filesystem.isFile(file) then
			if string.sub(file,-4)=='.lua' then
				local c = love.filesystem.load(file)()
				self:addFilter(c.name,c())
			end
		end
	end
end

function FilterManager:requestCanvas(w,h)
	for c,status in pairs(self.canvas) do
		if status ~= true then
			local canvas,_w,_h = unpack(c)
			if w==_w and h==_h then
				self.canvas[c] = true
				return canvas
			end
		end
	end
	local c = {love.graphics.newCanvas(w,h),w,h}
	self.canvascount = self.canvascount + 1
	self.canvas[c] = true
	return c[1]
end

function FilterManager:releaseCanvasExcept(except)
	for c,status in pairs(self.canvas) do
		if status == true then
			local canvas,_w,_h = unpack(c)
			if canvas~=except then
				self.canvas[c] = false
			end
		end
	end
end

function FilterManager:addFilter(name,filter)
	assert(name)
	assert(filter:isKindOf(Filter))
	if filter.reset then filter:reset() end
	self.filter[name] = filter
	for i,v in ipairs(self.filterindex) do
		if filter.priority > self.filter[v].priority then
			table.insert(self.filterindex,i,name)
			return
		end
	end
	table.insert(self.filterindex,name)
end

function FilterManager:removeFilter(name)
	assert(name)
	local f = self.filter[name]
	if not f then return end
	
	for i,v in ipairs(self.filterindex) do
		if f==v then
			table.remove(self.filterindex,i)
		end
	end
	
	self.filter[name] = nil
end

function FilterManager:setFilterArguments(name,...)
	if not self.filter[name] then return end
	self.filter[name]:setArguments(...)
end

function FilterManager:requestFilter(name,maskfunction)
	if not maskfunction then
		self.filterrequest[name] = true
	elseif self.filterrequest[name] ~= true then
		if self.filterrequest[name] == nil then
			self.filterrequest[name] = {}
		end
		table.insert(self.filterrequest,maskfunction)
	end
end

function FilterManager:update(dt)
	
	for c,status in pairs(self.canvas) do
		c[1]:clear()
	end
	for _,name in ipairs(self.filterindex) do
		self.filter[name]:update(dt)
	end
	DBGMSG('Canvas count: '..tostring(self.canvascount))
end

function FilterManager:reset()
	for _,name in ipairs(self.filterindex) do
		if self.filter[name].reset then
			self.filter[name]:reset()
		end
	end
end


function FilterManager:draw(drawfunc)
	local length = math.max(screen.w,screen.h)
	local c = self:requestCanvas(length,length)
	love.graphics.setCanvas(c)
	drawfunc()
	for _,name in ipairs(self.filterindex) do
		local request = self.filterrequest[name]
		if request == true then
			c = self.filter[name]:draw(c,function(w,h) return self:requestCanvas(w,h) end)
		-- TODO: masked
		end
		self:releaseCanvasExcept(c)
	end
	love.graphics.setCanvas()
	love.graphics.draw(c)
	self:releaseCanvasExcept()
	self.filterrequest = {}
end
