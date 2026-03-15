local sampleRate = 44100
local volume = 0.03

-- tempo
local bpm = 360

-- ticks per quarter note
local tpq = 4

-- duration of one tick
local tickDuration = (60 / bpm) / tpq

local currentStep = nil

local playing = true

--[[ 
2^(1/12) = 1,0594630943592952645618252949463
466,16376151808991640720312977637
493,8833012561241118307545418588
523,25113060119726935569998704655
554,36526195374419249757266720233
587,32953583481512052556602772104
622,25396744416182147274303865212
659,25511382573985947168352209293
698,4564628660077688907504812796
739,98884542326879786739041908497
--]]

-- note frequencies
local notes = {
	C = 261.63, -- do
	D = 293.66, -- re
	E = 329.63, -- mi -------------------
	F = 349.23, -- fa
	Fs= 369.99, -- fa#
	G = 392.00, -- sol ------------------
	A = 440.00, -- la
	B = 493.8833, -- si -------------------
	C2 = 523.2511, -- do
	Cs= 554.37, -- do# (C#5)
	D2 = 587.33, --re -------------------
	E2 = 659.25, -- mi 
	F2 = 698.46, -- la ------------------
	Fs2=739.99, -- fa#2
	G2 = 783.99, -- sol
	A2= 880.00, -- la2
}

-- pause helpers
local function pause(ticks)
	return {note=nil, dur=ticks}
end

local gap00 = pause(0.5)
local gap1 = pause(1)
local gap2 = pause(2)
local gap3 = pause(3)
local gap4 = pause(4)

local melody = {
  -- autor: darfrei, song "Early Morning"

	{note="A",  dur=2}, gap1,
	{note="A",  dur=2}, gap2,
	{note="Fs", dur=2}, gap1,
	{note="Fs", dur=2}, gap2,

	{note="G",  dur=2}, gap1,
	{note="G",  dur=2}, gap2,
	{note="E",  dur=2}, gap1,
	{note="E",  dur=3}, gap4,

---------------------------

	{note="A",  dur=2}, gap1,
	{note="A",  dur=2}, gap2,
	{note="Fs", dur=2}, gap1,
	{note="Fs", dur=2}, gap2,

	{note="G",  dur=2}, gap1,
	{note="G",  dur=2}, gap2,
	{note="E",  dur=2}, gap1,
	{note="E",  dur=3}, gap3,
	
---------------------------
	
	{note="D",  dur=2}, gap1,
	{note="D",  dur=2}, gap2,
	{note="G",  dur=2}, gap1,
	{note="G",  dur=3}, gap2,

	{note="E",  dur=2}, gap1,
	{note="E",  dur=2}, gap2,
	{note="A",  dur=2}, gap1,
	{note="A",  dur=2}, gap3,

---------------------------

	{note="C2",  dur=2}, gap1,
	{note="C2",  dur=2}, gap2,
	{note="Fs",  dur=2}, gap1,
	{note="Fs",  dur=2}, gap2,

	{note="A",  dur=2}, gap1,
	{note="A",  dur=2}, gap2,
	{note="D",  dur=2}, gap1,
	{note="D",  dur=3}, gap4,

--	pause(0.5),
}

local currentNote = 1
local timer = 0

-- generate silence
local function generateSilence(duration)
	local samples = duration * sampleRate
	local soundData = love.sound.newSoundData(samples, sampleRate, 16, 1)
	for i = 0, samples - 1 do
		soundData:setSample(i, 0)
	end
	return love.audio.newSource(soundData)
end


local function squareProfile (soundData, samples, freq)
	for i = 0, samples - 1 do
		local t = i / sampleRate
		local wave = math.sin(2 * math.pi * freq * t)
		local square
		if wave > 0 then
			square = volume
		else
			square = -volume
		end
		soundData:setSample(i, square)
	end

end

local function triangleProfile(soundData, samples, freq)
	for i = 0, samples - 1 do
		local t = i / sampleRate
		local phase = (t * freq) % 1.0
		local tri = (1 - 4 * math.abs(phase-0.1667)) * volume
		soundData:setSample(i, tri)
	end
end


-- generate square wave
local function generateWave(freq, duration)
	local samples = duration * sampleRate
	local soundData = love.sound.newSoundData(samples, sampleRate, 16, 1)
--	squareProfile (soundData, samples, freq)
	triangleProfile(soundData, samples, freq)

	return love.audio.newSource(soundData)
end

-- play step
local function playNote(step)

	currentStep = step

	local duration = step.dur * tickDuration

	if step.note == nil then
		local s = generateSilence(duration)
		s:play()
	else
		local freq = notes[step.note]
		if not freq then

			error (step.note)
		end
		local s = generateWave(freq, duration)
		s:play()
	end

end

function love.load()

	playNote(melody[currentNote])

end

function love.update(dt)
	if not playing then
		return
	end

	timer = timer + dt

	local step = melody[currentNote]
	local duration = step.dur * tickDuration

	if timer >= duration then

		timer = 0

		currentNote = currentNote + 1

		if currentNote > #melody then
			currentNote = 1
		end

		playNote(melody[currentNote])

	end

end

function love.draw()
	local y = 20
	love.graphics.print("chiptune player", 20, y)
	y = y + 20
	love.graphics.print("step: "..currentNote.." / "..#melody, 20, y)
	y = y + 20
	if currentStep then
		local noteName = "pause"
		local freq = 0
		if currentStep.note then
			noteName = currentStep.note
			freq = notes[currentStep.note]
		end
		local ticks = currentStep.dur
		local seconds = ticks * tickDuration
		love.graphics.print("note: "..noteName, 20, y)
		y = y + 20
		love.graphics.print("frequency: "..freq.." hz", 20, y)
		y = y + 20
		love.graphics.print("duration ticks: "..ticks, 20, y)
		y = y + 20
		love.graphics.print("duration sec: "..string.format("%.3f", seconds), 20, y)
		y = y + 20
	end
end


function love.keypressed(key)
	if key == "space" then
		playing = not playing
		if not playing then
			timer = 0
			local s = generateSilence(tickDuration)
			s:play()
		else
			playNote(melody[currentNote])
		end
	end
end