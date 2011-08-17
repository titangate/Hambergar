function PlayTutorial(t,time)
	time = time or 15
	if not TutorialSystem.panel then
		TutorialSystem.panel = goo.itempanel:new()
		TutorialSystem.panel:setSize(200,100)
	end
	if t then
		TutorialSystem.panel:setVisible(true)
	else
		TutorialSystem.panel:setVisible(false)
		return
	end
	TutorialSystem.panel:fillPanel(t)
	TutorialSystem.panel:setPos(60,screen.height-300)
	anim:easy(TutorialSystem.panel,'opacity',0,180,2,'linear')
	TutorialSystem.dt = 0
	TutorialSystem.time = time
end


TutorialSystem = {
	dt = 0,
	time = 15,
}
function TutorialSystem:update(dt)
	if not self.dt then return end
	self.dt = self.dt + dt
--	print (self.dt,self.time)
	if self.dt>self.time then
		self.dt = nil
		anim:easy(self.panel,'opacity',180,0,2,'linear')
	end
end

tutorialtable = {
	movement = {
		title = 'BASIC CONTROL',
		type = 'MOVEMENT',
		attributes = {
			{text = 'Use WSAD to move characters around.'}
		}
	},
	mainweapon = {
		title = 'BASIC CONTROL',
		type = 'MAIN WEAPON',
		attributes = {
			{text = 'Hold down left mouse button to fire continuously.'}
		}
	},
	skill = {
		title = 'BASIC CONTROL',
		type = 'SKILL',
		attributes = {
			{text = [[Hold down F to use Mind Ripfield
			Mind Ripfield is a powerful area damage + stun ability, very useful against small opponents.
			]]}
		}
	},
	openpanel = {
		title = 'CHARACTER PANEL',
		type = 'VIEW',
		attributes = {
			{text = 'Press T to call out ability/character panel. You can view your abilities, items, upgrades.'}
		}
	},
	
	abilitypanel = {
		title = 'ABILITY PANEL',
		type = 'VIEW',
		attributes = {
			{text = 'Hover skill buttons to view its description. Left click to upgrade them. You will need to find Hamber Spirit(s) to upgrade your abilities. Press C for Character Panel.'}
		}
	},
	characterpanel = {
		title = 'CHARACTER PANEL',
		type = 'VIEW',
		attributes = {
			{text = 'Hover item buttons to view its description. Drag to equip/unequip them. Press H for Ability Panel.'}
		}
	},
	bosshans = {
		title = 'HANS THE VOLCANO',
		type = 'BOSS',
		attributes = {
			{text = "You've encountered the first boss in the game. Try to study the boss' moves and figure out how to deal with them."}
		}
	},
	ultimate = {
		title = "DIVIDED WE STAND",
		type = 'ULTIMATE',
		attributes = {
			{text = "You can now use your ultimate. Divided We Stand is a powerful powerup skill and it requires a lot of energy and has a long cooldown. Use it only when you really have to."}
		}
	}
}