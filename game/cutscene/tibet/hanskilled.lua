local c = Cutscene(18)
c.path = 'cutscene/tibet/'

local pic1 = CutsceneObject(0,0,c:getCutsceneImage'hans1.png',0,0)
pic1.y = 0
pic1.sx = 2
pic1.sy = 2
pic1:addTransformation(ObjectTransformation{
	prop = 'y',
	total = 10,
	vi = -200,
	vf = 0,
	delay = 0,
})
c:addObject(pic1)


return c