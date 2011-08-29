
setfenv(1,{Object=Object,math=math,love=love,table=table,ipairs=ipairs,next=next,pairs=pairs,type=type,pulse=pulse,unpack=unpack})
function getPulse()
	local p = love.graphics.newParticleSystem(img.pulse,1024)
	p:setEmissionRate(100)
	p:setGravity(0)
	p:setSize(0.25, 0.05)
	p:setColor(0, 255, 0, 255, 0, 255, 0, 0)
	p:setLifetime(1)
	p:setParticleLife(1)
	p:start()
	return p
end
scale = 15
backgroundcolor = {0,0,0,255}
foregroundcolor = {0,255,0,255}
local chips = {}
Chip = Object:subclass('Chip')
function Chip:initialize(x,y,w,h)
	self.x,self.y,self.w,self.h = x,y,w,h
	self.wire = {length = 0}
	table.insert(chips,self)
	self.systems = {}
end

function Chip:update(dt)
	if self.activatetime then
		self.activatetime = self.activatetime - dt
		for k,v in pairs(self.wire) do
			if type(v)=='table' then
				for k,v2 in pairs(v) do
					local x,y = getInterpoint(v2,self.activatetime)
					self.systems[v2]:setPosition(x*scale,y*scale)
				end
			end
		end
		if self.activatetime <=0 then
			self.activatetime = nil
			
		end
	end
	if next(self.systems) then
		for k,sys in pairs(self.systems) do
			if sys:isEmpty() and not self.activatetime then
				self.systems = {}
				return
			end
			sys:update(dt)
		end
	end
end

function Chip:activate()
	self.activatetime = 1
	self.systems = {}
	for k,v in pairs(self.wire) do
		if type(v)=='table' then
			for k,v2 in pairs(v) do
				self.systems[v2]=getPulse()
			end
		end
	end
end

function getInterpoint(list,fraction)
	local c1 = list[math.floor(fraction*#list)]
	local c2 = list[math.ceil(fraction*#list)]
	c1 = c1 or c2
	c2 = c2 or c1
	if not c1 then return 0,0 end
	local x1,y1 = unpack(c1)
	local x2,y2 = unpack(c2)
	local x = x1+(x2-x1)*(fraction*#list-math.floor(fraction*#list))
	local y = y1+(y2-y1)*(fraction*#list-math.floor(fraction*#list))
	return x,y
end

function Chip:draw()
	love.graphics.setColor(backgroundcolor)
	love.graphics.rectangle('fill',self.x*scale,self.y*scale,self.w*scale,self.h*scale)
	love.graphics.setColor(foregroundcolor)
	love.graphics.rectangle('line',self.x*scale,self.y*scale,self.w*scale,self.h*scale)
	
	for k,v in pairs(self.wire) do
		if type(v)=='table' then
			for k,v2 in pairs(v) do
				for i=2,#v2 do
					love.graphics.line(v2[i-1][1]*scale,v2[i-1][2]*scale,v2[i][1]*scale,v2[i][2]*scale)
				end
			end
		end
	end
	for i,v in pairs(self.systems) do
		love.graphics.draw(v)
	end
end

function Chip:connect(b,path)
	self.wire[b] = self.wire[b] or {}
	self.wire.length = math.max(self.wire.length,#path)
 	table.insert(self.wire[b],path)
end

chip1=Chip:new(20,1,32,5)
chip2=Chip:new(10,1,7,5)
chip3=Chip:new(31,8,11,6)
chip4=Chip:new(30,28,12,7)
chip5=Chip:new(16,9,10,9)
chip6=Chip:new(48,8,9,9)
chip7=Chip:new(8,28,5,5)
chip8=Chip:new(48,22,9,6)
chip9=Chip:new(8,8,3,3)
chip10=Chip:new(8,12,3,3)
chip11=Chip:new(8,16,3,3)
chip12=Chip:new(60,22,3,3)
chip13=Chip:new(60,26,3,3)
chip14=Chip:new(60,30,3,3)
chip15=Chip:new(24,34,3,3)
chip16=Chip:new(45,34,3,3)
chip3:connect(chip4,{{36,28},{36,27},{36,26},{36,25},{36,24},{36,23},{36,22},{36,21},{36,20},{36,19},{36,18},{36,17},{36,16},{36,15},{36,14},})
chip4:connect(chip15,{{27,35},{28,35},{29,35},{30,35},})
chip4:connect(chip15,{{27,34},{26,33},{25,33},{24,33},{23,34},{23,35},{23,36},{23,37},{24,38},{25,38},{26,38},{27,38},{28,37},{29,36},{30,36},{31,35},})
chip4:connect(chip16,{{45,35},{44,35},{43,35},{42,35},})
chip4:connect(chip16,{{45,34},{46,33},{47,33},{48,33},{49,34},{49,35},{49,36},{49,37},{48,38},{47,38},{46,38},{45,38},{44,37},{43,36},{42,36},{41,35},})
chip4:connect(chip16,{{46,34},{45,33},{44,34},{43,34},{42,34},})
chip4:connect(chip16,{{45,36},{44,36},{43,37},{42,37},{41,36},{40,35},})
chip8:connect(chip12,{{60,23},{59,23},{58,23},{57,23},})
chip8:connect(chip13,{{60,28},{59,28},{58,28},{57,28},})
chip8:connect(chip14,{{60,30},{59,30},{58,30},{57,29},{56,28},})
chip5:connect(chip7,{{13,28},{13,27},{13,26},{13,25},{13,24},{13,23},{13,22},{13,21},{14,20},{15,19},{16,18},})
chip4:connect(chip7,{{13,30},{14,30},{15,30},{16,30},{17,30},{18,30},{19,30},{20,30},{21,30},{22,30},{23,30},{24,30},{25,30},{26,30},{27,30},{28,30},{29,30},{30,30},})
chip8:connect(chip7,{{12,28},{11,27},{10,27},{9,27},{8,27},{7,28},{7,29},{7,30},{7,31},{7,32},{7,33},{8,34},{9,34},{10,34},{11,34},{12,34},{13,34},{14,34},{15,34},{16,34},{17,34},{18,34},{19,34},{20,35},{21,36},{22,37},{23,38},{24,39},{25,39},{26,39},{27,39},{28,39},{29,39},{30,39},{31,39},{32,39},{33,39},{34,39},{35,39},{36,39},{37,39},{38,39},{39,39},{40,39},{41,39},{42,39},{43,39},{44,39},{45,39},{46,39},{47,39},{48,39},{49,38},{50,37},{50,36},{50,35},{50,34},{50,33},{50,32},{49,31},{48,30},{48,29},{48,28},})
chip5:connect(chip7,{{13,29},{14,28},{14,27},{14,26},{14,25},{14,24},{14,23},{14,22},{14,21},{15,20},{16,19},{17,18},})
chip4:connect(chip7,{{13,31},{14,31},{15,31},{16,31},{17,31},{18,31},{19,31},{20,31},{21,31},{22,31},{23,31},{24,31},{25,31},{26,31},{27,31},{28,31},{29,31},{30,31},})
chip1:connect(chip3,{{36,8},{36,7},{36,6},})
chip1:connect(chip3,{{37,8},{37,7},{37,6},})
chip1:connect(chip3,{{35,8},{35,7},{35,6},})
chip1:connect(chip3,{{38,8},{38,7},{38,6},})
chip1:connect(chip3,{{34,8},{34,7},{34,6},})
chip1:connect(chip3,{{39,8},{39,7},{39,6},})
chip1:connect(chip3,{{33,8},{33,7},{33,6},})
chip1:connect(chip3,{{40,8},{40,7},{40,6},})
chip1:connect(chip3,{{32,8},{32,7},{32,6},})
chip1:connect(chip3,{{41,8},{41,7},{41,6},})
chip1:connect(chip2,{{17,3},{18,3},{19,3},{20,3},})
chip1:connect(chip2,{{17,4},{18,4},{19,4},{20,4},})
chip1:connect(chip2,{{17,2},{18,2},{19,2},{20,2},})
chip1:connect(chip5,{{20,9},{20,8},{20,7},{20,6},})
chip1:connect(chip5,{{21,9},{21,8},{21,7},{21,6},})
chip1:connect(chip5,{{22,9},{22,8},{22,7},{22,6},})
chip1:connect(chip5,{{19,9},{19,8},{19,7},{19,6},{20,5},})
chip5:connect(chip9,{{11,9},{12,9},{13,9},{14,9},{15,9},{16,9},})
chip5:connect(chip9,{{11,10},{12,10},{13,10},{14,10},{15,10},{16,10},})
chip5:connect(chip10,{{11,13},{12,13},{13,13},{14,13},{15,13},{16,13},})
chip5:connect(chip10,{{11,14},{12,14},{13,14},{14,14},{15,14},{16,14},})
chip5:connect(chip11,{{11,17},{12,17},{13,17},{14,17},{15,17},{16,17},})
chip5:connect(chip11,{{11,16},{12,16},{13,16},{14,16},{15,16},{16,16},})
chip1:connect(chip6,{{52,8},{52,7},{52,6},})
chip1:connect(chip6,{{51,8},{51,7},{51,6},})
chip1:connect(chip6,{{53,8},{53,7},{53,6},{52,5},})
chip1:connect(chip6,{{50,8},{50,7},{50,6},})
chip1:connect(chip6,{{54,8},{54,7},{54,6},{53,5},{52,4},})
chip1:connect(chip6,{{49,8},{49,7},{49,6},})
chip6:connect(chip8,{{52,22},{52,21},{52,20},{52,19},{52,18},{52,17},})
chip6:connect(chip8,{{53,22},{53,21},{53,20},{53,19},{53,18},{53,17},})
chip6:connect(chip8,{{51,22},{51,21},{51,20},{51,19},{51,18},{51,17},})
chip6:connect(chip8,{{54,22},{54,21},{54,20},{54,19},{54,18},{54,17},})
chip6:connect(chip8,{{50,22},{50,21},{50,20},{50,19},{50,18},{50,17},})
chip6:connect(chip8,{{55,22},{55,21},{55,20},{55,19},{55,18},{55,17},})

local chiptable = {
	battery=chip1,
	drain=chip2,
	transmittertop=chip3,
	transmitterbot=chip4,
	cpu=chip5,
	pulser=chip6,
	prism=chip7,
	ionicpool=chip8,
	cpu1=chip9,
	cpu2=chip10,
	cpu3=chip11,
	ionicpool1=chip12,
	ionicpool2=chip13,
	ionicpool3=chip14,
	transmitter1=chip15,
	transmitter2=chip16,
}

function chiptable:update(dt)
	for k,v in ipairs(chips) do
		v:update(dt)
	end
end

function chiptable:draw()
--love.graphics.scale(15,15)
	for k,v in ipairs(chips) do
		v:draw()
	end
end
return chiptable