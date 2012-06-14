local l
local function switchfonts(loc)
	local t = {
	eng = function()
		fonts = {}
		fonts.default24 = love.graphics.newFont(24)
		fonts.oldsans12 = love.graphics.newFont('oldsansblack.ttf', 12)
		fonts.oldsans20 = love.graphics.newFont('oldsansblack.ttf', 20)
		fonts.oldsans24 = love.graphics.newFont('oldsansblack.ttf', 24)
		fonts.oldsans32 = love.graphics.newFont('oldsansblack.ttf', 32)
		fonts.bigfont = love.graphics.newFont("awesome.ttf",25)
		fonts.midfont = love.graphics.newFont("awesome.ttf",19)
		fonts.smallfont = love.graphics.newFont("awesome.ttf",13)
		pfn = love.graphics.printf
		sfn = love.graphics.setFont
		
		function fontGetWrap(font,text,width)
			
				return font:getWrap(text,width)
		end
	end,
	chr = function()
		fonts = {}
		local f = 'heiti.ttf'
		fonts.default24 = love.graphics.newFont(24)
		fonts.oldsans12 = love.graphics.newFont(f, 12)
		fonts.oldsans20 = love.graphics.newFont(f, 20)
		fonts.oldsans24 = love.graphics.newFont(f, 24)
		fonts.oldsans32 = love.graphics.newFont(f, 32)
		fonts.bigfont = love.graphics.newFont(f,25)
		fonts.midfont = love.graphics.newFont(f,19)
		fonts.smallfont = love.graphics.newFont(f,13)
		local fontsizes = {
			[fonts.default24] = 24,
			[fonts.oldsans12] = 12,
			[fonts.oldsans20] = 20,
			[fonts.oldsans24] = 24,
			[fonts.oldsans32] = 32,
			[fonts.bigfont] = 25,
			[fonts.midfont] = 19,
			[fonts.smallfont] = 13,
		}
		local pf = love.graphics.printf
		local fw = 25
		pfn = function(text,x,y,limit,align)
			text = tostring(text)
			limit = limit or 9999999
			local f = love.graphics.getFont()
			if f:getWidth(text) <= limit then
				pf(text,x,y,limit,align)
			else
				local len = #text
				local lines = math.ceil(len/3/fw)
				local h = math.floor(limit/fw)
				for i=1,lines do
					pf(string.sub(text,(h*(i-1))*3+1,3*h*i),x,y+(i-1)*fw,999999,align)
				end
			end
		end
		local sf = love.graphics.setFont
		sfn = function(font)
			sf(font)
			fw = fontsizes[font]
			
		end
		function fontGetWrap(font,text,width)
			text = tostring(text)
			limit = limit or 9999999
			local f = font
			if f:getWidth(text) <= width then
				return f:getWrap(text,width)
			else
				local len = #text
				return width,math.ceil(len/3/fw)
			end
		end
	end,}
	t[loc]()
end

function setLocalization(loc)
	if loc == 'eng' then 
		function LocalizedString(str)
			return str
		end
	else
		print (loc)
		
		l = require('localization.'..loc)
		function LocalizedString(str)
			return l[str] or str
		end
	end
	switchfonts(loc)
end