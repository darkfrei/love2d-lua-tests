local rate = 44100
local length = 1/32
local tone = 440 -- Hz
local p = math.floor(rate/tone) -- 128
local h = 0.125
local soundData = love.sound.newSoundData(length*rate, rate, 16, 1)
for i=0, length*rate-1 do soundData:setSample(i, i%p<p/2 and h or -h) end
local source = love.audio.newSource(soundData)
local function beep() source:play() end

return beep