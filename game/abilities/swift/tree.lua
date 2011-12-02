
local files = love.filesystem.enumerate('assets/swift/icon')
for i,v in ipairs(files) do
	if love.filesystem.isFile('assets/swift/icon/'..v) then
		local f = v:gmatch("(%w+).(%w+)")
		local file,ext=f()
		if ext=='png' then
			requireImage('assets/swift/icon/'..v,file,icontable)
		end
	end
end
SwiftAbiTree = Object:subclass('SwiftAbiTree')
function SwiftAbiTree:initialize(unit)
	assert(unit)
	self.unit = unit
end
