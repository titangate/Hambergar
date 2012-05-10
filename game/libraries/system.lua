

ImageLoader = Object:subclass('ImageLoader')
function ImageLoader:initialize()
	self.images={}
	self.loadingthread = love.thread.newThread('loadingthread','libraries/loadingthread.lua')
end

Loadscreen = {}
function Loadscreen:load()
	if currentsystem ~= self then
		pushsystem(self)
	end
end
function Loadscreen:update(dt)
	if #loadscreen>0 then
		self.name = table.remove(loadscreen)
		self.images[self.name] = love.image.newImageData(self.name)
	else
		popsystem()
	end
end
function Loadscreen:draw()
	love.graphics.printf(self.name)
end
loadable = {}
function ImageLoader:loaddata(name)
	if type(name)~='string' then return name end
	if not name then return end
	if not self.images[name] then
		self.images[name] = love.image.newImageData(name)
--		table.insert(loadable,name)
	end
	return self.images[name]
end
local il = ImageLoader:new()
lgn = love.graphics.newImage
function love.graphics.newImage(name)
	return lgn(il:loaddata(name))
end

img={}
function requireImage(path,label,t)
	local v = split(path,'/')
	v = v[#v]
	local f = v:gmatch("(%w+).(%w+)")
	local file,ext=f()
	
	label = label or file
	t = t or img
	t[label]=love.graphics.newImage(path)
end

Listener = Object:subclass('Listener')
function Listener:initialize()
	self.handlers = {}
	setmetatable(self.handlers,{__mode = 'v'})
	self.classifiedhandlers = {}
end

function Object:registerListener(listener)
	if not self.listeners then self.listeners = {} end
	self.listeners[listener]=true
end

function Object:unregisterListener(listener)
	if not self.listeners then self.listeners = {} end
	
	self.listeners[listener]=nil
end

function Object:notifyListeners(event)
	if not self.listeners then return end
	for listener,_ in pairs(self.listeners) do
		listener:notify(event)
	end
end

function Listener:register(handler)
	if handler.eventtype then
		self.classifiedhandlers[handler.eventtype] = self.classifiedhandlers[handler.eventtype] or {}
		self.classifiedhandlers[handler.eventtype][handler]=true
	else
		self.handlers[handler]=true
	end
end

function Listener:unregister(handler)
	if handler.eventtype then
		self.classifiedhandlers[handler.eventtype][handler]=false
	else
		self.handlers[handler]=false
	end
end

function Listener:notify(event)
	for k,v in pairs(self.handlers) do
		if v==false then
			self.handlers[k]=nil
		else k:handle(event) end
	end
	if event.type and self.classifiedhandlers[event.type] then
		for k,v in pairs(self.classifiedhandlers[event.type]) do
			if v==false then
				self.classifiedhandlers[event.type][k]=nil
			else k:handle(event) end
		end
	end
end

gamelistener = Listener:new()
--[[
staticImage = {}
function staticImage.loadImage(subfolder,file)
	if not staticImage[symbol] then
		staticImage[symbol] = 
end]]

--[[
   Save Table to File/Stringtable
   Load Table from File/Stringtable
   v 0.94
   
   Lua 5.1 compatible
   
   Userdata and indices of these are not saved
   Functions are saved via string.dump, so make sure it has no upvalues
   References are saved
   ----------------------------------------------------
   table.save( table [, filename] )
   
   Saves a table so it can be called via the table.load function again
   table must a object of type 'table'
   filename is optional, and may be a string representing a filename or true/1
   
   table.save( table )
      on success: returns a string representing the table (stringtable)
      (uses a string as buffer, ideal for smaller tables)
   table.save( table, true or 1 )
      on success: returns a string representing the table (stringtable)
      (uses io.tmpfile() as buffer, ideal for bigger tables)
   table.save( table, "filename" )
      on success: returns 1
      (saves the table to file "filename")
   on failure: returns as second argument an error msg
   ----------------------------------------------------
   table.load( filename or stringtable )
   
   Loads a table that has been saved via the table.save function
   
   on success: returns a previously saved table
   on failure: returns as second argument an error msg
   ----------------------------------------------------
   
   chillcode, http://lua-users.org/wiki/SaveTableToFile
   Licensed under the same terms as Lua itself.
]]--
do
   -- declare local variables
   --// exportstring( string )
   --// returns a "Lua" portable version of the string
   local function exportstring( s )
      s = string.format( "%q",s )
      -- to replace
      s = string.gsub( s,"\\\n","\\n" )
      s = string.gsub( s,"\r","\\r" )
      s = string.gsub( s,string.char(26),"\"..string.char(26)..\"" )
      return s
   end
--// The Save Function
function table.save(  tbl,filename )
   local charS,charE = "   ","\n"
   local file,err
   -- create a pseudo file that writes to a string and return the string
   if not filename then
      file =  { write = function( self,newstr ) self.str = self.str..newstr end, str = "" }
      charS,charE = "",""
   -- write table to tmpfile
   elseif filename == true or filename == 1 then
      charS,charE,file = "","",io.tmpfile()
   -- write table to file
   -- use io.open here rather than io.output, since in windows when clicking on a file opened with io.output will create an error
   else
      file,err = io.open( filename, "w" )
      if err then return _,err end
   end
   -- initiate variables for save procedure
   local tables,lookup = { tbl },{ [tbl] = 1 }
   file:write( "return {"..charE )
   for idx,t in ipairs( tables ) do
      if filename and filename ~= true and filename ~= 1 then
         file:write( "-- Table: {"..idx.."}"..charE )
      end
      file:write( "{"..charE )
      local thandled = {}
      for i,v in ipairs( t ) do
         thandled[i] = true
         -- escape functions and userdata
         if type( v ) ~= "userdata" then
            -- only handle value
            if type( v ) == "table" then
               if not lookup[v] then
                  table.insert( tables, v )
                  lookup[v] = #tables
               end
               file:write( charS.."{"..lookup[v].."},"..charE )
            elseif type( v ) == "function" then
               file:write( charS.."loadstring("..exportstring(string.dump( v )).."),"..charE )
            else
               local value =  ( type( v ) == "string" and exportstring( v ) ) or tostring( v )
               file:write(  charS..value..","..charE )
            end
         end
      end
      for i,v in pairs( t ) do
         -- escape functions and userdata
         if (not thandled[i]) and type( v ) ~= "userdata" then
            -- handle index
            if type( i ) == "table" then
               if not lookup[i] then
                  table.insert( tables,i )
                  lookup[i] = #tables
               end
               file:write( charS.."[{"..lookup[i].."}]=" )
            else
               local index = ( type( i ) == "string" and "["..exportstring( i ).."]" ) or string.format( "[%d]",i )
               file:write( charS..index.."=" )
            end
            -- handle value
            if type( v ) == "table" then
               if not lookup[v] then
                  table.insert( tables,v )
                  lookup[v] = #tables
               end
               file:write( "{"..lookup[v].."},"..charE )
            elseif type( v ) == "function" then
               file:write( "loadstring("..exportstring(string.dump( v )).."),"..charE )
            else
               local value =  ( type( v ) == "string" and exportstring( v ) ) or tostring( v )
               file:write( value..","..charE )
            end
         end
      end
      file:write( "},"..charE )
   end
   file:write( "}" )
   -- Return Values
   -- return stringtable from string
   if not filename then
      -- set marker for stringtable
      return file.str.."--|"
   -- return stringttable from file
   elseif filename == true or filename == 1 then
      file:seek ( "set" )
      -- no need to close file, it gets closed and removed automatically
      -- set marker for stringtable
      return file:read( "*a" ).."--|"
   -- close file and return 1
   else
      file:close()
      return 1
   end
end

--// The Load Function
function table.load( sfile )
   -- catch marker for stringtable
   if string.sub( sfile,-3,-1 ) == "--|" then
      tables,err = loadstring( sfile )
   else
      tables,err = loadfile( sfile )
   end
   if err then return _,err
   end
   tables = tables()
   for idx = 1,#tables do
      local tolinkv,tolinki = {},{}
      for i,v in pairs( tables[idx] ) do
         if type( v ) == "table" and tables[v[1]] then
            table.insert( tolinkv,{ i,tables[v[1]] } )
         end
         if type( i ) == "table" and tables[i[1]] then
            table.insert( tolinki,{ i,tables[i[1]] } )
         end
      end
      -- link values, first due to possible changes of indices
      for _,v in ipairs( tolinkv ) do
         tables[idx][v[1]] = v[2]
      end
      -- link indices
      for _,v in ipairs( tolinki ) do
         tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
      end
   end
   return tables[1]
end
-- close do
end

local loads = {}
loadingscreen = {}
function loadingscreen:update(dt)
	if #loads>0 then
		self.loadingfile = table.remove(loads)
		require (self.loadingfile)
	else
		popsystem()
		if self.finished then
			self.finished()
		end
	end
end

function loadingscreen:draw()
	love.graphics.print(self.loadingfile,screen.halfwidth,screen.halfheight)
end

local preloadlists = {}
function preloadlist(list)
	for k,v in pairs(list) do
		preloadlists[k] = preloadlists[k]or{} 
		for i,name in ipairs(v) do
			table.insert(preloadlists[k],name)
		end
	end
end

function preload(...)
	for k,name in ipairs(arg) do
		if preloadlists[name] then
			for i,v in ipairs(preloadlists[name]) do
				table.insert(loads,v)
			end
		end
	end
end

Trigger = Object:subclass('Trigger')
-- Each Trigger run on its on coroutine
function Trigger:initialize(action)
	if map.trigs then
		table.insert(map.trigs,self)
	end
	self.action=action
	self.handlers = {}
end
function Trigger:registerEventType(type)
	
	local handler = {
		eventtype=type,
		handle = function(handler,event)
			self:run(event)
		end
	}
	table.insert(self.handlers,handler)
	gamelistener:register(handler)
end
function Trigger:destroy()
	self.co=nil
	for k,handler in ipairs(self.handlers) do
		gamelistener:unregister(handler)
	end
end
function Trigger:close()
	self.closed = true
end
function Trigger:open()
	self.closed = nil
end
function Trigger:run(...)
	assert(self.action)
	if self.closed then return end
	self.co = coroutine.create(self.action)
	print (coroutine.resume(self.co,self,...))
end

function wait(time)
	local co=coroutine.running ()
	Timer:new(time,1,function()
		coroutine.resume(co)
	end,true,true)
	coroutine.yield()
end

function math.clamp(x,lower,upper)
	return math.min(math.max(x,lower),upper)
end

escaped = false
function cine_wait(time)
	if escaped then
		return
	else
		local co=coroutine.running ()
		Timer:new(time,1,function()
			coroutine.resume(co)
		end,true,true)
		coroutine.yield()
	end
end

function table.exist(t,i)
	for _,v in ipairs(t) do
		if v== i then return true end
	end
	return false
end
function split(s,re)
	local i1 = 1
	local ls = {}
	local append = table.insert
	if not re then re = '%s+' end
	if re == '' then return {s} end
	while true do
	local i2,i3 = s:find(re,i1)
	if not i2 then
	local last = s:sub(i1)
	if last ~= '' then append(ls,last) end
	if #ls == 1 and ls[1] == '' then
	return {}
	else
	return ls
	end
	end
	append(ls,s:sub(i1,i2-1))
	i1 = i3+1
	end
end

function gradientcolor(start,finish,step)
	assert(step>=2)
	step = step - 1
	local d = {}
	local r = {start}
	for i=1,#start do
		table.insert(d,(finish[i]-start[i])/step)
	end
	for i=1,step do
		local c = {}
		for j=1,#start do
			table.insert(c,start[j]+d[j]*i)
		end
		table.insert(r,c)
	end
	return r
end