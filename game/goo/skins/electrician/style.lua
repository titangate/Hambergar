-- Filename: goo.lua
-- Author: Luke Perkin
-- Date: 2010-02-26
-- Returns Style, Fonts.

-- How to use:
-- Each table reperesent a style sheet for a gui object.
-- Think of it like CSS. Colors are reperesented by RGBA tables.
-- If you specify an alpha value that property will not inherit its
-- parent's opacity.
-- use goo.skin to point to the current skin directory.

local style = {}
--[[
img.attritubebackground = love.graphics.newImage(GOO_SKINPATH .. 'attritubebackground.png')
img.conversationbg = love.graphics.newImage(GOO_SKINPATH .. 'conversationbg.png')
img.batteryimg = love.graphics.newImage(GOO_SKINPATH .. 'batteryimg.png')
img.cpu = love.graphics.newImage(GOO_SKINPATH .. 'cpu.png')
img.levelimg = love.graphics.newImage(GOO_SKINPATH .. 'electricianlevel.png')]]

local levelquad = love.graphics.newQuad(0,0,24,24,48,24)
function drawSkillLevel(x,y,current,max)
	levelquad:setViewport(0,0,24,24)
	for i=1,current do
		love.graphics.drawq(img.levelimg,levelquad,x+i*12-12,y)
	end
	if max then
		levelquad:setViewport(24,0,24,24)
		for i=current+1,max do
			love.graphics.drawq(img.levelimg,levelquad,x+i*12-12,y)
		end
	end
end


function drawDrainLevel(x,y,current,max)
	levelquad:setViewport(0,0,24,24)
	for i=1,current do
		love.graphics.drawq(img.levelimg,levelquad,x+i*12-12,y)
	end
	if max then
		levelquad:setViewport(24,0,24,24)
		for i=current+1,max do
			love.graphics.drawq(img.levelimg,levelquad,x+i*12-12,y)
		end
	end
end


style['goo list'] = {
	vertSpacing = 5,
}
style['goo list container'] = {
	
}
style['goo inventory'] = {
	
}

style['goo itembutton'] = {
	descriptionFont = fonts.oldsans12,
	titleFont = fonts.oldsans24
}


style['goo panel'] = {
	backgroundColor = {255,255,255},
	borderColor = {255,255,255},
	titleColor = {130,130,130},
	titleFont = fonts.oldsans12,
	seperatorColor = {100,100,100}
}

style['goo skillbutton'] = {
	textColor = {255,255,255},
	yMargin = -43,
	textFont = fonts.oldsans20,
}
style['goo learnbutton'] = {
	textColor = {0,0,0},
	textFont = fonts.midfont,
}
style['goo bottompanel'] = {
	xMargin = 50,
	yMargin = 100,
}

style['goo itempanel'] =
{
	backgroundColor = {255,255,255},
	titleColor = {255,255,255},
	titleFont = fonts.oldsans20,
	titleHeight = 30,
}

style['eh panel'] = {
	backgroundColor = {255,255,255},
	titleColor = {255,255,255},
	titleFont = fonts.oldsans24,
}

style['goo menuitem'] = {
	textColor = {255,255,255},
	textColorHover = {255,255,255},
	textFont = fonts.bigfont
}

style['goo close button'] = {
	color = {255,255,255},
	colorHover = {255,0,0}
}

style['goo button'] = {
	backgroundColor = {100,100,100},
	backgroundColorHover = {131,203,21},
	borderColor = {0,0,0,255},
	borderColorHover = {0,0,0},
	textColor = {255,255,255},
	textColorHover = {255,255,255},
	textFont = fonts.oldsans12
}

style['goo big button'] = {
	buttonColor = {255,255,255,255},
	buttonColorHover = {200,150,255,255},
	textColor = {0,0,0,255},
	textColorHover = {0,0,0,255},
	font = {'oldsansblack.ttf', 12}
}

style['goo text input'] = {
	borderColor = {0,0,0},
	backgroundColor = {255,255,255},
	textColor = {0,0,0},
	cursorColor = {0,0,0},
	cursorWidth = 2,
	borderWidth = 2,
	textFont = fonts.oldsans12,
	blinkRate = 0.5,
	leading = 12
}

style['goo progressbar'] = {
	backgroundColor = {255,255,255},
	fillMode		= 'fill'
}

style['goo image'] = {
	imageTint = {255,255,255}
}

style['goo imagelabel'] = {
	imageTint = {255,255,255},
	textFont = fonts.oldsans12,
	textColor = {255,255,255}
}

style['goo debug'] = {
	backgroundColor = {0,0,0,170},
	textColor = {255,255,255,255},
	textFont = fonts.oldsans12
}

style['goo DWSText'] = {
	textColor = {0,0,0,255},
	textFont = fonts.bigfont
}

style['goo DWSPanel'] = {
}

style['goo conversation panel'] = {
	textFont = fonts.oldsans12,
	speakerFont = fonts.oldsans24
}

return style, fonts

