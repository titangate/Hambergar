ActiveWidget = Widget:subclass('ActiveWidget')

function ActiveWidget:hover()
	self.hovering = true
	self:focus()
end

function ActiveWidget:unhover()
	self.hovering = false
	self:unfocus()
end

function ActiveWidget:focus()
end

function ActiveWidget:unfocus()
end

function ActiveWidget:interact(b)
end
