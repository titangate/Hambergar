require 'objectlua.init'
Object = objectlua.Object

font = {
	defaultfont = nil
}

color = {
	defaultcolor = {255,255,255,255},
--	defaulttextcolor = {0,0,0,255}
}

function mouseDown(b)
	return love.mouse.isDown(b)
end

require 'ehui.widget'
require 'ehui.label'
require 'ehui.panel'
require 'ehui.button'
require 'ehui.slider'
require 'ehui.mainmenu'
UI = {}
function UI.demo()

--	EHGameMenu = Widget:new(0,0,love.graphics.getWidth(),love.graphics.getHeight())
	UI.base:addChild(b_MenuButton:new('LAUNCH GAME',512,300,512,40))
	UI.base:addChild(b_MenuButton:new('CREDITS',512,300,512,40))
	UI.base:addChild(b_MenuButton:new('EXIT GAME',512,300,512,40))
	UI.base.xMargin = 512
	UI.base.yMargin = 10
	UI.base:layout('vertical')
--	UI.base = EHGameMenu
end
function UI.load()
	UI.base = Widget:new(0,0,love.graphics.getWidth(),love.graphics.getHeight())
	UI.demo()
end
function UI.draw()
	UI.base:draw(0,0)
end
function UI.update(dt,x,y)
	UI.mouseover = nil
	UI.base:update(dt,x,y)
	UI.mouseover = UI.top or UI.mouseover
end
function UI.mousepressed(x,y,k)
	if UI.mouseover then
		local dx,dy = UI.mouseover:getAboslutePosition(UI.mouseover)
		UI.mouseover:mousepressed(x-dx,y-dy,k)
	end
end
function UI.mousereleased(x,y,k)
	if UI.mouseover then
		local dx,dy = UI.mouseover:getAboslutePosition(UI.mouseover)
		UI.mouseover:mousereleased(x-dx,y-dy,k)
	end
end