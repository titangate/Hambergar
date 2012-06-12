SolarStormEffect = CircleAoEEffect:new(100)

SolarStormEffect:addAction(function (area,caster,skill)
	if caster:getMP()<skill.manacost then return end
	local units = map:findUnitsInArea(area)
	for k,v in pairs(units) do
		if v:isKindOf(Unit) and not v:isKindOf(SolarStormUnit) then
			v:damage('Electric',caster:getDamageDealing(skill.damage,'Electric'),caster)
		end
	end
end)

SolarStorm = Skill:subclass('SolarStorm')

function SolarStorm:initialize(unit,level)
	level = level or 0
	super.initialize(self)
	self.unit = unit
	self.name = 'SolarStorm'
	self.effecttime = 0.05
	self.casttime = 1
	self.cd = 120
	self.cdtime = 0
	self.effect = SolarStormEffect
	self:setLevel(level)
	self.manacost = 30
	self.damage = 150
end

function SolarStorm:stop()
	self.time = 0
end

function SolarStorm:setLevel(lvl)
	self.level = lvl
end


function SolarStorm:cdupdate(dt)
	if self.available then return end
	self.cdtime = self.cdtime - dt
	if self.cdtime <= 0  then
		self.available = true
	end
end

function SolarStorm:getRemainingCD()
	local groupname = self.groupname or self:className()
	return self.unit:getCD(groupname)
end

function SolarStorm:getCDPercent()
	local groupname = self.groupname or self:className()
	local cddt = self.unit:getCD(groupname) or 0
	return cddt/self.cd
end

function SolarStorm:isCD()
	local groupname = self.groupname or self:className()
	return self.unit:getCD(groupname) or not(self.unit.allowactive)
end

function SolarStorm:startChannel()
	if self:isCD() then
		return false,'Ability Cooldown'
	end
	if self.unit.mp < self.manacost then return end
	self.unit:startCD(self:className(),self.cd)
	local x,y = unpack(GetOrderPoint())
--	Blureffect.blur('zoom',{},0,2.3)
	super.startChannel(self)
	self.sunit = SolarStormUnit:new(x,y)
	map:addUnit(self.sunit)
	
	Blureffect.blur('zoom',self.sunit,0,10)
	local dws = CutSceneSequence:new()
	map.timescale = 0.25
	local panel2 = goo.object:new()
	local divide = goo.image:new(panel2)
	divide:setPos(screen.width-200,screen.halfheight)
	divide:setImage(icontable.solarstorm)
	local panel1 = goo.object:new()
	anim:easy(panel1,'x',-300,0,1,'quadInOut')
	anim:easy(panel2,'x',300,0,1,'quadInOut')
	local text = 'SOLAR STORM'
	local x,y = 100,screen.halfheight-50
	for c in text:gmatch"." do
		dws:push(ExecFunction:new(function()
			local ib = goo.DWSText:new(panel1)
			ib:setText(c)
			ib:setPos(x,y)
			local textscale = 2
			x = x+ib.w*textscale
			local animsx = anim:new({
				table = ib,
				key = 'xscale',
				start = 5*textscale,
				finish = 2*textscale,
				time = 0.3,
				style = anim.style.linear}
			)
			local animsy = anim:new({
				table = ib,
				key = 'yscale',
				start = 5*textscale,
				finish = 2*textscale,
				time = 0.3,
				style = anim.style.linear}
			)
			local animg = anim.group:new(animsx,animsy)
			animg:play()
			local animwx = anim:new({
				table = ib,
				key = 'xscale',
				start = 2*textscale,
				finish = 1*textscale,
				time = 0.5,
				style = 'elastic'
			})
			local animwy = anim:new({
				table = ib,
				key = 'yscale',
				start = 2*textscale,
				finish = 1*textscale,
				time = 0.5,
				style = 'elastic'
			})
			local animw = anim.group:new(animwx,animwy)
			local animc = anim.chain:new(animg,animw)
			animc:play()
			TEsound.play('sound/thunderclap.wav')
		end),0)
		
		dws:wait(0.2)
	end	
		dws:wait(0.5)
	dws:push(ExecFunction:new(function()
	anim:easy(panel1,'x',0,screen.width,2,'quadInOut')
	anim:easy(panel2,'x',0,-screen.width,2,'quadInOut')
	map.timescale = 1
	end),0)
	dws:push(ExecFunction:new(function()
	panel1:destroy()
	panel2:destroy()
	end),2)
	map:playCutscene(dws)
	map:addUpdatable(impact)
end

function SolarStorm:endChannel()
	if self.sunit then
		self.sunit.hp = 1
	end
	Blureffect.stop()
end

function SolarStorm:geteffectinfo()
	return {self.sunit.x,self.sunit.y},self.unit,self
end

function AI.SolarStorm(target)
	local seq = Sequence()
	seq:push(OrderMoveTowardsRange(target,50))
	seq:push(OrderWait(0.1))
	seq.loop = true
	return seq
end

requireImage('assets/electrician/solarstorm.png','solarstorm')
--requireImage('assets/electrician/solarstormbolt.png','solarstormbolt')
SolarStormUnit = Unit:subclass('SolarStormUnit')
function SolarStormUnit:initialize(x,y)
	super.initialize(self,x,y,16,10)
	self.HPRegen = -2
	self.maxhp = 20
	self.hp = 20
end

function SolarStormUnit:createBody(...)
	super.createBody(self,...)
	self.shape:setMask(1,2,3,4,5,6,7,9,10,11,12,13,14,15,16) -- except terrain
	self.impact = LightningImpact(self,12,0.5,0.05,100,{0,0,0},0.4)
	map:addUpdatable(self.impact)
	-- Mouse
	self.mousetarget = { update = function()
			local x,y = unpack(GetOrderPoint())
			self.mousetarget.x=x
			self.mousetarget.y=y
		end
	}
	self.mousetarget.update()
	self.ai = AI.SolarStorm(self.mousetarget)
end

function SolarStormUnit:update(dt)
	super.update(self,dt)
	self.mousetarget.update()
	if self.hp <= 0 then
		self:kill(self)
	end
end

function SolarStormUnit:kill(...)
	super.kill(self,...)
	self.impact.life = 1
end

function SolarStormUnit:draw()
	local alpha = math.clamp(self.hp*255,0,255)
	love.graphics.setColor(255,255,255,alpha)
	local r = self.hp - math.floor(self.hp)
	local r2 = self.hp/3
	r2 = r2- math.floor(r2)
	r = r*math.pi*2
		local x,y = self.x,self.y
	for i=1,3 do
		for j=1,4 do
			love.graphics.draw(img.solarstorm,x,y,r+j*math.pi*0.5+i*math.pi*0.33,i*0.3+0.4) -- forming a span
		end
		love.graphics.draw(beamimage[i],x,y,r2*math.pi*2+i*math.pi*2/3,2)
	end
	love.graphics.setColor(255,255,255)
end
