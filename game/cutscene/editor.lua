require 'MiddleClass'
local editor = {}
local objectpanel,camerapanel,transformationpanel,transformationlistpanel,timelinepanel
function editor.selectObject(obj)
	objectpanel:select(obj)
	transformationlistpanel:select(obj)
end
function editor.load()
	objectpanel = goo.panel()
	objectpanel:setPos(10,10)
	objectpanel:setSize(200,200)
	objectpanel:setTitle('Object Panel')
	objectpanel.props = {}
	local props = {
		x = {prop='x',
		vi = -1024,
		vf = 1024},
		y = {prop='y',
		vi = -600,
		vf = 600},
		r = {prop='r',
		vi = 0,
		vf = math.pi*2},
		sx = {prop='sx',
		vi = 0,
		vf = 10},
		sy = {prop='sy',
		vi = 0,
		vf = 10},
		start = {prop='start',
		vi = 0,
		vf = 120},
		life = {prop='life',
		vi = 0,
		vf = 120},
		ox = {prop='ox',
		vi = 0,
		vf = 500},
		oy = {prop='oy',
		vi = 0,
		vf = 500},
		
	}
	for i,v in ipairs{'x','y','r','sx','sy','start','life','ox','oy'} do
		local pg = goo.prop(objectpanel)
		pg:setPos(0,i*20)
		pg:setProp(props[v])
		table.insert(objectpanel.props,pg)
	end
	
	objectpanel.select = function(self,obj)
		for i,v in ipairs(self.props) do
			v:setObject(obj)
		end
	end
	
	-- a list of transformation
	transformationlistpanel = goo.panel()
	transformationlistpanel:setSize(200,200)
	transformationlistpanel.buttons = {}
	transformationlistpanel:setTitle('Transformation List')
	transformationlistpanel.select = function(self,obj)
		for i,v in ipairs(self.buttons) do
			v:destroy()
		end
		self.buttons = {}
		for i,v in ipairs(obj.transformations) do
			local b = goo.button(transformationlistpanel)
			b:setPos(0,i*30)
			b:setSize(100,20)
			b:setText(v.transformarg.prop..' Transformation')
			b.onClick = function (button)
				transformationpanel:select(v.transformarg)
			end
		end
	end
	
	-- Time line
	timelinepanel = goo.progressbar()
	timelinepanel:setPos(0,550)
	timelinepanel:setSize(800,20)
	timelinepanel.onChange = function(self)
		local s = editor.getScene()
		s:jumpToFrame(self:getPercentage()/100*s.time)
	end
	
	transformationpanel = goo.panel()
	transformationpanel:setPos(10,10)
	transformationpanel:setSize(200,200)
	transformationpanel:setTitle('Transformation Panel')
	transformationpanel.props = {}
	for i,v in ipairs{'vi','vf','delay','total'} do
		local pg = goo.prop(transformationpanel)
		pg:setPos(0,i*20)
		pg:setProp{
			prop = v,
			vi = 0,
			vf = 10,
		}
		table.insert(transformationpanel.props,pg)
	end
	
	transformationpanel.select = function(self,obj)
		for i,v in ipairs(self.props) do
			v:setObject(obj)
			if v.prop == 'vi' or v.prop == 'vf' then
				v:setProp{
					prop = v.prop,
					vi = props[obj.prop].vi,
					vf = props[obj.prop].vf,
				}
			end
		end
	end
end

return editor