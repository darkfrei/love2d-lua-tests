-- beep

local rate      = 44100 -- samples per second
local length    = 1/32  -- 0.03125 seconds
local tone      = 880.0 -- Hz
local p         = math.floor(rate/tone) -- 100 (wave length in samples)
local soundData = love.sound.newSoundData(math.floor(length*rate), rate, 16, 1)
for i=0, soundData:getSampleCount() - 1 do
--	soundData:setSample(i, math.sin(2*math.pi*i/p)) -- sine wave.

	-- square wave; the first half of the wave is 1, the second half is -1.
	soundData:setSample(i, i%p<p/2 and 1 or -1)     
end
local source = love.audio.newSource(soundData)

local function beep() source:play() end


return beep