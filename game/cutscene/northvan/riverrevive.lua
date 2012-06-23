return function(trig,m)
	function m.skip()
		popsystem()
		map:phase6()
		PlayMusic'music/riverrise.mp3'
	end
	PlayMusic'music/adagio.mp3'
	local temple = CutsceneObject(25,requireImage'cutscene/northvan/temple.png')
	temple:fit(1024)
	m:addUnit(temple)
	temple.x = 512
	temple.layer = 0
	m.anim:easy(temple,'y',0,100,25)
	
	
	local myfront = CutsceneObject(25,requireImage'cutscene/northvan/myfront.png')
	myfront:fit(nil,400)
	m:addUnit(myfront)
	myfront.x = 400
	myfront.layer = 1
	m.anim:easy(myfront,'y',100,200,25)
	
	
	local riverlay = CutsceneObject(25,requireImage'cutscene/northvan/riverlay.png')
	riverlay:fit(nil,800)
	m:addUnit(riverlay)
	riverlay.x = 600
	riverlay.layer = 2
	m.anim:easy(riverlay,'y',800,700,25)
	
	m:focus(myfront)
	
	wait(3)
	m:focus(riverlay,1,10)
	m:playConversation(LocalizedString"The cycle is complete.",3.5,LocalizedString"Master Yuen")
	wait(4)
	m.anim:easy(temple,'opacity',255,0,5)
	m.anim:easy(myfront,'opacity',255,0,5)
	wait(6)
	m.anim:easy(riverlay,'opacity',255,0,5)
	local riverback = CutsceneObject(24,requireImage'cutscene/northvan/riverback.png')
	riverback:fit(nil,800)
	m:addUnit(riverback)
	riverback.x = 600
	riverback.layer = 3
	m.anim:easy(riverback,'y',600,500,25)
	m.anim:easy(riverback,'opacity',0,255,5)
	m:focus(riverback,1,10)
	
	m:playConversation(LocalizedString"Where am I...",3.5,LocalizedString"River")
	wait(10)
	
	local lilyback = CutsceneObject(14,requireImage'cutscene/northvan/lilyback.png')
	lilyback:fit(nil,400)
	m:addUnit(lilyback)
	lilyback.x = 400
	lilyback.layer = 0
	m.anim:easy(lilyback,'opacity',0,255,5)
	
	m.anim:easy(lilyback,'y',400,500,25)
	m:playConversation(LocalizedString"Is that you again.. Lily?",4,LocalizedString"River")
	wait(4)
	m:playConversation(LocalizedString"Are you really going to give up now?",4.5,LocalizedString"Lily")
	wait(4)
	m:playConversation(LocalizedString"Haha... This must be a bad joke. I am pretty sure I'm dead... Otherwise, how can I see you?",6,LocalizedString"River")
	wait(6)
	local riverfront = CutsceneObject(50,requireImage'cutscene/northvan/riverstand.png')
	riverfront:fit(nil,500)
	m:addUnit(riverfront)
	riverfront.x = 300
	riverfront.layer = 3
	riverfront.y = 300
	m:focus(riverfront,1,10)
	
	
	local lilyfront = CutsceneObject(17,requireImage'cutscene/northvan/lilyfront.png')
	lilyfront:fit(nil,800)
	m:addUnit(lilyfront)
	lilyfront.x = 600
	lilyfront.layer = 5
	lilyfront.y = 400
	m.anim:easy(lilyfront,'x',600,700,20)
	m:playConversation(LocalizedString"The gracious gods have offered you the chance to relive a part of your life. Now, what is your choice?",6,LocalizedString"Lily")
	wait(7)
	m:playConversation(LocalizedString"You know what I am going to do.",4,LocalizedString"River")
	wait(4)
	m:playConversation(LocalizedString"Then, perhaps, your time has yet to come.",4,LocalizedString"Lily")
	wait(5)
	local temple = CutsceneObject(50,requireImage'cutscene/northvan/templeside.png')
	temple:fit(1024)
	m:addUnit(temple)
	temple.x = 512
	temple.layer = 0
	m.anim:easy(temple,'y',400,300,25)
	m.anim:easy(temple,'opacity',0,255,1)
	m.anim:easy(lilyfront,'opacity',255,0,1)
	TEsound.play'sound/shout2.mp3'
	local my1 = CutsceneObject(1.5,requireImage'cutscene/northvan/my1.png')
	my1:fit(nil,400)
	m:addUnit(my1)
	my1.layer = 3
	m.anim:easy(my1,'opacity',0,255,1)
	m.anim:easy(my1,'x',800,600,1.5)
	my1.y = 300
	wait(1.5)
	
	
	PlayMusic'music/riverrise.mp3'
	local my2 = CutsceneObject(10,requireImage'cutscene/northvan/my2.png')
	my2:fit(nil,400)
	m:addUnit(my2)
	my2.layer = 3
	my2.x = 600
	my2.y = 300
	for i=1,70 do
		local bullet = CutsceneObject(0.5,requireImage'assets/assassin/bullet.png')
		m.anim:easy(bullet,'x',0,my2.x,0.5)
		bullet.y = math.random(100,500)
		bullet.layer = 3
		bullet.color = {0,0,0}
		m:addUnit(bullet)
		wait(0.05)
		if math.random()>0.5 then
			m.anim:easy(my2,'x',my2.x,my2.x + 50,0.1)
		end
		if i%3== 0 then
			
			TEsound.play'sound/machine1.wav'
		end
		if i== 30 then
			
			TEsound.play'sound/groan.mp3'
		end
	end
	
	wait(2)
	riverfront.x = 512
	riverfront.y = 300
	riverfront:fit(nil,400)
	temple.layer = 1
	temple.img = requireImage'cutscene/northvan/temple.png'
	local gate = CutsceneObject(30,requireImage'assets/assassin/gate.png')
	gate:fit(nil,600)
	m:addUnit(gate)
	gate.layer = 2
	m.anim:easy(gate,'r',0,15,30)
	gate.y = 300
	gate.x = 512
--	wait(1.5)
	m.anim:easy(temple,'y',0,100,20)
	m.anim:easy(riverfront,'y',200,250,20)
	m.anim:easy(gate,'y',150,200,20)
	wait(3)
	
	m:playConversation(LocalizedString"THERE IS NO WAY!!!!",3.5,LocalizedString"Master Yuen")
	wait(3.5)
	m:playConversation(LocalizedString"YOU... YOU ARE THE KING OF DRAGONS, THE SERVENT OF GOD HIMSELF!!!!",5,LocalizedString"Master Yuen")
	wait(5)
	m:playConversation(LocalizedString"By the will of Amitabah, I condemn you to death.",5,LocalizedString"River")
	wait(10)
	m.skip()
	
	
end