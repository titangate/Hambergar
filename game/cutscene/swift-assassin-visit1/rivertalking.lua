
local c = Cutscene(30)
c.path = 'cutscene/swift-assassin-visit1/'
a = CutsceneObject(0,30,c:getCutsceneImage'waterfall_front.png',0,0)
a.x = 0
a.y = 0
c:addObject(a)

c.camera:addTransformation(ObjectTransformation{
	prop = 'y',
	total = 30,
	vi = -screen.halfheight,
	vf = -200,
})

local river_front = CutsceneObject(0,30,c:getCutsceneImage'river_front.png',0,0)
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