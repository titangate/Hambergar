goo.prop = class('goo prop', goo.object)
function goo.prop:initialize(parent)
	super.initialize(self,parent)
	self.text = goo.text(self)
	self.text:setPos(0,0)
	self.text:setSize(50,20)
	self.text.color = {0,0,0}
	self.bar = goo.progressbar(self)
	self.bar:setPos(50,5)
	self.bar:setSize(100,10)
	self.box = goo.textinput(self)
	self.box:setPos(160,0)
	self.box:setSize(40,20)
end

function goo.prop:setObject(obj)
	assert(obj)
	self.obj = obj
	assert(self.prop)
	self.box:setText(tostring(obj[self.prop]))
end

function goo.prop:setProp(arg)
	self.text:setText(arg.prop)
	self.prop = arg.prop
	self.bar.onChange = function (bar)
		if self.obj then
			self.obj[arg.prop] = self.bar:getPercentage()/100*(arg.vf-arg.vi)+arg.vi
			self.box:setText(tostring(self.obj[self.prop]))
		end
	end
	
	self.box.onChange = function(box,text)
		assert(self.obj)
		local num = tonumber(text)
		if num then
			self.obj[arg.prop] = num
		end
	end
end

return goo.prop