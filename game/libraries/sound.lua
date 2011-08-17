music_playing = nil
local music_name = nil

function PlayMusic(string)
	if music_name == string then
		return
	end
	music_name = string
	if music_playing then love.audio.stop(music_playing) end
	music_playing = love.audio.newSource(string)
	music_playing:setLooping(true)
	love.audio.play(music_playing)
end

function PauseMusic(state)
	if state then
		music_playing:pause()
	else
		music_playing:resume()
	end
end

environment_playing = nil
local environment_name = nil

function PlayEnvironmentSound(string)
	if environment_name == string then
		return
	end
	environment_name = string
	if musci_playing then love.audio.stop(environment_playing) end
	environment_playing = love.audio.newSource(string)
	environment_playing:setLooping(true)
	love.audio.play(environment_playing)
end

sfx = {}
maxsfx_count = 5
function PlaySFX(sound)
	if not sfx[sound] then
		sfx[sound] = {}
	end
end