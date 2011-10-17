local c = Cutscene(18)
c.path = 'cutscene/waterfall/'
local a = CutsceneObject(0,10,c:getCutsceneImage'waterfall.png',0,0)
a.x = 0
a.y = 0
c:addObject(a)

local waterfall_back = CutsceneObject(0,7,c:getCutsceneImage'waterfall_back.png',0,0)
waterfall_back.y = 0
waterfall_back:addTransformation(ObjectTransformation{
	prop = 'x',
	total = 7,
	vi = -176,
	vf = 176,
	delay = 0,
})
c:addObject(waterfall_back)

local river_sit_back = CutsceneObject(0,7,c:getCutsceneImage'river_sit_back.png',0,0)
river_sit_back.y = 300
river_sit_back.sx = 0.5
river_sit_back.x = 600
river_sit_back:addTransformation(ObjectTransformation{
	prop = 'x',
	total = 7,
	vi = 450,
	vf = 176,
	delay = 0,
})
c:addObject(river_sit_back)


c:delta(7)

local a = CutsceneObject(0,3000,c:getCutsceneImage'waterfall_front.png',0,0)
a.x = 0
a.y = 0
c:addObject(a)

c.camera:addTransformation(ObjectTransformation{
	prop = 'y',
	total = 30,
	vi = -screen.halfheight,
	vf = -200,
	delay = 7,
})
local river_front = CutsceneObject(0,3000,c:getCutsceneImage'river_front.png',0,0)
--river_front.sx = 0.8

river_front.x = 400
river_front:addTransformation(ObjectTransformation{
	prop = 'y',
	total = 30,
	vi = 300,
	vf = -50,
})
c:addObject(river_front)

return c