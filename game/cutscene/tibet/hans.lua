local c = Cutscene(30)
c.path = 'cutscene/tibet/'

local pic1 = CutsceneObject(0,10,c:getCutsceneImage'hans1.png',0,0)
pic1.y = 0
pic1.sx = 1
pic1.sy = 1
pic1:addTransformation(ObjectTransformation{
	prop = 'y',
	total = 10,
	vi = -200,
	vf = 200,
	delay = 0,
})
c:addObject(pic1)

local pic2 = CutsceneObject(10,10,c:getCutsceneImage'hans2.png',0,0)
pic2.y = -300
pic2.sx = 1
pic2.sy = 1
pic2:addTransformation(ObjectTransformation{
	prop = 'x',
	total = 10,
	vi = 0,
	vf = -200,
	delay = 0,
})
c:addObject(pic2)


local pic3 = CutsceneObject(20,10,c:getCutsceneImage'hans3.png',0,0)
pic3.y = 0
pic3.sx = 1
pic3.sy = 1
pic3:addTransformation(ObjectTransformation{
	prop = 'y',
	total = 10,
	vi = 0,
	vf = -200,
	delay = 0,
})
c:addObject(pic3)
return c