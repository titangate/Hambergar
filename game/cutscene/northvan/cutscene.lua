return function(trig,m)
	m.skip = function()
		PlayMusic'music/berserker.mp3'
		popsystem()
	end
	PlayMusic'music/adagio.mp3'
	local temple = CutsceneObject(50,requireImage'cutscene/northvan/temple.png')
	temple:fit(1024)
	m:addUnit(temple)
	temple.x = 512
	temple.layer = 0
	m.anim:easy(temple,'y',0,100,50)
	
	local riverback = CutsceneObject(50,requireImage'cutscene/northvan/riverback.png')
	riverback:fit(nil,800)
	m:addUnit(riverback)
	riverback.x = 600
	riverback.layer = 3
	m.anim:easy(riverback,'y',600,500,50)
	m.anim:easy(riverback,'opacity',0,255,5)
	
	m:focus(riverback,1,10)
	
	local lilyback = CutsceneObject(50,requireImage'cutscene/northvan/lilyback.png')
	lilyback:fit(nil,400)
	m:addUnit(lilyback)
	lilyback.x = 400
	lilyback.layer = 2
	m.anim:easy(lilyback,'y',300,400,50)
	m:playConversation(LocalizedString"Lily! You're alive!",3.5,LocalizedString"River")
	wait(3.5)
	m:focus(lilyback,1,1)
	m:playConversation(LocalizedString"Hello, Leon. You have fought hard to get here.",4,LocalizedString"Lily")
	wait(4)
	m:focus(riverback,1,1)
	m:playConversation(LocalizedString"Yes... Let's go home now...",4,LocalizedString"River")
	wait(4)
	m:focus(lilyback,1,1)
	m:playConversation(LocalizedString"I am sorry, I can't. There is no place left for us in this world.",5,LocalizedString"Lily")
	wait(5)
	m:focus(riverback,1,1)
	m:playConversation(LocalizedString"What are you talking about? I promised that we'd start anew... After I destroy Compass, we can go home!",6,LocalizedString"River")
	wait(6)
	m:focus(lilyback,1,1)
	m:playConversation(LocalizedString"I see. You have learned little since our last encounter.",5,LocalizedString"Lily")
	wait(5)
	m:focus(riverback,1,1)
	m:playConversation(LocalizedString"What are you talking about??",4,LocalizedString"River")
	wait(4)
	m:focus(lilyback,1,1)
	m:playConversation(LocalizedString"River. I work for Compass. Lily is my codename. I am employed to manipulate you.",6,LocalizedString"Lily")
	wait(6)
	m:focus(riverback,1,1)
	m:playConversation(LocalizedString"WHAT???!!!!",4,LocalizedString"River")
	wait(4)
	m:focus(lilyback,1,1)
	m:playConversation(LocalizedString"You are a hound, River. Even though you are leashed, your sense of justice may well endanger our project.",6,LocalizedString"Lily")
	wait(6)
	
	m:clear()
	local temple = CutsceneObject(50,requireImage'cutscene/northvan/templeside.png')
	temple:fit(1024)
	m:addUnit(temple)
	temple.x = 512
	temple.layer = 2
	m.anim:easy(temple,'y',400,300,50)
	
	local riverfront = CutsceneObject(50,requireImage'cutscene/northvan/riverstand.png')
	riverfront:fit(nil,500)
	m:addUnit(riverfront)
	riverfront.x = 300
	riverfront.layer = 3
	riverfront.y = 300
--	m:focus(riverfront,1,10)
	
	
	local lilyfront = CutsceneObject(50,requireImage'cutscene/northvan/lilyfront.png')
	lilyfront:fit(nil,800)
	m:addUnit(lilyfront)
	lilyfront.x = 600
	lilyfront.layer = 5
	lilyfront.y = 400
	m.anim:easy(lilyfront,'x',600,700,50)
	
	m:focus(lilyfront,1,1)
	m:playConversation(LocalizedString"However, you do have weaknesses. I made you fall in love with me, and your emotions have overpowered your logic and sense.",9,LocalizedString"Lily")
	wait(9)
	m:playConversation(LocalizedString"Just look at what you have accomplished. You destroyed the defences. You have sabotaged triumf.",8,LocalizedString"Lily")
	wait(8)
	m:playConversation(LocalizedString"Now you are here, a long way from what you have sworn to protect. His Grace's army is marching towards the Sanctuary as we speak.",9,LocalizedString"Lily")
	wait(9)
	m:focus(riverfront,1,1)
	m:playConversation(LocalizedString"This. Cannot. BE!!!!",4,LocalizedString"River")
	wait(4)
	m:focus(lilyfront,1,1)
	m:playConversation(LocalizedString"Now, this is your last trial. Kill me, and have the vengeance you have lusted for.",6,LocalizedString"Lily")
	wait(6)
	
	m:playConversation(LocalizedString"NOOOOOOOOOOOO!",4,LocalizedString"River")
	wait(8)
	m:clear()
	local blackout = CutsceneObject(20,requireImage'assets/dot.png')
	blackout:fit(100000)
	blackout.color = {0,0,0}
	blackout.layer = 5
	m:addUnit(blackout)
	TEsound.play'sound/shoot4.wav'
	PauseMusic(true)
	wait(5)
	m:playConversation(LocalizedString"Homage to infinite light.",4,LocalizedString"River")
	wait(6)
	m.anim:easy(blackout,'opacity',255,0,4)
	wait(3)
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
	
	
	local riverback = CutsceneObject(25,requireImage'cutscene/northvan/riverback.png')
	riverback:fit(nil,800)
	m:addUnit(riverback)
	riverback.x = 600
	riverback.layer = 2
	m.anim:easy(riverback,'y',800,700,25)
	
	m:focus(temple)
	
	PlayMusic'music/berserker.mp3'
	wait(3)
	m:focus(myfront,1,1)
	m:playConversation(LocalizedString"Nice to meet you again. I have seen what you've done.",6,LocalizedString"Master Yuen")
	wait(6)
	m:focus(riverback,1,1)
	m:playConversation(LocalizedString"You son of a ... BITCH!",4,LocalizedString"River")
	wait(4)
--	m:focus(myfront,1,1)
--	m:playConversation("Now I have fulfilled my promise. Time to bring you to Hell.",7,"Master Yuen")
--	wait(7)
--	m:focus(riverback,1,1)
	m:playConversation(LocalizedString'YOU WILL PAY!',4,LocalizedString"River")
	wait(6)
	popsystem()
	
	
end