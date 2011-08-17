testbackground = {}
--love.graphics.setBackgroundColor(200,200,200,255)
local bg = love.graphics.newFramebuffer(2000,2000)
love.graphics.setRenderTarget(bg)
love.graphics.setLineWidth(3)
for i = 1,50 do
	local n = i*40
	love.graphics.line(n,0,n,2000)
	love.graphics.line(0,n,2000,n)
end
love.graphics.setRenderTarget()
function testbackground:draw()
	love.graphics.draw(bg,-1000,-1000)
end
map = Tibet1:new(2000,2000)
--map.background = testbackground
t = Assassin:new(600,600,32,10)
t.controller = 'player'
t2 = LizardForeguard:new(500,600,'enemy')
t3 = LizardForeguard:new(500,600,'enemy')
map:addUnit(t,t2)
for i = 1,20 do
	local angle = math.pi/10*i
	local b = Box:new(300+100*math.cos(angle),300+100*math.sin(angle))
	b.controller = 'enemy'
	map:addUnit(b)
end

map.camera = FollowerCamera:new(t)
game = {}
melee = Melee:new()
melee.unit = t
function funcr() return t:getHPPercent() end
hpbar = AssassinHPBar:new(funcr,30,30,200)
mpbar = AssassinMPBar:new(function()return t:getMPPercent() end,30,60,200)
buttongroup = AssassinSkillButtonGroup:new(t)

--AIDemo = Sequence:new()
--AIDemo:push(MoveTo:new(100,500))
--AIDemo:push(OrderActiveSkill:new(t2.skills.dash,function()return {normalize(t.x-t2.x,t.y-t2.y)},t2,t2.skills.dash end))
--AIDemo:push(OrderWait:new(5))
--AIDemo:push(OrderChannelSkill:new(t2.skills.mindripfield,function()return {t.x,t.y},t2,t2.skills.mindripfield end))
--AIDemo:push(OrderMoveToClear:new(t2,t,500))
--AIDemo:push(OrderStop:new())
--AIDemo:push(OrderChannelSkill:new(t2.skills.mindripfield,function()return {t.x,t.y},t2,t2.skills.mindripfield end))

map:setBlock(80,80,1)
map:setBlock(80,120,1)
map:setBlock(80,160,1)

function game:update(dt)
	local walk = false
	local x,y = 0,0
	for k,v in pairs(shifts) do
		if love.keyboard.isDown(k) then
			walk = true
			x,y=x+v[1],y+v[2]
		end
	end
	t.direction = {normalize(x,y)}
	t.state = 'move'
	if not walk then
		t.state = 'stop'
	end
	if AIDemo then
		local status = AIDemo:process(dt,t2)
--		if status ~= STATE_ACTIVE then
--			AIDemo:clear()
--		end
	end
end

manager = AssassinPanelManager:new(t)
demosystem = {}
function demosystem:pushed()
	love.mouse.setVisible(false)
	music = love.audio.newSource('music/fight1.mp3','stream')
	music:setLooping(true)
	love.audio.play(music)
end

function demosystem:poped()
	love.mouse.setVisible(true)
end

function demosystem:keypressed(k)
	if k == 'e' then
		pushsystem(TileEditor)
	
	elseif k == 't' then
		manager:start()
		pushsystem(manager)
	end
	if k == 'i' then
		t.invisible = not t.invisible
	end
	buttongroup:keypressed(k)
	if k==' ' then
		AIDemo = Sequence:new()
		AIDemo:push(OrderMoveTowardsRange:new(t,400))
		AIDemo:push(OrderStop:new())
		AIDemo:push(OrderChannelSkill:new(t2.skills.pistol,function()return {normalize(t.x-t2.x,t.y-t2.y)},t2,t2.skills.pistol end))
		AIDemo:push(OrderWaitUntil:new(function()return getdistance(t,t2)>500 or t.invisible end))
		AIDemo:push(OrderStop:new())
		AIDemo.loop = true
	end
	if k=='n' then
		map:birth()
	end
end

function demosystem:keyreleased(k)
	buttongroup:keyreleased(k)
end

function demosystem:mousepressed(x,y,k)
	buttongroup:mousepressed(x,y,k)
end

function demosystem:mousereleased(x,y,k)
	buttongroup:mousereleased(x,y,k)
end

--mainmenubgm = love.audio.newSource('music/mainmenu.mp3','stream')
--love.audio.play(mainmenubgm)
function demosystem:update(dt)
		game:update(dt)
		map:update(dt)
		hpbar:update(dt)
		mpbar:update(dt)
		buttongroup:update(dt)
end

function demosystem:draw()
	map:draw()
	map.camera:revert()
	hpbar:draw()
	mpbar:draw()
	buttongroup:draw()
	local x,y = unpack(GetOrderDirection())
	local px,py = love.mouse.getPosition()
	love.graphics.draw(cursor,px,py,math.atan2(y,x),1,1,16,16)
end
map:addUnit(HealthPotion:new(200,300))
map:addUnit(BigHealthPotion:new(100,300))
map:addUnit(FiveSlash:new(400,600))

pushsystem(MainMenu)
--pushsystem(demosystem)
--pushsystem(Editor)
