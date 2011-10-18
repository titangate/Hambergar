local c = Cutscene(18)
c.path = 'cutscene/granvilleisland/'

local potion_back = CutsceneObject(0,700,c:getCutsceneImage'potion_background.png',0,0)
potion_back.y = 0
potion_back.sx = 2
potion_back.sy = 2
potion_back:addTransformation(ObjectTransformation{
	prop = 'x',
	total = 50,
	vi = -176,
	vf = -76,
	delay = 0,
})
c:addObject(potion_back)

local tom_stand = CutsceneObject(0,700,c:getCutsceneImage'tom_stand.png',0,0)
tom_stand.y = 300
tom_stand.sx = 0.5
tom_stand.x = 600
tom_stand:addTransformation(ObjectTransformation{
	prop = 'x',
	total = 50,
	vi = 800,
	vf = -176,
	delay = 0,
})
c:addObject(tom_stand)
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