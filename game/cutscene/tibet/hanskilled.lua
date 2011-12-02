local c = Cutscene(18)
c.path = 'cutscene/granvilleisland/'

local armory_back = CutsceneObject(0,700,c:getCutsceneImage'armory_background.png',0,0)
armory_back.y = 0
armory_back.sx = 2
armory_back.sy = 2
armory_back:addTransformation(ObjectTransformation{
	prop = 'x',
	total = 50,
	vi = -176,
	vf = -76,
	delay = 0,
})
c:addObject(armory_back)

local brandon_stand = CutsceneObject(0,700,c:getCutsceneImage'brandon_stand.png',0,0)
brandon_stand.y = 300
brandon_stand.sx = 0.5
brandon_stand.x = 600
brandon_stand:addTransformation(ObjectTransformation{
	prop = 'x',
	total = 50,
	vi = 800,
	vf = -176,
	delay = 0,
})
c:addObject(brandon_stand)
local river_stand = CutsceneObject(0,1500,c:getCutsceneImage'river_stand.png',0,0)
river_stand.y = 300
river_stand.sx = 0.8
river_stand.x = 600
river_stand:addTransformation(ObjectTransformation{
	prop = 'x',
	total = 50,
	vi = 300,
	vf = 50,
	delay = 0,
})
c:addObject(river_stand)

return c