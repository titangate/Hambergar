ShaderEffect = Object:subclass'ShaderEffect'

function ShaderEffect:initialize()
end

function ShaderEffect:update(dt)
end

function ShaderEffect:predraw()
end

function ShaderEffect:postdraw()
end

function ShaderEffect:drawfunc(f)
	self:predraw()
	f()
	self:postdraw()
end