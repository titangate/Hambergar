
local c = Cutscene(18)
c.path = 'cutscene/waterfall/'
a = CutsceneObject(0,10,c:getCutsceneImage'waterfall.png',0,0)
a.x = 0
a.y = 0
c:addObject(a)

c.camera:addTransformation(ObjectTransformation{
	prop = 'x',
	total = 5,
	vi = -screen.halfwidth,
	vf = -screen.halfwidth+300,
})

local swift_side = CutsceneObject(0,10,c:getCutsceneImage'swift_side.png',0,0)
swift_side.sx = 0.5
swift_side.y = 200
swift_side.x = 100
swift_side:addTransformation(ObjectTransformation{
	prop = 'x',
	total = 1,
	vi = 100,
	vf = 150,
	delay = 2,
})
c:addObject(swift_side)

local assassin_side = CutsceneObject(0,10,c:getCutsceneImage'river_sit_side.png',0,0)
assassin_side.sx = 0.5
assassin_side.y = 250
assassin_side.x = 800
c:addObject(assassin_side)

c:delta(10)

c.camera:addTransformation(ObjectTransformation{
	prop = 'x',
	total = 100,
	delay = 10,
	vi = -screen.halfwidth,
	vf = 0,
})

local waterfall_back = CutsceneObject(0,1500,c:getCutsceneImage'waterfall_back.png',0,0)
waterfall_back.y = 0
waterfall_back:addTransformation(ObjectTransformation{
	prop = 'x',
	total = 7,
	vi = -176,
	vf = 176,
	delay = 0,
})
c:addObject(waterfall_back)

local river_sit_back = CutsceneObject(0,1500,c:getCutsceneImage'river_sit_back.png',0,0)
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
local swift_back = CutsceneObject(0,1500,c:getCutsceneImage'swift_back.png',0,0)
swift_back.y = 300
swift_back.sx = 0.8
swift_back.x = 600
swift_back:addTransformation(ObjectTransformation{
	prop = 'x',
	total = 7,
	vi = 300,
	vf = 50,
	delay = 0,
})
c:addObject(swift_back)

return c