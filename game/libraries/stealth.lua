StealthAI = Object:subclass'StealthAI'
function StealthAI:initialize(unit,target)
	self.unit = unit
	self.target = target
	self.spotvalue = 0
end

function StealthAI:fireDetector()
end