
StationKeycard = Item:subclass('StationKeycard')
requireImage( 'assets/item/keycard.png','keycard' )

function StationKeycard:initialize(x,y)
	super.initialize(self,'misc',x,y)
	self.name = "KEYCARD"
	self.stack = 1
	self.maxstack = 1
end

function StationKeycard:getPanelData()
	return {
		title = self.name,
		type = self.type,
		attributes = {
			{text="It says on the back:reh dnif reven lluoy. I don't think I know what it means."},
		}
	}
end
function StationKeycard:update(dt)
end

function StationKeycard:draw(x,y)
	if not x then x,y = self.body:getPosition() end
	love.graphics.draw(img.keycard,x,y,0,1,1,24,24)
end